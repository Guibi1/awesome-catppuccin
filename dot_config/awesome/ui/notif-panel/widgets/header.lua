---@diagnostic disable: undefined-global
local gears = require "gears"
local awful = require "awful"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Header
local title = wibox.widget {
    font = beautiful.font .. " Bold 20",
    markup = "Notifications",
    halign = "center",
    widget = wibox.widget.textbox,
}

-- Button
local button_clear_all = helpers.ui.create_icon("bell-slash", beautiful.xcolor10, 24)


-- Mouse
helpers.ui.add_hover_cursor(button_clear_all, "hand2")
button_clear_all:buttons(gears.table.join(awful.button({}, 1, function()
    awesome.emit_signal("notif-panel::clear")
end)))


-- Widget
return wibox.widget {
    {
        {
            nil,
            title,
            button_clear_all,
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        left = dpi(5),
        right = dpi(5),
        top = dpi(7),
        bottom = dpi(7),
        widget = wibox.container.margin,
    },
    shape = helpers.ui.rrect(8),
    bg = beautiful.xcolorS0,
    widget = wibox.container.background,
}
