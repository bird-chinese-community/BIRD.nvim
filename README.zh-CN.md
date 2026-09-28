<p align="center">
  <img src=".github/assets/icon-256.png" width="128" height="128" alt="BIRD.nvim" />
</p>

# BIRD.nvim

[English](README.md) | 简体中文

[![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](LICENSE)
[![Neovim 0.9+](https://img.shields.io/badge/Neovim-0.9+-green.svg)](https://neovim.io/)
[![GitHub Release](https://img.shields.io/github/v/release/bird-chinese-community/BIRD.nvim)](https://github.com/bird-chinese-community/BIRD.nvim/releases/latest)

Neovim 语法高亮和文件类型插件，支持 BIRD 2 和 BIRD 3 配置文件。

这是 [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) 项目的 Neovim 插件组件。

> [!NOTE]
> 本仓库已从 `BIRD2.nvim` 更名为 `BIRD.nvim`，以体现同时支持 BIRD 2 与 BIRD 3。GitHub 会重定向旧 URL；`bird2` filetype、`require("bird2")`、命令和配置键继续保持兼容。

![BIRD.nvim 预览](https://raw.githubusercontent.com/bird-chinese-community/BIRD-tm-language-grammar/main/.github/assets/bird2-grammar-vim-preview.jpg)

## 安装

### 使用 lazy.nvim

```lua
{
  "bird-chinese-community/BIRD.nvim",
  version = "^1.0.14",
  lazy = false,
  config = function()
    require("bird2").setup()
  end,
}
```

插件需要在文件类型检测前加载；仅使用 `ft = "bird2"` 会让 BIRD 专用文件名形成检测与加载的循环依赖。

### 使用原生 package

将仓库克隆到 `start` package 目录后，Neovim 会在启动时加载：

```bash
git clone https://github.com/bird-chinese-community/BIRD.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
```

### 手动安装

克隆仓库并将其添加到 Neovim runtime path：

```bash
git clone https://github.com/bird-chinese-community/BIRD.nvim.git
cd BIRD.nvim
```

每个 [GitHub Release](https://github.com/bird-chinese-community/BIRD.nvim/releases) 附带 ZIP、tar.gz 和 `SHA256SUMS`。Release 压缩包不包含仅供开发使用的 `shared/` submodule，并已生成 `doc/tags`。完整包体约束与验证步骤参见[发布手册](RELEASING.md)。

## 更新

GitHub 会重定向原 `BIRD2.nvim` 仓库 URL，现有 checkout 仍可继续拉取。先把插件管理器配置中的仓库名改为新名称，再执行更新：

```vim
" lazy.nvim
:Lazy sync

" packer.nvim
:PackerSync
```

如果现有原生 package checkout 仍使用旧目录名，请重命名目录、更新 remote，再拉取：

如果旧版 vimdoc 安装使用小写目录名 `bird2.nvim`，请在第一条命令中用它替换 `BIRD2.nvim`。

```bash
mv ~/.local/share/nvim/site/pack/plugins/start/BIRD2.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim \
  remote set-url origin https://github.com/bird-chinese-community/BIRD.nvim.git
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim pull --ff-only
```

对于位于其他路径的手动 checkout，目录名可保持不变；更新 remote：

```bash
git -C /path/to/BIRD2.nvim remote set-url origin \
  https://github.com/bird-chinese-community/BIRD.nvim.git
git -C /path/to/BIRD2.nvim pull --ff-only
```

`shared/` submodule 只在贡献语法变更时需要，日常使用插件无需初始化。

兼容 API 保持不变：现有配置继续使用 `require("bird2")`、`filetype=bird2`、`:Bird2` 与 `:checkhealth bird2`。

## 文件类型检测

- 文件扩展名：`.bird`, `.bird2`, `.bird3` 和匹配 `*.bird*.conf` 的文件
- 文件名：`bird.conf`, `bird2.conf`, `bird3.conf`, `bird6.conf`、`bird-*` 等模式
- 目录路径：位于 `bird/`, `bird2/` 或 `bird3/` 目录下的文件
- 内容检测：扫描 `.conf` 文件的前 200 行。BIRD 独有结构会直接命中；通用结构需要两个独立的匹配信号来减少误判。


## 文档

安装后查看帮助文档：

```vim
:help bird2
```

重新生成帮助标签：

```vim
:helptags ~/.local/share/nvim/site/doc
```

发布历史参见[更新日志](CHANGELOG.md)。对于用户可见或需要进入发布说明的变更，贡献者应按照 [change fragment 指南](.changeset/README.md) 添加双语片段。

## 配置

无需配置即可使用。

### 禁用启发式检测

如需禁用 `.conf` 文件的内容检测：

```lua
require("bird2").setup({
  heuristic_detect = false,
})
```

### 自定义文件扩展名

添加自定义文件扩展名：

```lua
vim.filetype.add({
  extension = {
    myext = "bird2",
  },
})
```

## 贡献

### 同步语法源

`syntax/bird2.vim` 保持为普通文件，确保本仓库单独安装时也可正常工作。

从已初始化的 `shared/bird2.vim`（`BIRD.vim`）submodule 同步语法更新：

```bash
bash scripts/sync-syntax.sh
```

也可指定显式源路径：

```bash
bash scripts/sync-syntax.sh /path/to/BIRD.vim/syntax/bird2.vim
```

提交 Pull Request：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

## 许可证

插件文件：[Mozilla Public License 2.0](LICENSE)
版权所有 (c) BIRD 中文社区 (BIRDCC)

BIRDCC 与 BIRD 的维护方 CZ.NIC 没有隶属关系。

## 相关项目

- [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) - BIRD 2 与 BIRD 3 的 TextMate 语法
- [BIRD.vim](https://github.com/bird-chinese-community/BIRD.vim) - Vim 语法源
- [vscode-bird2](https://github.com/bird-chinese-community/vscode-bird2-conf) - VS Code 扩展

由 [BIRD 中文社区](https://github.com/bird-chinese-community) 维护
