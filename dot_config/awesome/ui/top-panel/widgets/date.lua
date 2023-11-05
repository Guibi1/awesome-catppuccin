local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

-- Icon
local icon = helpers.ui.create_icon("calendar", beautiful.xcolor5)

-- Text
local date = wibox.widget.textbox()
date.font = beautiful.font_name .. "11"
date.align = 'center'

-- Data
gears.timer {
	timeout = 60,
	autostart = true,
	call_now = true,
	callback = function()
		date.markup = os.date("%a %b %d")
	end
}

-- Widget
local widget = wibox.widget {
	{
		{
			icon,
			date,
			spacing = dpi(8),
			layout = wibox.layout.fixed.horizontal,
		},
		left = 1,
		right = 1,
		layout = wibox.container.margin,
	},
	layout = wibox.layout.fixed.horizontal,
}

return widget
