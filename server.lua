-- server.lua for YS Blackmarket (Storm Development) - Multi-Framework & Multi-Inventory
local ESX = nil
local QBCore = nil
local purchaseCooldowns = {}
local detectedInventory = nil

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
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        if ESX == nil then
            pcall(function()
                ESX = exports['es_extended']:getSharedObject()
            end)
        end
    elseif Config.Framework == "qb" then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end

Citizen.CreateThread(function()
    InitFramework()
end)

-- Function to get item configuration
local function GetItemConfig(itemId)
    for _, item in ipairs(Config.Items) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

-- Get player object from framework
local function GetPlayer(src)
    if Config.Framework == "esx" and ESX then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == "qb" and QBCore then
        return QBCore.Functions.GetPlayer(src)
    end
    return nil
end

-- Get player identifier (Citizen ID for QB, License/Steam for ESX)
local function GetPlayerIdentifier(xPlayer)
    if Config.Framework == "esx" then
        return xPlayer.identifier
    elseif Config.Framework == "qb" then
        return xPlayer.PlayerData.citizenid
    end
    return nil
end

-- Get player name
local function GetPlayerName(xPlayer)
    if Config.Framework == "esx" then
        return xPlayer.getName()
    elseif Config.Framework == "qb" then
        return xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
    end
    return "Unknown"
end

-- Centralized inventory detection function
local function GetInventoryType()
    if detectedInventory then
        return detectedInventory
    end

    local invType = Config.Inventory
    if invType == "auto" then
        if GetResourceState('ox_inventory') == 'started' then
            invType = "ox"
        elseif GetResourceState('qs-inventory') == 'started' then
            invType = "qs"
        elseif GetResourceState('codem-inventory') == 'started' or GetResourceState('m-inventory') == 'started' then
            invType = "codem"
        elseif GetResourceState('core_inventory') == 'started' then
            invType = "core"
        elseif GetResourceState('brutal_inventory') == 'started' then
            invType = "brutal"
        elseif GetResourceState('origen_inventory') == 'started' then
            invType = "origen"
        elseif GetResourceState('tgiann-inventory') == 'started' then
            invType = "tgiann"
        elseif GetResourceState('ak47_inventory') == 'started' or GetResourceState('ak47_qb_inventory') == 'started' then
            invType = "ak47"
        elseif GetResourceState('disc-inventoryhud') == 'started' then
            invType = "disc"
        elseif GetResourceState('chezza-inventory') == 'started' or GetResourceState('inventory') == 'started' then
            if exports['inventory'] and exports['inventory'].AddItem then
                invType = "chezza"
            end
        end
        
        -- Fallback if no specific inventory is detected
        if invType == "auto" then
            if Config.Framework == "qb" then
                invType = "qb"
            elseif Config.Framework == "esx" then
                invType = "esx"
            end
        end
    end

    detectedInventory = invType
    return detectedInventory
end

-- Helper fallbacks for framework inventory interactions
local function GetItemCountFallback(xPlayer, src, itemName)
    if Config.Framework == "qb" then
        local item = xPlayer.Functions.GetItemByName(itemName)
        return item and item.amount or 0
    elseif Config.Framework == "esx" then
        local item = xPlayer.getInventoryItem(itemName)
        return item and item.count or 0
    end
    return 0
end

local function RemoveItemFallback(xPlayer, src, itemName, amount)
    if Config.Framework == "qb" then
        return xPlayer.Functions.RemoveItem(itemName, amount)
    elseif Config.Framework == "esx" then
        xPlayer.removeInventoryItem(itemName, amount)
        return true
    end
    return false
end

local function AddItemFallback(xPlayer, src, itemName, amount)
    if Config.Framework == "qb" then
        return xPlayer.Functions.AddItem(itemName, amount)
    elseif Config.Framework == "esx" then
        xPlayer.addInventoryItem(itemName, amount)
        return true
    end
    return false
end

