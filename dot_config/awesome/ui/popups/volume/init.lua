---@diagnostic disable: undefined-global
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local wibox = require("wibox")
local helpers = require("helpers")
local dpi = xresources.apply_dpi


-- Header
local osd_header = wibox.widget({
	text = "Volume",
	font = beautiful.font_name .. "Bold 12",
	align = "left",
	valign = "center",
	widget = wibox.widget.textbox,
})

-- Text
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
local last_vol_update = 0
awesome.connect_signal("signal::volume", function(vol, muted)
	last_vol_update = vol
	slider:set_value(vol)
	osd_value.text = vol .. "%"

	if muted then
		slider.bar_active_color = beautiful.xcolor10
		slider.handle_color = beautiful.xcolor10
	else
		slider.bar_active_color = beautiful.xcolor2
		slider.handle_color = beautiful.xcolor2
	end
end)

slider:connect_signal("property::value", function(_, new_vol)
	if new_vol ~= last_vol_update then
		awesome.emit_signal("volume::set", new_vol)
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
		awful.screen.focused().volume_popup.visible = false
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
local volume_osd_height = dpi(125)
local volume_osd_width = dpi(250)

screen.connect_signal("request::desktop_decoration", function(s)
	s.volume_popup = awful.popup({
		type                = "notification",
		screen              = s,
		shape               = helpers.ui.rrect(15),
		height              = volume_osd_height,
		width               = volume_osd_width,
		maximum_height      = volume_osd_height,
		maximum_width       = volume_osd_width,
		bg                  = beautiful.transparent,
		offset              = dpi(5),
		border_width        = dpi(3),
		border_color        = beautiful.xcolorS0,
		ontop               = true,
		visible             = false,
		preferred_anchors   = "middle",
		preferred_positions = { "left", "right", "top", "bottom" },
		widget              = {
			{
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(24),
					{
						layout = wibox.layout.align.horizontal,
						expand = "none",
						osd_header,
						nil,
						osd_value,
					},
					slider,

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

	s.volume_popup:connect_signal("mouse::enter", stop_timer_hide_popup)
	s.volume_popup:connect_signal("mouse::leave", start_timer_hide_popup)
end)


-- Set the popup visibility
awesome.connect_signal("popup::volume:visible", function(visible)
	local volume_popup = awful.screen.focused().volume_popup
	awful.placement.centered(volume_popup)
	volume_popup.visible = visible

	if volume_popup ~= visible then
		if visible then
			start_timer_hide_popup()
			awesome.emit_signal("popup::brightness:visible", false)
		else
			stop_timer_hide_popup()
		end
	end
end)
