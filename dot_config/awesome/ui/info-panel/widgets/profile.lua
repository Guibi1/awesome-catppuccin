---@diagnostic disable: undefined-global
local awful = require "awful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


-- Pfp
local pfp = wibox.widget.imagebox()
pfp.image = beautiful.pfp
pfp.clip_shape = gears.shape.circle
pfp.forced_height = dpi(0)

-- User
local user = wibox.widget.textbox()
user.font = beautiful.font_name .. "SemiBold 18"
user.markup = helpers.ui.colorize_text(os.getenv 'USER', beautiful.fg_normal)

-- Hostname
local hostname = wibox.widget.textbox()
hostname.font = beautiful.font_name .. "14"

-- Uptime
local uptime = wibox.widget.textbox()
uptime.font = beautiful.font_name .. "12"

-- Power options
local shutdown = wibox.widget {
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
awesome.connect_signal("signal::uptime", function(time)
    uptime.markup = helpers.ui.colorize_text("up " .. time, beautiful.fg_normal)
end)

awful.spawn.easy_async_with_shell("echo $HOST", function(stdout)
    hostname.markup = helpers.ui.colorize_text("@" .. (stdout:match("(%a+)") or ""), beautiful.xcolor1)
end)


-- Mouse
helpers.ui.add_hover_cursor(shutdown, "hand2")
shutdown:buttons(gears.table.join(
    awful.button({}, 1, function()
        awesome.emit_signal("module::exit_screen:show")
    end)
))

shutdown:connect_signal("mouse::enter", function()
    shutdown.bg = beautiful.xcolorS2
end)

shutdown:connect_signal("mouse::leave", function()
    shutdown.bg = beautiful.xcolorS1
end)


-- Widget
return wibox.widget {
    {
        {
            pfp,
            {
                {
                    user,
                    hostname,
                    uptime,
                    expand  = "none",
                    spacing = dpi(4),
                    layout  = wibox.layout.fixed.vertical,
                },
                left = dpi(16),
                right = dpi(16),
                widget = wibox.container.margin,
            },
            {
                nil,
                shutdown,
                expand = "none",
                layout = wibox.layout.align.vertical,
            },
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
    },
    forced_height = dpi(130),
    shape = helpers.ui.rrect(8),
    bg = beautiful.xcolorS0,
    widget = wibox.container.background,
}
