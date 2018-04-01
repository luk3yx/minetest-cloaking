--
-- Minetest player cloaking mod
--
-- © 2018 by luk3yx
--

cloaking = {}

local real_get_players = minetest.get_connected_players
local cloaked_players = {}

minetest.get_connected_players = function()
    local a = {}
    for _,player in ipairs(real_get_players()) do
        if not cloaked_players[player:get_player_name()] then
            table.insert(a, player)
        end
    end
    return a
end

cloaking.cloak_player = function(player)
    if type(player) == "string" then
        player = minetest.get_player_by_name(player)
    end
    victim = player:get_player_name()
    
    player:set_properties({visual_size = {x = 0, y = 0}, collisionbox = {0,0,0,0,0,0}})
    p:set_nametag_attributes({text = " "})
    
    cloaked_players[victim] = true
    
    minetest.chat_send_all("*** " .. victim .. " left the game")
    if irc then
        irc.say("*** " .. victim .. " left the game")
    end
end

cloaking.uncloak_player = function(player)
    if type(player) == "string" then
        player = minetest.get_player_by_name(player)
    end
    victim = player:get_player_name()
    
    player:set_properties({visual_size = {x = 1, y = 1}, collisionbox = {-0.25,-0.85,-0.25,0.25,0.85,0.25}})
    p:set_nametag_attributes({text = victim})
    
    cloaked_players[victim] = false
    
    minetest.chat_send_all("*** " .. victim .. " joined the game")
    if irc then
        irc.say("*** " .. victim .. " joined the game")
    end
end

minetest.register_on_chat_message(function(name, message)
    if cloaked_players[name] then
        cloaking.uncloak_player(name)
    end
end)

minetest.register_chatcommand("cloak", {
    params = "[victim]",
    description = "Cloak a player so they are not visible.",
    privs = {privs = true}, 
    func = function(player, victim)
        if not victim or victim == '' then
            victim = player
        end
        
        p = minetest.get_player_by_name(victim)
        if not p then
            return false, "Could not find a player with the name '" .. victim .. "'!"
        end
        
        if cloaked_players[victim] then
            return false, victim .. " is already cloaked!"
        end
        
        cloaking.cloak_player(p)
        return true, "Cloaked!"
    end
})

minetest.register_chatcommand("uncloak", {
    params = "[victim]",
    description = "Uncloak a player so they are visible.",
    func = function(player, victim)
        if not victim or victim == '' then
            victim = player
        elseif not minetest.get_player_privs(player).privs then
            return false, "You don't have permission to uncloak someone else."
        end
        
        p = minetest.get_player_by_name(victim)
        if not p then
            return false, "Could not find a player with the name '" .. victim .. "'!"
        end
        
        if not cloaked_players[victim] then
            return false, victim .. " is not cloaked!"
        end
        
        cloaking.uncloak_player(p)
        return true, "Uncloaked!"
    end
})
