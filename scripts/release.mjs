#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  utimesSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const PROJECT = "BIRD.nvim";
const RUNTIME_ENTRIES = [
  "CHANGELOG.md",
  "LICENSE",
  "README.md",
  "README.zh-CN.md",
  "doc",
  "ftplugin",
  "lua",
  "plugin",
  "syntax",
];
const REQUIRED_FILES = [
  "LICENSE",
  "README.md",
  "doc/bird2.txt",
  "doc/tags",
  "ftplugin/bird2.lua",
  "lua/bird2/config.lua",
  "lua/bird2/health.lua",
  "lua/bird2/init.lua",
  "plugin/bird2.lua",
  "syntax/bird2.vim",
];
const FORBIDDEN_ENTRIES = [
  ".git",
  ".github",
  ".changeset",
  ".gitmodules",
  "dist",
  "shared",
  "tests",
];

function fail(message) {
  throw new Error(message);
}

function run(command, args, options = {}) {
  return execFileSync(command, args, {
    encoding: "utf8",
    stdio: options.capture ? "pipe" : "inherit",
    ...options,
  });
}

function parseTag(tag) {
  const match = /^v(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)$/.exec(tag);
  if (!match) fail(`release tag must use standard SemVer form vX.Y.Z: ${tag}`);
  return { tag, version: match[1], prerelease: match[1].includes("-") };
}

function runtimeVersion(root = ROOT) {
  const lua = readFileSync(join(root, "lua", "bird2", "init.lua"), "utf8");
  const luaMatch = /^M\.version\s*=\s*"(\d+\.\d+\.\d+)"\s*$/m.exec(lua);
  if (!luaMatch) fail("lua/bird2/init.lua does not contain M.version");

  const syntax = readFileSync(join(root, "syntax", "bird2.vim"), "utf8");
  const syntaxMatch = /^" Version:\s+(\d+\.\d+\.\d+)(?:-[0-9]{8})?\s*$/m.exec(syntax);
  if (!syntaxMatch) fail("syntax/bird2.vim does not contain a supported Version line");
  if (luaMatch[1] !== syntaxMatch[1]) {
    fail(`Lua version ${luaMatch[1]} does not match syntax version ${syntaxMatch[1]}`);
  }
  return luaMatch[1];
}

function validateTag(tag, root = ROOT) {
  const metadata = parseTag(tag);
  const current = runtimeVersion(root);
  if (metadata.version !== current) {
    fail(`tag ${tag} does not match runtime version ${current}`);
  }
  return metadata;
}

