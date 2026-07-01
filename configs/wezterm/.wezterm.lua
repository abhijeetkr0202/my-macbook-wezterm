local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.max_fps = 120

config.font = wezterm.font("MesloLGS Nerd Font Mono")

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.inactive_pane_hsb = {
	saturation = 0.0,
	brightness = 0.5,
}



config.window_background_opacity = 0.8
config.macos_window_background_blur = 10
config.font_size = 15.0
config.window_frame = {
	font_size = 13.0,
}

local maximize_window = wezterm.action_callback(function(window, pane)
	window:maximize()
end)

config.keys = {
    {
        key = "Enter",
        mods = "CMD",
        action = maximize_window,
    },
    {
        key = "d",
        mods = "CMD",
        action = wezterm.action.SplitHorizontal,
    },
    {
        key = "D",
        mods = "CMD|SHIFT",
        action = wezterm.action.SplitVertical,
    },
}

return config
