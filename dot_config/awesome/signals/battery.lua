---@diagnostic disable: undefined-global
local awful = require "awful"
local gears = require "gears"
local naughty = require "naughty"


-- Notification
local notification = nil
local function notify(title, text)
    if notification then
        naughty.replace_text(notification, title, text)
    else
        notification = naughty.notify({
            title = title,
            text = text,
            icon = nil,
            timeout = 10,
        })
    end
end


local function update()
    awful.spawn.easy_async_with_shell("acpi -b", function(battery_data)
        local battery_charging, battery_perc = battery_data:match("(%a+), (%d+)%%")
        local hours, minutes = battery_data:match("(%d%d):(%d%d):%d%d remaining")

        awesome.emit_signal(
            "signal::battery",
            tonumber(battery_perc),
            battery_charging == 'Charging',
            tonumber(hours),
            tonumber(minutes)
        )

        -- Show notification
        if tonumber(battery_perc) < 20 and battery_charging ~= 'Charging' then
            notify("Batterie faible",
                "Il reste " ..
                battery_perc ..
                "% (" ..
                ((tonumber(hours) > 0) and tonumber(hours) ..
                    " heure " or "") .. tonumber(minutes) .. " minutes)")
        elseif notification then
            naughty.destroy(
                notification,
                naughty.notificationClosedReason.dismissedByCommand)
            notification = nil
        end
    end)
end

local listener = awful.spawn.with_line_callback("acpi_listen", {
    stdout = function() update() end,
})
awesome.connect_signal("exit", function()
    awesome.kill(listener, awesome.unix_signal.SIGTERM)
end)

gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
        update()
    end
}
