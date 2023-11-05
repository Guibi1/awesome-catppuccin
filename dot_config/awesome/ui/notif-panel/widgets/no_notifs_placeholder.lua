---@diagnostic disable: undefined-global
local wibox = require "wibox"
local beautiful = require "beautiful"
local helpers = require "helpers"


-- Widget
local widget = wibox.widget {
    {
        markup = helpers.ui.colorize_text("No notifs", beautiful.xcolorT2),
        font = beautiful.font .. " Bold 17",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    },
    forced_height = 730,
    bg = beautiful.xcolorS0,
    shape = helpers.ui.rrect(8),
    widget = wibox.container.background,
}

return widget
