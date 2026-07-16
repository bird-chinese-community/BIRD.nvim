# BIRD2.nvim

<div align="center">

**BIRD 2 与 BIRD 3 配置文件的 Neovim 插件**

Version: [English](README.md) | 简体中文

<!-- Badge -->

[![MPL-2.0 许可证](https://img.shields.io/badge/License-MPL--2.0-blue?style=flat-square)](LICENSE)
[![Neovim 0.9+](https://img.shields.io/badge/Neovim-0.9+-green?style=flat-square&logo=neovim)](https://neovim.io/)
[![GitHub Stars](https://img.shields.io/github/stars/bird-chinese-community/BIRD2.nvim?style=flat-square&logo=github)](https://github.com/bird-chinese-community/BIRD2.nvim)
[![GitHub Issues](https://img.shields.io/github/issues/bird-chinese-community/BIRD2.nvim?style=flat-square&logo=github)](https://github.com/bird-chinese-community/BIRD2.nvim/issues)
[![维护状态](https://img.shields.io/badge/维护中-是-success?style=flat-square)](https://github.com/bird-chinese-community/BIRD2.nvim/graphs/commit-activity)

<!-- 预览图片 -->

![BIRD2.nvim 预览](https://raw.githubusercontent.com/bird-chinese-community/BIRD-tm-language-grammar/main/.github/assets/bird2-grammar-vim-preview.jpg)

</div>

---

## 目录

- [BIRD2.nvim](#bird2nvim)
  - [目录](#目录)
  - [概述](#概述)
  - [功能特性](#功能特性)
  - [安装](#安装)
    - [使用 lazy.nvim](#使用-lazynvim)
    - [使用 pack.nvim](#使用-packnvim)
  - [文件类型检测](#文件类型检测)
  - [文档](#文档)
  - [配置](#配置)
    - [禁用启发式检测](#禁用启发式检测)
    - [自定义文件扩展名](#自定义文件扩展名)
  - [贡献](#贡献)
  - [许可证](#许可证)
  - [相关项目](#相关项目)

---

## 概述

`BIRD2.nvim` 为 BIRD 2 与 BIRD 3 配置文件提供 Neovim 语法高亮、文件类型检测和文件类型插件支持。

这是 [BIRD 中文社区](https://github.com/bird-chinese-community) 的 [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) 项目的 Neovim 插件组件。

---

## 功能特性

- :rainbow: **语法高亮** - 与当前 BIRD 2.19 和 BIRD 3.3 对齐
- :mag: **自动文件类型检测** - 支持 `.bird`, `.bird2`, `.bird3`, `.conf` 等扩展名
- :brain: **智能启发式检测** - 对通用 `.conf` 文件的内容检测
- :wrench: **文件类型特定设置** - 注释、格式选项等
- :book: **内置帮助文档** - 通过 `:help bird2` 访问

---

## 安装

<details>
<summary><b>:package: 快速安装</b></summary>

选择你喜欢的插件管理器：

### 使用 lazy.nvim

```lua
{
  "bird-chinese-community/BIRD2.nvim",
  ft = "bird2",
  config = function()
    require("bird2").setup()
  end,
}
```

### 使用 pack.nvim

```vim
packadd! BIRD2.nvim
```

或手动克隆到 pack 目录：

```bash
git clone https://github.com/bird-chinese-community/BIRD2.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD2.nvim
```

</details>

<details>
<summary><b>:wrench: 手动安装</b></summary>

```bash
# 克隆仓库
git clone https://github.com/bird-chinese-community/BIRD2.nvim.git
cd BIRD2.nvim

# 将该目录加入 Neovim runtime path
```

本仓库可直接作为 Neovim package 目录使用。

</details>

---

## 文件类型检测

- **:page_facing_up: 扩展名**：`.bird`、`.bird2`、`.bird3`
- **:file_folder: 文件名**：`bird.conf`、`bird2.conf`、`bird3.conf`、`bird6.conf`，以及明确的 `bird-*`/`*.bird*.conf` 变体
- **:open_file_folder: 已知路径**：位于 `bird`、`bird2` 或 `bird3` 目录下的配置文件
- **:mag: 内容检测**：扫描通用 `.conf` 文件的前 200 行；BIRD 独有结构会直接命中，通用结构需要两个独立信号，从而减少误判。

---

## 文档

安装后，可查看帮助文档：

```vim
:help bird2
```

重新生成帮助标签：

```vim
:helptags ~/.local/share/nvim/site/doc
```

---

## 配置

无需配置即可使用。

<details>
<summary><b>:gear: 高级选项</b></summary>

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

</details>

---

## 贡献

### 同步语法源

`syntax/bird2.vim` 保持为普通文件，确保本仓库单独安装时也可正常工作。

从 `BIRD2.vim` 同步语法更新：

```bash
bash scripts/sync-syntax.sh
```

也可指定显式源路径：

```bash
bash scripts/sync-syntax.sh /path/to/BIRD2.vim/syntax/bird2.vim
```

欢迎贡献！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

---

## 许可证

- 插件文件：[Mozilla Public License 2.0](LICENSE)
- 版权所有 (c) BIRD 中文社区

---

## 相关项目

- :bookmark: [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) - BIRD 2 与 BIRD 3 的 TextMate 语法
- :star: [BIRD2.vim](https://github.com/bird-chinese-community/BIRD2.vim) - Vim 语法源
- :electric_plug: [vscode-bird2](https://github.com/bird-chinese-community/vscode-bird2-conf) - VS Code 扩展

---

<div align="center">

用 :heart: 维护，由 [BIRD 中文社区](https://github.com/bird-chinese-community) 呈现

</div>
