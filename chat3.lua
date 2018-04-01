--
-- Minetest cloaking mod: chat3 fixes
--
-- © 2018 by luk3yx
--

-- Override minetest.get_connected_players() yet again
local get_uncloaked_players = minetest.get_connected_players

minetest.get_connected_players = function()
    local d = debug.getinfo(2)
    if d.func == chat3.send then
        return cloaking.get_connected_players()
    else
        return get_uncloaked_players()
    end
end

local get_uncloaked_player_by_name = minetest.get_player_by_name

minetest.get_player_by_name = function(player)
    local d = debug.getinfo(2)
    if d.func == chat3.send then
        return cloaking.get_player_by_name(player)
    else
        return get_uncloaked_player_by_name(player)
    end
end
