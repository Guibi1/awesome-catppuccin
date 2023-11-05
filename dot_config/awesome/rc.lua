---@diagnostic disable: undefined-global
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
require("awful.autofocus")

-- Theme --
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- Main/Configuration --
require "main"

-- Libraries/Modules --
require "lib"

-- Signals/Monitoring --
require "signals"

-- Ui/Panels --
require "ui"

-- Bling --
local bling = require("lib.bling")

bling.widget.window_switcher.enable {
    type = "thumbnail",
    cycleClientsByIdx = awful.client.focus.byidx,
    filterClients = awful.widget.tasklist.filter.currenttags,
}

-- Lock the screen on boot! --
-- awesome.emit_signal("lockscreen::show")

-- Autostart --
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    'dex --environment Awesome --autostart'
)
