# Feature 003 — Dotfiles

## What it does

Stores the zsh and neovim configurations that `setup/setup.sh` symlinks into place on a fresh machine. The dotfiles live in a single git repository cloned to `~/dotfiles` during setup.

## Structure

```
dotfiles/
├── zsh/
│   └── .zshrc          # symlinked to ~/.zshrc
└── nvim/
    └── init.lua        # directory symlinked to ~/.config/nvim
```

## How symlinks are created

`setup/setup.sh` creates two symlinks:

| Source | Destination |
|--------|-------------|
| `~/dotfiles/zsh/.zshrc` | `~/.zshrc` |
| `~/dotfiles/nvim` | `~/.config/nvim` |

If a file already exists at the destination, setup backs it up to `.bak` before symlinking.

To update your config on a running machine, edit the files in `~/dotfiles/` directly — changes take effect immediately since the shell and editor read through the symlinks.

## zsh config

- No oh-my-zsh dependency
- Edit `dotfiles/zsh/.zshrc` to add aliases, functions, plugins, etc.
- The stub sets a minimal prompt, `PATH` extension, and history options

## neovim config

- Entry point: `init.lua` (Lua-based configuration)
- Full config replaces the stub — add plugin manager bootstrapping, keymaps, and options as needed
- The entire `dotfiles/nvim/` directory is symlinked, so subdirectories (`lua/`, `after/`, etc.) are automatically included

## Decisions

| Decision | Choice |
|----------|--------|
| Repo structure | Single repo (zsh + nvim in one) |
| Clone target | `~/dotfiles` |
| nvim entry point | `init.lua` |
| zsh framework | None (no oh-my-zsh) |

## Extending

Add new dotfiles by:
1. Creating the config file under `dotfiles/<tool>/`
2. Adding a `link_<tool>()` function in `setup/setup.sh`
3. Calling it from `main()` in `setup/setup.sh`
4. Updating `docs/feature_002_setup/README.md` and this file
