---@diagnostic disable: undefined-global
local awful = require "awful"
local wibox = require "wibox"
local rubato = require "lib.rubato"
local gshape = require "gears.shape"
local beautiful = require "beautiful"
local gmatrix = require "gears.matrix"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi

local capi = { mouse = mouse }

local _ui = {}

function _ui.colorize_text(text, color)
    return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function _ui.create_icon(name, color, size)
    local icon = wibox.widget {
        image = beautiful.icons_path .. (name or "") .. ".svg",
        stylesheet = "svg { fill: " .. (color or "black") .. "; }",
        forced_width = size or 16,
        forced_height = size or 16,
        halign = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
    }

    function icon:set_color(primary, secondary)
        self.stylesheet = "svg { fill: " .. primary or "black" .. "; --fa-primary-color: " .. secondary .. "; } "
    end

    function icon:set_icon(name)
        self.image = beautiful.icons_path .. name .. ".svg"
    end

    return icon
end

function _ui.add_hover_cursor(w, hover_cursor)
    local original_cursor = "left_ptr"

    w:connect_signal("mouse::enter", function()
        local widget = capi.mouse.current_wibox
        if widget then
            widget.cursor = hover_cursor
        end
    end)

    w:connect_signal("mouse::leave", function()
        local widget = capi.mouse.current_wibox
        if widget then
            widget.cursor = original_cursor
        end
    end)
end

function _ui.vertical_pad(height)
    return wibox.widget({
        forced_height = height,
        layout = wibox.layout.fixed.vertical,
    })
end

function _ui.horizontal_pad(width)
    return wibox.widget({
        forced_width = width,
        layout = wibox.layout.fixed.horizontal,
    })
end

function _ui.rrect(radius)
    return function(cr, width, height)
        gshape.rounded_rect(cr, width, height, radius)
    end
end

function _ui.pie(width, height, start_angle, end_angle, radius)
    return function(cr)
        gshape.pie(cr, width, height, start_angle, end_angle, radius)
    end
end

function _ui.prgram(height, base)
    return function(cr, width)
        gshape.parallelogram(cr, width, height, base)
    end
end

function _ui.prrect(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gshape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
    end
end

function _ui.custom_shape(cr, width, height)
    cr:move_to(0, height / 25)
    cr:line_to(height / 25, 0)
    cr:line_to(width, 0)
    cr:line_to(width, height - height / 25)
    cr:line_to(width - height / 25, height)
    cr:line_to(0, height)
    cr:close_path()
end

local function _get_widget_geometry(_hierarchy, widget)
    local width, height = _hierarchy:get_size()
    if _hierarchy:get_widget() == widget then
        -- Get the extents of this widget in the device space
        local x, y, w, h = gmatrix.transform_rectangle(_hierarchy:get_matrix_to_device(), 0, 0, width, height)
        return { x = x, y = y, width = w, height = h, hierarchy = _hierarchy }
    end

    for _, child in ipairs(_hierarchy:get_children()) do
        local ret = _get_widget_geometry(child, widget)
        if ret then
            return ret
        end
    end
end

function _ui.get_widget_geometry(wibox, widget)
    return _get_widget_geometry(wibox._drawable._widget_hierarchy, widget)
end

function _ui.screen_mask(s, bg)
    local mask = wibox({
        visible = false,
        ontop = true,
        type = "splash",
        screen = s,
    })
    awful.placement.maximize(mask)
    mask.bg = bg
    return mask
end

function _ui.grouping_widget(w1, w2, dpi1)
    local container = wibox.widget {
        w1,
        {
            nil,
            w2,
            expand = 'none',
            layout = wibox.layout.flex.vertical,
        },
        spacing = dpi1,
        layout = wibox.layout.fixed.horizontal,
    }

    return container
end

function _ui.create_button(text, color, bg_color, hover_color, radius, font_size, mx, my)
    local button = wibox.widget {
        {
            {
                markup = _ui.colorize_text(text, color or beautiful.xcolorT0),
                font = beautiful.font_name .. (font_size or "12"),
                align = 'center',
                widget = wibox.widget.textbox,
            },
            top = dpi(my or 8),
            bottom = dpi(my or 8),
            left = dpi(mx or 16),
            right = dpi(mx or 16),
            widget = wibox.container.margin,
        },
        bg = bg_color or beautiful.xcolorS0,
        shape = _ui.rrect(radius or 8),
        widget = wibox.container.background,
    }
    button.hover = false

    _ui.add_hover_cursor(button, "hand2")
    button:connect_signal("mouse::enter", function()
        button.hover = true
        button.bg = hover_color or beautiful.xcolorS1
    end)
    button:connect_signal("mouse::leave", function()
        button.hover = false
        button.bg = bg_color or beautiful.xcolorS0
    end)

    return button
end

function _ui.create_loading_bar(color, bg_color, mx, my)
    color = color or beautiful.xcolor5
    bg_color = bg_color or beautiful.xcolorS0

    local bar = wibox.widget {
        color = color,
        value = 0,
        forced_height = 4,
        shape = gshape.rounded_bar,
        background_color = bg_color,
        widget = wibox.widget.progressbar,
    }

    local widget = wibox.widget {
        {
            bar,
            top = dpi(my or 8),
            bottom = dpi(my or 8),
            left = dpi(mx or 0),
            right = dpi(mx or 0),
            widget = wibox.container.margin,
        },
        direction = "north",
        widget = wibox.container.rotate,
    }

    -- Animation
    local animation = rubato.timed {
        pos = 0,
        rate = 60,
        duration = 0.6,
        subscribed = function(pos)
            bar.value = pos
        end,
        awestore_compat = true,
    }

    animation.target = 1
    animation.ended:subscribe(function()
        if animation.target == 1 then
            widget.direction = widget.direction == "north" and "south" or "north"
            animation.target = 0
        else
            animation.target = 1
        end
    end)

    return widget
end

function _ui.create_scroll_container(widget)
    local container_height = 0
    local max_y = 0
    widget.point = { x = 0, y = 0 }

    local scroll_container = wibox.widget {
        widget,
        layout = wibox.layout.manual,
    }

    local scrollbar = wibox.widget {
        bar_shape = gshape.rounded_rect,
        bar_color = beautiful.xcolorS2,
        handle_color = beautiful.xcolor5,
        handle_width = 20,
        handle_shape = gshape.rounded_rect,
        value = 0,
        widget = wibox.widget.slider,
    }

    -- Animation
    local animation = rubato.timed {
        pos = 0,
        rate = 60,
        duration = 0.1,
        intro = 0.01,
        outro = 0.05,
        subscribed = function(pos)
            scroll_container:move(1, function(geo, args)
                container_height = args.parent.height
                -- max_y = args.parent.height - geo.height
                return { x = 0, y = pos }
            end)
        end,
    }


    -- Mouse
    scroll_container:buttons(gears.table.join(awful.button({}, 5, function()
            animation.target = animation.target - 20
            -- animation.target = math.max(animation.target - 20, max_y)
            scrollbar.value = -animation.target
            scrollbar.maximum = container_height
        end),
        awful.button({}, 4, function()
            -- animation.target = math.min(animation.target + 20, 0)
            animation.target = animation.target + 20
            scrollbar.value = -animation.target
            scrollbar.maximum = container_height
        end)
    ))

    return wibox.widget {
        {
            nil,
            scroll_container,
            {
                {
                    scrollbar,
                    forced_height = 5,
                    widget = wibox.container.constraint,
                },
                direction = "west",
                widget = wibox.container.rotate,
            },
            layout = wibox.layout.align.horizontal,
        },
        widget = wibox.container.background
    }
end

return _ui
