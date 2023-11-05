---@diagnostic disable: undefined-global
local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"
local helpers = require "helpers"
local beautiful = require "beautiful"
local rubato = require "lib.rubato"
local dpi = beautiful.xresources.apply_dpi

local opened = 100
local closed = 2

-- Icon
local arrow = wibox.widget.textbox()
arrow.align = "center"
arrow.valign = "center"
arrow.font = beautiful.font_name .. "12"
arrow.markup = "󰄾"

-- Tray
local tray = wibox.widget({
    widget = wibox.container.constraint,
    strategy = "max",
    width = dpi(closed),
    {
        widget = wibox.container.margin,
        margins = dpi(3),
        wibox.widget.systray(),
    },
})


-- Animation
local tray_fixed = false
local animation = rubato.timed {
    rate = 60,
    duration = 0.2,
    easing = rubato.easing.linear,
    subscribed = function(width)
        tray.width = width
    end,
}


-- Widget
local widget = wibox.widget {
    arrow,
    tray,
    spacing = dpi(2),
    layout = wibox.layout.fixed.horizontal,
}


-- Mouse
arrow:buttons(gears.table.join(awful.button({}, 1,
    function()
        if tray_fixed == true then
            arrow.markup = "󰄾"
        else
            arrow.markup = "󰄽"
        end
        tray_fixed = not tray_fixed
    end
)))

helpers.ui.add_hover_cursor(widget, "hand2")
widget:connect_signal("mouse::enter", function()
    if tray_fixed == false then
        animation.target = opened
    end
end)
widget:connect_signal("mouse::leave", function()
    if tray_fixed == false then
        animation.target = closed
    end
end)


return widget
