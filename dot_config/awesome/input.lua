local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local rubato = require "lib.rubato"
local base = wibox.widget.base
local dpi = beautiful.xresources.apply_dpi


local function create_input()
    local widget = base.make_widget()
    widget.text = widget.text or ""

    -- Border
    widget.border = wibox.widget {
        border_width = widget.border_width or dpi(2),
        shape = gears.shape.rounded_rect,
        widget = wibox.container.background,
    }

    -- Custom Widget implementation
    function widget:fit(context, width, height)
        return width, 40
    end

    function widget:draw(context, cr, width, height)
        cr:set_font_size(16)

        local te = cr:text_extents(widget.text)
        cr:move_to(16, (height - te.y_bearing) / 2)
        cr:show_text(widget.text)
    end

    function widget:layout(context, width, height)
        local layout = {}

        -- Border
        table.insert(layout, base.place_widget_at(self.border, 0, 0, width, height))

        return layout
    end

    -- Keyboard listener
    widget.keygrabber = awful.keygrabber {
        stop_key = { ModKey },
        keypressed_callback = function(self, mod, key, event)
            if #key == 1 then
                widget.text = widget.text .. key
            elseif key == "BackSpace" then
                widget.text = widget.text:sub(1, -2)
            else
                return
            end
            widget:emit_signal("widget::redraw_needed")
        end,
        start_callback = function(self)
            awful.mouse.append_global_mousebinding(awful.button({}, 1, widget.unfocus))
            widget:buttons({})
            widget.border.border_color = beautiful.xcolor5
        end,
        stop_callback = function(self, stop_key, stop_mods, sequence)
            awful.mouse.remove_global_mousebinding(awful.button({}, 1, widget.unfocus))
            widget:buttons({ awful.button({}, 1, widget.focus) })
            widget.border.border_color = beautiful.xcolorS3

            if stop_key == "Return" and widget.submit then
                widget.submit(widget.text)
            end
        end
    }


    function widget:focus()
        widget.keygrabber:start()
    end

    function widget:unfocus()
        widget.keygrabber:stop()
    end

    widget:unfocus()
    return widget
end


return create_input
