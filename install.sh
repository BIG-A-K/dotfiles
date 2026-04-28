#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
STARSHIP_PROFILE="earth"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --starship NAME  Starship profile name: mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
  --dry-run        Show actions without changing files
  -h, --help       Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --starship)
      if [ "$#" -lt 2 ]; then
        echo "error: --starship requires a profile name" >&2
        exit 1
      fi
      STARSHIP_PROFILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

backup_path() {
  local target="$1"

  run mkdir -p "$BACKUP_DIR"
  run mv "$target" "$BACKUP_DIR/$(basename "$target")"
}

link_file() {
  local source="$1"
  local target="$2"
  local target_dir

  if [ ! -e "$source" ]; then
    echo "error: source not found: $source" >&2
    exit 1
  fi

  target_dir="$(dirname "$target")"
  run mkdir -p "$target_dir"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    printf 'skip: %s already links to %s\n' "$target" "$source"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    printf 'backup: %s -> %s\n' "$target" "$BACKUP_DIR/$(basename "$target")"
    backup_path "$target"
  fi

  printf 'link: %s -> %s\n' "$target" "$source"
  run ln -s "$source" "$target"
}

case "$STARSHIP_PROFILE" in
  mercury|venus|earth|mars|jupiter|saturn|uranus|neptune) ;;
  *)
    echo "error: unknown starship profile: $STARSHIP_PROFILE" >&2
    echo "available profiles: mercury, venus, earth, mars, jupiter, saturn, uranus, neptune" >&2
    exit 1
    ;;
esac

link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/alias" "$HOME/.alias"
link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/starship.conf/$STARSHIP_PROFILE.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/scripts/imgcat" "$HOME/.local/bin/imgcat"

printf 'done\n'
