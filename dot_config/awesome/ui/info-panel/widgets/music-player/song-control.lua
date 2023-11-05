local awful = require "awful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local playerctl = require "signals.playerctl"
local dpi = beautiful.xresources.apply_dpi


-- Icons
local back = helpers.ui.create_icon("backward", beautiful.xcolorT2, 24)
local play = helpers.ui.create_icon("play", beautiful.xcolor2, 32)
local next = helpers.ui.create_icon("forward", beautiful.xcolorT2, 24)

-- Slider
local time_slider = wibox.widget {
    bar_shape = helpers.ui.rrect(9),
    bar_height = dpi(6),
    bar_color = beautiful.xcolorbase,
    bar_active_color = beautiful.xcolor2,
    handle_shape = gears.shape.circle,
    handle_color = beautiful.xcolor2,
    handle_width = dpi(12),
    minimum = 0,
    maximum = 1,
    value = 0,
    widget = wibox.widget.slider,
}

-- Data
playerctl:connect_signal("playback_status", function(_, playing)
    if playing then
        play:set_icon("play")
    else
        play:set_icon("pause")
    end
end)

local last_pos_update = 0
playerctl:connect_signal("position", function(_, current, length)
    if length == 0 then
        length = 1
    end

    last_pos_update = current
    time_slider:set_maximum(length)
    time_slider:set_value(current)
end)

time_slider:connect_signal("property::value", function(_, new_pos)
    if new_pos ~= last_pos_update then
        playerctl:set_position(new_pos)
    end
end)


-- Mouse
play:buttons(gears.table.join(
    awful.button({}, 1, function() playerctl:play_pause() end)
))
next:buttons(gears.table.join(
    awful.button({}, 1, function() playerctl:next() end)
))
back:buttons(gears.table.join(
    awful.button({}, 1, function() playerctl:previous() end)
))


-- Widget
local widget = wibox.widget {
    {
        nil,
        {
            back,
            play,
            next,
            spacing = dpi(25),
            layout = wibox.layout.fixed.horizontal,
        },
        expand = "outside",
        layout = wibox.layout.align.horizontal,
    },
    time_slider,
    layout = wibox.layout.fixed.vertical,
}

return widget
