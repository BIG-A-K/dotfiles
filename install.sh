#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
STARSHIP_PROFILE="earth"
DRY_RUN=0
FORCE=0
SKIP_SUBMODULES=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --starship NAME    Starship profile name: mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pruto (default: earth)
                     The matching tmux color theme (tmux.conf.d/NAME.conf) is linked as well.
  --dry-run          Show actions without changing files
  -f, --force        Overwrite existing symlinks and back up existing files/directories
  --skip-submodules  Do not sync/update git submodules
  -h, --help         Show this help
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
    -f|--force)
      FORCE=1
      shift
      ;;
    --skip-submodules)
      SKIP_SUBMODULES=1
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

update_submodules() {
  if [ "$SKIP_SUBMODULES" -eq 1 ]; then
    printf 'skip: submodule update (--skip-submodules)\n'
    return
  fi

  if [ ! -f "$DOTFILES_DIR/.gitmodules" ]; then
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "warn: git not found; skipping submodule update" >&2
    return
  fi

  if ! git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    echo "warn: $DOTFILES_DIR is not a git repository; skipping submodule update" >&2
    return
  fi

  printf 'submodule: sync and update\n'
  run git -C "$DOTFILES_DIR" submodule sync --recursive
  run git -C "$DOTFILES_DIR" submodule update --init --recursive
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

  if [ -L "$target" ]; then
    # A symlink holds no content of its own, so replacing one loses nothing.
    if [ "$(readlink "$target")" = "$source" ]; then
      printf 'skip: %s already links to %s\n' "$target" "$source"
      return
    fi

    printf 'relink: %s (was -> %s)\n' "$target" "$(readlink "$target")"
    run rm "$target"
  elif [ -e "$target" ]; then
    # A real file or directory may hold local edits; only -f may move it aside.
    if [ "$FORCE" -eq 0 ]; then
      printf 'skip: %s exists and is not a symlink; rerun with -f to back it up\n' "$target"
      return
    fi

    printf 'backup: %s -> %s\n' "$target" "$BACKUP_DIR/$(basename "$target")"
    backup_path "$target"
  fi

  printf 'link: %s -> %s\n' "$target" "$source"
  run ln -s "$source" "$target"
}

case "$STARSHIP_PROFILE" in
  mercury|venus|earth|mars|jupiter|saturn|uranus|neptune|pruto) ;;
  *)
    echo "error: unknown starship profile: $STARSHIP_PROFILE" >&2
    echo "available profiles: mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pruto" >&2
    exit 1
    ;;
esac

update_submodules

link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/alias" "$HOME/.alias"
link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/tmux.conf.d/$STARSHIP_PROFILE.conf" "$HOME/.tmux.theme.conf"
link_file "$DOTFILES_DIR/starship.conf/$STARSHIP_PROFILE.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/scripts/imgcat" "$HOME/.local/bin/imgcat"

printf 'done\n'
