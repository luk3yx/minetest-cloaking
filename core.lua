--
-- Minetest player cloaking mod: Core functions
--
-- © 2019 by luk3yx
--

cloaking = {}

-- Expose the real get_connected_players and get_player_by_name for mods that
--   can use them.
cloaking.get_player_by_name         = minetest.get_player_by_name
cloaking.get_objects_inside_radius  = minetest.get_objects_inside_radius
cloaking.get_server_status          = minetest.get_server_status

local cloaked_players = {}
local chatcommands_modified = false

-- Override built-in functions
function minetest.get_player_by_name(player)
    if cloaked_players[player] then
        return nil
    else
        return cloaking.get_player_by_name(player)
    end
end

function minetest.get_objects_inside_radius(pos, radius)
    local objs = {}
    for _, obj in ipairs(cloaking.get_objects_inside_radius(pos, radius)) do
        if not cloaked_players[obj:get_player_name()] then
            table.insert(objs, obj)
        end
    end
    return objs
end

function minetest.get_server_status()
    local status = cloaking.get_server_status()
    local motd   = status:sub(status:find('}', 1, true) + 0)
    status = status:sub(1, status:find('{', 1, true))
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        table.insert(players, player:get_player_name())
    end
    players = table.concat(players, ', ')
    status = status .. players .. motd
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
        if not def.allow_while_cloaked and not def._allow_while_cloaked then
            local real_cmd = def.func
            minetest.chatcommands[name].func = function(name, param)
                if cloaked_players[name] then
                    local pass, r1, r2
                    if def._disallow_while_cloaked then
                        pass = false
                    else
                        pass, r1, r2 = pcall(real_cmd, name, param)
                    end
                    if pass then
                        return r1, r2
                    else
                        return false, "You may not execute this chatcommand " ..
                            "while cloaked. Please use /uncloak if you want " ..
                            "to execute this chatcommand."
                    end
                else
                    return real_cmd(name, param)
                end
            end
        end
    end

    local c = 0
    for _, func in ipairs(minetest.registered_on_leaveplayers) do
        c = c + 1
        local f = func
        if f ~= cloaking.delayed_uncloak then
            minetest.registered_on_leaveplayers[c] = function(p, t, cloaked)
                if cloaked ~= 'cloaking' and
                  cloaked_players[p:get_player_name()] then
                    return
                end
                return f(p, t)
            end
        end
    end
end

-- Handle chat messages
function cloaking.on_chat_message(name, message)
    if message:sub(1, 1) ~= "/" and cloaked_players[name] then
        minetest.chat_send_player(name, "You cannot use chat while cloaked." ..
            " Please use /uncloak if you want to use chat.")
        return true
    end
end

table.insert(minetest.registered_on_chat_messages, 1, cloaking.on_chat_message)
minetest.callback_origins[cloaking.on_chat_message] = {
    mod  = 'cloaking',
    name = 'on_chat_message'
}

-- Disallow some built-in commands.
for _, cmd in ipairs({'me', 'msg'}) do
    if minetest.chatcommands[cmd] then
        minetest.override_chatcommand(cmd, {
            _disallow_while_cloaked = true
        })
    end
end

-- The cloak and uncloak functions
local use_areas = minetest.get_modpath('areas')
function cloaking.cloak(player)
    if not chatcommands_modified then override_chatcommands() end
    if type(player) == "string" then
        player = cloaking.get_player_by_name(player)
    end
    local victim = player:get_player_name()

    if cloaked_players[victim] then
        return
    end

    player:set_properties({visual_size = {x = 0, y = 0}, collisionbox = {0,0,0,0,0,0}})
    player:set_nametag_attributes({text = " "})

    local t = nil
    if use_areas and areas.hud[victim] then
        t = areas.hud[victim]
    end

    for _, f in ipairs(minetest.registered_on_leaveplayers) do
        if f ~= cloaking.delayed_uncloak then
            f(player, false, 'cloaking')
        end
    end

    cloaked_players[victim] = true

    if t then
        areas.hud[victim] = t
        player:hud_change(areas.hud[victim].areasId, "text", "Cloaked")
        areas.hud[victim].oldAreas = ""
    end

    minetest.log('verbose', victim .. ' was cloaked.')
end

function cloaking.uncloak(player)
    if type(player) == "string" then
        player = cloaking.get_player_by_name(player)
    end
    local victim = player:get_player_name()

    if not cloaked_players[victim] then
        return
    end

    player:set_properties({visual_size = {x = 1, y = 1},
        collisionbox = {-0.25,-0.85,-0.25,0.25,0.85,0.25}})
    player:set_nametag_attributes({text = victim})

    cloaked_players[victim] = nil

    -- In singleplayer, there is no joined the game message by default.
    if victim == "singleplayer" then
        minetest.chat_send_all("*** " .. victim .. " joined the game.")
    end

    for _, f in ipairs(minetest.registered_on_joinplayers) do
        f(player)
    end

    minetest.log('verbose', victim .. ' was uncloaked.')
end

-- API functions
function cloaking.auto_uncloak(player)
    if type(player) ~= "string" then
        player = player:get_player_name()
    end
    if cloaked_players[player] then
        cloaking.uncloak(player)
    end
end

function cloaking.delayed_uncloak(player)
    local victim = player:get_player_name()
    if cloaked_players[victim] then
        minetest.after(0.5, function()
            cloaked_players[victim] = nil
            if areas and areas.hud and areas.hud[victim] then
                areas.hud[victim] = nil
            end
        end)
    end
end

-- Register cloaking.delayed_uncloak "manually" so that the profiler can't
--   hijack it, preventing it from running.
minetest.registered_on_leaveplayers[#minetest.registered_on_leaveplayers + 1]
    = cloaking.delayed_uncloak
minetest.callback_origins[cloaking.delayed_uncloak] = {
    mod  = 'cloaking',
    name = 'delayed_uncloak'
}

-- The cloaking mod is so good it fools the built-in get_connected_players, so
--   overlay that with one that adds cloaked players in.
function cloaking.get_connected_players()
    local a = minetest.get_connected_players()
    for player, cloaked in pairs(cloaked_players) do
        if cloaked then
            table.insert(a, cloaking.get_player_by_name(player))
        end
    end
    return a
end

function cloaking.get_cloaked_players()
    local players = {}
    for player, cloaked in pairs(cloaked_players) do
        if cloaked then
            table.insert(players, player)
        end
    end
    return players
end

-- Allow mods to get a list of cloaked and uncloaked player names.
function cloaking.get_connected_names()
    local a = cloaking.get_cloaked_players()
    for _, player in ipairs(minetest.get_connected_players()) do
        table.insert(a, player:get_player_name())
    end
    return a
end

function cloaking.is_cloaked(player)
    if type(player) ~= "string" then player = player:get_player_name() end
    return cloaked_players[player] and true or false
end

-- Prevent cloaked players dying
minetest.register_on_player_hpchange(function(player, hp_change)
    if player and hp_change < 0 then
        local name = player:get_player_name()
        if cloaked_players[name] then
            hp_change = 0 - hp_change
        end
    end
    return hp_change
end, true)
