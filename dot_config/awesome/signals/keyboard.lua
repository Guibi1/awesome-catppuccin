---@diagnostic disable: undefined-global
local awful = require "awful"

local kbmap_is_ca = true

local function update()
	awful.spawn.easy_async_with_shell("setxkbmap -query | grep layout", function(stdout)
		local layout = stdout:match("layout:%s+(%a+)")

		kbmap_is_ca = layout == "ca"
		awesome.emit_signal("signal::keyboard", layout)
	end)
end

update()

awesome.connect_signal("keyboard::update", function()
	update()
end)

awesome.connect_signal("keyboard::toggle", function()
	if kbmap_is_ca == false then
		awful.spawn("setxkbmap ca")
	else
		awful.spawn("setxkbmap us")
	end

	update()
end)
