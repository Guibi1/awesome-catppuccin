---@diagnostic disable: undefined-global
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Icon
local icon_battery_critical = "battery-exclamation"
local icon_battery_low = "battery-low"
local icon_battery_quarter = "battery-quarter"
local icon_battery_half = "battery-half"
local icon_battery_three_quarters = "battery-three-quarters"
local icon_battery_full = "battery-full"
local icon_battery_charging = "battery-bolt"
local icon = helpers.ui.create_icon("", beautiful.xcolor6)

-- Text
local battery = wibox.widget.textbox()
battery.font = beautiful.font_name .. "11"
battery.align = 'center'


-- Data
awesome.connect_signal("signal::battery",
    function(battery_perc, battery_charging)
        if battery_perc == nil then
            battery_perc = 0
        end

        battery.markup = battery_perc .. "%"

        if battery_perc <= 5 then
            icon:set_color(beautiful.xcolor10)
        elseif battery_perc <= 15 then
            icon:set_color(beautiful.xcolor12)
        else
            icon:set_color(beautiful.xcolor6)
        end

        if battery_charging then
            icon:set_icon(icon_battery_charging)
        elseif battery_perc <= 5 then
            icon:set_icon(icon_battery_critical)
        elseif battery_perc <= 15 then
            icon:set_icon(icon_battery_low)
        elseif battery_perc <= 30 then
            icon:set_icon(icon_battery_quarter)
        elseif battery_perc <= 50 then
            icon:set_icon(icon_battery_half)
        elseif battery_perc <= 75 then
            icon:set_icon(icon_battery_three_quarters)
        else
            icon:set_icon(icon_battery_full)
        end
    end
)


-- Widget
local widget = wibox.widget {
    {
        {
            icon,
            battery,
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        left = 1,
        right = 0,
        layout = wibox.container.margin,
    },
    forced_width = 60, -- Makes it fixed and not Moves Whole Bar
    layout = wibox.layout.fixed.horizontal,
}

return widget
