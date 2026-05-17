Config = {}

-- Blackmarket points
Config.BlackmarketPoints = {
    { coords = vector3(-1015.8478, 858.5199, 155.1159) }
}

-- NPC Configuration
Config.NPCModel = "g_m_m_chicold_01"
Config.NPCScenario = "WORLD_HUMAN_SMOKING"
Config.InteractDistance = 2.0
Config.InteractKey = 38 -- E key

-- Categories for organized display
Config.Categories = {
    {
        id = "pistols",
        name = "Pistols",
        icon = "fa-gun",
        description = "Handguns and pistols"
    },
    {
        id = "rifles",
        name = "Rifles",
        icon = "fa-gun",
        description = "Assault rifles and sniper rifles"
    },
    {
        id = "tools",
        name = "Tools",
        icon = "fa-tools",
        description = "Breaking and entering tools"
    },
    {
        id = "medical",
        name = "Medical",
        icon = "fa-first-aid",
        description = "Health and medical supplies"
    },
    {
        id = "other",
        name = "Other",
        icon = "fa-box",
        description = "Miscellaneous items"
    }
}

-- ITEMS organized by categories
-- Important: item IDs must match EXACTLY with ox_inventory/items.lua
Config.Items = {
    -- Pistols Category
    {
        id = "WEAPON_PRISMATICP80",
        name = "Basic Pistol",
        description = "Standard semi-automatic pistol. Medium accuracy.",
        price = 100000,
        category = "pistols",
        itemType = "weapon",
        ammo = 0,
        image = "assets/images/weapons/WEAPON_PRISMATICP80.png"
    },
    {
        id = "WEAPON_PRISMATICFNX45",
        name = "Combat Pistol",
        description = "Combat pistol, more powerful than standard.",
        price = 150000,
        category = "pistols",
        itemType = "weapon",
        ammo = 0,
        image = "assets/images/weapons/WEAPON_PRISMATICFNX45.png"
    },
    {
        id = "weapon_appistol",
        name = "AP PISTOL",
        description = "Standard automatic pistol.",
        price = 500000,
        category = "pistols",
        itemType = "weapon",
        ammo = 0,
        image = "assets/images/weapons/weapon_appistol.png"
    },
    
    -- Rifles Category
    {
        id = "weapon_assaultrifle",
        name = "Assault Rifle",
        description = "Standard assault rifle for combat situations.",
        price = 15000,
        category = "rifles",
        itemType = "weapon",
        ammo = 180,
        image = "assets/images/weapons/weapon_assaultrifle.png"
    },
    {
        id = "weapon_carbinerifle",
        name = "Carbine Rifle",
        description = "Lightweight carbine rifle, accurate and fast.",
        price = 18500,
        category = "rifles",
        itemType = "weapon",
        ammo = 210,
        image = "assets/images/weapons/weapon_carbinerifle.png"
    },
    -- Tools Category
    {
        id = "laptop",
        name = "laptop",
        description = "laptop",
        price = 400,
        category = "tools",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/laptop.png"
    },
    {
        id = "drill",
        name = "Drill",
        description = "Robust electric drill for basic safes.",
        price = 3200,
        category = "tools",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/drill.png"
    },
    -- Medical Category
    {
        id = "bandage",
        name = "Bandage",
        description = "Sterile bandage for treating light wounds.",
        price = 150,
        category = "medical",
        itemType = "item",
        stack = 5,
        image = "assets/images/items/bandage.png"
    },
    
    -- Other Category
    {
        id = "pooch_bag",
        name = "pooch bag",
        description = "pooch bag",
        price = 2200,
        category = "other",
        itemType = "item",
        stack = 25,
        image = "assets/images/items/pooch_bag.png"
    },
    {
        id = "empty_lean_bottle",
        name = "empty lean bottle",
        description = "empty lean bottle",
        price = 2200,
        category = "other",
        itemType = "item",
        stack = 25,
        image = "assets/images/items/empty_lean_bottle.png"
    },
    {
        id = "lighter",
        name = "lighter",
        description = "lighter",
        price = 2200,
        category = "other",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/lighter.png"
    },
    {
        id = "empty_cup",
        name = "empty_cup",
        description = "empty_cup",
        price = 2200,
        category = "other",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/empty_cup.png"
    }
}

-- Anti-spam cooldown (in milliseconds)
Config.PurchaseCooldown = 1000

-- 3D help text
Config.HelpText = "Press [E] to open the ~b~Blackmarket"

-- Notification settings
Config.NotificationDuration = 3000 -- ms

-- Debug mode (set to false in production)
Config.DebugMode = false

-- Required ox_inventory items check
Config.VerifyItemsOnStart = true

-- UI Settings
Config.DefaultCategory = "pistols" -- Default category to show