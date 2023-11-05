---@diagnostic disable: undefined-global
local awful     = require "awful"
local gears     = require "gears"
local wibox     = require "wibox"
local helpers   = require "helpers"
local rubato    = require "lib.rubato"
local beautiful = require "beautiful"
local naughty   = require "naughty"
local dpi       = beautiful.xresources.apply_dpi


local text_widget = wibox.widget.textbox()
text_widget.text = "test test"
text_widget.font = beautiful.font_name .. "11"

-- Widget
local info_panel = wibox {
    visible = false,
    ontop = true,
    width = dpi(410),
    height = awful.screen.focused().geometry.height - dpi(100),
    y = dpi(60),
    bg = beautiful.bg_normal,
    border_width = dpi(3),
    border_color = beautiful.xcolor5,
    shape = helpers.ui.rrect(14),
    widget = {
        {
            require "ui.info-panel.widgets.profile",
            require "ui.info-panel.widgets.music-player",
            require "ui.info-panel.widgets.weather",
            -- require "ui.info-panel.widgets.calendar",
            require "ui.info-panel.widgets.wifi",
            spacing = dpi(20),
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
    }
}

-- Animation
local target_closed = dpi(-40) - info_panel.width
local target_opened = dpi(40)
local animation = rubato.timed {
    pos = target_closed,
    rate = 60,
    intro = 0.15,
    duration = 0.3,
    subscribed = function(pos)
        info_panel.x = pos
    end
}


-- Timer of panel's death
-- (required so that the panel finishes the animation before being invisible)
info_panel.visibility_timer = gears.timer {
    timeout = 0.4,
    single_shot = true,
    callback = function()
        info_panel.visible = false
    end
}

-- Toggle visibility
local panel_open = false
awesome.connect_signal("info-panel::toggle", function()
    if panel_open then
        animation.target = target_closed
        info_panel.visibility_timer:start()
    else
        info_panel.visible = true
        animation.target = target_opened
        info_panel.visibility_timer:stop()
    end
    panel_open = not panel_open
end)
