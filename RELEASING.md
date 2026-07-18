# Release process / 发布流程

This repository publishes standard SemVer tags (`vX.Y.Z`) and standalone,
root-installable ZIP and tar.gz archives. The attached archives are the supported
installation artifacts; GitHub's automatic source archives remain useful for
source review.

Publishable archives must be produced on Linux with GNU tar, either in GitHub
Actions or an isolated Debian container. Archives built locally on macOS are
preflight artifacts only.

本仓库使用标准 SemVer tag（`vX.Y.Z`），并发布无开发期 submodule 依赖、可直接
作为 Neovim runtime 安装的 ZIP 与 tar.gz 包。正式安装应优先使用 Release 附件；
GitHub 自动生成的源码包主要用于源码审阅。

## Current release / 当前版本发布

1. Consume all change fragments into `CHANGELOG.md`.
2. Confirm both runtime versions, build the archives, and run the extracted-tree
   smoke test:

   ```sh
   node scripts/changeset.mjs check-release
   node scripts/release.mjs check v1.0.14
   node scripts/release.mjs package v1.0.14 dist
   node scripts/release.mjs verify v1.0.14 dist
   ```

3. Merge the reviewed release commit to the default branch.
4. Create an annotated tag on that exact commit and push it. The Release
   workflow re-runs the tests, rebuilds and verifies both archives, publishes
   `SHA256SUMS`, and reuses the matching changelog section as release notes.

不得移动或复用已经发布的 tag。若需修正内容，应发布新的 patch 版本。

## Historical backfill / 历史版本回填

The following tags are reconstructed from the first usable standalone commit
carrying each syntax version:

| Tag | Commit |
| --- | --- |
| `v1.0.6` | `d6a2aef21fb9986e934dfb01c44b9cdf9c493970` |
| `v1.0.7` | `c0587d963bcf5d734e2f311f6b5f056c8e5af1ff` |
| `v1.0.8` | `4d222d24dcab47ec5397b62b3df245f7ca39cdbd` |
| `v1.0.11` | `11f4e9aedea4812dc771a7b208e4d5e031b285d5` |

`package-ref` reads files directly from the selected Git object, includes only
the runtime allowlist, materializes the MPL-2.0 license if an old commit contains
the former development-submodule symlink, generates `doc/tags`, normalizes
timestamps to the source commit, and rejects every remaining symlink. `verify`
compares extracted ZIP and tar.gz trees, checks hashes and required paths, and
launches Neovim against the extracted plugin.

```sh
node scripts/release.mjs package-ref v1.0.8 \
  4d222d24dcab47ec5397b62b3df245f7ca39cdbd dist/backfill/v1.0.8
node scripts/release.mjs verify v1.0.8 dist/backfill/v1.0.8
node scripts/release.mjs notes v1.0.8 dist/backfill/v1.0.8/release-notes.md
```

Create and push each annotated historical tag only after the mapping and package
verification have passed. Historical tag pushes do not execute workflows that
were absent from those commits, so publish their verified assets explicitly with
the corresponding changelog notes.
