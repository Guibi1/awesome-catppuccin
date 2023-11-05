---@diagnostic disable: undefined-global
local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local gears = require "gears"
local helpers = require "helpers"
local dpi = beautiful.xresources.apply_dpi

-- Icon
local icon = helpers.ui.create_icon("keyboard", beautiful.xcolor4)

-- Text
local keyboard = wibox.widget.textbox()
keyboard.font = beautiful.font_name .. "11"
keyboard.align = 'center'


-- Data
awesome.connect_signal("signal::keyboard",
    function(layout)
        keyboard.markup = layout
    end
)

-- Widget
local widget = wibox.widget {
    {
        {
            icon,
            keyboard,
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        left = 1,
        right = 0,
        layout = wibox.container.margin,
    },
    forced_width = 45,
    layout = wibox.layout.fixed.horizontal,
}

-- Mouse
helpers.ui.add_hover_cursor(widget, "hand2")
widget:buttons(
    gears.table.join(awful.button({}, 1,
        function()
            awesome.emit_signal("keyboard::toggle")
        end
    ))
)

return widget
