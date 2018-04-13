--
-- Minetest cloaking mod: IRC fixes
--
-- © 2018 by luk3yx
--

local irc_sendLocal = irc.sendLocal

irc.sendLocal = function(msg)
    for _, player in ipairs(cloaking.get_cloaked_players()) do
        minetest.chat_send_player(player, msg)
    end
    return irc_sendLocal(msg)
end
