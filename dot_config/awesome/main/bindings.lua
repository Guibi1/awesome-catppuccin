---@diagnostic disable: undefined-global
local awful = require "awful"
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require "menubar"
local machi = require "lib.layout-machi"
local menu = require "main.menu"

local apps = require "main.apps"

ModKey = "Mod4"

-- General awesome keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ ModKey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ ModKey, }, "Return", function() awful.spawn(apps.terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ ModKey, "Shift" }, "c", function() menu.mainmenu:show() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({ ModKey }, "p", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" }),
})

-- Tag bindings
awful.keyboard.append_global_keybindings({
    awful.key({ ModKey, "Control" }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ ModKey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ ModKey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ ModKey, }, "Tab", awful.tag.history.restore,
        { description = "go back", group = "tag" }),
})

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { ModKey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { ModKey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers   = { ModKey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { ModKey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { ModKey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

-- Focus bindings
awful.keyboard.append_global_keybindings({
    awful.key({ ModKey, }, "Escape",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),
    awful.key({ ModKey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ ModKey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ ModKey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:activate { raise = true, context = "key.unminimize" }
            end
        end,
        { description = "restore minimized", group = "client" }),
})

-- Layout bindings
awful.keyboard.append_global_keybindings({
    awful.key({ ModKey, "Shift" }, "k", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ ModKey, "Shift" }, "j", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ ModKey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ ModKey, }, "k", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ ModKey, }, "j", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ ModKey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ ModKey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ ModKey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ ModKey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    --  awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    --            {description = "select next", group = "layout"}),
    --  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),
    awful.key({ ModKey, }, "-", function() machi.default_editor.start_interactive() end,
        { description = "edit the current layout if it is a machi layout", group = "layout" }),
    awful.key({ ModKey, }, ".", function() machi.switcher.start(client.focus) end,
        { description = "switch between windows for a machi layout", group = "layout" }),
})

-- Client bindings
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ ModKey }, "w", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ ModKey, "Control" }, "space", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ ModKey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
        awful.key({ ModKey, }, "o", function(c) c:move_to_screen() end,
            { description = "move to screen", group = "client" }),
        awful.key({ ModKey, }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top", group = "client" }),
        awful.key({ ModKey, }, "n",
            function(c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end,
            { description = "minimize", group = "client" }),
        awful.key({ ModKey, }, "m",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "toggle fullscreen", group = "client" }),
        awful.key({ ModKey, "Control" }, "m",
            function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "(un)maximize vertically", group = "client" }),
        awful.key({ ModKey, "Shift" }, "m",
            function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            { description = "(un)maximize horizontally", group = "client" }),
    })
end)

-- Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function()
        menu.mainmenu:toggle()
        return
    end),

    -- Scroll tags --
    -- awful.button({}, 4, awful.tag.viewprev),
    -- awful.button({}, 5, awful.tag.viewnext),
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ ModKey }, 1, function(c)
            c:activate { context = "mouse_click", action = "mouse_move" }
        end),
        awful.button({ ModKey }, 3, function(c)
            c:activate { context = "mouse_click", action = "mouse_resize" }
        end),
    })
end)
