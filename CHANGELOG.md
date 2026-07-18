# Changelog 🕊️

<!-- markdownlint-disable MD024 -->

All notable changes to BIRD.nvim are documented in this file.

本文记录 BIRD.nvim 的重要变更。

> The bundled syntax describes BIRD configuration syntax for editors. It does
> not implement or claim coverage of upstream BIRD runtime semantic changes.
>
> 内置语法用于描述编辑器中的 BIRD 配置语法，不实现也不声称覆盖 BIRD 上游
> 运行时语义变化。

<!-- changeset-release-marker -->

## [1.0.14] - 2026-07-19

### 🐛 Fixed / 修复

- 🐛 **修复 MPL-2.0 许可证正文与识别信息** / **Fix MPL-2.0 license text and detection**

  此前的 LICENSE 文件在标准 MPL-2.0 正文中混入了不相关条款，导致 GitHub 将仓库许可证识别为 “Other”，v1.0.13 安装包也携带了该错误正文。本版本恢复 Mozilla 发布的标准 MPL-2.0 全文，使仓库元数据和新生成的安装包一致、正确地声明 MPL-2.0。

  The previous LICENSE file mixed unrelated clauses into the MPL-2.0 text, causing GitHub to identify the repository license as “Other” and the v1.0.13 archives to carry the incorrect text. This release restores Mozilla's canonical MPL-2.0 text so repository metadata and newly generated archives consistently declare MPL-2.0.

## [1.0.13] - 2026-07-17

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

  Added exact detection for `.bird`, `.bird2`, and `.bird3` extensions,
  canonical filenames, and configuration directories, together with
  `FileType conf`, buffer read/write, and late-populated-content paths.

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
  Workflow 改用标准 `v*` SemVer 标签与 Neovim 专用发布说明。

  The lazy.nvim example now loads the detector eagerly, avoiding the
  `ft = "bird2"` loading cycle. The Release Workflow now uses standard `v*`
  SemVer tags and Neovim-specific release notes.

- 🔄 **CI 与语法镜像同步** / **CI and syntax-mirror synchronization**

  CI 覆盖 Neovim `v0.9.5` 与 stable，运行 Luacheck、StyLua，递归检出
  submodule，并验证 Vim/Neovim 语法镜像逐字节一致。

  CI covers Neovim `v0.9.5` and stable, runs Luacheck and StyLua, checks out
  submodules recursively, and verifies byte-identical Vim/Neovim syntax mirrors.

- 🧾 **引入可审计的变更片段** / **Adopt auditable change fragments**

  新增零依赖的变更片段工作流，可在 PR 中记录语义版本级别和双语发布说明，
  发布时按分类汇总到 CHANGELOG，并让 GitHub Release 直接复用同一份说明。

  Added a dependency-free change-fragment workflow that records semantic
  version bumps and bilingual notes in pull requests, groups them into the
  changelog, and feeds the same notes into GitHub Releases.

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

- 仓库由 BIRD2.nvim 更名为 BIRD.nvim，并提供 lazy.nvim、packer.nvim、原生
  packages 与现有 checkout 的双语迁移步骤；`shared/` 开发子模块同步指向
  BIRD.vim。
- The repository was renamed from BIRD2.nvim to BIRD.nvim with bilingual
  migration steps for lazy.nvim, packer.nvim, native packages, and existing
  checkouts; the development-only `shared/` submodule now points to BIRD.vim.
- 对外兼容面仍为 `filetype=bird2`、`require("bird2")`、`:Bird2`、
  `:Bird2Health` 与 `:checkhealth bird2`。
- The public compatibility surface remains `filetype=bird2`,
  `require("bird2")`, `:Bird2`, `:Bird2Health`, and `:checkhealth bird2`.

## [1.0.11] - 2026-06-11

### 🔧 Changed / 变更

- 🏷️ **同步插件与语法版本** / **Synchronized plugin and syntax versions**

  将 Neovim runtime 内置语法更新为 `1.0.11-20260611`，与独立 BIRD.vim
  及主语法仓库保持一致；现有 Lua 配置接口保持兼容。

  Updated the bundled Neovim syntax to `1.0.11-20260611`, matching BIRD.vim
  and the canonical grammar repository while preserving the existing Lua
  configuration interface.

## [1.0.8] - 2026-03-01

### ✨ Added / 新增

- 🔤 **扩展协议、属性与短语覆盖** / **Expanded protocol, property, and phrase coverage**

  同步 BIRD.vim 中新增的协议与地址关键字、CLI 多词短语、byte string、属性与
  操作符规则。

  Synchronized the protocol and address keywords, multi-word CLI phrases,
  byte-string handling, property rules, and operators added in BIRD.vim.

### 🐛 Fixed / 修复

- 🔐 **修正 RPKI 与语法镜像** / **Corrected RPKI and the syntax mirror**

  修正 `retry` 等 RPKI 关键字分类，并确保仓库内的 Neovim syntax 是可独立
  安装的普通文件，而不是依赖仓库外路径的链接。

  Corrected RPKI keyword classification including `retry` and kept the bundled
  Neovim syntax as a standalone regular file rather than an external-path link.

## [1.0.7] - 2026-02-28

### ✨ Added / 新增

- 🧪 **建立独立 CI 与发布基础** / **Established standalone CI and release foundations**

  新增 Neovim CI、Release workflow、语法同步脚本与 BIRD.vim 开发期 submodule，
  并将 `1.0.7-20260228` 语法作为普通 runtime 文件随插件交付。

  Added Neovim CI, a release workflow, a syntax synchronization script, and a
  development-time BIRD.vim submodule while shipping syntax snapshot
  `1.0.7-20260228` as a regular runtime file.

## [1.0.6] - 2025-12-24

### ✨ Added / 新增

- 🐦 **首个独立 Neovim 插件版本** / **Initial standalone Neovim plugin**

  提供 Lua `setup()` API、自动 filetype detection、health check、ftplugin、
  BIRD 2 syntax、双语 README、vimdoc 与初始测试套件。

  Introduced the Lua `setup()` API, automatic filetype detection, health
  checks, an ftplugin, BIRD 2 syntax, bilingual READMEs, vimdoc, and the initial
  test suite.

[1.0.13]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.13
[1.0.11]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.11
[1.0.8]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.8
[1.0.7]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.7
[1.0.6]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.6
[1.0.14]: https://github.com/bird-chinese-community/BIRD.nvim/releases/tag/v1.0.14
