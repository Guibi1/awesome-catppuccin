---@diagnostic disable: undefined-global
local awful = require "awful"


local function update()
	awful.spawn.easy_async_with_shell("pamixer --get-volume --get-mute", function(stdout)
		local muted, vol = stdout:match("(%a+) (%d+)")

		awesome.emit_signal("signal::volume", tonumber(vol) or 0, muted == "true")
	end)
end

update()

awesome.connect_signal("volume::update", function()
	update()
end)

awesome.connect_signal("volume::set", function(vol)
	awful.spawn("pamixer --set-volume " .. vol, false)
	update()
end)

awesome.connect_signal("volume::increase", function()
	awful.spawn("pamixer -i 5 -u", false)
	update()
end)

awesome.connect_signal("volume::decrease", function()
	awful.spawn("pamixer -d 5", false)
	update()
end)

awesome.connect_signal("volume::mute", function()
	awful.spawn("pamixer -t", false)
	update()
end)
