local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local playerctl = require "signals.playerctl"
local dpi = beautiful.xresources.apply_dpi


-- Status text
local status_text = wibox.widget {
    font = beautiful.font_name .. "Medium 10",
    valign = "center",
    widget = wibox.widget.textbox,
}

-- Song title
local music_title = wibox.widget {
    font = beautiful.font_name .. "Bold 16",
    valign = "center",
    widget = wibox.widget.textbox,
}

-- Song artist
local music_artist = wibox.widget {
    font = beautiful.font_name .. "Regular 13",
    valign = "center",
    widget = wibox.widget.textbox,
}


-- Data
playerctl:connect_signal("metadata", function(_, title, artist)
    if title == "" then
        title = "Nothing Playing"
    end

    music_title:set_markup_silently(helpers.ui.colorize_text(title, beautiful.xcolor2))
    music_artist:set_markup_silently(helpers.ui.colorize_text(artist, beautiful.xcolorT2))
end)

playerctl:connect_signal("playback_status", function(_, playing, __)
    if playing then
        status_text:set_markup_silently(helpers.ui.colorize_text("Now Playing", beautiful.xcolorO0))
    else
        status_text:set_markup_silently(helpers.ui.colorize_text("Music", beautiful.xcolorO0))
    end
end)


-- Widget
local widget = wibox.widget {
    {
        require "ui.info-panel.widgets.music-player.art-background",
        {
            {
                {
                    status_text,
                    helpers.ui.vertical_pad(dpi(15)),
                    {
                        music_title,
                        step_function = wibox.container.scroll.step_functions
                            .waiting_nonlinear_back_and_forth,
                        fps = 60,
                        speed = 75,
                        widget = wibox.container.scroll.horizontal,
                    },
                    {
                        music_artist,
                        step_function = wibox.container.scroll.step_functions
                            .waiting_nonlinear_back_and_forth,
                        fps = 60,
                        speed = 75,
                        widget = wibox.container.scroll.horizontal,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                require "ui.info-panel.widgets.music-player.song-control",
                spacing = dpi(16),
                layout = wibox.layout.fixed.vertical,
            },
            top = dpi(16),
            bottom = dpi(16),
            left = dpi(24),
            right = dpi(24),
            widget = wibox.container.margin,
        },
        layout = wibox.layout.stack,
    },
    forced_height = dpi(200),
    shape = helpers.ui.rrect(8),
    bg = beautiful.xcolorS0,
    widget = wibox.container.background,
}

return widget
