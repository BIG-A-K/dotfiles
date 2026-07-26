#!/usr/bin/env bash
#
# starship.conf/*.toml のカラーテーマを、実際に適用せずに一覧でプレビューする。
#
# プロンプトの描画は starship 自身に任せているため（STARSHIP_CONFIG を差し替えて
# `starship prompt` を呼ぶ）、ここに出る見た目は install.sh で適用した後の
# 見た目と完全に一致する。tmux のステータスバーだけは実物を起動できないので、
# tmux.conf.d/<name>.conf から色を読み出して同じ構造で組み立てている。

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STARSHIP_DIR="$DOTFILES_DIR/starship.conf"
TMUX_THEME_DIR="$DOTFILES_DIR/tmux.conf.d"

# 太陽系の順。install.sh の --starship が受け付ける名前と揃えている
PROFILES=(mercury venus earth mars jupiter saturn uranus neptune pruto)

SAMPLE_PATH="$DOTFILES_DIR"
SHOW_TMUX=1
SELECTED=()

usage() {
  cat <<'USAGE'
Usage: scripts/starship-list.sh [options] [PROFILE...]

starshipのカラーテーマを適用せずに一覧プレビューする。
PROFILE を指定するとそのテーマだけを表示する。

Options:
  -s, --starship-only  starshipのプロンプトのみ表示（tmuxのバーを省く）
  -p, --path DIR       プロンプトに表示するサンプルパス (default: dotfilesのルート)
  -h, --help           このヘルプを表示

Examples:
  scripts/starship-list.sh              # 全テーマを一覧表示
  scripts/starship-list.sh jupiter      # jupiterだけ表示
  scripts/starship-list.sh -s -p ~/src  # ~/src を使いプロンプトのみ表示
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -s|--starship-only) SHOW_TMUX=0; shift ;;
    -p|--path)
      if [ "$#" -lt 2 ]; then
        echo "error: --path requires a directory" >&2
        exit 1
      fi
      SAMPLE_PATH="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1 ;;
    *)
      SELECTED+=("$1"); shift ;;
  esac
done

if ! command -v starship >/dev/null 2>&1; then
  echo "error: starship not found in PATH" >&2
  exit 1
fi

# 指定されたプロファイル名を検証する
if [ "${#SELECTED[@]}" -gt 0 ]; then
  for want in "${SELECTED[@]}"; do
    if [ ! -f "$STARSHIP_DIR/$want.toml" ]; then
      echo "error: unknown starship profile: $want" >&2
      echo "available profiles: ${PROFILES[*]}" >&2
      exit 1
    fi
  done
  PROFILES=("${SELECTED[@]}")
fi

# --- 色のユーティリティ ----------------------------------------------------

