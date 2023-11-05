---@diagnostic disable: undefined-global
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

--- Icons
local poweroff_text_icon = "power-off"
local reboot_text_icon = "rotate"
local suspend_text_icon = "moon"
local exit_text_icon = "door-open"
local lock_text_icon = "lock"


--- Commands
local poweroff_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awful.spawn.with_shell("systemctl poweroff")
end

local reboot_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awful.spawn.with_shell("systemctl reboot")
end

local suspend_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awful.spawn.with_shell("systemctl suspend")
end

local exit_command = function()
    awesome.quit()
end

local lock_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awesome.emit_signal("lockscreen::show")
end

local create_button = function(symbol, hover_color, command)
    local icon = helpers.ui.create_icon(symbol, beautiful.xcolorS0, dpi(56))

    local button = wibox.widget({
        {
            icon,
            margins = dpi(32),
            layout = wibox.container.margin,
        },
        forced_height = icon_size,
        forced_width = icon_size,
        border_width = dpi(8),
        border_color = beautiful.xcolorS0,
        shape = helpers.ui.rrect(beautiful.border_width * 2),
        bg = beautiful.xcolorbase,
        widget = wibox.container.background,
    })

    button:buttons(gears.table.join(awful.button({}, 1, function()
        command()
    end)))

    button:connect_signal("mouse::enter", function()
        icon:set_color(hover_color)
        button.border_color = hover_color
    end)
    button:connect_signal("mouse::leave", function()
        icon:set_color(beautiful.xcolorS0)
        button.border_color = beautiful.xcolorS0
    end)

    helpers.ui.add_hover_cursor(button, "hand1")

    return button
end

--- Create the buttons
local poweroff = create_button(poweroff_text_icon, beautiful.xcolor10, poweroff_command)
local reboot = create_button(reboot_text_icon, beautiful.xcolor6, reboot_command)
local suspend = create_button(suspend_text_icon, beautiful.xcolor8, suspend_command)
local exit = create_button(exit_text_icon, beautiful.xcolor2, exit_command)
local lock = create_button(lock_text_icon, beautiful.xcolor12, lock_command)

local create_exit_screen = function(s)
    s.exit_screen = wibox({
        screen = s,
        type = "splash",
        visible = false,
        ontop = true,
        bg = beautiful.transparent,
        fg = beautiful.fg_normal,
        height = s.geometry.height,
        width = s.geometry.width,
        x = s.geometry.x,
        y = s.geometry.y,
    })

    s.exit_screen:buttons(gears.table.join(
        awful.button({}, 2, function()
            awesome.emit_signal("module::exit_screen:hide")
        end),
        awful.button({}, 3, function()
            awesome.emit_signal("module::exit_screen:hide")
        end)
    ))

    s.exit_screen:setup({
        nil,
        {
            nil,
            {
                poweroff,
                reboot,
                suspend,
                exit,
                lock,
                spacing = dpi(50),
                layout = wibox.layout.fixed.horizontal,
            },
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        expand = "none",
        layout = wibox.layout.align.vertical,
    })
end

screen.connect_signal("request::desktop_decoration", function(s)
    create_exit_screen(s)
end)

screen.connect_signal("removed", function(s)
    create_exit_screen(s)
end)

local exit_screen_grabber = awful.keygrabber({
    auto_start = true,
    stop_event = "release",
    keypressed_callback = function(self, mod, key, command)
        if key == "s" then
            suspend_command()
        elseif key == "e" then
            exit_command()
        elseif key == "l" then
            lock_command()
        elseif key == "p" then
            poweroff_command()
        elseif key == "r" then
            reboot_command()
        elseif key == "Escape" or key == "q" or key == "x" then
            awesome.emit_signal("module::exit_screen:hide")
        end
    end,
})

awesome.connect_signal("module::exit_screen:show", function()
    for s in screen do
        s.exit_screen.visible = false
    end
    awful.screen.focused().exit_screen.visible = true
    exit_screen_grabber:start()
end)

awesome.connect_signal("module::exit_screen:hide", function()
    exit_screen_grabber:stop()
    for s in screen do
        s.exit_screen.visible = false
    end
end)
