#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
STARSHIP_PROFILE="earth"
STARSHIP_PROFILE_SET=0
DRY_RUN=0
FORCE=0
SKIP_SUBMODULES=0
SELECT_ALL=0
SELECTED=""

ALL_MODULES="zsh bash alias git vim tmux wezterm nvim starship scripts"

# 端末から実行されているときだけ対話できる
if [ -t 0 ] && [ -t 1 ]; then
  CAN_PROMPT=1
else
  CAN_PROMPT=0
fi

module_desc() {
  case "$1" in
    zsh)      echo '~/.zshrc (zsh-autosuggestions の submodule も更新)' ;;
    bash)     echo '~/.bashrc' ;;
    alias)    echo '~/.alias' ;;
    git)      echo '~/.gitconfig' ;;
    vim)      echo '~/.vimrc' ;;
    tmux)     echo '~/.tmux.conf, ~/.tmux.theme.conf (カラーテーマ)' ;;
    wezterm)  echo '~/.config/wezterm/wezterm.lua' ;;
    nvim)     echo '~/.config/nvim' ;;
    starship) echo '~/.config/starship.toml' ;;
    scripts)  echo '~/.local/bin/imgcat' ;;
    *)        echo '' ;;
  esac
}

# モジュールごとのリンク定義を "source<TAB>target" で出力する
module_links() {
  case "$1" in
    zsh)      printf '%s\t%s\n' "$DOTFILES_DIR/zshrc" "$HOME/.zshrc" ;;
    bash)     printf '%s\t%s\n' "$DOTFILES_DIR/bashrc" "$HOME/.bashrc" ;;
    alias)    printf '%s\t%s\n' "$DOTFILES_DIR/alias" "$HOME/.alias" ;;
    git)      printf '%s\t%s\n' "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig" ;;
    vim)      printf '%s\t%s\n' "$DOTFILES_DIR/vimrc" "$HOME/.vimrc" ;;
    tmux)
      printf '%s\t%s\n' "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
      printf '%s\t%s\n' "$DOTFILES_DIR/tmux.conf.d/$STARSHIP_PROFILE.conf" "$HOME/.tmux.theme.conf"
      ;;
    wezterm)  printf '%s\t%s\n' "$DOTFILES_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua" ;;
    nvim)     printf '%s\t%s\n' "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" ;;
    starship) printf '%s\t%s\n' "$DOTFILES_DIR/starship.conf/$STARSHIP_PROFILE.toml" "$HOME/.config/starship.toml" ;;
    scripts)  printf '%s\t%s\n' "$DOTFILES_DIR/scripts/imgcat" "$HOME/.local/bin/imgcat" ;;
  esac
}

is_module() {
  local m
  for m in $ALL_MODULES; do
    if [ "$m" = "$1" ]; then
      return 0
    fi
  done
  return 1
}

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options] [module...]

モジュールを指定するとその分だけを反映します。省略した場合、端末から実行していれば
対話メニューで選択、そうでなければ全モジュールを対象にします。

Options:
  -a, --all          対話メニューを出さずに全モジュールを対象にする
  -l, --list         モジュール一覧を表示して終了
      --starship NAME
                     Starship profile name: mercury, venus, earth, mars, jupiter,
                     saturn, uranus, neptune, pruto (default: earth)
                     対応する tmux カラーテーマ (tmux.conf.d/NAME.conf) も同時に張る
      --dry-run      ファイルを変更せず、実行内容だけ表示する
  -f, --force        既存のsymlinkを上書きし、既存の実ファイル/ディレクトリを退避する
      --skip-submodules
                     git submodule の sync/update を行わない
  -h, --help         このヘルプを表示

Examples:
  ./install.sh                  # 対話メニューで選択
  ./install.sh nvim tmux        # nvim と tmux だけ更新
  ./install.sh --all --force    # 全部を、既存ファイルを退避しつつ反映
USAGE
}

list_modules() {
  printf 'Modules:\n'
  local m
  for m in $ALL_MODULES; do
    printf '  %-9s %s\n' "$m" "$(module_desc "$m")"
  done
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --starship)
      if [ "$#" -lt 2 ]; then
        echo "error: --starship requires a profile name" >&2
        exit 1
      fi
      STARSHIP_PROFILE="$2"
      STARSHIP_PROFILE_SET=1
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
    -a|--all)
      SELECT_ALL=1
      shift
      ;;
    -l|--list)
      list_modules
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if ! is_module "$1"; then
        echo "error: unknown module: $1" >&2
        list_modules >&2
        exit 1
      fi
      SELECTED="$SELECTED $1"
      shift
      ;;
  esac
done

# `--` の後ろに残ったモジュール名
while [ "$#" -gt 0 ]; do
  if ! is_module "$1"; then
    echo "error: unknown module: $1" >&2
    list_modules >&2
    exit 1
  fi
  SELECTED="$SELECTED $1"
  shift
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

