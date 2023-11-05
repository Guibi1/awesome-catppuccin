---@diagnostic disable: undefined-global
local dbus         = require "lib.dbus_proxy"
local GVariant     = require("lgi").GLib.Variant
local naughty      = require("naughty")

-- NetworkManager proxy
local nm_proxy     = dbus.Proxy:new {
    bus = dbus.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager",
    path = "/org/freedesktop/NetworkManager",
}

-- Wifi proxy
local wifi_proxy
local wifi_device_proxy

local allow_rescan = true
awesome.connect_signal("wifi::allow_rescan", function(allow)
    allow_rescan = allow
end)

local function emit_wireless_state()
    awesome.emit_signal("wifi::enabled", nm_proxy.WirelessEnabled)
end

local function get_available_networks(proxy)
    local aps = proxy.AccessPoints

    -- Get the currently active SSID
    local active_ssid = nil
    if wifi_device_proxy and wifi_device_proxy.State == 100 then -- 100 is NM_DEVICE_STATE_ACTIVATED
        local active_path = wifi_device_proxy.ActiveConnection
        local active_conn = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Connection.Active",
            path = active_path,
        }
        active_ssid = active_conn.Id
    end

    -- Find ssids
    local found_networks = {}
    local active_network
    for _, path in ipairs(aps) do
        local device = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.AccessPoint",
            path = path,
        }
        local ssid = string.char(table.unpack(device.Ssid))
        if ssid ~= "" then
            local strength = tonumber(device.Strength)
            if strength < 30 then
                break
            elseif ssid == active_ssid then
                active_network = {
                    ssid = ssid,
                    strength = strength,
                    path = path,
                    is_active = (ssid == active_ssid)
                }
            elseif found_networks[ssid] == nil or strength > found_networks[ssid].strength then
                found_networks[ssid] = {
                    ssid = ssid,
                    strength = strength,
                    path = path,
                    is_active = (ssid == active_ssid)
                }
            end
        end
    end

    -- Order and extract ssids
    local networks = {}
    for ssid, network in pairs(found_networks) do
        local pos = nil
        for i, net in ipairs(networks) do
            if network.strength > net.strength then
                pos = i
                break
            end
        end
        table.insert(networks, pos or (#networks + 1), network)
    end

    if active_network then
        table.insert(networks, 1, active_network)
    end
    return networks
end


local function find_wifi_device()
    local devices = nm_proxy:GetDevices()

    local device, wireless
    for _, device_path in ipairs(devices) do
        device = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Device",
            path = device_path,
        }
        if device.DeviceType == 2 then
            wireless = dbus.Proxy:new {
                bus = dbus.Bus.SYSTEM,
                name = "org.freedesktop.NetworkManager",
                interface = "org.freedesktop.NetworkManager.Device.Wireless",
                path = device_path,
            }
            break
        end
    end

    wireless:on_properties_changed(function(proxy, changed, invalidated)
        if changed.LastScan ~= nil and allow_rescan then
            awesome.emit_signal("wifi::networks", get_available_networks(wireless))
        end
    end)

    device:connect_signal(function(proxy, state, old, reason)
        if state == 100 or state <= 30 then
            awesome.emit_signal("wifi::allow_rescan", true)
            awesome.emit_signal("wifi::rescan")
        end
        awesome.emit_signal("wifi::wifi-state", state, reason)
    end, "StateChanged")

    wifi_proxy = wireless
    wifi_device_proxy = device
end

awesome.connect_signal("wifi::rescan", function()
    wifi_proxy:RequestScan({})
end)

local function find_connection_from_ssid(ssid)
    local connections = wifi_device_proxy.AvailableConnections
    local interface = wifi_device_proxy.Interface

    for _, connection_path in ipairs(connections) do
        local connection = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Settings.Connection",
            path = connection_path,
        }

        local settings = connection:GetSettings()
        if settings.connection.id == ssid and settings.connection["interface-name"] == interface then
            return connection
        end
    end

    return nil
end

awesome.connect_signal("wifi::connect", function(network)
    local connection_settings = find_connection_from_ssid(network.ssid)
    local new_connection = connection_settings == nil
    local active_connection_path

    if connection_settings then
        local out = nm_proxy:ActivateConnection(connection_settings.object_path, wifi_device_proxy.object_path,
            network.path)
        active_connection_path = out[1]
    else
        local out = nm_proxy:AddAndActivateConnection2({}, wifi_device_proxy.object_path, network.path,
            { persist = GVariant("s", "volatile") })

        active_connection_path = out[2]
        connection_settings = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Settings.Connection",
            path = out[1],
        }
        naughty.notify { text = out[1], title = "out 1 con_set" }
    end

    -- Connect to the state signal
    if active_connection_path ~= nil then
        local active_connection_proxy = dbus.Proxy:new {
            bus = dbus.Bus.SYSTEM,
            name = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Connection.Active",
            path = active_connection_path,
        }

        if new_connection then
            active_connection_proxy:connect_signal(function(proxy, state, reason)
                if state == 2 then
                    connection_settings:Save()
                end
            end, "StateChanged")

            awesome.connect_signal("wifi::set-password", function(password)
                local settings = connection_settings:GetSettings()
                naughty.notify { text = settings }
                settings["802-11-wireless-security"]["psk"] = GVariant("s", password)
                connection_settings:Update(settings)
            end)
        end
    end
end)



nm_proxy:on_properties_changed(function(proxy, changed, invalidated)
    if changed.Devices ~= nil then
        find_wifi_device()
    end

    if changed.WirelessEnabled ~= nil then
        emit_wireless_state()

        if proxy.WirelessEnabled then
            awesome.emit_signal("wifi::rescan")
        end
    end
end)

awesome.connect_signal("wifi::toggle", function()
    nm_proxy.WirelessEnabled = GVariant("b", (not nm_proxy.WirelessEnabled))
end)


-- Setup inital values and send signals
find_wifi_device()
emit_wireless_state()
awesome.emit_signal("wifi::rescan")
