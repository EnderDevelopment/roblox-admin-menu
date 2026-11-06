local function hasPermission(source)
    return source == 0 or IsPlayerAceAllowed(source, Config.AcePermission)
end

local function notify(source, message, kind)
    TriggerClientEvent('ender_admin:notify', source, tostring(message), kind or 'info')
end

local function getTarget(source, targetId)
    local id = tonumber(targetId)
    if not id or id < 1 or id % 1 ~= 0 or not GetPlayerName(id) then
        notify(source, 'That player is no longer online.', 'error')
        return nil
    end
    return id
end

local function getPlayerList()
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local playerId = tonumber(id)
        players[#players + 1] = {
            id = playerId,
            name = GetPlayerName(playerId) or 'Unknown',
            ping = GetPlayerPing(playerId) or 0
        }
    end
    table.sort(players, function(a, b) return a.id < b.id end)
    return players
end

RegisterNetEvent('ender_admin:requestOpen', function()
    local src = source
    if not hasPermission(src) then
        notify(src, 'You do not have permission to use the admin menu.', 'error')
        return
    end
    TriggerClientEvent('ender_admin:open', src, getPlayerList())
end)

RegisterNetEvent('ender_admin:refreshPlayers', function()
    local src = source
    if not hasPermission(src) then return end
    TriggerClientEvent('ender_admin:players', src, getPlayerList())
end)

RegisterNetEvent('ender_admin:action', function(action, data)
    local src = source
    if not hasPermission(src) or type(action) ~= 'string' or type(data) ~= 'table' then
        if not hasPermission(src) then notify(src, 'Permission denied.', 'error') end
        return
    end

    local reason = tostring(data.reason or ''):gsub('[\r\n]', ' '):sub(1, Config.MaxReasonLength)
    if action == 'kick' then
        local target = getTarget(src, data.id)
        if not target then return end
        if target == src then notify(src, 'You cannot kick yourself.', 'error'); return end
        local displayReason = reason ~= '' and reason or 'Removed by an administrator.'
        DropPlayer(target, 'You were kicked by an administrator. Reason: ' .. displayReason)
        notify(src, ('Kicked %s [%d].'):format(GetPlayerName(target) or 'player', target), 'success')
    elseif action == 'freeze' then
        local target = getTarget(src, data.id)
        if not target then return end
        if target == src then notify(src, 'You cannot freeze yourself.', 'error'); return end
        TriggerClientEvent('ender_admin:freeze', target, data.enabled == true)
        notify(src, (data.enabled and 'Froze ' or 'Unfroze ') .. (GetPlayerName(target) or 'player') .. '.', 'success')
    elseif action == 'heal' or action == 'revive' then
        local target = getTarget(src, data.id)
        if not target then return end
        TriggerClientEvent('ender_admin:healthAction', target, action)
        notify(src, (action == 'heal' and 'Healed ' or 'Revived ') .. (GetPlayerName(target) or 'player') .. '.', 'success')
    elseif action == 'teleportTo' or action == 'bring' then
        local target = getTarget(src, data.id)
        if not target then return end
        if action == 'teleportTo' then
            TriggerClientEvent('ender_admin:teleportToPlayer', src, target)
        else
            if target == src then notify(src, 'You cannot bring yourself.', 'error'); return end
            TriggerClientEvent('ender_admin:bringPlayer', target, src)
        end
        notify(src, action == 'bring' and 'Player brought to you.' or 'Teleported to player.', 'success')
    elseif action == 'announce' then
        local message = tostring(data.message or ''):gsub('[\r\n]', ' '):sub(1, Config.MaxAnnouncementLength)
        if message:match('^%s*$') then notify(src, 'Enter an announcement first.', 'error'); return end
        TriggerClientEvent('ender_admin:announcement', -1, message, GetPlayerName(src) or 'Admin')
        notify(src, 'Announcement sent.', 'success')
    else
        notify(src, 'Unknown admin action.', 'error')
    end
end)