-- Helper function to check player money
local function GetPlayerMoney(xPlayer, src)
    if Config.UseItemAsMoney then
        local invType = GetInventoryType()

        if invType == "ox" then
            local item = exports.ox_inventory:GetItem(src, Config.MoneyItem, nil, false)
            return item and item.count or 0
        elseif invType == "qs" then
            if exports['qs-inventory'] and exports['qs-inventory'].GetItemTotalAmount then
                return exports['qs-inventory']:GetItemTotalAmount(src, Config.MoneyItem) or 0
            end
            return GetItemCountFallback(xPlayer, src, Config.MoneyItem)
        elseif invType == "codem" then
            local codemExport = exports['codem-inventory'] or exports['m-inventory']
            if codemExport and codemExport.GetItemCount then
                return codemExport:GetItemCount(src, Config.MoneyItem) or 0
            end
            return GetItemCountFallback(xPlayer, src, Config.MoneyItem)
        elseif invType == "chezza" then
            if exports['inventory'] and exports['inventory'].GetItemCount then
                return exports['inventory']:GetItemCount(src, Config.MoneyItem) or 0
            end
            return GetItemCountFallback(xPlayer, src, Config.MoneyItem)
        elseif invType == "tgiann" then
            if exports['tgiann-inventory'] and exports['tgiann-inventory'].GetItemCount then
                return exports['tgiann-inventory']:GetItemCount(src, Config.MoneyItem) or 0
            end
            return GetItemCountFallback(xPlayer, src, Config.MoneyItem)
        else
            return GetItemCountFallback(xPlayer, src, Config.MoneyItem)
        end
    else
        if Config.Framework == "esx" then
            local account = xPlayer.getAccount(Config.MoneyType)
            return account and account.money or 0
        elseif Config.Framework == "qb" then
            return xPlayer.Functions.GetMoney(Config.MoneyType) or 0
        end
    end
    return 0
end

-- Helper function to remove player money
local function RemovePlayerMoney(xPlayer, src, amount)
    if Config.UseItemAsMoney then
        local invType = GetInventoryType()

        if invType == "ox" then
            return exports.ox_inventory:RemoveItem(src, Config.MoneyItem, amount)
        elseif invType == "qs" then
            if exports['qs-inventory'] and exports['qs-inventory'].RemoveItem then
                return exports['qs-inventory']:RemoveItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "codem" then
            local codemExport = exports['codem-inventory'] or exports['m-inventory']
            if codemExport and codemExport.RemoveItem then
                return codemExport:RemoveItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "core" then
            if exports['core_inventory'] and exports['core_inventory'].removeItem then
                return exports['core_inventory']:removeItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "chezza" then
            if exports['inventory'] and exports['inventory'].RemoveItem then
                return exports['inventory']:RemoveItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "tgiann" then
            if exports['tgiann-inventory'] and exports['tgiann-inventory'].RemoveItem then
                return exports['tgiann-inventory']:RemoveItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "brutal" then
            if exports['brutal_inventory'] and exports['brutal_inventory'].RemoveItem then
                return exports['brutal_inventory']:RemoveItem(src, Config.MoneyItem, amount)
            end
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        else
            return RemoveItemFallback(xPlayer, src, Config.MoneyItem, amount)
        end
    else
        if Config.Framework == "esx" then
            xPlayer.removeAccountMoney(Config.MoneyType, amount)
            return true
        elseif Config.Framework == "qb" then
            return xPlayer.Functions.RemoveMoney(Config.MoneyType, amount, "blackmarket-purchase")
        end
    end
    return false
end

-- Helper function to add player money (for refund)
local function AddPlayerMoney(xPlayer, src, amount)
    if Config.UseItemAsMoney then
        local invType = GetInventoryType()

        if invType == "ox" then
            return exports.ox_inventory:AddItem(src, Config.MoneyItem, amount)
        elseif invType == "qs" then
            if exports['qs-inventory'] and exports['qs-inventory'].AddItem then
                return exports['qs-inventory']:AddItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "codem" then
            local codemExport = exports['codem-inventory'] or exports['m-inventory']
            if codemExport and codemExport.AddItem then
                return codemExport:AddItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "core" then
            if exports['core_inventory'] and exports['core_inventory'].addItem then
                return exports['core_inventory']:addItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "chezza" then
            if exports['inventory'] and exports['inventory'].AddItem then
                return exports['inventory']:AddItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "tgiann" then
            if exports['tgiann-inventory'] and exports['tgiann-inventory'].AddItem then
                return exports['tgiann-inventory']:AddItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        elseif invType == "brutal" then
            if exports['brutal_inventory'] and exports['brutal_inventory'].AddItem then
                return exports['brutal_inventory']:AddItem(src, Config.MoneyItem, amount)
            end
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        else
            return AddItemFallback(xPlayer, src, Config.MoneyItem, amount)
        end
    else
        if Config.Framework == "esx" then
            xPlayer.addAccountMoney(Config.MoneyType, amount)
            return true
        elseif Config.Framework == "qb" then
            return xPlayer.Functions.AddMoney(Config.MoneyType, amount, "blackmarket-refund")
        end
    end
    return false
