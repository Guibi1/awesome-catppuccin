local bling = require("lib.bling")

local playerctl = nil

if not playerctl then
	playerctl = bling.signal.playerctl.lib({
		update_on_activity = true,
		player = { "cider", "mpd", "%any", },
		debounce_delay = 1,
	})
end

return playerctl
