--
-- Minetest player cloaking mod
--
-- Copyright © 2021 by luk3yx
--

minetest.register_chatcommand('shadow', {
    privs = {cloaking = true, teleport = true},
    description = 'Attaches you to a player. If `victim` is not specified, ' ..
        'this command will detach you instead.',
    params = '[victim]',
    func = function(name, param)
        if not cloaking.is_cloaked(name) then
            return false, 'You must be cloaked to use /shadow!'
        elseif name == param then
            return false, 'You cannot shadow yourself!'
        end
        local player = cloaking.get_player_by_name(name)
        if param == '' then
            player:set_detach()
            return true, 'You are free to move normally.'
        end
        local victim = cloaking.get_player_by_name(param)
        if not victim then
            return false, ('Invalid player %q.'):format(param)
        end
        player:set_attach(victim, '', {x=0, y=0, z=0}, {x=0, y=0, z=0})
        return true, ('You are now shadowing %q.'):format(param)
    end
})

-- Detach on uncloak
minetest.register_on_joinplayer(function(player)
    if not minetest.check_player_privs(player, "cloaking", "teleport") then
        return
    end

    local parent = player:get_attach()
    if minetest.is_player(parent) and parent:is_player() then
        player:set_detach()
    end
end)
