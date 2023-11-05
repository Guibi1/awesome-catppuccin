---@diagnostic disable: undefined-global
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local icon_muted = "volume-xmark"
local icon_low = "volume-low"
local icon_normal = "volume"
local icon_high = "volume-high"

-- Icon
local icon = helpers.ui.create_icon(icon_normal, beautiful.xcolor6)

-- Text
local volume = wibox.widget.textbox()
volume.font = beautiful.font_name .. "11"
volume.align = 'center'

-- Data
awesome.connect_signal("signal::volume", function(vol, muted)
    if vol == nil then
        vol = 0
        muted = true
    end

    if muted then
        volume.markup = "mute"
        icon:set_icon(icon_muted)
    else
        volume.markup = vol .. "%"

        if vol < 30 then
            icon:set_icon(icon_low)
        elseif vol < 70 then
            icon:set_icon(icon_low)
        else
            icon:set_icon(icon_high)
        end
    end
end)

awesome.emit_signal("volume::update")

-- Widget
local widget = wibox.widget {
    {
        {
            icon,
            volume,
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        left = 1,
        right = 0,
        layout = wibox.container.margin,
    },
    forced_width = 65,
    layout = wibox.layout.fixed.horizontal,
}

return widget
