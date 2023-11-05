---@diagnostic disable: undefined-global
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

-- Icon
local icon = helpers.ui.create_icon("memory", beautiful.xcolor6)

-- Text
local mem = wibox.widget.textbox()
mem.font = beautiful.font_name .. "11"
mem.align = 'center'

-- Data
local function get_val()
	awesome.connect_signal("signal::mem", function(mem_perc)
		mem.markup = tonumber(mem_perc) .. "%"
	end)
end

get_val()

-- Widget
local widget = wibox.widget {
	{
		{
			icon,
			mem,
			spacing = dpi(8),
			layout = wibox.layout.fixed.horizontal,
		},
		left = 1,
		right = 0,
		layout = wibox.container.margin,
	},
	forced_width = 60,
	layout = wibox.layout.fixed.horizontal,
}

return widget
