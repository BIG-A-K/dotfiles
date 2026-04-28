local wezterm = require 'wezterm'

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
config.show_new_tab_button_in_tab_bar = true
config.show_close_tab_button_in_tabs = true
config.native_macos_fullscreen_mode = false

config.colors = {
  cursor_bg = '#FFFFFF',
  cursor_fg = '#102134',
  cursor_border = '#FFFFFF',
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

wezterm.on('format-tab-title', function(tab, _, _, _, _, max_width)
  local background = '#102134'
  local foreground = '#FFFFFF'
  if tab.is_active then
    background = '#896f3d'
  end

  local title = '   ' .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. '   '
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
