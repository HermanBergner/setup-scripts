# Feature 003 — Dotfiles

## What it does

Stores the zsh and neovim configurations that `setup/setup.sh` symlinks into place on a fresh machine. The dotfiles live in a single git repository (`https://github.com/HermanBergner/dotfiles`) cloned to `~/dotfiles` during setup.

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc              # symlinked to ~/.zshrc
│   └── config/             # symlinked to ~/.config/zsh
│       ├── alias.zsh
│       ├── executables.zsh
│       ├── fzf.zsh
│       ├── history.zsh
│       ├── plugins.zsh
│       ├── prompt.zsh
│       └── plugins/        # populated by setup.sh (not in repo)
│           ├── fzf-tab
│           ├── zsh-syntax-highlighting
│           └── zsh-autosuggestions
└── nvim/                   # directory symlinked to ~/.config/nvim
    ├── init.lua
    └── lua/
        ├── config/
        └── plugins/
```

## How symlinks are created

`setup/setup.sh` creates three symlinks:

| Source | Destination |
|--------|-------------|
| `~/dotfiles/zsh/.zshrc` | `~/.zshrc` |
| `~/dotfiles/zsh/config` | `~/.config/zsh` |
| `~/dotfiles/nvim` | `~/.config/nvim` |

If a file already exists at the destination, setup backs it up to `.bak` before symlinking.

To update your config on a running machine, edit the files in `~/dotfiles/` directly — changes take effect immediately since the shell and editor read through the symlinks.

## zsh plugins

The plugins directory (`~/.config/zsh/plugins/`) is populated by `setup.sh` at install time by cloning from upstream — the plugin repos are not vendored into the dotfiles repo. Plugins installed:

| Plugin | Source |
|--------|--------|
| fzf-tab | https://github.com/Aloxaf/fzf-tab |
| zsh-syntax-highlighting | https://github.com/zsh-users/zsh-syntax-highlighting |
| zsh-autosuggestions | https://github.com/zsh-users/zsh-autosuggestions |

## zsh config

- No oh-my-zsh dependency
- `.zshrc` sources modular files from `~/.config/zsh/` (alias, prompt, history, fzf, plugins, executables)
- Edit files in `~/dotfiles/zsh/config/` to customise

## neovim config

- Entry point: `init.lua` (Lua-based configuration)
- Uses `lazy.nvim` as plugin manager
- The entire `dotfiles/nvim/` directory is symlinked, so subdirectories (`lua/config/`, `lua/plugins/`, etc.) are automatically included

## Decisions

| Decision | Choice |
|----------|--------|
| Repo structure | Single repo (zsh + nvim in one) |
| Clone target | `~/dotfiles` |
| nvim entry point | `init.lua` |
| zsh framework | None (no oh-my-zsh) |
| zsh plugins | Cloned at setup time, not vendored into dotfiles repo |

## Extending

Add new dotfiles by:
1. Creating the config file under `dotfiles/<tool>/`
2. Adding a `link_<tool>()` function in `setup/setup.sh`
3. Calling it from `main()` in `setup/setup.sh`
4. Updating `docs/feature_002_setup/README.md` and this file
