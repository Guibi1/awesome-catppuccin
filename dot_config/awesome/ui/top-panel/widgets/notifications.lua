---@diagnostic disable: undefined-global
local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"
local helpers = require "helpers"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Icon
local icon = helpers.ui.create_icon("bell", beautiful.xcolor5, 12)

local function set_normal()
    icon:set_color(beautiful.xcolor5)
    icon:set_icon("bell")
end


-- Data
local notif_count = 0
naughty.connect_signal("request::display", function()
    notif_count = notif_count + 1
    icon:set_color(beautiful.xcolor6)
    icon:set_icon("bell-exclamation")
end)

awesome.connect_signal("notif-panel::clear", function()
    notif_count = 0
    set_normal()
end)

awesome.connect_signal("notif-panel::remove", function()
    notif_count = notif_count - 1
    if notif_count == 0 then
        set_normal()
    end
end)


-- Widget
local widget = icon

-- Mouse
helpers.ui.add_hover_cursor(widget, "hand2")
widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        awesome.emit_signal("notif-panel::toggle")
    end)
))

return widget
