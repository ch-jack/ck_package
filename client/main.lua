
CK = nil
CPlayer = nil
Type = "package"

Citizen.CreateThread(function()
    while CK == nil do
        TriggerEvent('CK:GetCoreObject', function(obj) CK = obj end)
        Citizen.Wait(50)
    end
    CPlayer = CK.Player
end)

RegisterNetEvent('CK:KeyF5')
AddEventHandler('CK:KeyF5', function()
	openInventory()
end)

function openInventory()
    Type = "package"
    loadPlayerInventory()
    isInInventory = true
    SendNUIMessage(
        {
            action = "display",
            type = "normal"
        }
    )
    SetNuiFocus(true, true)
end

function closeInventory()
    isInInventory = false
    SendNUIMessage(
        {
            action = "hide"
        }
    )
    SetNuiFocus(false, false)
end

RegisterNUICallback("NUIFocusOff",function()
    closeInventory()
end)

RegisterNUICallback("UseItem",function(data, cb)
    if CPlayer.GetObj("package")[data.name] then
        CK.SendData("CK:UseItem", data.name, data.count)
    end
    closeInventory()
    cb("ok")
end)

RegisterNUICallback("DropItem", function(data, cb)
    if IsPedSittingInAnyVehicle(CPlayer.PlayerPedId) then
        return
    end

    if CPlayer.GetObj("package")[data.name] then
        CK.SendData("CK:RemovePackage", data.name, data.count)
    end

    cb("ok")
end)

RegisterNUICallback("GiveItem", function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true
            end
        end
    end

    if foundPlayer then
        local count = tonumber(data.number)

        if data.item.type == "item_weapon" then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end

        TriggerServerEvent("esx:giveInventoryItem", data.player, data.item.type, data.item.name, count)
        Wait(250)
        loadPlayerInventory()
    else
        TriggerEvent('esx:showNotification', _U("player_nearby"))
    end
    cb("ok")
end)

function loadPlayerInventory()
	-- SendNUIMessage(
		-- {
			-- action = "setInfoText",
			-- text = "<strong>我的背包</strong><br>" .. GetPlayerName(PlayerId())
		-- }
	-- )
    local items = {}

    if CPlayer.GetObj("package") then
        for key, value in pairs(CPlayer.GetObj("package")) do
            value.type = "item_standard"
            table.insert(items, value)
        end
    end
    -- if Config.IncludeWeapons and weapons ~= nil then
    --     for key, value in pairs(weapons) do
    --         local weaponHash = GetHashKey(value.name)
    --         local playerPed = PlayerPedId()
    --         if HasPedGotWeapon(playerPed, weaponHash, false) and value.name ~= "WEAPON_UNARMED" then
    --             -- local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
    --             table.insert(
    --                 items,
    --                 {
    --                     label = value.label,
    --                     count = value.ammo,
    --                     limit = -1,
    --                     type = "item_weapon",
    --                     name = value.name,
    --                     usable = false,
    --                     rare = false,
    --                     canRemove = true
    --                 }
    --             )
    --         end
    --     end
    -- end
    SendNUIMessage(
        {
            action = "setItems",
            itemList = items
        }
    )
end