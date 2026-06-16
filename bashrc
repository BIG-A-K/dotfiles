# ~/.bashrc: small, optional-dependency friendly bash config.

# Only configure interactive shells.
case $- in
  *i*) ;;
  *) return ;;
esac

# history
HISTCONTROL=ignoreboth
HISTSIZE=100000
HISTFILESIZE=200000
shopt -s histappend

# Keep terminal size variables current after each command.
shopt -s checkwinsize

if [ -f "$HOME/.alias" ]; then
  . "$HOME/.alias"
fi

# Optional tools. Keep bash usable when they are absent.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\u@\h:\w\$ '
fi

# Return a tab title. Prefix the host name when this shell runs over SSH.
_tab_title() {
  if [ -n "${SSH_CONNECTION:-}" ]; then
    printf '%s:%s\n' "${HOSTNAME%%.*}" "${PWD##*/}"
  else
    printf '%s\n' "${PWD##*/}"
  fi
}

_set_tab_title() {
  printf '\033]0;%s\007' "$(_tab_title)"
}

if [ -n "${PROMPT_COMMAND:-}" ]; then
  PROMPT_COMMAND="_set_tab_title; $PROMPT_COMMAND"
else
  PROMPT_COMMAND='_set_tab_title'
fi
