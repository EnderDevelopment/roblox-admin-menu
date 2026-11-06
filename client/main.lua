local menuOpen = false
local frozen = false
local actionCooldown = 0

local function setMenu(open, players)
    menuOpen = open
    SetNuiFocus(open, open)
    SendNUIMessage({ type = open and 'open' or 'close', players = players or {} })
end

RegisterCommand(Config.Command, function()
    TriggerServerEvent('ender_admin:requestOpen')
end, false)
RegisterKeyMapping(Config.Command, 'Open the administration menu', 'keyboard', Config.OpenKey)

RegisterNetEvent('ender_admin:open', function(players) setMenu(true, players) end)
RegisterNetEvent('ender_admin:players', function(players)
    if menuOpen then SendNUIMessage({ type = 'players', players = players }) end
end)
RegisterNetEvent('ender_admin:notify', function(message, kind)
    SendNUIMessage({ type = 'toast', message = message, kind = kind })
end)
RegisterNetEvent('ender_admin:freeze', function(enabled)
    frozen = enabled == true
    FreezeEntityPosition(PlayerPedId(), frozen)
end)
RegisterNetEvent('ender_admin:healthAction', function(action)
    local ped = PlayerPedId()
    if action == 'heal' then
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedBloodDamage(ped)
    elseif action == 'revive' then
        if IsEntityDead(ped) then
            local coords = GetEntityCoords(ped)
            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
        end
        local revivedPed = PlayerPedId()
        ClearPedTasksImmediately(revivedPed)
        SetEntityHealth(revivedPed, GetEntityMaxHealth(revivedPed))
        ClearPedBloodDamage(revivedPed)
    end
end)

RegisterNetEvent('ender_admin:teleportToPlayer', function(target)
    local player = GetPlayerFromServerId(target)
    if player == -1 then return end
    local coords = GetEntityCoords(GetPlayerPed(player))
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, false)
end)
RegisterNetEvent('ender_admin:bringPlayer', function(adminId)
    local player = GetPlayerFromServerId(adminId)
    if player == -1 then return end
    local coords = GetEntityCoords(GetPlayerPed(player))
    SetEntityCoords(PlayerPedId(), coords.x + 1.0, coords.y, coords.z, false, false, false, false)
end)
RegisterNetEvent('ender_admin:announcement', function(message, sender)
    SendNUIMessage({ type = 'announcement', message = message, sender = sender })
end)

RegisterNUICallback('close', function(_, cb)
    setMenu(false)
    cb({ ok = true })
end)
RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('ender_admin:refreshPlayers')
    cb({ ok = true })
end)
RegisterNUICallback('action', function(data, cb)
    local now = GetGameTimer()
    if now - actionCooldown < 250 then cb({ ok = false }); return end
    actionCooldown = now
    if type(data) == 'table' then TriggerServerEvent('ender_admin:action', data.action, data) end
    cb({ ok = true })
end)

CreateThread(function()
    while true do
        if frozen then
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            Wait(0)
        else
            Wait(300)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end)
