local gears = require "gears"
local wibox = require "wibox"
local beautiful = require "beautiful"
local playerctl_daemon = require "signals.playerctl"
local dpi = beautiful.xresources.apply_dpi


-- Background artwork
local music_art = wibox.widget {
    image = beautiful.music,
    resize = true,
    widget = wibox.widget.imagebox,
}


-- Data
playerctl_daemon:connect_signal("metadata", function(_, __, ___, album_path)
    if album_path == "" then
        album_path = beautiful.music
    end

    music_art:set_image(gears.surface.load_uncached(album_path))
end)


-- Widget
local widget = wibox.widget {
    {
        music_art,
        forced_height = dpi(200),
        forced_width = dpi(200),
        widget = wibox.container.background,
    },
    {
        {
            bg = {
                type = "linear",
                from = { 0, 0 },
                to = { 0, 160 },
                stops = { { 0, beautiful.xcolorS0 .. "cc" }, { 1, beautiful.xcolorS0 } },
            },
            forced_height = dpi(120),
            forced_width = dpi(120),
            widget = wibox.container.background,
        },
        direction = "east",
        widget = wibox.container.rotate,
    },
    layout = wibox.layout.stack,
}

return widget
