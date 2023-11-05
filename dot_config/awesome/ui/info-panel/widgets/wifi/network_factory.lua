---@diagnostic disable: undefined-global
local awful = require "awful"
local gears = require "gears"
local wibox = require "wibox"
local helpers = require "helpers"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local capi = { mouse = mouse }


local signal_handler = gears.object()
local auto_close_timer = gears.timer {
    timeout = 5,
    callback = function()
        awesome.emit_signal("wifi::allow_rescan", true)
        awesome.emit_signal("wifi::rescan")
    end
}

local function create_network_button(network)
    local vbox = wibox.widget {
        layout = wibox.layout.fixed.vertical
    }

    local widget = wibox.widget {
        {
            {
                {
                    {
                        helpers.ui.create_icon("wifi", beautiful.xcolorT1, 20),
                        right = dpi(16),
                        widget = wibox.container.margin,
                    },
                    {
                        nil,
                        {
                            markup = helpers.ui.colorize_text(network.ssid, beautiful.xcolorT1),
                            font = beautiful.font_name .. "SemiBold 11",
                            widget = wibox.widget.textbox
                        },
                        {
                            markup = helpers.ui.colorize_text((network.is_active and "Connected" or ""),
                                beautiful.xcolorT0),
                            font = beautiful.font_name .. "SemiLight 10",
                            widget = wibox.widget.textbox
                        },
                        layout = wibox.layout.align.vertical,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                vbox,
                layout = wibox.layout.fixed.vertical,
            },
            left = dpi(16),
            right = dpi(16),
            top = dpi(8),
            bottom = dpi(8),
            widget = wibox.container.margin,
        },
        bg = beautiful.xcolorS0,
        shape = helpers.ui.rrect(8),
        widget = wibox.container.background
    }
    widget.container = vbox
    widget.closed = true

    -- States
    function widget:reset()
        self.container:reset()
        self.closed = false

        if self.ask_password_signal then
            awesome.disconnect_signal("wifi::password::request", self.ask_password_signal)
            self.ask_password_signal = nil
        end

        auto_close_timer:stop()
        widget:buttons(awful.button({}, 1, function() end))

        local current = capi.mouse.current_wibox
        if current and not widget.closed then
            current.cursor = "left_ptr"
        end
    end

    function widget:close()
        self:reset()
        self.closed = true

        if self.close_signal then
            signal_handler:disconnect_signal("close", self.close_signal)
            self.close_signal = nil
        end

        widget:buttons(awful.button({}, 1, function()
            widget:open()
        end))
    end

    function widget:open()
        self:reset()
        awesome.emit_signal("wifi::allow_rescan", false)
        auto_close_timer:again()

        self.close_signal = function()
            widget:close()
        end
        signal_handler:emit_signal("close")
        signal_handler:connect_signal("close", self.close_signal)

        local connect_button = helpers.ui.create_button("Connect",
            beautiful.xcolorbase,
            beautiful.xcolor5,
            beautiful.xcolor5 .. "D0"
        )

        helpers.ui.add_hover_cursor(connect_button, "hand2")
        connect_button:buttons(awful.button({}, 1, function()
            self:set_loading()
            self.ask_password_signal = function()
                self:ask_password()
            end
            awesome.connect_signal("wifi::password::request", self.ask_password_signal)
            awesome.emit_signal("wifi::connect", network)
        end))
        self.container:add(connect_button)
    end

    function widget:set_loading()
        self:reset()
        self.container:add(helpers.ui.create_loading_bar())
    end

    function widget:ask_password()
        self:reset()
        self.container:add(wibox.widget {
            submit = function(input)
                awesome.emit_signal("wifi::password::set", input)
                self:set_loading()
            end,
            widget = require("input")
        })
    end

    -- Mouse
    widget:connect_signal("mouse::enter", function()
        widget.bg = beautiful.xcolorS1
        local current = capi.mouse.current_wibox
        if current and widget.closed then
            current.cursor = "hand2"
        end
    end)

    widget:connect_signal("mouse::leave", function()
        widget.bg = beautiful.xcolorS0
        local current = capi.mouse.current_wibox
        if current and widget.closed then
            current.cursor = "left_ptr"
        end
    end)


    widget:close()
    return widget
end

return create_network_button
