--
-- Minetest cloaking mod: IRC fixes
--
-- Copyright © 2019 by luk3yx
--

local irc_sendLocal = irc.sendLocal

function irc.sendLocal(msg)
    for _, player in ipairs(cloaking.get_cloaked_players()) do
        minetest.chat_send_player(player, msg)
    end
    return irc_sendLocal(msg)
end
