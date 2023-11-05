---@diagnostic disable: undefined-global
local gears = require "gears"
local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local helpers = require "helpers"
local naughty = require "naughty"
local rubato = require "lib.rubato"
local dpi = beautiful.xresources.apply_dpi

local no_notifs_placeholder = require "ui.notif-panel.widgets.no_notifs_placeholder"
local create_notif = require "ui.notif-panel.widgets.notification_factory"


-- Notifications
local notifs_container_has_placeholder = true
local notifs_container = wibox.widget {
    no_notifs_placeholder,
    spacing = 10,
    forced_width = 320,
    forced_height = 730,
    layout = wibox.layout.fixed.vertical,
}

-- Data
awesome.connect_signal("notif-panel::clear", function()
    notifs_container:reset(notifs_container)
    notifs_container:add(no_notifs_placeholder)
    notifs_container_has_placeholder = true
end)

awesome.connect_signal("notif-panel::remove", function(widget)
    notifs_container:remove_widgets(widget)

    if #notifs_container.children == 0 then
        notifs_container:add(no_notifs_placeholder)
        notifs_container_has_placeholder = true
    end
end)

-- Mouse
notifs_container:buttons(gears.table.join(
    awful.button({}, 4, nil, function()
        if not notifs_container_has_placeholder then
            notifs_container:insert(1, notifs_container.children[#notifs_container.children])
            notifs_container:remove(#notifs_container.children)
        end
    end),

    awful.button({}, 5, nil, function()
        if not notifs_container_has_placeholder then
            notifs_container:insert(#notifs_container.children + 1, notifs_container.children[1])
            notifs_container:remove(1)
        end
    end)
))


-- Notification received
naughty.connect_signal("request::display", function(n)
    if notifs_container_has_placeholder then
        notifs_container:reset(notifs_container)
        notifs_container_has_placeholder = false
    end

    local appicon = n.icon or n.app_icon
    if not appicon then
        appicon = beautiful.pfp --notification_icon
    end

    notifs_container:insert(1, create_notif(appicon, n))
end)


-- Sliders
local sliders = wibox.widget {
    {
        {
            require "ui.notif-panel.widgets.bri_slider",
            require "ui.notif-panel.widgets.vol_slider",
            require "ui.notif-panel.widgets.mic_slider",
            spacing = dpi(2),
            layout = wibox.layout.flex.vertical,
        },
        widget = wibox.container.margin,
        top = 20,
        bottom = 20,
        left = 35,
        right = 35,
    },
    bg = beautiful.xcolorS0,
    shape = helpers.ui.rrect(8),
    widget = wibox.container.background,
}


-- Widget
local notif_panel = wibox {
    visible = false,
    ontop = true,
    width = dpi(410),
    height = awful.screen.focused().geometry.height - dpi(100),
    y = dpi(60),
    bg = beautiful.bg_normal,
    border_width = dpi(3),
    border_color = beautiful.xcolor5,
    shape = helpers.ui.rrect(14),
    widget = {
        {
            require "ui.notif-panel.widgets.header",
            notifs_container,
            sliders,
            spacing = dpi(20),
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
    }
}

-- Animation
local target_closed = dpi(40)
local target_opened = dpi(-40) - notif_panel.width
local animation = rubato.timed {
    pos = target_closed,
    rate = 60,
    intro = 0.15,
    duration = 0.3,
    subscribed = function(pos)
        notif_panel.x = awful.screen.focused().geometry.width + pos
    end
}


-- Timer of panel's death
-- (required so that the panel finishes the animation before being invisible)
notif_panel.visibility_timer = gears.timer {
    timeout = 0.4,
    single_shot = true,
    callback = function()
        notif_panel.visible = false
    end
}

-- Toggle visibility
local panel_open = false
awesome.connect_signal("notif-panel::toggle", function()
    if panel_open then
        animation.target = target_closed
        notif_panel.visibility_timer:start()
    else
        notif_panel.visible = true
        animation.target = target_opened
        notif_panel.visibility_timer:stop()
    end
    panel_open = not panel_open
end)