end

-- Helper function to add item to player's inventory
local function AddItemToInventory(src, xPlayer, itemId, itemConfig)
    local quantity = 1
    if itemConfig.stack and itemConfig.stack > 1 then
        quantity = itemConfig.stack
    end

    local invType = GetInventoryType()

    local metadata = {}
    if itemConfig.itemType == "weapon" then
        metadata.ammo = itemConfig.ammo or 30
        metadata.components = {}
        metadata.durability = 100
        metadata.serial = (Config.SerialPrefix or "YS-") .. math.random(10000000, 99999999)
        metadata.registered = false
    end

    if invType == "ox" then
        if not exports.ox_inventory then return false, "ox_inventory_not_available" end
        local success = exports.ox_inventory:AddItem(src, itemId, quantity, metadata)
        return success, success and "success" or "inventory_full"

    elseif invType == "qs" then
        if not exports['qs-inventory'] then return false, "qs_inventory_not_available" end
        local success = exports['qs-inventory']:AddItem(src, itemId, quantity, nil, metadata)
        return success, success and "success" or "inventory_full"

    elseif invType == "codem" then
        local codemExport = exports['codem-inventory'] or exports['m-inventory']
        if codemExport then
            local success = codemExport:AddItem(src, itemId, quantity, nil, metadata)
            return success, success and "success" or "inventory_full"
        else
            return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"
        end

    elseif invType == "core" then
        if not exports['core_inventory'] then return false, "core_inventory_not_available" end
        local success = exports['core_inventory']:addItem(src, itemId, quantity, metadata)
        return success, success and "success" or "inventory_full"

    elseif invType == "chezza" then
        if exports['inventory'] and exports['inventory'].AddItem then
            local success = exports['inventory']:AddItem(src, itemId, quantity, metadata)
            return success, success and "success" or "inventory_full"
        end
        return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"

    elseif invType == "tgiann" then
        if exports['tgiann-inventory'] and exports['tgiann-inventory'].AddItem then
            local success = exports['tgiann-inventory']:AddItem(src, itemId, quantity, false, metadata, true)
            return success, success and "success" or "inventory_full"
        end
        return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"

    elseif invType == "brutal" then
        if exports['brutal_inventory'] then
            if exports['brutal_inventory'].AddItem then
                local success = exports['brutal_inventory']:AddItem(src, itemId, quantity, metadata)
                return success, success and "success" or "inventory_full"
            elseif exports['brutal_inventory'].AddInventoryItem then
                local success = exports['brutal_inventory']:AddInventoryItem(src, itemId, quantity, metadata)
                return success, success and "success" or "inventory_full"
            end
        end
        return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"

    elseif invType == "origen" then
        if exports['origen_inventory'] and exports['origen_inventory'].AddItem then
            local success = exports['origen_inventory']:AddItem(src, itemId, quantity, metadata)
            return success, success and "success" or "inventory_full"
        end
        return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"

    elseif invType == "ak47" then
        if exports['ak47_inventory'] and exports['ak47_inventory'].AddItem then
            local success = exports['ak47_inventory']:AddItem(src, itemId, quantity, metadata)
            return success, success and "success" or "inventory_full"
        elseif exports['ak47_qb_inventory'] and exports['ak47_qb_inventory'].AddItem then
            local success = exports['ak47_qb_inventory']:AddItem(src, itemId, quantity, metadata)
            return success, success and "success" or "inventory_full"
        end
        return AddItemFallback(xPlayer, src, itemId, quantity) and true or false, "inventory_full"

    elseif invType == "disc" then
        if Config.Framework == "esx" then
            xPlayer.addInventoryItem(itemId, quantity)
            return true, "success"
        end
        return false, "framework_mismatch"

    elseif invType == "qb" then
        local success = xPlayer.Functions.AddItem(itemId, quantity, nil, metadata)
        if success then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemId], "add")
            return true, "success"
        else
            return false, "inventory_full"
        end

    elseif invType == "esx" then
        if xPlayer.canCarryItem and not xPlayer.canCarryItem(itemId, quantity) then
            return false, "inventory_full"
        end
        xPlayer.addInventoryItem(itemId, quantity)
        return true, "success"
        
    elseif invType == "custom" then
        return true, "success"
    end

    return false, "unknown_inventory"
