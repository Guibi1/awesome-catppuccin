---@diagnostic disable: undefined-global
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi


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
  -- forced_width = dpi(220),
  widget = wibox.widget.slider,
}

-- Text
local osd_value = wibox.widget {
  text = "0%",
  font = beautiful.font_name .. "10",
  widget = wibox.widget.textbox(),
}

-- Icon
local icon = helpers.ui.create_icon("brightness", beautiful.xcolor2)


-- Data
local last_brightness_update = 0
awesome.connect_signal("signal::brightness", function(bright)
  last_brightness_update = bright
  slider:set_value(bright)
  osd_value.text = bright .. "%"
end)

slider:connect_signal("property::value", function(_, new_bright)
  if new_bright ~= last_brightness_update then
    awesome.emit_signal("brightness::set", new_bright)
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
