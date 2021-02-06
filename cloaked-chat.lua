--
-- Minetest player cloaking mod: "Cloaked chat"
--
-- Copyright © 2019 by luk3yx
--

cloaking.chat = {prefix = '-Cloaked-'}

-- Send a message to all players with the "cloaking" privilege.
function cloaking.chat.send(msg)
    -- Add the "cloaked chat" prefix and remove newlines.
    msg = msg:gsub('[\r\n]', ' ')

    -- Log the chat message
    minetest.log('action', 'CLOAKED CHAT: ' .. msg)

    -- Send the message to everyone with the "cloaking" priv.
    msg = cloaking.chat.prefix .. ' ' .. msg
    for _, name in ipairs(cloaking.get_connected_names()) do
        if minetest.check_player_privs(name, 'cloaking') then
            minetest.chat_send_player(name, msg)
        end
    end
end

-- Create a '/cloak_chat' command
minetest.register_chatcommand('cloak_chat', {
    params = '<message>',
    description = 'Send a chat message to cloaked players.',
    privs = {cloaking = true},
    _allow_while_cloaked = true,

    func = function(name, param)
        cloaking.chat.send('<' .. name .. '> ' .. param)
    end
})
minetest.registered_chatcommands['cloak-chat'] =
    minetest.registered_chatcommands['cloak_chat']

-- Override cloaking.on_chat_message
function cloaking.on_chat_message(name, message)
    if message:sub(1, 1) ~= "/" and cloaking.is_cloaked(name) then
        if minetest.check_player_privs(name, 'cloaking') then
            cloaking.chat.send('<' .. name .. '> ' .. message)
        else
            minetest.chat_send_player(name, "You cannot use chat while" ..
                " cloaked. Please use /uncloak if you want to use chat.")
        end
        return true
    end
end

minetest.registered_on_chat_messages[1] = cloaking.on_chat_message
