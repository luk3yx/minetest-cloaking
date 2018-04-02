--
-- Minetest player cloaking mod: Core functions
--
-- © 2018 by luk3yx
--

cloaking = {}

-- Expose the real get_connected_players and get_player_by_name for mods that
--   can use them.
cloaking.get_connected_players      = minetest.get_connected_players
cloaking.get_player_by_name         = minetest.get_player_by_name
cloaking.get_objects_inside_radius  = minetest.get_objects_inside_radius
cloaking.get_server_status          = minetest.get_server_status

local cloaked_players = {}
local chatcommands_modified = false

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

minetest.get_objects_inside_radius = function(pos, radius)
    local objs = {}
    for _, obj in ipairs(cloaking.get_objects_inside_radius(pos, radius)) do
        if not cloaked_players[obj:get_player_name()] then
            table.insert(objs, obj)
        end
    end
    return objs
end

minetest.get_server_status = function()
    local status = cloaking.get_server_status()
    status = status:sub(1, status:find('{', 1, true))
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        table.insert(players, player:get_player_name())
    end
    players = table.concat(players, ', ')
    status = status .. players .. '}'
    return status
end

-- Change the on-join status
minetest.settings:set_bool('show_statusline_on_connect', false)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    minetest.chat_send_player(name, minetest.get_server_status())
end)

-- Don't allow chat or chatcommands in all commands that don't have the
--   allow_while_cloaked parameter set.
local override_chatcommands = function()
    for name, def in pairs(minetest.chatcommands) do
        if not def.allow_while_cloaked then
            local real_cmd = def.func
            minetest.chatcommands[name].func = function(name, param)
                if cloaked_players[name] then
                    return false, "You may not execute most chatcommands " ..
                        "while cloaked. Please use /uncloak if you want "  ..
                        "to execute a chatcommand."
                else
                    return real_cmd(name, param)
                end
            end
        end
    end
end

minetest.register_on_chat_message(function(name)
    if cloaked_players[name] then
        minetest.chat_send_player(name, "You cannot use chat while cloaked." ..
            " Please use /uncloak if you want to use chat.")
        return true
    end
end)

-- Allow some commands through the above restriction.
for _, cmd in ipairs({'status', 'kick', 'ban', 'xban', 'xtempban', 'help'}) do
    if minetest.chatcommands[cmd] then
        minetest.override_chatcommand(cmd, {
            allow_while_cloaked = true
        })
    end
end

-- The cloak and uncloak functions
cloaking.cloak = function(player)
    if not chatcommands_modified then override_chatcommands() end
    if type(player) == "string" then
        player = cloaking.get_player_by_name(player)
    end
    victim = player:get_player_name()
    
    player:set_properties({visual_size = {x = 0, y = 0}, collisionbox = {0,0,0,0,0,0}})
    p:set_nametag_attributes({text = " "})
    
    cloaked_players[victim] = true
    
    local t = nil
    if areas and areas.hud and areas.hud[victim] then
        t = areas.hud[victim]
    end
    
    for _, f in ipairs(minetest.registered_on_leaveplayers) do
        if f ~= cloaking.auto_uncloak then
            f(p)
        end
    end
    
    if t then
        areas.hud[victim] = t
        p:hud_change(areas.hud[victim].areasId, "text", "Cloaked")
        areas.hud[victim].oldAreas = "" 
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
    
    if not chat3 then
        minetest.chat_send_all("*** " .. victim .. " joined the game.")
    end
    
    for _, f in ipairs(minetest.registered_on_joinplayers) do
        if f ~= cloaking.auto_uncloak then
            f(p)
        end
    end
end

-- Auto-uncloaking
cloaking.auto_uncloak = function(player)
    if type(player) ~= "string" then
        player = player:get_player_name()
    end
    if cloaked_players[player] then
        cloaking.uncloak(player)
    end
end

minetest.register_on_leaveplayer(cloaking.auto_uncloak)


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