function walkFiles(root, current = root) {
  const files = [];
  for (const entry of readdirSync(current, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const absolute = join(current, entry.name);
    if (entry.isSymbolicLink()) fail(`release package must not contain symlinks: ${relative(root, absolute)}`);
    if (entry.isDirectory()) files.push(...walkFiles(root, absolute));
    else if (entry.isFile()) files.push(relative(root, absolute));
    else fail(`unsupported release entry: ${relative(root, absolute)}`);
  }
  return files.sort();
}

function normalizeTimes(root, epochSeconds) {
  const date = new Date(epochSeconds * 1000);
  for (const file of walkFiles(root)) utimesSync(join(root, file), date, date);
  for (const entry of readdirSync(root, { withFileTypes: true })) {
    if (entry.isDirectory()) normalizeTimes(join(root, entry.name), epochSeconds);
  }
  utimesSync(root, date, date);
}

function sha256(file) {
  return createHash("sha256").update(readFileSync(file)).digest("hex");
}

function generateHelpTags(stage) {
  const editor = process.env.NVIM || "nvim";
  run(editor, [
    "--headless",
    "-u",
    "NONE",
    "-c",
    `execute 'helptags ' . fnameescape('${join(stage, "doc").replaceAll("'", "''")}')`,
    "-c",
    "qa!",
  ]);
}

function packageRelease(tag, outputArgument = "dist") {
  const metadata = validateTag(tag);
  const output = resolve(ROOT, outputArgument);
  const stage = mkdtempSync(join(tmpdir(), "bird-nvim-release-"));
  mkdirSync(output, { recursive: true });

  try {
    for (const entry of RUNTIME_ENTRIES) {
      const source = join(ROOT, entry);
      if (!existsSync(source)) fail(`required release entry is missing: ${entry}`);
      cpSync(source, join(stage, entry), { recursive: true });
    }

    generateHelpTags(stage);
    const files = walkFiles(stage);
    for (const required of REQUIRED_FILES) {
      if (!files.includes(required)) fail(`release package is missing ${required}`);
    }

    const epoch = Number(run("git", ["show", "-s", "--format=%ct", "HEAD"], {
      cwd: ROOT,
      capture: true,
    }).trim());
    if (!Number.isSafeInteger(epoch)) fail("cannot determine release timestamp");
    normalizeTimes(stage, epoch);

    const base = `${PROJECT}-${tag}`;
    const zipPath = join(output, `${base}.zip`);
    const tarPath = join(output, `${base}.tar`);
    const tarGzPath = `${tarPath}.gz`;
    rmSync(zipPath, { force: true });
    rmSync(tarGzPath, { force: true });

    run("zip", ["-X", "-q", zipPath, ...files], { cwd: stage });
    const tarVersion = run("tar", ["--version"], { capture: true });
    const deterministicArgs = tarVersion.includes("GNU tar")
      ? [
          "--sort=name",
          `--mtime=@${epoch}`,
          "--owner=0",
          "--group=0",
          "--numeric-owner",
          "-cf",
          tarPath,
          "-C",
          stage,
          ".",
        ]
      : ["-cf", tarPath, "-C", stage, "."];
    run("tar", deterministicArgs);
    run("gzip", ["-n", "-f", tarPath]);

    const checksumPath = join(output, "SHA256SUMS");
    const checksumLines = [zipPath, tarGzPath]
      .map((file) => `${sha256(file)}  ${file.slice(output.length + 1)}`)
      .join("\n");
    writeFileSync(checksumPath, `${checksumLines}\n`);

    process.stdout.write(`${JSON.stringify({ ...metadata, output, files: [zipPath, tarGzPath, checksumPath] }, null, 2)}\n`);
  } finally {
    rmSync(stage, { recursive: true, force: true });
  }
}

function compareTrees(left, right) {
  const leftFiles = walkFiles(left);
  const rightFiles = walkFiles(right);
  if (JSON.stringify(leftFiles) !== JSON.stringify(rightFiles)) {
    fail("ZIP and tar.gz package contents differ");
  }
  for (const file of leftFiles) {
    if (sha256(join(left, file)) !== sha256(join(right, file))) {
      fail(`ZIP and tar.gz package bytes differ: ${file}`);
    }
  }
  return leftFiles;
}

function smokeTest(root, version, fixture) {
  const init = join(dirname(fixture), "verify.lua");
  writeFileSync(
    init,
    [
      "local root = assert(os.getenv('BIRD_RELEASE_ROOT'))",
      "local fixture = assert(os.getenv('BIRD_RELEASE_FIXTURE'))",
      "vim.opt.runtimepath:prepend(root)",
      "vim.cmd('filetype plugin on')",
      "vim.cmd('syntax enable')",
      "vim.cmd('runtime plugin/bird2.lua')",
      "local bird2 = require('bird2')",
      "bird2.setup()",
      "vim.cmd.edit(vim.fn.fnameescape(fixture))",
      "assert(vim.bo.filetype == 'bird2', vim.bo.filetype)",
      "assert(vim.bo.syntax == 'bird2', vim.bo.syntax)",
      "assert(vim.bo.commentstring == '# %s', vim.bo.commentstring)",
      `assert(bird2.version == '${version}', bird2.version)`,
      "vim.cmd('qa!')",
      "",
    ].join("\n"),
  );
  run(process.env.NVIM || "nvim", ["--headless", "-u", init], {
    env: {
      ...process.env,
      BIRD_RELEASE_ROOT: root,
      BIRD_RELEASE_FIXTURE: fixture,
    },
  });
}

function verifyRelease(tag, outputArgument = "dist") {
  const metadata = validateTag(tag);
  const output = resolve(ROOT, outputArgument);
  const base = `${PROJECT}-${tag}`;
  const zipPath = join(output, `${base}.zip`);
  const tarGzPath = join(output, `${base}.tar.gz`);
  const checksumPath = join(output, "SHA256SUMS");
  for (const file of [zipPath, tarGzPath, checksumPath]) {
    if (!existsSync(file)) fail(`release asset is missing: ${file}`);
  }

  const checksumText = readFileSync(checksumPath, "utf8");
  for (const file of [zipPath, tarGzPath]) {
    const name = file.slice(output.length + 1);
    if (!checksumText.includes(`${sha256(file)}  ${name}`)) fail(`checksum mismatch: ${name}`);
  }

  const temporary = mkdtempSync(join(tmpdir(), "bird-nvim-verify-"));
  const zipRoot = join(temporary, "zip");
  const tarRoot = join(temporary, "tar");
  mkdirSync(zipRoot);
  mkdirSync(tarRoot);

  try {
    run("unzip", ["-q", zipPath, "-d", zipRoot]);
    run("tar", ["-xzf", tarGzPath, "-C", tarRoot]);
    const files = compareTrees(zipRoot, tarRoot);
    for (const required of REQUIRED_FILES) {
      if (!files.includes(required)) fail(`verified package is missing ${required}`);
    }
    for (const forbidden of FORBIDDEN_ENTRIES) {
      if (existsSync(join(zipRoot, forbidden))) fail(`verified package contains ${forbidden}`);
    }

    const fixture = join(temporary, "bird.conf");
    writeFileSync(fixture, "router id 192.0.2.1;\nprotocol device {}\n");
    smokeTest(zipRoot, metadata.version, fixture);
    process.stdout.write(`Verified ${base}: ${files.length} files\n`);
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

function writeReleaseNotes(tag, outputArgument = "release-notes.md") {
  const metadata = validateTag(tag);
  const notes = run(process.execPath, [
    join(ROOT, "scripts", "changeset.mjs"),
    "notes",
    metadata.version,
  ], { cwd: ROOT, capture: true }).trim();
  const installation = [
    "## Installation",
    "",
    "Using lazy.nvim:",
    "",
    "```lua",
    "{",
    '  "bird-chinese-community/BIRD.nvim",',
    `  version = "${tag}",`,
    "  lazy = false,",
    "  config = function()",
    '    require("bird2").setup()',
    "  end,",
    "}",
    "```",
    "",
    "The attached ZIP and tar.gz archives contain a standalone Neovim runtime",
    "without development submodules. Verify downloads with `SHA256SUMS`.",
    "",
  ].join("\n");
  writeFileSync(resolve(ROOT, outputArgument), `${notes}\n\n${installation}`);
}

function writeOutputs(metadata) {
  const output = process.env.GITHUB_OUTPUT;
  if (!output) fail("GITHUB_OUTPUT is required for gha-outputs");
  const lines = [
    `tag=${metadata.tag}`,
    `version=${metadata.version}`,
    `prerelease=${metadata.prerelease}`,
  ];
  writeFileSync(output, `${lines.join("\n")}\n`, { flag: "a" });
}

function main() {
  const [command, tag, argument] = process.argv.slice(2);
  if (!command) fail("usage: release.mjs <current-tag|check|notes|package|verify|gha-outputs> [vX.Y.Z] [path]");
  if (command === "current-tag") {
    process.stdout.write(`v${runtimeVersion()}\n`);
    return;
  }
  if (!tag) fail(`${command} requires a vX.Y.Z tag`);
  if (command === "check") process.stdout.write(`${JSON.stringify(validateTag(tag), null, 2)}\n`);
  else if (command === "notes") writeReleaseNotes(tag, argument);
  else if (command === "package") packageRelease(tag, argument);
  else if (command === "verify") verifyRelease(tag, argument);
  else if (command === "gha-outputs") writeOutputs(validateTag(tag));
  else fail(`unknown command: ${command}`);
}

try {
  main();
} catch (error) {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
}