confirm() {
  local reply=""

  printf '%s [y/N]: ' "$1" >&2
  # 呼び出し元がstdinをリダイレクトしていても端末から読む
  IFS= read -r reply </dev/tty || reply=""
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

# 対話メニュー。結果は SELECTED に入る
prompt_modules() {
  local mods
  local sel
  local n
  local i
  local idx
  local reply
  local tok
  local mark

  mods=($ALL_MODULES)
  n=${#mods[@]}
  for ((i = 0; i < n; i++)); do
    sel[$i]=1
  done

  while true; do
    printf '\n== インストールするモジュールを選択 ==\n'
    for ((i = 0; i < n; i++)); do
      if [ "${sel[$i]}" -eq 1 ]; then mark="x"; else mark=" "; fi
      printf '  %2d) [%s] %-9s %s\n' "$((i + 1))" "$mark" "${mods[$i]}" "$(module_desc "${mods[$i]}")"
    done
    printf '\n番号でトグル (例: 1 3 5) / a=全選択 / n=全解除 / q=中止 / Enter=決定 > '

    reply=""
    IFS= read -r reply </dev/tty || reply="q"

    case "$reply" in
      "")
        break
        ;;
      a|A)
        for ((i = 0; i < n; i++)); do sel[$i]=1; done
        ;;
      n|N)
        for ((i = 0; i < n; i++)); do sel[$i]=0; done
        ;;
      q|Q)
        echo "中止しました" >&2
        exit 1
        ;;
      *)
        for tok in $reply; do
          case "$tok" in
            '' | *[!0-9]*)
              printf '  無視: %s\n' "$tok"
              continue
              ;;
          esac
          if [ "$tok" -ge 1 ] && [ "$tok" -le "$n" ]; then
            idx=$((tok - 1))
            if [ "${sel[$idx]}" -eq 1 ]; then sel[$idx]=0; else sel[$idx]=1; fi
          else
            printf '  範囲外: %s\n' "$tok"
          fi
        done
        ;;
    esac
  done

  SELECTED=""
  for ((i = 0; i < n; i++)); do
    if [ "${sel[$i]}" -eq 1 ]; then
      SELECTED="$SELECTED ${mods[$i]}"
    fi
  done
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
    # A real file or directory may hold local edits; move it aside only with
    # -f, or with an explicit yes when we can ask.
    if [ "$FORCE" -eq 0 ]; then
      if [ "$CAN_PROMPT" -eq 0 ] || [ "$DRY_RUN" -eq 1 ]; then
        printf 'skip: %s exists and is not a symlink; rerun with -f to back it up\n' "$target"
        return
      fi

      printf '\n%s は実ファイル/ディレクトリとして存在します。\n' "$target"
      if ! confirm "  $BACKUP_DIR へ退避してsymlinkに置き換えますか?"; then
        printf 'skip: %s (退避せず)\n' "$target"
        return
      fi
    fi

    printf 'backup: %s -> %s\n' "$target" "$BACKUP_DIR/$(basename "$target")"
    backup_path "$target"
  fi

  printf 'link: %s -> %s\n' "$target" "$source"
  run ln -s "$source" "$target"
}

install_module() {
  local module="$1"
  local source
  local target

  printf '\n--- %s ---\n' "$module"

  if [ "$module" = "zsh" ]; then
    update_submodules
  fi

  # module_links の出力はタブ区切りなので IFS をタブに固定して読む
  while IFS="$(printf '\t')" read -r source target; do
    [ -n "$source" ] || continue
    link_file "$source" "$target"
  done <<EOF
$(module_links "$module")
EOF
}

# --starship 未指定なら、いま張られているリンクからプロファイルを引き継ぐ。
# 一部のモジュールだけ入れ直したときに、テーマが既定値へ戻るのを防ぐ。
detect_starship_profile() {
  local link
  local name

  for link in "$HOME/.config/starship.toml" "$HOME/.tmux.theme.conf"; do
    [ -L "$link" ] || continue
    name="$(basename "$(readlink "$link")")"
    name="${name%.toml}"
    name="${name%.conf}"
    case "$name" in
      mercury|venus|earth|mars|jupiter|saturn|uranus|neptune|pruto)
        printf '%s\n' "$name"
        return
        ;;
    esac
  done
}

STARSHIP_PROFILE_NOTE=""
if [ "$STARSHIP_PROFILE_SET" -eq 0 ]; then
  detected="$(detect_starship_profile)"
  if [ -n "$detected" ]; then
    STARSHIP_PROFILE="$detected"
    STARSHIP_PROFILE_NOTE=" (既存のリンクから継承。変更するには --starship NAME)"
  fi
fi

case "$STARSHIP_PROFILE" in
  mercury|venus|earth|mars|jupiter|saturn|uranus|neptune|pruto) ;;
  *)
    echo "error: unknown starship profile: $STARSHIP_PROFILE" >&2
    echo "available profiles: mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pruto" >&2
    exit 1
    ;;
esac

if [ -n "$SELECTED" ]; then
  : # コマンドラインで指定済み
elif [ "$SELECT_ALL" -eq 1 ]; then
  SELECTED="$ALL_MODULES"
elif [ "$CAN_PROMPT" -eq 1 ]; then
  prompt_modules
else
  SELECTED="$ALL_MODULES"
fi

if [ -z "${SELECTED// /}" ]; then
  echo "対象モジュールがありません。何もしませんでした。"
  exit 0
fi

SELECTED="$(printf '%s' "$SELECTED" | tr -s ' ' | sed 's/^ //;s/ $//')"

printf '\ntarget modules: %s\n' "$SELECTED"
printf 'starship profile: %s%s\n' "$STARSHIP_PROFILE" "$STARSHIP_PROFILE_NOTE"

for module in $SELECTED; do
  install_module "$module"
done

printf '\ndone\n'
