--
-- Minetest cloaking mod: chat3 fixes
--
-- © 2018 by luk3yx
--

-- Override minetest.get_connected_players() so it lists cloaked players for
--   chat3.
local get_uncloaked_players = minetest.get_connected_players

minetest.get_connected_players = function()
    local d = debug.getinfo(2)
    if d.func == chat3.send or d.func == minetest.chatcommands['me'].func then
        return cloaking.get_connected_players()
    else
        return get_uncloaked_players()
    end
end

-- Override get_player_by_name() to allow chat3 to access cloaked players.
local get_uncloaked_player_by_name = minetest.get_player_by_name

minetest.get_player_by_name = function(player)
    local d = debug.getinfo(2)
    if d.func == chat3.send or d.func == minetest.chatcommands["me"].func then
        return cloaking.get_player_by_name(player)
    else
        return get_uncloaked_player_by_name(player)
    end
end

-- Override chat3.colorize to work around not being able to use
--   minetest.register_on_chat_message() with chat3.
local original_colorize = chat3.colorize
chat3.colorize = function(name, colour, msg)
    local pattern = '<' .. name .. '> '
    if msg:sub(1, pattern:len()) == pattern then
        cloaking.auto_uncloak(name)
    end  
    return original_colorize(name, colour, msg)
end
