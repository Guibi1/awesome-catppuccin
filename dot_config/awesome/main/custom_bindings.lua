---@diagnostic disable: undefined-global
local awful = require "awful"
local filesystem = require "gears.filesystem"

local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

ModKey = "Mod4"
AltKey = "Mod1"


local screenshot_area = utils_dir .. "screensht area"
local screenshot_full = utils_dir .. "screensht full"


awful.keyboard.append_global_keybindings({
	awful.key({ AltKey }, "Tab", function() awesome.emit_signal("bling::window_switcher::turn_on") end,
		{ description = "Window Switcher", group = "bling" }
	),
	awful.key({ ModKey }, "Print", function() awful.spawn.easy_async_with_shell(screenshot_area, function() end) end,
		{ description = "take a area screenshot", group = "Utils" }
	),
	awful.key({}, "Print", function() awful.spawn.easy_async_with_shell(screenshot_full, function() end) end,
		{ description = "take a full screenshot", group = "Utils" }
	),
	awful.key({ ModKey }, "q", function() awesome.emit_signal("module::exit_screen:show") end,
		{ description = "show Exit Screen", group = "Utils" }
	),
	awful.key({ ModKey }, "s", function() awesome.emit_signal("scratchpad::toggle") end,
		{ description = "show Scratchpad", group = "Utils" }
	),
	awful.key({ ModKey }, "t", function() awful.titlebar.toggle(client.focus) end,
		{ description = "toggle titlebar for active client", group = "Utils" }
	),
	awful.key({ ModKey }, "l", function() awesome.emit_signal("lockscreen::show") end,
		{ description = "lock the screen", group = "Utils" }
	),
})

-- Launch app
awful.keyboard.append_global_keybindings({
	-- Rofi
	awful.key({ ModKey }, "r", function() awful.spawn("rofi -show drun -theme ~/.config/rofi/launcher.rasi") end,
		{ description = "open app launcher", group = "launcher" }
	),
	-- Thunar
	awful.key({ ModKey }, "e", function() awful.spawn("thunar") end,
		{ description = "open file explorer", group = "launcher" }
	),
	-- Brave
	awful.key({ ModKey }, "b", function() awful.spawn("brave") end,
		{ description = "open browser", group = "launcher" }
	),
	-- Code
	awful.key({ ModKey }, "v", function() awful.spawn("code") end,
		{ description = "open vs code", group = "launcher" }
	),
	-- Mailspring
	awful.key({ ModKey }, "c", function() awful.spawn("mailspring") end,
		{ description = "open mail", group = "launcher" }
	),
	awful.key({ ModKey }, "o", function()
			awesome.emit_signal("info-panel::toggle")
			awesome.emit_signal("notif-panel::toggle")
		end,
		{ description = "open mail", group = "launcher" }
	),
})

-- Volume
awful.keyboard.append_global_keybindings({
	awful.key({}, "XF86AudioRaiseVolume", function()
		awesome.emit_signal("volume::increase")
		awesome.emit_signal("popup::volume:visible", true)
	end),
	awful.key({}, "XF86AudioLowerVolume", function()
		awesome.emit_signal("volume::decrease")
		awesome.emit_signal("popup::volume:visible", true)
	end),
	awful.key({}, "XF86AudioMute",
		function()
			awesome.emit_signal("volume::mute")
			awesome.emit_signal("popup::volume:visible", true)
		end)
})

-- Brightness
awful.keyboard.append_global_keybindings({
	awful.key({}, "XF86MonBrightnessUp", function()
		awesome.emit_signal("brightness::increase")
		awesome.emit_signal("popup::brightness:visible", true)
	end),
	awful.key({}, "XF86MonBrightnessDown", function()
		awesome.emit_signal("brightness::decrease")
		awesome.emit_signal("popup::brightness:visible", true)
	end)
})
