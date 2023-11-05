---@diagnostic disable: undefined-global
local awful = require "awful"

local user_vars = require "user_variables"
local microphone = user_vars.widget.mic.name


local function update()
	awful.spawn.easy_async_with_shell("pamixer --source " .. microphone .. " --get-volume  --get-mute", function(stdout)
		local muted, vol = stdout:match("(%a+) (%d+)")

		awesome.emit_signal("signal::mic", tonumber(vol) or 0, muted == "true")
	end)
end

awesome.connect_signal("mic::update", function()
	update()
end)

awesome.connect_signal("mic::set", function(vol)
	awful.spawn("pamixer --source " .. microphone .. " --set-volume " .. vol, false)
	update()
end)

awesome.connect_signal("mic::mute", function()
	awful.spawn("pamixer --source " .. microphone .. " -t", false)
	update()
end)

update()
