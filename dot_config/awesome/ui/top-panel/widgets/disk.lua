---@diagnostic disable: undefined-global
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

-- Icon
local icon = helpers.ui.create_icon("hard-drive", beautiful.xcolor7)

-- Text
local disk = wibox.widget.textbox()
disk.font = beautiful.font_name .. "11"
disk.align = 'center'

-- Data
awesome.connect_signal("signal::disk", function(disk_perc)
	disk.markup = tonumber(disk_perc) .. "%"
end)

-- Widget
local widget = wibox.widget {
	{
		{
			icon,
			disk,
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
