local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Icon
local icon = helpers.ui.create_icon("clock", beautiful.xcolor12)

-- Text
local clock = wibox.widget.textbox()
clock.font = beautiful.font_name .. "11"
clock.align = 'center'

-- Data
gears.timer {
	timeout = 60,
	autostart = true,
	call_now = true,
	callback = function()
		clock.markup = os.date("%H:%M")
	end
}

-- Widget
local widget = wibox.widget {
	{
		{
			icon,
			clock,
			spacing = dpi(2),
			layout = wibox.layout.fixed.horizontal,
		},
		left = 1,
		right = 1,
		layout = wibox.container.margin,
	},
	layout = wibox.layout.fixed.horizontal,
}

return widget
