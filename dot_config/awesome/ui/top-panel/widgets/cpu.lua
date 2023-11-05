---@diagnostic disable: undefined-global
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Icon
local icon = helpers.ui.create_icon("microchip", beautiful.xcolor9)

-- Text
local cpu  = wibox.widget.textbox()
cpu.font   = beautiful.font_name .. "11"
cpu.align  = 'center'

-- Data
awesome.connect_signal("signal::cpu", function(cpu_perc)
	cpu.markup = cpu_perc .. "%"
end)

-- Widget
local widget = wibox.widget {
	{
		{
			icon,
			cpu,
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
