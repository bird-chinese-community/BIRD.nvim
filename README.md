# BIRD.nvim

<div align="center">

**Neovim syntax highlighting for BIRD 2 and BIRD 3 configuration files**

Version: English | [简体中文](README.zh-CN.md)

<!-- Badge -->

[![MPL-2.0 License](https://img.shields.io/badge/License-MPL--2.0-blue?style=flat-square)](LICENSE)
[![Neovim 0.9+](https://img.shields.io/badge/Neovim-0.9+-green?style=flat-square&logo=neovim)](https://neovim.io/)
[![GitHub Release](https://img.shields.io/github/v/release/bird-chinese-community/BIRD.nvim?style=flat-square)](https://github.com/bird-chinese-community/BIRD.nvim/releases/latest)
[![GitHub Stars](https://img.shields.io/github/stars/bird-chinese-community/BIRD.nvim?style=flat-square&logo=github)](https://github.com/bird-chinese-community/BIRD.nvim)
[![GitHub Issues](https://img.shields.io/github/issues/bird-chinese-community/BIRD.nvim?style=flat-square&logo=github)](https://github.com/bird-chinese-community/BIRD.nvim/issues)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-success?style=flat-square)](https://github.com/bird-chinese-community/BIRD.nvim/graphs/commit-activity)

<!-- Preview Image -->

![BIRD.nvim Preview](https://raw.githubusercontent.com/bird-chinese-community/BIRD-tm-language-grammar/main/.github/assets/bird2-grammar-vim-preview.jpg)

</div>

---

## Table of Contents

- [BIRD.nvim](#birdnvim)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Installation](#installation)
    - [Using lazy.nvim](#using-lazynvim)
    - [Using native packages](#using-native-packages)
  - [Updating](#updating)
  - [Filetype Detection](#filetype-detection)
  - [Documentation](#documentation)
  - [Configuration](#configuration)
    - [Disable heuristic detection](#disable-heuristic-detection)
    - [Custom file extensions](#custom-file-extensions)
  - [Contributing](#contributing)
  - [License](#license)
  - [Related Projects](#related-projects)

---

## Overview

`BIRD.nvim` provides Neovim syntax highlighting, filetype detection, and filetype plugin support for BIRD 2 and BIRD 3 configuration files.

This is the Neovim plugin component of the [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) project by the **BIRD Chinese Community**.

> [!NOTE]
> This repository was renamed from `BIRD2.nvim` to reflect support for both BIRD 2 and BIRD 3. GitHub redirects the old URL, while the `bird2` filetype, `require("bird2")`, commands, and configuration keys remain compatible.

---

## Features

- :rainbow: **Syntax highlighting** aligned with current BIRD 2.19 and BIRD 3.3 syntax
- :mag: **Automatic filetype detection** for `.bird`, `.bird2`, `.bird3`, and `.conf` files
- :brain: **Smart heuristic detection** for generic `.conf` files
- :wrench: **Filetype-specific settings** (comments, format options, etc.)
- :book: **Built-in help documentation** accessible via `:help bird2`

---

## Installation

<details>
<summary><b>:package: Quick Installation</b></summary>

Choose your preferred plugin manager:

### Using lazy.nvim

```lua
{
  "bird-chinese-community/BIRD.nvim",
  version = "^1.0.13",
  lazy = false,
  config = function()
    require("bird2").setup()
  end,
}
```

The plugin must load before filetype detection runs; using `ft = "bird2"` alone
creates a detection/loading cycle for BIRD-specific filenames.

### Using native packages

Clone the repository into a `start` package directory; Neovim loads it during
startup:

```bash
git clone https://github.com/bird-chinese-community/BIRD.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
```

</details>

<details>
<summary><b>:wrench: Manual Installation</b></summary>

```bash
# Clone the repository
git clone https://github.com/bird-chinese-community/BIRD.nvim.git
cd BIRD.nvim

# Add this directory to your Neovim runtime path
```

This repository can be used directly as a Neovim package directory.

Every [GitHub Release](https://github.com/bird-chinese-community/BIRD.nvim/releases)
also includes standalone ZIP and tar.gz archives plus `SHA256SUMS`. Release
archives exclude the development-only `shared/` submodule and include generated
`doc/tags`. See the [release runbook](RELEASING.md) for the verified package
contract.

</details>

---

## Updating

GitHub redirects the former `BIRD2.nvim` repository URL, so existing checkouts continue to fetch. Update the repository name in your plugin-manager configuration, then refresh it:

```vim
" lazy.nvim
:Lazy sync

" packer.nvim
:PackerSync
```

For an existing native package checkout, rename its directory, update the
remote, and then refresh the repository:

If an older vimdoc installation uses the lowercase directory `bird2.nvim`,
substitute that name for `BIRD2.nvim` in the first command.

```bash
mv ~/.local/share/nvim/site/pack/plugins/start/BIRD2.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim \
  remote set-url origin https://github.com/bird-chinese-community/BIRD.nvim.git
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim pull --ff-only
```

For a manual checkout at another path, the directory name can remain unchanged;
update its remote:

```bash
git -C /path/to/BIRD2.nvim remote set-url origin \
  https://github.com/bird-chinese-community/BIRD.nvim.git
git -C /path/to/BIRD2.nvim pull --ff-only
```

The `shared/` submodule is only needed when contributing syntax changes; it is
not required to use the plugin.

The compatibility API remains unchanged: keep `require("bird2")`, `filetype=bird2`, `:Bird2`, and `:checkhealth bird2` in existing configurations.

---

## Filetype Detection

- **:page_facing_up: Extension**: `.bird`, `.bird2`, `.bird3`
- **:file_folder: Filename**: `bird.conf`, `bird2.conf`, `bird3.conf`, `bird6.conf`, and explicit `bird-*`/`*.bird*.conf` variants
- **:open_file_folder: Known paths**: configuration files below `bird`, `bird2`, or `bird3` directories
- **:mag: Content**: scans the first 200 lines of generic `.conf` files. Strong BIRD-only constructs are accepted immediately; generic constructs require two independent signals to reduce false positives.

---

## Documentation

After installation, view the help documentation:

```vim
:help bird2
```

To regenerate help tags:

```vim
:helptags ~/.local/share/nvim/site/doc
```

See the [changelog](CHANGELOG.md) for release history. Contributors should add
a bilingual fragment following the [change-fragment guide](.changeset/README.md)
for user-visible or release-worthy changes.

---

## Configuration

No configuration is required. The plugin works out of the box.

<details>
<summary><b>:gear: Advanced Options</b></summary>

### Disable heuristic detection

If you want to disable content-based detection for `.conf` files:

```lua
require("bird2").setup({
  heuristic_detect = false,
})
```

### Custom file extensions

To add custom file extensions:

```lua
vim.filetype.add({
  extension = {
    myext = "bird2",
  },
})
```

</details>

---

## Contributing

### Sync Syntax Source

`syntax/bird2.vim` is stored as a regular file so this repository works when installed standalone.

To sync syntax updates from the initialized `shared/bird2.vim` (`BIRD.vim`)
submodule:

```bash
bash scripts/sync-syntax.sh
```

Or use an explicit source path:

```bash
bash scripts/sync-syntax.sh /path/to/BIRD.vim/syntax/bird2.vim
```

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

- Plugin files: [Mozilla Public License 2.0](LICENSE)
- Copyright (c) BIRD Chinese Community (BIRDCC)

---

## Related Projects

- :bookmark: [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) - TextMate grammar for BIRD 2 and BIRD 3
- :star: [BIRD.vim](https://github.com/bird-chinese-community/BIRD.vim) - Vim syntax source
- :electric_plug: [vscode-bird2](https://github.com/bird-chinese-community/vscode-bird2-conf) - VS Code extension

---

<div align="center">

Maintained with :heart: by the [BIRD Chinese Community](https://github.com/bird-chinese-community)

</div>
