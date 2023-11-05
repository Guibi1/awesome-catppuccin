---@diagnostic disable: undefined-global
local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"
local beautiful = require "beautiful"
local helpers = require "helpers"
local dpi = beautiful.xresources.apply_dpi

-- Icon
local icon = helpers.ui.create_icon("bars", beautiful.xcolor5, 12)


-- Widget
local widget = icon

-- Mouse
helpers.ui.add_hover_cursor(widget, "hand2")
widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        awesome.emit_signal("info-panel::toggle")
    end)
))

return widget