end

-- Check if item exists in registered items
local function VerifyItemExists(itemId)
    local invType = GetInventoryType()

    if invType == "ox" then
        if exports.ox_inventory and exports.ox_inventory.Items then
            local items = exports.ox_inventory:Items()
            return items and items[itemId] ~= nil
        end
    elseif invType == "qs" then
        if exports['qs-inventory'] then
            local items = exports['qs-inventory']:GetItemList()
            return items and items[itemId] ~= nil
        end
    elseif invType == "tgiann" then
        if exports['tgiann-inventory'] and exports['tgiann-inventory'].GetItemList then
            local items = exports['tgiann-inventory']:GetItemList()
            return items and items[itemId] ~= nil
        end
    elseif invType == "brutal" then
        if exports['brutal_inventory'] and exports['brutal_inventory'].GetItemList then
            local items = exports['brutal_inventory']:GetItemList()
            return items and items[itemId] ~= nil
        end
    elseif invType == "qb" and QBCore then
        return QBCore.Shared.Items[itemId] ~= nil
    elseif invType == "esx" and ESX then
        if ESX.Items and ESX.Items[itemId] ~= nil then
            return true
        end
        local ok, label = pcall(function()
            return ESX.GetItemLabel(itemId)
        end)
        return ok and label ~= nil
    end
    return true -- Fallback for others
end

-- Main purchase event
RegisterNetEvent('ys_blackmarket:purchase')
AddEventHandler('ys_blackmarket:purchase', function(itemId)
    local src = source
    local xPlayer = GetPlayer(src)
    
    if not xPlayer then
        print("^1[YS Blackmarket]^7 Error: Player not found for source " .. src)
        return
    end
    
    local identifier = GetPlayerIdentifier(xPlayer)
    if not identifier then
        return
    end

    -- Anti-spam cooldown
    if purchaseCooldowns[identifier] and purchaseCooldowns[identifier] > os.time() then
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, 
            "Please wait " .. (purchaseCooldowns[identifier] - os.time()) .. " seconds.")
        return
    end

    -- Get item configuration
    local itemConfig = GetItemConfig(itemId)
    if not itemConfig then
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, "Item not available.")
        return
    end

    -- Security Gate: Verify that the item actually exists in the inventory system database on the server
    local itemExists = VerifyItemExists(itemId)
    if not itemExists then
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, "Item registry error: Item not registered on this server.")
        print(("^1[YS Blackmarket]^7 Warning: Player %s tried to purchase unregistered item '%s'!"):format(GetPlayerName(xPlayer), itemId))
        return
    end

    -- Check money
    local playerMoney = GetPlayerMoney(xPlayer, src)
    if playerMoney < itemConfig.price then
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, 
            "Insufficient money. Need: $" .. itemConfig.price .. ", Have: $" .. playerMoney)
        return
    end

    -- Remove money
    local removed = RemovePlayerMoney(xPlayer, src, itemConfig.price)
    if not removed then
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, "Failed to process payment.")
        return
    end

    -- Add item using generalized inventory helper with pcall protection (crash safeguard)
    local success = false
    local errorMsg = "unknown_error"
    
    local ok, res, err = pcall(function()
        return AddItemToInventory(src, xPlayer, itemId, itemConfig)
    end)
    
    if ok then
        success = res
        errorMsg = err or "inventory_error"
    else
        print("^1[YS Blackmarket]^7 Crash prevented! Inventory system threw a script error: " .. tostring(res))
        success = false
        errorMsg = "script_crash"
    end
    
    if success then
        -- Apply cooldown
        purchaseCooldowns[identifier] = os.time() + (Config.PurchaseCooldown / 1000)
        
        -- Success notification
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, true, 
            "Purchased: " .. itemConfig.name .. " for $" .. itemConfig.price)
        
        -- Log transaction
        print(('[^2BLACKMARKET^7] %s (%s) purchased %s for $%s'):format(
            GetPlayerName(xPlayer), identifier, itemConfig.name, itemConfig.price
        ))
        
        -- Debug log
        if Config.DebugMode then
            print("[DEBUG] Item ID: " .. itemId .. ", Type: " .. (itemConfig.itemType or "unknown"))
        end
    else
        -- Refund money if failed
        AddPlayerMoney(xPlayer, src, itemConfig.price)
        
        -- Error handling
        local errorMessage = "Purchase failed. "
        if errorMsg == "inventory_full" then
            errorMessage = errorMessage .. "Your inventory is full."
        elseif errorMsg == "ox_inventory_not_available" then
            errorMessage = errorMessage .. "Inventory system error."
        elseif errorMsg == "script_crash" then
            errorMessage = errorMessage .. "Server inventory script error."
        else
            errorMessage = errorMessage .. "Unknown error: " .. tostring(errorMsg)
        end
        
        TriggerClientEvent('ys_blackmarket:purchaseResult', src, false, errorMessage)
        
        -- Error log
        print("^1[YS Blackmarket]^7 Failed to add item: " .. itemId)
        print("^1[YS Blackmarket]^7 Error: " .. tostring(errorMsg))
        print("^1[YS Blackmarket]^7 Player: " .. GetPlayerName(xPlayer))
    end