# "#RRGGBB" -> "R;G;B"
rgb() {
  local h="${1#\#}"
  printf '%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}
fg() { printf '\033[38;2;%sm' "$(rgb "$1")"; }
bg() { printf '\033[48;2;%sm' "$(rgb "$1")"; }
rst() { printf '\033[0m'; }

# powerlineの区切り。PUA文字なのでUTF-8のバイト列で直接指定する
SEP_R=$(printf '\356\202\260')  # U+E0B0 右向き
SEP_L=$(printf '\356\202\262')  # U+E0B2 左向き

# --- starship プロンプトの描画 ---------------------------------------------

# starship本体に描かせるので、実際に適用したときと同じ出力になる。
# STARSHIP_SHELL を空にすると zsh の %{...%} 等で包まずに生のANSIを吐く。
render_starship() {
  local toml="$1"
  STARSHIP_SHELL= STARSHIP_CONFIG="$toml" \
    starship prompt --path "$SAMPLE_PATH" --logical-path "$SAMPLE_PATH" \
                    --status 0 --terminal-width "$WIDTH" 2>/dev/null \
    | sed -e '/./,$!d' -e 's/^/  /'
}

# --- tmux ステータスバーの描画 ---------------------------------------------

# tmux.conf.d/<name>.conf から `set -g <option> "<value>"` の値を取り出す
tmux_opt() {
  grep -E "^set(w)? -g $2 " "$1" 2>/dev/null | head -1 | sed -E 's/^[^"]*"//; s/"$//' || true
}
style_fg() { printf '%s' "$1" | grep -oE 'fg=#[0-9A-Fa-f]{6}' | head -1 | cut -d= -f2 || true; }
style_bg() { printf '%s' "$1" | grep -oE 'bg=#[0-9A-Fa-f]{6}' | head -1 | cut -d= -f2 || true; }

# テーマ定義から色を読み、tmux.conf.d/*.conf と同じ組み立てでバーを再現する
render_tmux_bar() {
  local conf="$1"
  local bar text accent accent_fg dir dir_fg git muted

  bar=$(style_bg "$(tmux_opt "$conf" status-style)")
  text=$(style_fg "$(tmux_opt "$conf" status-style)")
  accent=$(style_bg "$(tmux_opt "$conf" message-style)")
  accent_fg=$(style_fg "$(tmux_opt "$conf" message-style)")
  dir=$(style_bg "$(tmux_opt "$conf" mode-style)")
  dir_fg=$(style_fg "$(tmux_opt "$conf" mode-style)")
  git=$(style_bg "$(tmux_opt "$conf" message-command-style)")
  muted=$(tmux_opt "$conf" display-panes-colour)

  # どれか欠けていたら諦める（テーマ側の書式が変わった場合）
  for c in "$bar" "$text" "$accent" "$accent_fg" "$dir" "$dir_fg" "$git" "$muted"; do
    [ -n "$c" ] || { printf '  (tmux theme not previewable: %s)\n' "$(basename "$conf")"; return; }
  done

  # 表示文字列（幅計算のため素のテキストを先に決める）
  local s_left w_inact w_act w_last s_host s_time
  s_left=" demo "
  w_inact=" 0:zsh "
  w_act=" 1:edit "
  w_last=" 2:logs "
  s_host=" $(hostname -s 2>/dev/null || echo host):$(whoami) "
  # 曜日はロケールによって全角になり（ja_JPなら「日」）幅計算が1桁ずれるため、
  # プレビュー用の日付は LC_TIME=C に固定して常にASCIIで出す
  s_time=" $(LC_TIME=C date '+%Y-%m-%d(%a) %H:%M') "

  # 区切りグリフ5個とインデント2桁を含めた可視幅から余白を逆算する
  local used=$(( ${#s_left} + 1 + ${#w_inact} + 1 + ${#w_act} + 1 + ${#w_last} \
                 + 1 + ${#s_host} + 1 + ${#s_time} + 2 ))
  local pad=$(( WIDTH - used ))
  [ "$pad" -lt 0 ] && pad=0

  {
    printf '  '
    # 左: セッション名バッジ
    bg "$accent"; fg "$accent_fg"; printf '\033[1m%s\033[22m' "$s_left"
    bg "$bar"; fg "$accent"; printf '%s' "$SEP_R"
    # ウィンドウ一覧（アクティブは1つ目のみ浮かせる）
    bg "$bar"; fg "$muted"; printf '%s' "$w_inact"
    fg "$dir"; printf '%s' "$SEP_L"
    bg "$dir"; fg "$dir_fg"; printf '\033[1m%s\033[22m' "$w_act"
    bg "$bar"; fg "$dir"; printf '%s' "$SEP_R"
    bg "$bar"; fg "$muted"; printf '%s' "$w_last"
    # 余白
    bg "$bar"; printf '%*s' "$pad" ''
    # 右: ホスト名 + 日時
    fg "$git"; printf '%s' "$SEP_L"
    bg "$git"; fg "$text"; printf '%s' "$s_host"
    fg "$accent"; printf '%s' "$SEP_L"
    bg "$accent"; fg "$accent_fg"; printf '\033[1m%s\033[22m' "$s_time"
    rst; printf '\n'
  }
}

# --- 出力 ------------------------------------------------------------------

WIDTH=$( { tput cols 2>/dev/null || echo 100; } )
[ "$WIDTH" -gt 100 ] && WIDTH=100
[ "$WIDTH" -lt 60 ] && WIDTH=60

# いま ~/.config/starship.toml がどのプロファイルを指しているか
CURRENT=""
link=$(readlink "$HOME/.config/starship.toml" 2>/dev/null || true)
[ -n "$link" ] && CURRENT="$(basename "$link" .toml)"

# tmux 側が別プロファイルを指していたら後で知らせる
CURRENT_TMUX=""
tlink=$(readlink "$HOME/.tmux.theme.conf" 2>/dev/null || true)
[ -n "$tlink" ] && CURRENT_TMUX="$(basename "$tlink" .conf)"

case "${COLORTERM:-}" in
  truecolor|24bit) ;;
  *) printf 'note: COLORTERM が truecolor ではないため、色が近似される場合があります\n\n' ;;
esac

for name in "${PROFILES[@]}"; do
  toml="$STARSHIP_DIR/$name.toml"
  [ -f "$toml" ] || continue

  # 見出し
  marker=""
  [ "$name" = "$CURRENT" ] && marker="  \033[1;32m← current\033[0m"
  printf '\033[1m%s\033[0m%b\n' "$name" "$marker"
  printf '\033[2m%*s\033[0m\n' "$WIDTH" '' | tr ' ' '-'

  render_starship "$toml"

  if [ "$SHOW_TMUX" -eq 1 ] && [ -f "$TMUX_THEME_DIR/$name.conf" ]; then
    printf '\n'
    render_tmux_bar "$TMUX_THEME_DIR/$name.conf"
  fi
  printf '\n'
done

printf '\033[2m適用: ./install.sh --starship <name>\033[0m\n'
if [ -n "$CURRENT_TMUX" ] && [ "$CURRENT_TMUX" != "$CURRENT" ]; then
  printf '\033[33mwarn: starship=%s に対して tmux=%s がリンクされています\033[0m\n' \
    "${CURRENT:-none}" "$CURRENT_TMUX"
fi
