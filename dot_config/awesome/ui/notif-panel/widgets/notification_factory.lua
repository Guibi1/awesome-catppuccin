---@diagnostic disable: undefined-global
local gears = require "gears"
local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local helpers = require "helpers"
local dpi = beautiful.xresources.apply_dpi


local function create_notif(image, n)
    -- Time
    local time = wibox.widget {
        markup = helpers.ui.colorize_text(os.date "%H:%M", beautiful.xcolorT2),
        align = "right",
        font = beautiful.font .. " Bold 10",
        widget = wibox.widget.textbox,
    }

    -- Icon
    local icon = wibox.widget {
        {
            {
                image = image,
                resize = true,
                clip_shape = gears.shape.circle,
                halign = "center",
                valign = "center",
                widget = wibox.widget.imagebox,
            },
            border_width = dpi(2),
            border_color = accent_colors,
            shape = gears.shape.circle,
            widget = wibox.container.background,
        },
        strategy = "exact",
        height = dpi(50),
        width = dpi(50),
        widget = wibox.container.constraint,
    }

    -- Title
    local title = wibox.widget {
        step_function = wibox.container.scroll.step_functions
            .waiting_nonlinear_back_and_forth,
        speed = 50,
        {
            markup = n.title,
            font = beautiful.font .. " Bold 9",
            align = "left",
            widget = wibox.widget.textbox,
        },
        widget = wibox.container.scroll.horizontal,
    }

    -- Message
    local message = wibox.widget {
        step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
        speed = 50,
        {
            markup = n.message,
            align = "left",
            widget = wibox.widget.textbox,
        },
        forced_width = 220,
        widget = wibox.container.scroll.horizontal,
    }

    -- Grid layout
    local grid = wibox.widget {
        horizontal_spacing = 16,
        vertical_spacing   = 8,
        layout             = wibox.layout.grid,
    }
    grid:add_widget_at(icon, 1, 1, 2, 1)
    grid:add_widget_at(title, 1, 2, 1, 3)
    grid:add_widget_at(message, 2, 2, 1, 4)
    grid:add_widget_at(time, 1, 5, 1, 1)

    -- Widget
    local notification = wibox.widget {
        {
            grid,
            margins = dpi(16),
            widget = wibox.container.margin,
        },
        forced_width = 320,
        forced_height = 80,
        shape = helpers.ui.rrect(8),
        bg = beautiful.xcolorS0,
        widget = wibox.container.background,
    }

    -- Remove on click
    notification:buttons(gears.table.join(awful.button({}, 1, function()
        awesome.emit_signal("notif-panel::remove", notification)
    end)))

    -- return notification
    return wibox.widget {
        markup = n.message,
        align = "left",
        widget = wibox.widget.textbox,
    }
end

return create_notif
