--
-- Minetest cloaking mod: chatcommands
--
-- Copyright © 2018-2021 by luk3yx
--

minetest.register_privilege('cloaking',
    'Allows players to cloak and uncloak any in-game player.')

minetest.register_chatcommand("cloak", {
    params = "[victim]",
    description = "Cloak a player so they are not visible.",
    privs = {cloaking = true},
    _allow_while_cloaked = true,
    func = function(name, victim)
        if not victim or victim == '' then
            victim = name
        end

        local p = cloaking.get_player_by_name(victim)
        if not p then
            return false, "Could not find a player with the name '" ..
                victim .. "'!"
        end

        if cloaking.is_cloaked(victim) then
            return false, victim .. " is already cloaked!"
        end

        minetest.log('action', name .. ' cloaks ' .. victim .. '.')
        cloaking.cloak(p)
        return true, "Cloaked!"
    end
})

minetest.register_chatcommand("uncloak", {
    params = "[victim]",
    description = "Uncloak a player so they are visible.",
    _allow_while_cloaked = true,
    func = function(name, victim)
        if not victim or victim == '' then
            victim = name
        elseif not minetest.get_player_privs(name).cloaking then
            return false, "You don't have permission to uncloak someone else."
        end


        if victim == '*' then
            minetest.log('action', name .. ' uncloaks everyone.')
            for _, player in ipairs(cloaking.get_cloaked_players()) do
                cloaking.uncloak(player)
            end
            return true, "Uncloaked everyone!"
        end

        local p = cloaking.get_player_by_name(victim)
        if not p then
            return false, "Could not find a player with the name '" ..
                victim .. "'!"
        end

        if not cloaking.is_cloaked(victim) then
            return false, victim .. " is not cloaked!"
        end

        minetest.log('action', name .. ' uncloaks ' .. victim .. '.')
        cloaking.uncloak(p)
        return true, "Uncloaked!"
    end
})

-- Allow /teleport to be used on cloaked players if you have the "cloaking"
--  privilege.
local tp = minetest.registered_chatcommands['teleport'].func
minetest.override_chatcommand('teleport', {
    func = function(name, param)
        if minetest.check_player_privs(name, 'cloaking') then
            local g = minetest.get_player_by_name
            minetest.get_player_by_name = cloaking.get_player_by_name

            local err, msg = tp(name, param)

            minetest.get_player_by_name = g
            return err, msg
        else
            return tp(name, param)
        end
    end
})
