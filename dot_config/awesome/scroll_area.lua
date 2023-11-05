--- A simple vertical scroll area.
-- @author Guibi1 <laurent@guibi.ca>

local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local rubato = require "lib.rubato"
local base = wibox.widget.base


local function create_scroll_area()
    local widget = base.make_widget()
    widget.children = {}

    -- Scroll Bar
    widget.scroll_bar = wibox.widget {
        bar_shape = gears.shape.rounded_rect,
        bar_color = beautiful.xcolorS2,
        handle_color = beautiful.xcolor5,
        handle_width = 20,
        handle_shape = gears.shape.rounded_rect,
        value = 0,
        maximum = 1,
        orientation = "vertical",
        widget = wibox.widget.slider,
    }
    widget.scroll_bar_container = wibox.container.rotate(widget.scroll_bar, "west")
    widget.scroll_pos = 0
    widget.max_scroll = 0


    -- Custom Widget implementation
    function widget:reset()
        self.children = {}
        self:emit_signal("widget::layout_changed")
    end

    function widget:add(child, no_emit)
        table.insert(self.children, child)
        if no_emit then
            self:emit_signal("widget::layout_changed")
        end
    end

    function widget:set_children(children)
        for _, child in ipairs(children) do
            self:add(child, true)
        end
        self:emit_signal("widget::layout_changed")
    end

    function widget:fit(context, width, height)
        self.width = width
        self.height = height
        return width, height
    end

    function widget:layout(context, width, height)
        local layout = {}
        local content_height = 0
        local spacing = self.spacing or 0

        -- Children
        for i, child in ipairs(self.children) do
            local _, child_height = base.fit_widget(self, context, child, width - 14, height * 100)
            local offset = content_height + self.scroll_pos + (i - 1) * spacing
            if offset + child_height > 0 and offset < self.height then
                table.insert(layout, base.place_widget_at(child,
                    0,
                    offset,
                    width - 14,
                    child_height
                ))
            end
            content_height = content_height + child_height
        end
        self.max_scroll = math.min(height - content_height, 0)

        -- Scrollbar
        self.scroll_bar.maximum = math.max(content_height - height, 0)
        self.scroll_bar.value = math.min(self.scroll_bar.value, self.scroll_bar.maximum)
        self.scroll_bar.handle_width = height * height / math.max(content_height, 1)
        if self.scroll_bar.maximum > 0 then
            table.insert(
                layout,
                base.place_widget_at(self.scroll_bar_container, width - 6, 0, 6, height)
            )
        end

        return layout
    end

    function widget:before_draw_children(context, cr, width, height)
        -- Define a clipping region. This ensures that nothing gets drawn outside this area.
        cr:save() -- Save the current state of the context
        cr:rectangle(0, 0, width, height)
        cr:clip()
    end

    function widget:after_draw_children(context, cr, width, height)
        cr:restore() -- Restore the context to its state before clipping was set
    end

    -- Animation
    local last_pos_update = 0
    local animation = rubato.timed {
        pos = 0,
        rate = 60,
        duration = 0.1,
        intro = 0.01,
        outro = 0.05,
        subscribed = function(pos)
            widget.scroll_pos = pos
            last_pos_update = -pos
            widget.scroll_bar.value = -pos
            widget:emit_signal("widget::layout_changed")
        end,
    }


    -- Mouse
    widget:buttons(gears.table.join(
        awful.button({}, 5, function()
            animation.target = math.max(animation.target - 20, widget.max_scroll)
        end),
        awful.button({}, 4, function()
            animation.target = math.min(animation.target + 20, 0)
        end)
    ))

    widget.scroll_bar:connect_signal("property::value", function(_, pos)
        if pos ~= last_pos_update then
            animation.target = -pos
        end
    end)


    return widget
end

return create_scroll_area
