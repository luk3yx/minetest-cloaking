--
-- Minetest player cloaking mod: Core functions
--
-- © 2018 by luk3yx
--

cloaking = {}

-- Expose the real get_connected_players and get_player_by_name for mods that
--   can use them.
cloaking.get_connected_players = minetest.get_connected_players
cloaking.get_player_by_name = minetest.get_player_by_name

local cloaked_players = {}

-- Override built-in functions
minetest.get_connected_players = function()
    local a = {}
    for _, player in ipairs(cloaking.get_connected_players()) do
        if not cloaked_players[player:get_player_name()] then
            table.insert(a, player)
        end
    end
    return a
end

minetest.get_player_by_name = function(player)
    if cloaked_players[player] then
        return nil
    else
        return cloaking.get_player_by_name(player)
    end
end

-- Override chatcommands
minetest.register_chatcommand("status", {
    description = "Print server status",
    func = function(name, param)
        local status = minetest.get_server_status()
        status = status:sub(1, status:find('{', 1, true))
        local players = {}
        for _, player in ipairs(minetest.get_connected_players()) do
            table.insert(players, player:get_player_name())
        end
        players = table.concat(players, ', ')
        status = status .. players .. '}'
        return true, status
    end
})

-- The cloak and uncloak functions
cloaking.cloak = function(player)
    if type(player) == "string" then
        player = cloaking.get_player_by_name(player)
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

cloaking.uncloak = function(player)
    if type(player) == "string" then
        player = cloaking.get_player_by_name(player)
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

-- Auto-uncloaking
local auto_uncloak = function(player)
    if type(player) ~= "string" then
        player = player:get_player_name()
    end
    if cloaked_players[player] then
        cloaking.uncloak(player)
    end
end

minetest.register_on_chat_message(auto_uncloak)
minetest.register_on_leaveplayer(auto_uncloak)

-- API functions
cloaking.get_cloaked_players = function()
    local players = {}
    for player, cloaked in pairs(cloaked_players) do
        if cloaked then
            table.insert(players, player)
        end
    end
    return players
end

cloaking.is_cloaked = function(player)
    if type(player) ~= "string" then player = player:get_player_name() end
    return cloaked_players[player] and true or false
end
