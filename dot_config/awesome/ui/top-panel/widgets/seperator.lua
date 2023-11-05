local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local seperator = wibox.widget {
    {
        forced_width = dpi(1),
        bg = beautiful.xcolorO1,
        widget = wibox.container.background
    },
    left = dpi(8),
    right = dpi(8),
    widget = wibox.container.margin
}

return seperator
