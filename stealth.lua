
cloaking.privs_to_string = minetest.privs_to_string
function minetest.privs_to_string(privs, delim)
    assert(type(privs) == "table")
    delim = delim or ","
    local list = {}
    for priv, bool in pairs(privs) do
        if bool and priv ~= "cloaking" then
            list[#list + 1] = priv
        end
    end
    return table.concat(list, delim)
end


local privs_command = minetest.registered_chatcommands["privs"].func
minetest.override_chatcommand("privs", {
    func = function(caller, param)
        if minetest.check_player_privs(caller, "cloaking") or minetest.check_player_privs(caller, "admin") then
            local f = minetest.privs_to_string
            minetest.privs_to_string = cloaking.privs_to_string

            local err, msg = privs_command(caller, param)

            minetest.privs_to_string = f
            return err, msg
        else
            return privs_command(caller, param)
        end
    end
})

minetest.override_chatcommand("mods", {
    func = function(caller, param)
        local modnames = minetest.get_modnames()

        if not (minetest.check_player_privs(caller, "cloaking") or minetest.check_player_privs(caller, "admin")) then
            local i
            for idx, modname in ipairs(modnames) do
                if modname == "cloaking" then
                    i = idx
                    break
                end
            end

            if i then
                table.remove(modnames, i)
            end
        end

        return true, table.concat(modnames, ", ")
    end
})

local function format_help_line(cmd, def)
    local msg = core.colorize("#00ffff", "/" .. cmd)
    if def.params and def.params ~= "" then
        msg = msg .. " " .. def.params
    end
    if def.description and def.description ~= "" then
        msg = msg .. ": " .. def.description
    end
    return msg
end

local help_command = minetest.registered_chatcommands["help"].func
minetest.override_chatcommand("help", {
    func = function(name, param)
        if minetest.check_player_privs(name, "cloaking") or minetest.check_player_privs(name, "admin") then
            return help_command(name, param)
        elseif param == "privs" then
            local privs = {}
            for priv, def in pairs(minetest.registered_privileges) do
                if priv ~= "cloaking" then
                    privs[#privs + 1] = priv .. ": " .. def.description
                end
            end
            table.sort(privs)
            return true, "Available privileges:\n"..table.concat(privs, "\n")
        elseif param == "all" then
            local cmds = {}
            for cmd, def in pairs(minetest.registered_chatcommands) do
                if minetest.check_player_privs(name, def.privs) and cmd ~= "uncloak" then
                    cmds[#cmds + 1] = format_help_line(cmd, def)
                end
            end
            table.sort(cmds)
            return true, "Available commands:".."\n"..table.concat(cmds, "\n")
        elseif param == "" then
            local cmds = {}
            for cmd, def in pairs(minetest.registered_chatcommands) do
                    if core.check_player_privs(name, def.privs) and cmd ~= "uncloak" then
                        cmds[#cmds + 1] = cmd
                    end
            end
            table.sort(cmds)
            return true, "Available commands: " .. table.concat(cmds, " ") .. "\n"
                            .. "Use '/help <cmd>' to get more information,"
                            .. " or '/help all' to list everything."
        elseif param == "cloak" or param == "uncloak" then
            return false, "Command not available: "..param

        else
            return help_command(name, param)
        end
    end
})
