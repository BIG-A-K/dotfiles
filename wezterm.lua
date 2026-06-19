local wezterm = require 'wezterm'

-- 起動時にウィンドウを最大化する
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

local config = wezterm.config_builder()

config.audible_bell = 'Disabled'

config.window_decorations = 'RESIZE|TITLE'
config.scrollback_lines = 7000
config.use_ime = true
config.hide_tab_bar_if_only_one_tab = true
-- タブを等幅で並べてウィンドウ幅いっぱいに広げるため、
-- テキストベースの retro タブバーを使う（fancy だと幅制御ができない）
config.use_fancy_tab_bar = false
-- タブ幅の上限を実質撤廃（実際の幅は format-tab-title で計算する）
config.tab_max_width = 999
config.tab_bar_at_bottom = false
config.native_macos_fullscreen_mode = false
-- ウィンドウ背景を半透明にして、背面の壁紙やウィンドウが透けて見えるようにする
--config.window_background_opacity = 0.8
-- macOS でウィンドウ背景のブラー効果を有効にする（値が大きいほどブラーが強くなる）
config.macos_window_background_blur = 5

config.colors = {
  cursor_bg = '#FFFFFF',
  cursor_fg = '#102134',
  cursor_border = '#FFFFFF',
  tab_bar = {
    background = '#0b1521',
    new_tab = { bg_color = '#102134', fg_color = '#FFFFFF' },
    new_tab_hover = { bg_color = '#896f3d', fg_color = '#FFFFFF' },
  },
}

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'ayu'
  end
  return 'neobones_light'
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

config.keys = {
  -- Cmd+D で垂直分割（左右に並べる）
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Cmd+Shift+D で水平分割（上下に並べる）
  {
    key = 'D',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'F',
    mods = 'CMD|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- 現在のウィンドウ幅（文字数）。タブ幅の計算に使う。
-- format-tab-title はウィンドウ幅を直接知れないため、update-status 側で
-- 取得した値をここに保持しておく。初期値はフォールバック。
local window_cols = 120

-- ステータス更新のたびにウィンドウ幅（カラム数）を記録する。
-- pane:get_dimensions() は分割時にアクティブペイン側の幅しか返さないため、
-- タブ内の全ペインの右端の最大値からウィンドウ全体の幅を求める。
wezterm.on('update-status', function(window, pane)
  local tab = window:active_tab()
  if not tab then return end
  local max_right = 0
  for _, p in ipairs(tab:panes_with_info()) do
    local right = p.left + p.width
    if right > max_right then max_right = right end
  end
  if max_right > 0 then
    window_cols = max_right
  end
end)

-- タブのタイトルを描画する。
-- ウィンドウ幅をタブ数で等分し、各タブを同じ幅で中央寄せ表示することで
-- タブが増えるほど 1/2, 1/3 … と縮みつつ幅いっぱいに広がるようにする。
wezterm.on('format-tab-title', function(tab, tabs, _, _, _, _)
  -- アクティブなタブだけ背景色を変える
  local background = '#102134'
  local foreground = '#FFFFFF'
  if tab.is_active then
    background = '#896f3d'
  end

  -- 表示テキスト（カレントディレクトリ名などのペインタイトル）
  local display = tab.active_pane.title

  -- ウィンドウ幅をタブ数で割って 1 タブあたりの幅を決める
  local tab_width = math.floor(window_cols / #tabs)
  -- 左右に最低 1 文字ずつ余白を確保しつつ、テキストの最大長を決める
  local text_max = tab_width - 2
  if text_max < 4 then text_max = 4 end

  -- 幅をはみ出す場合は右側を切り詰める
  local truncated = wezterm.truncate_right(display, text_max)
  -- タブ幅とテキスト幅の差を左右の余白に振り分けて中央寄せにする
  -- （column_width は全角文字も考慮した表示幅を返す）
  local padding = tab_width - wezterm.column_width(truncated)
  local left_pad = math.floor(padding / 2)
  local right_pad = padding - left_pad
  if left_pad < 0 then left_pad = 0 end
  if right_pad < 0 then right_pad = 0 end

  local title = string.rep(' ', left_pad) .. truncated .. string.rep(' ', right_pad)
  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

config.font_size = 12.0
config.font = wezterm.font("HackGen Console NF")

--config.font = wezterm.font('JetBrainsMono Nerd Font')

return config
