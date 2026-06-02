-- Local variables
local ESX = nil
local QBCore = nil
local isMenuOpen = false
local currentCooldown = 0
local nearMarket = false
local currentMarket = nil
local npcPed = nil  -- Un seul NPC maintenant
local npcCreated = false

-- Framework detection and loading
local function InitFramework()
    if Config.Framework == "auto" then
        if GetResourceState('es_extended') == 'started' then
            Config.Framework = "esx"
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = "qb"
        else
            print("^1[YS Blackmarket] Error: No compatible framework detected!^7")
        end
    end

    if Config.Framework == "esx" then
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(100)
            end
        end)
    elseif Config.Framework == "qb" then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end

Citizen.CreateThread(function()
    InitFramework()
end)

-- Notification Helper
local function ShowNotification(message, type)
    if Config.Framework == "esx" and ESX then
        ESX.ShowNotification(message)
    elseif Config.Framework == "qb" and QBCore then
        QBCore.Functions.Notify(message, type or "primary")
    else
        -- Native GTA notification fallback
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

-- Standalone DrawText3D function
local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

-- Function to create a completely static NPC
local function CreateNPC(coords, heading)
    -- Supprimer l'ancien NPC s'il existe
    if DoesEntityExist(npcPed) then
        DeleteEntity(npcPed)
    end
    
    local pedModel = GetHashKey(Config.NPCModel)
    
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(10)
    end
    
    local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1.0, heading, false, true)
    
    -- Make NPC completely static
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedConfigFlag(ped, 188, true)
    SetPedConfigFlag(ped, 243, true)
    SetPedConfigFlag(ped, 244, true)
    
    -- Disable all reactions
    SetPedAlertness(ped, 0)
    SetPedCombatAbility(ped, 0)
    SetPedCombatRange(ped, 0)
    SetPedAsEnemy(ped, false)
    SetPedCanBeTargettedByPlayer(ped, PlayerId(), false)
    
    -- Start and lock smoking animation
    TaskStartScenarioInPlace(ped, Config.NPCScenario, 0, true)
    SetPedKeepTask(ped, true)
    
    SetModelAsNoLongerNeeded(pedModel)
    npcCreated = true
    
    return ped
end

-- Initialize NPC ONLY ONCE when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(2000) -- Wait a bit for everything to load
    
    if #Config.BlackmarketPoints > 0 and not npcCreated then
        local point = Config.BlackmarketPoints[1] -- Prend le premier point seulement
        npcPed = CreateNPC(point.coords, point.npcHeading)
        print("^2[YS Blackmarket]^7 NPC created at: " .. point.coords.x .. ", " .. point.coords.y)
    end
end)

-- Single thread to maintain the NPC animation
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every 60 seconds seulement
        
        if DoesEntityExist(npcPed) then
            -- Vérifier si l'animation de fumée est toujours en cours
            if not IsEntityPlayingAnim(npcPed, Config.NPCScenario, 3) then
                -- Redémarrer l'animation seulement
                ClearPedTasksImmediately(npcPed)
                TaskStartScenarioInPlace(npcPed, Config.NPCScenario, 0, true)
                SetPedKeepTask(npcPed, true)
                
                if Config.DebugMode then
                    print("^3[YS Blackmarket]^7 NPC smoking animation restarted")
                end
            end
        else
            -- Recréer le NPC s'il a disparu
            if #Config.BlackmarketPoints > 0 and npcCreated then
                local point = Config.BlackmarketPoints[1]
                npcPed = CreateNPC(point.coords, point.npcHeading)
                print("^3[YS Blackmarket]^7 NPC was missing, recreated")
            end
        end
    end
end)

-- Proximity check to blackmarket points
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNear = false
        local sleep = 1500

        for i, market in ipairs(Config.BlackmarketPoints) do
            local distance = #(playerCoords - market.coords)

            if distance < Config.InteractDistance then
                isNear = true
                currentMarket = market
                sleep = 0

                -- Show 3D help text
                DrawText3D(
                    vector3(market.coords.x, market.coords.y, market.coords.z + 1.0), 
                    Config.HelpText
                )

                -- Open menu with E key
                if IsControlJustPressed(0, Config.InteractKey) and not isMenuOpen then
                    OpenBlackmarketMenu()
                    Citizen.Wait(300)
                end
            end
        end

        nearMarket = isNear
        if not isNear then
            currentMarket = nil
            -- Close menu if player moves away
            if isMenuOpen then
                CloseBlackmarketMenu()
                ShowNotification("~r~You have moved away from the blackmarket.", "error")
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Function to organize items by category for the UI
local function OrganizeItemsByCategory()
    local organized = {}
    
    -- Initialize categories
    for _, category in ipairs(Config.Categories) do
        organized[category.id] = {
            name = category.name,
            icon = category.icon,
            description = category.description,
            items = {}
        }
    end
    
    -- Add "all" category
    organized["all"] = {
        name = "All Items",
        icon = "fa-store",
        description = "All available items",
        items = {}
    }
    
    -- Organize items
    for _, item in ipairs(Config.Items) do
        if organized[item.category] then
            table.insert(organized[item.category].items, item)
        end
        table.insert(organized["all"].items, item)
    end
    
    return organized
