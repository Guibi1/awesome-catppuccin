---@diagnostic disable: undefined-global
local awful = require "awful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local create_network_button = require "ui.info-panel.widgets.wifi.network_factory"
local dpi = beautiful.xresources.apply_dpi


-- Refresh wifi list button
local rescan = wibox.widget {
    {
        helpers.ui.create_icon("rotate", beautiful.xcolor10, 32),
        margins = dpi(16),
        widget = wibox.container.margin,
    },
    bg = beautiful.xcolorS1,
    shape = helpers.ui.rrect(8),
    widget = wibox.container.background,
}

-- SSIDs list
local networks_container = wibox.widget {
    spacing = dpi(4),
    layout = require("scroll_area"),
}

-- Power button
local toggle = wibox.widget {
    {
        helpers.ui.create_icon("power-off", beautiful.xcolor10, 32),
        margins = dpi(16),
        widget = wibox.container.margin,
    },
    bg = beautiful.xcolorS1,
    shape = helpers.ui.rrect(8),
    widget = wibox.container.background,
}


-- Data
awesome.connect_signal("wifi::enabled", function(enabled)
    if not enabled then
        networks_container:reset()
    end
end)

awesome.connect_signal("wifi::networks", function(networks)
    networks_container:reset()
    for i, network in ipairs(networks) do
        networks_container:add(create_network_button(network))
    end
end)


-- Mouse
helpers.ui.add_hover_cursor(toggle, "hand2")
toggle:buttons(gears.table.join(
    awful.button({}, 1, function()
        awesome.emit_signal("wifi::toggle")
    end)
))

toggle:connect_signal("mouse::enter", function()
    toggle.bg = beautiful.xcolorS2
end)

toggle:connect_signal("mouse::leave", function()
    toggle.bg = beautiful.xcolorS1
end)

helpers.ui.add_hover_cursor(rescan, "hand2")
rescan:buttons(gears.table.join(
    awful.button({}, 1, function()
        awesome.emit_signal("wifi::rescan")
    end)
))


-- Widget
return wibox.widget {
    {
        {
            {
                toggle,
                uptime,
                rescan,
                layout = wibox.layout.align.horizontal,
            },
            networks_container,
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(8),
        widget = wibox.container.margin,
    },
    forced_height = dpi(400),
    shape = helpers.ui.rrect(8),
    bg = beautiful.xcolorS0,
    widget = wibox.container.background,
}
