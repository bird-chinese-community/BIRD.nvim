<p align="center">
  <img src=".github/assets/icon-256.png" width="128" height="128" alt="BIRD.nvim" />
</p>

# BIRD.nvim

English | [简体中文](README.zh-CN.md)

[![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](LICENSE)
[![Neovim 0.9+](https://img.shields.io/badge/Neovim-0.9+-green.svg)](https://neovim.io/)
[![GitHub Release](https://img.shields.io/github/v/release/bird-chinese-community/BIRD.nvim)](https://github.com/bird-chinese-community/BIRD.nvim/releases/latest)

Neovim syntax highlighting and filetype plugin for BIRD 2 and BIRD 3 configuration files.

This is the Neovim plugin component of the [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) project.

> [!NOTE]
> The repository was renamed from `BIRD2.nvim` to reflect support for both BIRD 2 and BIRD 3. GitHub redirects the old URL; the `bird2` filetype, `require("bird2")`, commands, and configuration keys remain compatible.

![BIRD.nvim Preview](https://raw.githubusercontent.com/bird-chinese-community/BIRD-tm-language-grammar/main/.github/assets/bird2-grammar-vim-preview.jpg)

## Installation

### Using lazy.nvim

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

The plugin must load before filetype detection runs; using `ft = "bird2"` alone creates a detection/loading cycle for BIRD-specific filenames.

### Using native packages

Clone the repository into a `start` package directory; Neovim loads it during startup:

```bash
git clone https://github.com/bird-chinese-community/BIRD.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
```

### Manual installation

Clone the repository and add it to your Neovim runtime path:

```bash
git clone https://github.com/bird-chinese-community/BIRD.nvim.git
cd BIRD.nvim
```

Every [GitHub Release](https://github.com/bird-chinese-community/BIRD.nvim/releases) includes ZIP and tar.gz archives plus `SHA256SUMS`. Release archives exclude the development-only `shared/` submodule and include generated `doc/tags`. See the [release runbook](RELEASING.md) for the verified package contract.

## Updating

GitHub redirects the old `BIRD2.nvim` URL, so existing checkouts continue to fetch. Update the repository name in your plugin-manager configuration, then refresh:

```vim
" lazy.nvim
:Lazy sync

" packer.nvim
:PackerSync
```

For a native package checkout, rename the directory, update the remote, and pull:

If an older installation uses lowercase `bird2.nvim`, substitute that in the first command.

```bash
mv ~/.local/share/nvim/site/pack/plugins/start/BIRD2.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim \
  remote set-url origin https://github.com/bird-chinese-community/BIRD.nvim.git
git -C ~/.local/share/nvim/site/pack/plugins/start/BIRD.nvim pull --ff-only
```

For a manual installation at another path, update the remote:

```bash
git -C /path/to/BIRD2.nvim remote set-url origin \
  https://github.com/bird-chinese-community/BIRD.nvim.git
git -C /path/to/BIRD2.nvim pull --ff-only
```

The `shared/` submodule is only needed when contributing syntax changes; it is not required for normal plugin use.

The compatibility API remains unchanged: keep `require("bird2")`, `filetype=bird2`, `:Bird2`, and `:checkhealth bird2` in existing configurations.

## Filetype Detection

- File extensions: `.bird`, `.bird2`, `.bird3`, and files matching `*.bird*.conf`
- Filenames: `bird.conf`, `bird2.conf`, `bird3.conf`, `bird6.conf`, `bird-*`, and similar patterns
- Directory paths: files below `bird/`, `bird2/`, or `bird3/` directories
- Content: scans the first 200 lines of `.conf` files. BIRD-specific constructs are accepted immediately; generic constructs require two independent matches to minimize false positives.

## Documentation

View the help documentation after installation:

```vim
:help bird2
```

Regenerate help tags:

```vim
:helptags ~/.local/share/nvim/site/doc
```

See the [changelog](CHANGELOG.md) for release history. Contributors should add a bilingual fragment following the [change-fragment guide](.changeset/README.md) for user-visible or release-worthy changes.

## Configuration

No configuration is required. The plugin works without additional setup.

### Disable heuristic detection

To disable content-based detection for `.conf` files:

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

## Contributing

### Sync Syntax Source

The `syntax/bird2.vim` file is stored as a regular file so this repository works when installed standalone.

To sync syntax updates from the `shared/bird2.vim` (`BIRD.vim`) submodule:

```bash
bash scripts/sync-syntax.sh
```

Or specify an explicit source path:

```bash
bash scripts/sync-syntax.sh /path/to/BIRD.vim/syntax/bird2.vim
```

To submit a change:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Plugin files: [Mozilla Public License 2.0](LICENSE)
Copyright (c) BIRD Chinese Community (BIRDCC)

BIRDCC is not affiliated with CZ.NIC, the maintainers of BIRD.

## Related Projects

- [BIRD-tm-language-grammar](https://github.com/bird-chinese-community/bird-tm-language-grammar) - TextMate grammar for BIRD 2 and BIRD 3
- [BIRD.vim](https://github.com/bird-chinese-community/BIRD.vim) - Vim syntax source
- [vscode-bird2](https://github.com/bird-chinese-community/vscode-bird2-conf) - VS Code extension

Maintained by the [BIRD Chinese Community](https://github.com/bird-chinese-community)
