########################################

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.bun/bin"
  "$HOME/.opencode/bin"
  "$HOME/.antigravity/antigravity/bin"
  "/Library/TeX/texbin"
  "/opt/homebrew/opt/openjdk/bin"
  $path
)

# macOS system paths
if [ -x /usr/libexec/path_helper ]; then
  eval "$(/usr/libexec/path_helper -s)"
fi

# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

# zsh-suggestion
if [ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# aliasのファイルを読み込む
if [ -f "$HOME/.alias" ]; then
  source "$HOME/.alias"
fi
# bind_keyのファイルを読み込む
# source ~/.bind_keys
# ctrl + 矢印キーを使う
bindkey ";3C" forward-word
bindkey ";3D" backward-word
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey ";5A" up-line-or-history
bindkey ";5B" down-line-or-history
bindkey '^H' backward-kill-word
bindkey '5~' kill-word
# コマンド実行前にタブタイトルを更新
precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}

# コマンド実行中はコマンド名を表示
preexec() {
  echo -ne "\033]0;$1\007"
}

# Ctrl+Tab で逆順に補完候補を参照
bindkey '^[[Z' reverse-menu-complete

if [ -f "$HOME/.env" ]; then
  export $(grep -v '^#' "$HOME/.env" | xargs)
fi

# history
## Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
## 直前のコマンドの重複を削除
# D85E33
setopt hist_ignore_dups
## 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
## 同時に起動したzshの間でヒストリを共有
setopt share_history

if command -v defaults >/dev/null 2>&1; then
  THEME=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
fi

#if [ "$THEME" = "Dark" ]; then
#    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
#else
#    export STARSHIP_CONFIG="$HOME/.config/light-starship.toml"
#fi
export STARSHIP_CONFIG="$HOME/.config/starship.toml"


# 色を使用出来るようにする
autoload -Uz colors
colors
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Set up the prompt
autoload -Uz promptinit
promptinit
# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e


# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep

export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
#export LSCOLORS=gxfxcxdxbxegedabagacad

# Use modern completion system
## 補完機能を有効にする
if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi
if [ -e /opt/homebrew/share/zsh-completions ]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi
autoload -Uz compinit
compinit -u
## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## 補完候補を詰めて表示
setopt list_packed
## 補完候補一覧をカラー表示
zstyle ':completion:*' list-colors ''

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export LS_COLORS

export EDITOR=nvim
export VISUAL=nvim

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
