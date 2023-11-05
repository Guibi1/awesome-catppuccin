---@diagnostic disable: undefined-global
local awful = require "awful"


local function update()
	awful.spawn.easy_async_with_shell('brillo -G', function(brightness)
		awesome.emit_signal("signal::brightness", math.floor(tonumber(brightness) or 0))
	end)
end

update()

awesome.connect_signal("brightness::update", function()
	update()
end)

awesome.connect_signal("brightness::set", function(vol)
	awful.spawn("brillo -S " .. vol, false)
	update()
end)

awesome.connect_signal("brightness::increase", function()
	awful.spawn("brillo -A 5", false)
	update()
end)

awesome.connect_signal("brightness::decrease", function()
	awful.spawn("brillo -U 5", false)
	update()
end)
