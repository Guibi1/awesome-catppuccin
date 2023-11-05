-- Standard awesome library --
---@diagnostic disable: undefined-global
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local widgets = require("ui.top-panel.widgets")
local dpi = beautiful.xresources.apply_dpi

-- Widgets
local battery = widgets.battery
local clock = widgets.clock
local cpu = widgets.cpu
local date = widgets.date
local disk = widgets.disk
local keyboard = widgets.keyboard
local mem = widgets.mem
local menu = widgets.menu
local notifications = widgets.notifications
local seperator = widgets.seperator
local systray = widgets.systray
local volume = widgets.volume

-- Create top panel
screen.connect_signal("request::desktop_decoration", function(s)
    s.top_panel = awful.wibar {
        position = "top",
        screen   = s,
        widget   = {
            layout = wibox.container.margin,
            color = "#313244",
            bottom = dpi(2),
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                {
                    { -- Left widgets
                        menu,
                        seperator,
                        s.taglist,
                        -- seperator,
                        -- s.tasklist,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    left = 8,
                    right = 0,
                    top = 2,
                    bottom = 2,
                    layout = wibox.container.margin,
                },
                { -- Central widgets
                    {
                        clock,
                        date,
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.horizontal,
                    },
                    margins = 1,
                    layout = wibox.container.margin,
                },
                { -- Right widgets
                    {
                        systray,
                        seperator,
                        volume,
                        cpu,
                        mem,
                        disk,
                        battery,
                        keyboard,
                        seperator,
                        notifications,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    left = 0,
                    right = 8,
                    top = 2,
                    bottom = 2,
                    layout = wibox.container.margin
                },
            },
        },
    }
end)
