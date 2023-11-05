---@diagnostic disable: undefined-global
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi

local icon_normal = "volume"
local icon_low = "volume-low"
local icon_muted = "volume-xmark"
local color_normal = beautiful.xcolor2
local color_muted = beautiful.xcolor12

-- Slider
local slider = wibox.widget {
  bar_shape = helpers.ui.rrect(9),
  bar_height = 6,
  bar_color = beautiful.xcolorbase,
  bar_active_color = beautiful.xcolor2,
  handle_shape = gears.shape.circle,
  handle_color = beautiful.xcolor2,
  handle_width = 12,
  value = 75,
  forced_width = dpi(220),
  widget = wibox.widget.slider,
}

-- Text
local osd_value = wibox.widget {
  text = "0%",
  font = beautiful.font_name .. "10",
  widget = wibox.widget.textbox(),
}

-- Icon
local icon = helpers.ui.create_icon(icon_normal, color_normal)


-- Data
local last_vol_update = 0
awesome.connect_signal("signal::volume", function(vol, muted)
  last_vol_update = vol
  slider:set_value(vol)
  osd_value.text = vol .. "%"

  if muted then
    icon:set_icon(icon_muted)
    icon:set_color(color_muted)
  elseif vol < 30 then
    icon:set_icon(icon_low)
    icon:set_color(color_normal)
  else
    icon:set_icon(icon_normal)
    icon:set_color(color_normal)
  end
end)

slider:connect_signal("property::value", function(_, new_vol)
  if new_vol ~= last_vol_update then
    awesome.emit_signal("volume::set", new_vol)
  end
end)


-- Mouse
helpers.ui.add_hover_cursor(icon, "hand2")
icon:buttons(gears.table.join(
  awful.button({}, 1, function()
    awesome.emit_signal("volume::mute")
  end)
))

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

-- Widget
local widget = wibox.widget {
  icon,
  {
    slider,
    left = dpi(8),
    right = dpi(8),
    top = 0,
    bottom = 0,
    layout = wibox.container.margin
  },
  osd_value,
  layout = wibox.layout.align.horizontal,
}

return widget
