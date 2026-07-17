# Changelog 🕊️

<!-- markdownlint-disable MD024 -->

All notable changes to BIRD.nvim are documented in this file.

本文记录 BIRD.nvim 的重要变更。

> The bundled syntax describes BIRD configuration syntax for editors. It does
> not implement or claim coverage of upstream BIRD runtime semantic changes.

<!-- changeset-release-marker -->

## [1.0.13] - 2026-07-17

`1.0.13` 由 [PR #1] 于 2026-07-17 合并，并内置 `1.0.13-20260717` 的
BIRD.vim 语法快照。BIRD.nvim 仓库本身尚未为该版本创建独立 GitHub Release。

Version `1.0.13` was merged in [PR #1] on 2026-07-17 and embeds the
`1.0.13-20260717` BIRD.vim syntax snapshot. The BIRD.nvim repository itself
does not have a separate GitHub Release for this version.

### ✨ Added / 新增

- 🛰️ **BIRD 2.19 与 BIRD 3.3 配置语法** / **BIRD 2.19 and BIRD 3.3 configuration syntax**

  同步当前与冷门关键字、枚举、CLI 短语、运行时/接口属性、BGP
  hidden/unknown attributes、`mac` / `mac set` 类型、`bt_check_assign`、压缩
  IPv6 前缀、prefix range 及无冲突的位运算符规则。

  Synchronized current and uncommon keywords, enums, CLI phrases,
  runtime/interface attributes, BGP hidden/unknown attributes, `mac` / `mac set`
  types, `bt_check_assign`, compressed IPv6 prefixes, prefix ranges, and
  collision-safe bitwise operators.

- 🧭 **精确名称、目录与内容识别** / **Exact name, directory, and content detection**

  新增 `.bird`、`.bird2`、`.bird3`、规范配置文件名与配置目录识别，并加入
  `FileType conf`、buffer read/write 和稍后写入内容的检测路径。

  Added exact extension, canonical filename, and configuration-directory
  detection, together with `FileType conf`, buffer read/write, and
  late-populated-content paths.

- 🧪 **headless runtime 集成测试** / **Headless runtime integration tests**

  新增对 runtime option、映射、注释行为、health check、启发式检测、filetype
  保留及语法加载的 headless 回归覆盖。

  Added headless regression coverage for runtime options, mappings, comment
  behavior, health checks, heuristics, filetype preservation, and syntax loading.

### 🔧 Changed / 变更

- 🔎 **有界、注释感知的启发式检测** / **Bounded, comment-aware heuristics**

  通用 `.conf` 文件仅扫描前 200 行并忽略注释。BIRD 独有结构可直接命中，
  较通用结构必须同时出现两个独立信号；已有的非 `conf` filetype 不会被覆盖。

  Generic `.conf` files are scanned only through the first 200 lines with
  comments ignored. BIRD-specific structures match directly, while generic
  structures require two independent signals; existing non-`conf` filetypes
  are preserved.

- 📦 **修正 lazy.nvim 与发布自动化** / **Corrected lazy.nvim and release automation**

  lazy.nvim 示例改为提前加载检测器，避免 `ft = "bird2"` 造成加载循环；Release
  Workflow 改用 `nvim-v*` 标签与 Neovim 专用发布说明。

  The lazy.nvim example now loads the detector eagerly, avoiding the
  `ft = "bird2"` loading cycle. The Release Workflow now uses `nvim-v*` tags
  and Neovim-specific release notes.

- 🔄 **CI 与语法镜像同步** / **CI and syntax-mirror synchronization**

  CI 覆盖 Neovim `v0.9.5` 与 stable，运行 Luacheck、StyLua，递归检出
  submodule，并验证 Vim/Neovim 语法镜像逐字节一致。

  CI covers Neovim `v0.9.5` and stable, runs Luacheck and StyLua, checks out
  submodules recursively, and verifies byte-identical Vim/Neovim syntax mirrors.

### 🐛 Fixed / 修复

- ♻️ **`on_attach` 幂等性与自动换行** / **Idempotent `on_attach` and text wrapping**

  重复执行 `on_attach` 不再持续追加 buffer option 与 `matchpairs`，并移除意外
  启用自动文本换行的 `formatoptions` 标志。

  Repeated `on_attach` calls no longer append buffer options or `matchpairs`,
  and the `formatoptions` flag that enabled unintended automatic wrapping was
  removed.

- 💬 **注释缩进与用户映射** / **Comment indentation and user mappings**

  普通模式与可视模式切换注释时保留缩进，并避免覆盖用户已有的 `<Leader>c`
  等映射。

  Normal and visual comment toggling now preserves indentation, and existing
  user mappings such as `<Leader>c` are no longer replaced.

- 🩺 **health check 容错** / **Health-check resilience**

  `:checkhealth bird2` 在 syntax runtime path 缺失时不再异常，并通过当前
  Neovim detector 报告 filetype 注册状态。

  `:checkhealth bird2` now tolerates a missing syntax runtime path and reports
  filetype registration through the active Neovim detector.

- 🗃️ **误识别与 typed table 边界** / **False positives and typed-table boundaries**

  避免 `bluebird.conf` 等 substring-only 误识别；正确识别 `eth table`、
  `neighbor table` 与 `ipv6 sadr table`，同时排除 address-family 标签。

  Avoids substring-only false positives such as `bluebird.conf`; recognizes
  `eth table`, `neighbor table`, and `ipv6 sadr table` without classifying
  address-family labels as table declarations.

### 🔌 Compatibility / 兼容性

- 对外兼容面仍为 `filetype=bird2`、`require("bird2")`、`:Bird2`、
  `:Bird2Health` 与 `:checkhealth bird2`。
- The public compatibility surface remains `filetype=bird2`,
  `require("bird2")`, `:Bird2`, `:Bird2Health`, and `:checkhealth bird2`.

[1.0.13]: https://github.com/bird-chinese-community/BIRD.nvim/pull/1
[PR #1]: https://github.com/bird-chinese-community/BIRD.nvim/pull/1