end)

-- Check if item exists in registered items (NUI client request)
RegisterNetEvent('ys_blackmarket:verifyItem')
AddEventHandler('ys_blackmarket:verifyItem', function(itemId)
    local src = source
    local exists = VerifyItemExists(itemId)
    TriggerClientEvent('ys_blackmarket:itemVerified', src, exists, itemId)
end)

-- Admin command to reset cooldowns
RegisterCommand('ys_reset', function(source, args, rawCommand)
    if source == 0 then
        purchaseCooldowns = {}
        print('[^2BLACKMARKET^7] All cooldowns reset by console.')
    elseif IsPlayerAceAllowed(source, 'command.ys_reset') then
        purchaseCooldowns = {}
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^2[BLACKMARKET]^7", "All purchase cooldowns have been reset."}
        })
        print('[^2BLACKMARKET^7] Cooldowns reset by admin.')
    end
end, false)

-- Admin command to add item directly (for testing)
RegisterCommand('ys_give', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'command.ys_give') then
        if #args < 2 then
            print("Usage: ys_give [playerId] [itemId]")
            return
        end
        
        local targetId = tonumber(args[1])
        local itemId = args[2]
        local quantity = tonumber(args[3]) or 1
        
        local itemConfig = GetItemConfig(itemId)
        if not itemConfig then
            print("^1[YS Blackmarket]^7 Item not found in config: " .. itemId)
            return
        end
        
        local xPlayer = GetPlayer(targetId)
        if not xPlayer then
            print("^1[YS Blackmarket]^7 Player not found: " .. targetId)
            return
        end
        
        local success, errorMsg = AddItemToInventory(targetId, xPlayer, itemId, itemConfig)
        if success then
            print("^2[YS Blackmarket]^7 Item given: " .. itemId .. " to player " .. GetPlayerName(xPlayer))
        else
            print("^1[YS Blackmarket]^7 Failed to give item: " .. tostring(errorMsg))
        end
    end
end, false)

-- Verify all items on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait a bit for framework / exports to load
        Citizen.Wait(1000)
        InitFramework()
        
        print("^2[YS Blackmarket]^7 Initializing...")
        
        -- Print Framework detected
        print("^2[YS Blackmarket]^7 Framework: ^2" .. tostring(Config.Framework):upper() .. "^7")
        
        -- Detect/Print Inventory detected
        local invType = GetInventoryType()
        print("^2[YS Blackmarket]^7 Inventory System: ^2" .. tostring(invType):upper() .. "^7")
        
        if Config.VerifyItemsOnStart then
            print("^2[YS Blackmarket]^7 Verifying configured items in inventory registry...")
            for _, item in ipairs(Config.Items) do
                local exists = VerifyItemExists(item.id)
                if exists then
                    print(("^3[YS Blackmarket]^7 Item: %s (%s) - ^2VERIFIED^7"):format(item.id, item.name))
                else
                    print(("^1[YS Blackmarket]^7 Item: %s (%s) - ^1NOT FOUND IN INVENTORY REGISTRY!^7"):format(item.id, item.name))
                end
            end
            print("^2[YS Blackmarket]^7 Total items: " .. #Config.Items)
        end
        
        print("^2[YS Blackmarket]^7 Ready for business!")
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[YS Blackmarket]^7 Shutting down...")
    end
end)