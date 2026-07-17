# Change fragments

This repository uses a small, dependency-free change-fragment workflow inspired
by the Changesets setup in BIRD-LSP. It keeps release notes reviewable in pull
requests without introducing an npm package solely for release tooling.

## Add a fragment

Create a kebab-case fragment name and select its semantic-version bump and
category:

```sh
node scripts/changeset.mjs new bright-birds patch fixed
```

Edit the generated file and replace both placeholder paragraphs. Release notes
use the BIRD-LSP style: a bilingual title, followed by a Simplified Chinese
paragraph and an English paragraph.

```md
---
bump: patch
category: fixed
---

- 🐛 **中文标题** / **English title**

  中文说明。

  English summary.
```

Supported bumps are `patch`, `minor`, and `major`. Supported categories are
listed in `config.json`. Add a fragment for any user-visible or release-worthy
change; purely internal test or CI maintenance may omit one.

## Check pending changes

```sh
node scripts/changeset.mjs check
node scripts/changeset.mjs status
```

CI runs `check` automatically. It validates the emoji, bilingual title,
two-space paragraph indentation, and Chinese/English paragraph order. `status`
lists pending fragments and reports the highest requested bump.

To preview the notes for a version that is already in the changelog:

```sh
node scripts/changeset.mjs notes 1.0.13
```

Use inline Markdown links in fragments so extracted GitHub Release notes remain
self-contained.

## Prepare a release

1. Inspect the pending fragments with `status`.
2. Choose the next plugin version, update `lua/bird2/init.lua` and relevant
   vimdoc references, and synchronize the BIRD.vim syntax snapshot when needed.
3. Preview the generated changelog section:

   ```sh
   node scripts/changeset.mjs release 1.0.14 \
     --date 2026-07-18 --dry-run
   ```

4. Run the same command without `--dry-run`. It inserts the new bilingual
   section in `CHANGELOG.md` and deletes the consumed fragments.
5. Review and commit the release diff, then create the matching standard SemVer
   tag (`v1.0.14`, for example). The Release workflow validates the tag against
   both the Lua module version and bundled syntax version before publishing.

The command intentionally does not modify Lua/Vim runtime files or create tags.
Those remain explicit release-review steps.
