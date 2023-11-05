---@diagnostic disable: undefined-global
local lgi = require "lgi"
local dbus = require "lib.dbus_proxy"
local Gio = lgi.require "Gio"
local GLib = lgi.require "GLib"
local GObject = lgi.require "GObject"

-- enum NMSecretAgentGetSecretsFlags
local NM_SECRET_AGENT_GET_SECRETS_FLAG_NONE = 0x0
local NM_SECRET_AGENT_GET_SECRETS_FLAG_ALLOW_INTERACTION = 0x1
local NM_SECRET_AGENT_GET_SECRETS_FLAG_REQUEST_NEW = 0x2
local NM_SECRET_AGENT_GET_SECRETS_FLAG_USER_REQUESTED = 0x4
local NM_SECRET_AGENT_GET_SECRETS_FLAG_WPS_PBC_ACTIVE = 0x8


-- NetworkManager Connections proxy
local nm_agent_manager_proxy = dbus.Proxy:new {
    bus = dbus.Bus.SYSTEM,
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager.AgentManager",
    path = "/org/freedesktop/NetworkManager/AgentManager",
}

local function unpack_connection(variant)
    -- Ensure the variant is of the expected type
    assert(variant.type == "a{sa{sv}}", "Expected GVariant of type 'a{sa{sv}}'")

    local result = {}

    print(variant:print())
    for i = 0, #variant - 1 do
        local entry = variant:get_child_value(i)
        local setting_name = entry:get_child_value(0).value
        local setting = entry:get_child_value(1)
        result[setting_name] = {}

        for key, value in setting:pairs() do
            result[setting_name][key] = value
        end
    end

    return result
end


local function start_dbus()
    local function busAcquiredCallback(bus, user_data)
        local dbus_interface = [[
            <node>
                <interface name="org.freedesktop.NetworkManager.SecretAgent">
                    <method name="GetSecrets">
                        <arg type="a{sa{sv}}" name="connection" direction="in"/>
                        <arg type="o" name="connection_path" direction="in"/>
                        <arg type="s" name="setting_name" direction="in"/>
                        <arg type="as" name="hints" direction="in"/>
                        <arg type="u" name="flags" direction="in"/>
                        <arg type="a{sa{sv}}" name="secrets" direction="out"/>
                    </method>
                    <method name="CancelGetSecrets">
                        <arg type="o" name="connection_path" direction="in"/>
                        <arg type="s" name="setting_name" direction="in"/>
                    </method>
                    <method name="SaveSecrets">
                        <arg type="a{sa{sv}}" name="connection" direction="in"/>
                        <arg type="o" name="connection_path" direction="in"/>
                    </method>
                    <method name="DeleteSecrets">
                        <arg type="a{sa{sv}}" name="connection" direction="in"/>
                        <arg type="o" name="connection_path" direction="in"/>
                    </method>
                </interface>
            </node>
        ]]

        local interface_info = Gio.DBusNodeInfo.new_for_xml(dbus_interface):lookup_interface(
            "org.freedesktop.NetworkManager.SecretAgent")

        -- See "GDBusInterfaceMethodCallFunc" for types
        local method_call_callback = function(bus, sender, object_path, interface_name, method_name, parameters,
                                              invocation, user_data)
            print("METHOD CALLED " .. method_name)

            if method_name == "GetSecrets" then
                local connection = unpack_connection(parameters:get_child_value(0))
                local dbus_connection_path = parameters[2]
                local setting_name = parameters[3]
                local hints = parameters[4]
                local flags = parameters[5]

                -- TODO: handle the other security types
                -- "ieee8021x"
                -- "owe"
                -- "sae"
                -- "wpa-eap"
                -- "wpa-eap-suite-b-192"

                if (flags & NM_SECRET_AGENT_GET_SECRETS_FLAG_ALLOW_INTERACTION) ~= 0 then
                    local security_type = connection[setting_name]["key-mgmt"].value
                    if security_type == "wpa-psk" then
                        awesome.emit_signal("wifi::password::request", dbus_connection_path)
                        local function set_password(input)
                            if input then
                                connection[setting_name]["psk"] = GLib.Variant("s", input)
                                local value = GLib.Variant("(a{sa{sv}})", { connection })
                                invocation:return_value(value)
                            end
                            awesome.disconnect_signal("wifi::password::set", set_password)
                        end
                        awesome.connect_signal("wifi::password::set", set_password)
                    end
                end
                invocation:return_value(GLib.Variant("(a{sa{sv}})", { connection }))
            elseif method_name == "CancelGetSecrets" then
                local dbus_connection_path = parameters[1]
                local setting_name = parameters[2]
                awesome.emit_signal("wifi::password::cancel", dbus_connection_path)
            elseif method_name == "SaveSecrets" then
            elseif method_name == "DeleteSecrets" then
            end
        end

        bus:register_object("/org/freedesktop/NetworkManager/SecretAgent", interface_info,
            GObject.Closure(method_call_callback))
        -- naughty.notify { text = "Bus acquired." }
        print("Bus acquired.")
        nm_agent_manager_proxy:RegisterWithCapabilities("ca.guibi.awesome-nm-agent", 0x0)
    end

    local function nameAcquiredCallback(connection, name, user_data)
        -- naughty.notify { text = "Name " .. name .. " successfully acquired!" }
        print("Name " .. name .. " successfully acquired!")
    end

    local function nameLostCallback(connection, name, user_data)
        -- naughty.notify { text = "Lost ownership of name " .. name }
        print("Lost ownership of name " .. name)
    end

    local nameOwnerID = Gio.bus_own_name(
        Gio.BusType.SYSTEM,                    -- The bus type (SESSION bus in this case)
        "ca.guibi.awesome-nm-agent",           -- The name you want to own
        Gio.BusNameOwnerFlags.NONE,            -- Flags, you can use NONE or ALLOW_REPLACEMENT or others as needed
        GObject.Closure(busAcquiredCallback),  -- Called when the bus is acquired
        GObject.Closure(nameAcquiredCallback), -- Called when the name is successfully acquired
        GObject.Closure(nameLostCallback),     -- Called when you lose the name or if acquiring fails
        nil,                                   -- User data passed to callbacks (optional)
        nil                                    -- Function to free the user data (optional)
    )
end

start_dbus()
