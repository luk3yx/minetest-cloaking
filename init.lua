--
-- Minetest player cloaking mod
--
-- © 2020 by luk3yx
--
local path = minetest.get_modpath('cloaking')
dofile(path .. '/core.lua')
dofile(path .. '/chatcommands.lua')

if minetest.get_modpath('chat3') then
    dofile(path .. '/chat3.lua')
end

if minetest.get_modpath('irc') then
    dofile(path .. '/irc.lua')
end

-- Load cloaked chat if enabled
local cloaked_chat = minetest.settings:get_bool('cloaking.enable_cloaked_chat')
if cloaked_chat or cloaked_chat == nil then
    dofile(path .. '/cloaked-chat.lua')
end

-- Load /shadow if enabled
local shadow = minetest.settings:get_bool('cloaking.enable_shadow')
if shadow or shadow == nil then
    dofile(path .. '/shadow.lua')
end

-- The following code is for backporting bugfixes, if the setting was disabled
-- simply return now.
local backport_fixes = minetest.settings:get_bool('cloaking.backport_bugfixes')
if backport_fixes ~= nil and not backport_fixes then
    return
end

-- Enforce security of logs
if not minetest.features.formspec_version_element then
    -- Not required in Minetest 5.0.1 or later.
    table.insert(minetest.registered_on_chat_messages, 1, function(name, msg)
        if msg:find('[\r\n]') then
            minetest.chat_send_player(name,
                'You cannot use newlines in chat messages.')
            return true
        end
    end)
end

-- Stop "%2" from crashing the server
if minetest.format_chat_message then
    local good, _ = pcall(minetest.format_chat_message, 'name', '%2')
    if not good then
        local format_chat_message = minetest.format_chat_message
        function minetest.format_chat_message(name, message)
            return format_chat_message(name, message:gsub('%%', '%%%%'))
        end
    end
end

-- Backport https://github.com/minetest/minetest/pull/10341
-- TODO: Only apply this workaround on vulnerable MT versions.
if minetest.register_allow_player_inventory_action then
    minetest.register_allow_player_inventory_action(function(player, _, inv)
        local inv_location = inv:get_location()
        if inv_location.type == 'player' and
                inv_location.name ~= player:get_player_name() then
            return 0
        end
    end)
end
