-- persist_volume.lua
-- Saves and restores global volume level

local utils = require 'mp.utils'
local persist_file = mp.command_native({"expand-path", "~~/volume.txt"})

local function save_volume()
    local volume = mp.get_property_number("volume")
    if volume then
        local f = io.open(persist_file, "w")
        if f then
            f:write(tostring(volume))
            f:close()
        end
    end
end

local function load_volume()
    local f = io.open(persist_file, "r")
    if f then
        local volume = tonumber(f:read("*all"))
        if volume then
            mp.set_property_number("volume", volume)
        end
        f:close()
    end
end

mp.register_event("shutdown", save_volume)
mp.add_hook("on_load", 50, load_volume)