end

-- Function to open the blackmarket menu
function OpenBlackmarketMenu()
    if not currentMarket then
        ShowNotification("~r~You must be near the dealer.", "error")
        return
    end
    
    if currentCooldown > GetGameTimer() then
        ShowNotification("~y~Please wait before reopening the menu.", "error")
        return
    end

    isMenuOpen = true
    currentCooldown = GetGameTimer() + 1000

    -- Freeze player and disable controls
    FreezeEntityPosition(PlayerPedId(), true)
    SetNuiFocus(true, true)

    -- Organize items by category and send to NUI
    local organizedItems = OrganizeItemsByCategory()
    
    SendNUIMessage({
        action = 'open',
        categories = Config.Categories,
        itemsByCategory = organizedItems,
        defaultCategory = Config.DefaultCategory,
        uiTitle = Config.UITitle,
        uiLogoIcon = Config.UILogoIcon,
        uiWarning = Config.UIWarning,
        uiCopyright = Config.UICopyright
    })

    -- Play open sound
    SendNUIMessage({ action = 'playSound', sound = 'open' })

    -- Notification
    ShowNotification("~b~Blackmarket ~w~open. Secure transactions.", "success")
end

-- Function to close the menu
function CloseBlackmarketMenu()
    isMenuOpen = false
    SetNuiFocus(false, false)
    FreezeEntityPosition(PlayerPedId(), false)
    SendNUIMessage({ action = 'close' })
    SendNUIMessage({ action = 'playSound', sound = 'close' })
end

-- ESC key to close menu
Citizen.CreateThread(function()
    while true do
        if isMenuOpen then
            if IsControlJustReleased(0, 202) then -- ESC key
                CloseBlackmarketMenu()
            end
        end
        Citizen.Wait(0)
    end
end)

-- NUI callback for closing
RegisterNUICallback('close', function(data, cb)
    CloseBlackmarketMenu()
    cb('ok')
end)

-- NUI callback for purchase
RegisterNUICallback('purchase', function(data, cb)
    local itemId = data.id
    
    if currentCooldown > GetGameTimer() then
        ShowNotification("~r~Please wait before a new purchase.", "error")
        cb({ success = false, message = "Cooldown active" })
        return
    end
    
    currentCooldown = GetGameTimer() + Config.PurchaseCooldown

    -- Play click sound
    SendNUIMessage({ action = 'playSound', sound = 'click' })

    -- Send purchase request to server
    TriggerServerEvent('ys_blackmarket:purchase', itemId)

    cb('ok')
end)

-- NUI callback for category change
RegisterNUICallback('changeCategory', function(data, cb)
    SendNUIMessage({ action = 'playSound', sound = 'click' })
    cb('ok')
end)

-- Event listener for purchase result
RegisterNetEvent('ys_blackmarket:purchaseResult')
AddEventHandler('ys_blackmarket:purchaseResult', function(success, message)
    if success then
        ShowNotification("~g~Purchase successful! ~w~" .. message, "success")
    else
        ShowNotification("~r~Purchase failed. ~w~" .. message, "error")
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CloseBlackmarketMenu()
        
        -- Clean up the single NPC
        if DoesEntityExist(npcPed) then
            DeleteEntity(npcPed)
            print("^2[YS Blackmarket]^7 NPC deleted on resource stop")
        end
    end
end)

-- Cleanup on resource start (remove any existing NPCs)
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        -- Clean up any existing NPCs before creating a new one
        if DoesEntityExist(npcPed) then
            DeleteEntity(npcPed)
        end
        
        -- Reset NPC creation flag
        npcCreated = false
        
        print("^2[YS Blackmarket]^7 Resource started, NPC will be created")
    end
end)

-- Debug command
if Config.DebugMode then
    RegisterCommand('blackmarket_debug', function()
        print("=== BLACKMARKET DEBUG ===")
        print("NPC Exists: " .. tostring(DoesEntityExist(npcPed)))
        print("NPC Created: " .. tostring(npcCreated))
        print("Menu Open: " .. tostring(isMenuOpen))
        print("Near Market: " .. tostring(nearMarket))
        print("Current Market: " .. tostring(currentMarket))
        print("Items in Config: " .. #Config.Items)
        print("Categories: " .. #Config.Categories)
        
        if DoesEntityExist(npcPed) then
            print("NPC Coords: " .. GetEntityCoords(npcPed))
            print("NPC Playing Anim: " .. tostring(IsEntityPlayingAnim(npcPed, Config.NPCScenario, 3)))
        end
        print("=========================")
    end, false)
end