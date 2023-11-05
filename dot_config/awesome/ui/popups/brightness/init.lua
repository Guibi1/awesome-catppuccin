---@diagnostic disable: undefined-global
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")


-- Header
local osd_header = wibox.widget({
	text = "Brightness",
	font = beautiful.font_name .. "Bold 12",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Test
local osd_value = wibox.widget({
	text = "0%",
	font = beautiful.font_name .. "Bold 12",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Slider
local slider = wibox.widget.slider {
	bar_shape = gears.shape.rounded_rect,
	bar_height = dpi(12),
	bar_color = beautiful.xcolorS0,
	bar_active_color = beautiful.xcolor2,
	handle_color = beautiful.xcolor2,
	handle_shape = gears.shape.circle,
	handle_width = dpi(24),
	handle_border_color = "#00000012",
	handle_border_width = dpi(1),
	maximum = 100,
}


-- Data
local last_bright_update = 0
awesome.connect_signal("signal::brightness", function(brightness)
	last_bright_update = brightness
	slider:set_value(brightness)
	osd_value.text = brightness .. "%"
end)

slider:connect_signal("property::value", function(_, new_brightness)
	if new_brightness ~= last_bright_update then
		awesome.emit_signal("brightness::set", new_brightness)
	end
end)


-- Mouse
helpers.ui.add_hover_cursor(slider, "hand1")
slider:buttons(gears.table.join(
	awful.button({}, 4, nil, function()
		if slider:get_value() > 100 then
			slider:set_value(100)
			return
		end
		slider:set_value(slider:get_value() + 5)
	end),
	awful.button({}, 5, nil, function()
		if slider:get_value() < 0 then
			slider:set_value(0)
			return
		end
		slider:set_value(slider:get_value() - 5)
	end)
))


-- Animation
local timer_hide_popup = gears.timer({
	timeout = 1,
	autostart = false,
	callback = function()
		awful.screen.focused().brightness_popup.visible = false
	end,
})

local function start_timer_hide_popup()
	if timer_hide_popup.started then
		timer_hide_popup:again()
	else
		timer_hide_popup:start()
	end
end

local function stop_timer_hide_popup()
	if timer_hide_popup.started then
		timer_hide_popup:stop()
	end
end


-- Widget
local brightness_osd_height = dpi(125)
local brightness_osd_width = dpi(250)

screen.connect_signal("request::desktop_decoration", function(s)
	s.brightness_popup = awful.popup({
		type                = "notification",
		screen              = s,
		shape               = helpers.ui.rrect(15),
		height              = brightness_osd_height,
		width               = brightness_osd_width,
		maximum_height      = brightness_osd_height,
		maximum_width       = brightness_osd_width,
		bg                  = beautiful.transparent,
		offset              = dpi(5),
		border_width        = dpi(3),
		border_color        = beautiful.xcolorS0,
		ontop               = true,
		visible             = false,
		preferred_anchors   = "bottom+middle",
		preferred_positions = { "left", "right", "top", "bottom" },
		widget              = {
			{
				{
					{
						osd_header,
						nil,
						osd_value,
						expand = "none",
						layout = wibox.layout.align.horizontal,
					},
					slider,
					spacing = dpi(24),
					layout = wibox.layout.fixed.vertical,
				},
				left = dpi(24),
				right = dpi(24),
				top = dpi(24),
				bottom = dpi(24),
				widget = wibox.container.margin,
			},
			bg = beautiful.xcolorbase,
			widget = wibox.container.background,
		},
	})

	s.brightness_popup:connect_signal("mouse::enter", stop_timer_hide_popup)
	s.brightness_popup:connect_signal("mouse::leave", start_timer_hide_popup)
end)



-- Set the popup visibility
awesome.connect_signal("popup::brightness:visible", function(visible)
	local brightness_popup = awful.screen.focused().brightness_popup
	awful.placement.centered(brightness_popup)

	if brightness_popup.visible ~= visible then
		brightness_popup.visible = visible

		if visible then
			start_timer_hide_popup()
			awesome.emit_signal("popup::volume:visible", false)
		else
			stop_timer_hide_popup()
		end
	end
end)
