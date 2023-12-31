---@diagnostic disable: undefined-global
local awful = require "awful"
local ruled = require "ruled"
local helpers = require "helpers"
local apps = require "main.apps"

local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            --     shape = helpers.ui.rrect(15), -- Shape is in Titlebar --
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    }

    ruled.client.append_rule {
        id = "titlebars",
        rule_any = {
            type = { "normal", "dialog" },
        },
        properties = {
            titlebars_enabled = true
        }
    }

    ruled.client.append_rule {
        rule = { class = apps["launcher"] },
        properties = {
            titlebars_enabled = false
        },
    }


    ruled.client.append_rule {
        rule = { instance = "bf1.exe" },
        properties = { shape = helpers.ui.rrect(0), fullscreen = true, tag = "", switchtotag = true, }, --ontop = true, sticky = true, },
    }
    ruled.client.append_rule {
        rule = { instance = "wine" },
        properties = { shape = helpers.ui.rrect(0), titlebars_enabled = false, }, --ontop = true, sticky = true, },
    }

    ruled.client.append_rule({
        rule_any = {
            floating = true,
        },
        properties = {
            placement = awful.placement.centered,
            ontop = true,
        },
    })

    ruled.client.append_rule({
        rule_any = {
            class = {
                "xfce",
            },
            instance = {
                "xfce",
            },
        },
        properties = {
            floating = true,
        },
    })

    ruled.client.append_rules({
        {
            rule = { class = "discord" },
            properties = {
                tag = screen[1].tags[5]
            }
        },
        {
            rule = { class = "Blueman-manager" },
            properties = {
                floating = true,
            },
        },
    })
end)
