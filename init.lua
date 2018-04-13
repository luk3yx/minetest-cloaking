--
-- Minetest player cloaking mod
--
-- © 2018 by luk3yx
--
local path = minetest.get_modpath('cloaking')
dofile(path .. '/core.lua')
dofile(path .. '/chatcommands.lua')

if chat3 then
    dofile(path .. '/chat3.lua')
end

if irc then
    dofile(path .. '/irc.lua')
end
