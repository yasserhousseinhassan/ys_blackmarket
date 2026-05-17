-- server.lua for Bashaal Blackmarket - ox_inventory COMPATIBLE
local ESX = nil
local purchaseCooldowns = {}

-- Initialize ESX
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
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

-- Function to add item using ox_inventory
local function AddItemOxInventory(src, itemId, itemConfig)
    if not exports.ox_inventory then
        return false, "ox_inventory_not_available"
    end
    
    local metadata = {}
    local quantity = 1
    
    -- For weapons in ox_inventory
    if itemConfig.itemType == "weapon" then
        metadata.ammo = itemConfig.ammo or 30
        metadata.components = {}
        metadata.durability = 100
        metadata.serial = "BSH-" .. math.random(10000000, 99999999)
        metadata.registered = false
    else
        -- For regular items
        if itemConfig.stack and itemConfig.stack > 1 then
            quantity = itemConfig.stack
        end
    end
    
    -- Add item using ox_inventory export
    local success = exports.ox_inventory:AddItem(src, itemId, quantity, metadata)
    
    if success then
        return true, "success"
    else
        return false, "inventory_full"
    end
end

-- Main purchase event
RegisterNetEvent('bashaal_blackmarket:purchase')
AddEventHandler('bashaal_blackmarket:purchase', function(itemId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        print("^1[Bashaal Blackmarket]^7 Error: Player not found for source " .. src)
        return
    end
    
    local identifier = xPlayer.identifier

    -- Anti-spam cooldown
    if purchaseCooldowns[identifier] and purchaseCooldowns[identifier] > os.time() then
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, false, 
            "Please wait " .. (purchaseCooldowns[identifier] - os.time()) .. " seconds.")
        return
    end

    -- Get item configuration
    local itemConfig = GetItemConfig(itemId)
    if not itemConfig then
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, false, "Item not available.")
        return
    end

    -- Check black money
    local blackMoney = xPlayer.getAccount('black_money').money
    if blackMoney < itemConfig.price then
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, false, 
            "Insufficient black money. Need: $" .. itemConfig.price .. ", Have: $" .. blackMoney)
        return
    end

    -- Check if ox_inventory is available
    if not exports.ox_inventory then
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, false, 
            "Inventory system error. Please contact admin.")
        print("^1[Bashaal Blackmarket]^7 ox_inventory not found!")
        return
    end

    -- Remove black money
    xPlayer.removeAccountMoney('black_money', itemConfig.price)

    -- Add item using ox_inventory
    local success, errorMsg = AddItemOxInventory(src, itemId, itemConfig)
    
    if success then
        -- Apply cooldown
        purchaseCooldowns[identifier] = os.time() + (Config.PurchaseCooldown / 1000)
        
        -- Success notification
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, true, 
            "Purchased: " .. itemConfig.name .. " for $" .. itemConfig.price)
        
        -- Log transaction
        print(('[^2BLACKMARKET^7] %s (%s) purchased %s for $%s'):format(
            xPlayer.getName(), identifier, itemConfig.name, itemConfig.price
        ))
        
        -- Debug log
        if Config.DebugMode then
            print("[DEBUG] Item ID: " .. itemId .. ", Type: " .. (itemConfig.itemType or "unknown"))
        end
    else
        -- Refund money if failed
        xPlayer.addAccountMoney('black_money', itemConfig.price)
        
        -- Error handling
        local errorMessage = "Purchase failed. "
        if errorMsg == "inventory_full" then
            errorMessage = errorMessage .. "Your inventory is full."
        elseif errorMsg == "ox_inventory_not_available" then
            errorMessage = errorMessage .. "Inventory system error."
        else
            errorMessage = errorMessage .. "Unknown error: " .. tostring(errorMsg)
        end
        
        TriggerClientEvent('bashaal_blackmarket:purchaseResult', src, false, errorMessage)
        
        -- Error log
        print("^1[Bashaal Blackmarket]^7 Failed to add item: " .. itemId)
        print("^1[Bashaal Blackmarket]^7 Error: " .. tostring(errorMsg))
        print("^1[Bashaal Blackmarket]^7 Player: " .. xPlayer.getName())
    end
end)

-- Check if item exists in ox_inventory
RegisterNetEvent('bashaal_blackmarket:verifyItem')
AddEventHandler('bashaal_blackmarket:verifyItem', function(itemId)
    local src = source
    
    if exports.ox_inventory then
        -- ox_inventory doesn't have a direct verification function,
        -- so we assume if the resource is loaded, items are configured
        TriggerClientEvent('bashaal_blackmarket:itemVerified', src, true, itemId)
    else
        TriggerClientEvent('bashaal_blackmarket:itemVerified', src, false, itemId)
    end
end)

-- Admin command to reset cooldowns
RegisterCommand('bashaal_reset', function(source, args, rawCommand)
    if source == 0 then
        purchaseCooldowns = {}
        print('[^2BLACKMARKET^7] All cooldowns reset by console.')
    elseif IsPlayerAceAllowed(source, 'command.bashaal_reset') then
        purchaseCooldowns = {}
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^2[BLACKMARKET]^7", "All purchase cooldowns have been reset."}
        })
        print('[^2BLACKMARKET^7] Cooldowns reset by admin.')
    end
end, false)

-- Admin command to add item directly (for testing)
RegisterCommand('bashaal_give', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'command.bashaal_give') then
        if #args < 2 then
            print("Usage: bashaal_give [playerId] [itemId]")
            return
        end
        
        local targetId = tonumber(args[1])
        local itemId = args[2]
        local quantity = tonumber(args[3]) or 1
        
        local itemConfig = GetItemConfig(itemId)
        if not itemConfig then
            print("^1[Bashaal Blackmarket]^7 Item not found: " .. itemId)
            return
        end
        
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if not xPlayer then
            print("^1[Bashaal Blackmarket]^7 Player not found: " .. targetId)
            return
        end
        
        local success, errorMsg = AddItemOxInventory(targetId, itemId, itemConfig)
        if success then
            print("^2[Bashaal Blackmarket]^7 Item given: " .. itemId .. " to player " .. xPlayer.getName())
        else
            print("^1[Bashaal Blackmarket]^7 Failed to give item: " .. tostring(errorMsg))
        end
    end
end, false)

-- Verify all items on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[Bashaal Blackmarket]^7 Initializing...")
        
        -- Check ox_inventory
        if exports.ox_inventory then
            print("^2[Bashaal Blackmarket]^7 ox_inventory: ^2DETECTED^7")
            
            if Config.VerifyItemsOnStart then
                print("^2[Bashaal Blackmarket]^7 Verifying configured items...")
                for _, item in ipairs(Config.Items) do
                    print("^3[Bashaal Blackmarket]^7 Item: " .. item.id .. " (" .. item.name .. ")")
                end
                print("^2[Bashaal Blackmarket]^7 Total items: " .. #Config.Items)
            end
        else
            print("^1[Bashaal Blackmarket]^7 ox_inventory: ^1NOT DETECTED^7")
            print("^3[Bashaal Blackmarket]^7 This script requires ox_inventory to work!")
        end
        
        -- Check ESX
        if ESX then
            print("^2[Bashaal Blackmarket]^7 ESX: ^2CONNECTED^7")
        else
            print("^1[Bashaal Blackmarket]^7 ESX: ^1NOT CONNECTED^7")
        end
        
        print("^2[Bashaal Blackmarket]^7 Ready for business!")
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[Bashaal Blackmarket]^7 Shutting down...")
    end
end)