--
-- Minetest player cloaking mod
--
-- © 2019 by luk3yx
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

-- Attempt to support older versions of Minetest
local cloaked_chat = 'cloaking.enable_cloaked_chat'
local backport_bugfixes = 'cloaking.backport_bugfixes'
if minetest.settings and minetest.settings.get_bool then
    cloaked_chat = minetest.settings:get_bool(cloaked_chat)
    backport_bugfixes = minetest.settings:get_bool(backport_bugfixes)
else
    cloaked_chat = minetest.setting_getbool(cloaked_chat)
    backport_bugfixes = minetest.setting_getbool(backport_bugfixes)
end

-- Load cloaked chat if enabled
if cloaked_chat or cloaked_chat == nil then
    dofile(path .. '/cloaked-chat.lua')
end

-- The following code is for backporting bugfixes, if the setting was disabled
-- simply return now.
if backport_bugfixes ~= nil and not backport_bugfixes then
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

local log = minetest.log
function minetest.log(level, text)
    level = level:gsub('[\r\n]', '  ')
    if text then
        text  = text:gsub('[\r\n]', '  ')
    else
        text  = level
        level = 'none'
    end
    return log(level, text)
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
