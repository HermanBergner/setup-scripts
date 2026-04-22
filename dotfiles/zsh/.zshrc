# .zshrc — managed in wsl-setup dotfiles
# Replace this stub with your full zsh configuration.

export PATH="$HOME/.local/bin:$PATH"

PROMPT='%n@%m %~ %# '

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
