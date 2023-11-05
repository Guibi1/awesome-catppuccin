---@diagnostic disable: undefined-global
local awful = require "awful"

local spacer = "    "

local terminal = "" .. spacer
local files = "󰝰" .. spacer
local browser = "󰖟" .. spacer
local code = "󰨞" .. spacer
local discord = "󰙯" .. spacer
local mail = "󰇯" .. spacer

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag({ terminal, files, code, browser, discord, mail }, s, awful.layout.layouts[1])
end)

screen.connect_signal("tag::history::update", function()
	local tag = awful.screen.focused().selected_tag
	if next(tag:clients()) == nil then
		if tag.name == discord then
			awful.spawn("discord")
		end
	end
end)
