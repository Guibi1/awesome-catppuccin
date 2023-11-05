---@diagnostic disable: undefined-global
local awful = require "awful"

-- Script
local title_sc = 'mpc -f %title% | head -1'
local artist_sc = 'mpc -f %artist% | head -1'
local length_sc = "mpc | awk '{print $3}' | awk 'NR==2'"
local status_sc = "mpc | awk '{print $1}' | awk 'NR==2' | sed 's/[[]*//g' | sed 's/[]]*//g'"

-- function
local function update()
	awful.spawn.easy_async_with_shell(title_sc, function(title)
		awful.spawn.easy_async_with_shell(artist_sc, function(artist)
			awful.spawn.easy_async_with_shell(length_sc, function(length)
				awful.spawn.easy_async_with_shell(status_sc, function(status)
					title = string.gsub(title, "\n", "")
					artist = string.gsub(artist, "\n", "")
					length = string.gsub(length, "\n", "")
					status = string.gsub(status, "\n", "")
					awesome.emit_signal("signal::player", title, artist, length, status)
				end)
			end)
		end)
	end)
end

awesome.connect_signal("widget::update_player", function()
	update()
end)

update()
