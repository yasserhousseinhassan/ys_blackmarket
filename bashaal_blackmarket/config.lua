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
        id = "weapon_pistol",
        name = "Pistol",
        description = "Standard semi-automatic handgun. High accuracy, low damage.",
        price = 5000,
        category = "pistols",
        itemType = "weapon",
        ammo = 36,
        image = "assets/images/weapons/weapon_pistol.png"
    },
    {
        id = "weapon_combatpistol",
        name = "Combat Pistol",
        description = "Compact semi-automatic handgun, highly favored by security forces.",
        price = 10000,
        category = "pistols",
        itemType = "weapon",
        ammo = 48,
        image = "assets/images/weapons/weapon_combatpistol.png"
    },
    {
        id = "weapon_appistol",
        name = "AP Pistol",
        description = "Fully automatic pistol. High fire rate and armor penetration.",
        price = 25000,
        category = "pistols",
        itemType = "weapon",
        ammo = 36,
        image = "assets/images/weapons/weapon_appistol.png"
    },
    
    -- Rifles Category
    {
        id = "weapon_smg",
        name = "Submachine Gun",
        description = "Compact submachine gun. Fast firing rate and low recoil.",
        price = 30000,
        category = "rifles",
        itemType = "weapon",
        ammo = 120,
        image = "assets/images/weapons/weapon_smg.png"
    },
    {
        id = "weapon_assaultrifle",
        name = "Assault Rifle",
        description = "Standard automatic rifle. Good range and high firepower.",
        price = 50000,
        category = "rifles",
        itemType = "weapon",
        ammo = 180,
        image = "assets/images/weapons/weapon_assaultrifle.png"
    },
    {
        id = "weapon_carbinerifle",
        name = "Carbine Rifle",
        description = "Modern assault carbine, excellent accuracy and handling.",
        price = 60000,
        category = "rifles",
        itemType = "weapon",
        ammo = 180,
        image = "assets/images/weapons/weapon_carbinerifle.png"
    },

    -- Tools Category
    {
        id = "lockpick",
        name = "Lockpick",
        description = "Used to pick basic locks on vehicles or simple safes.",
        price = 500,
        category = "tools",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/lockpick.png"
    },
    {
        id = "drill",
        name = "Drill",
        description = "Industrial grade electric drill used for breaking vaults.",
        price = 5000,
        category = "tools",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/drill.png"
    },
    {
        id = "thermite",
        name = "Thermite",
        description = "Chemical mixture that burns at extremely high temperatures. Used for melting metal locks.",
        price = 2500,
        category = "tools",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/thermite.png"
    },

    -- Medical Category
    {
        id = "bandage",
        name = "Bandage",
        description = "Sterile medical bandage to dress wounds and stop minor bleeding.",
        price = 100,
        category = "medical",
        itemType = "item",
        stack = 5,
        image = "assets/images/items/bandage.png"
    },
    {
        id = "medikit",
        name = "First Aid Kit",
        description = "Complete trauma kit. Treats major wounds and restores health fully.",
        price = 1000,
        category = "medical",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/medikit.png"
    },
    
    -- Other Category
    {
        id = "weed_baggy",
        name = "Bag of Weed",
        description = "Ziploc baggy containing medical grade cannabis.",
        price = 150,
        category = "other",
        itemType = "item",
        stack = 10,
        image = "assets/images/items/weed_baggy.png"
    },
    {
        id = "cocaine_baggy",
        name = "Bag of Cocaine",
        description = "Small bag containing processed cocaine powder.",
        price = 300,
        category = "other",
        itemType = "item",
        stack = 10,
        image = "assets/images/items/cocaine_baggy.png"
    },
    {
        id = "meth_baggy",
        name = "Bag of Meth",
        description = "Baggy containing high purity blue meth crystals.",
        price = 250,
        category = "other",
        itemType = "item",
        stack = 10,
        image = "assets/images/items/meth_baggy.png"
    },
    {
        id = "rolex",
        name = "Rolex Watch",
        description = "High-end luxury gold watch. Can be fenced or worn.",
        price = 2000,
        category = "other",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/rolex.png"
    },
    {
        id = "armor",
        name = "Body Armor",
        description = "Lightweight bulletproof vest for protection against gunshots.",
        price = 1200,
        category = "other",
        itemType = "item",
        stack = 1,
        image = "assets/images/items/armor.png"
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

-- UI Customization
Config.UITitle = "YS BLACKMARKET"
Config.UILogoIcon = "logo.png"
Config.UIWarning = "All transactions are final and anonymous. No refunds."
Config.UICopyright = "Storm Development © 2026 - Blackmarket System v1.0"

-- Weapon/Item Serial Prefix
Config.SerialPrefix = "YS-"

-- Framework Settings
Config.Framework = "auto" -- "auto" (detect automatically), "esx", "qb"

-- Inventory Settings
Config.Inventory = "auto" -- "auto" (detect automatically), "ox" (ox_inventory), "qb" (qb/ps/lj-inventory), "esx" (default ESX), "qs" (Quasar), "codem" (m-inventory), "core" (Core Inventory), "chezza" (Chezza), "brutal" (Brutal Inventory), "origen" (Origen Inventory), "tgiann" (Tgiann Inventory), "ak47" (Ak47 Inventory), "disc" (disc-inventoryhud), "custom"

-- Currency Settings
Config.MoneyType = "black_money" -- For ESX: "black_money", "money". For QBCore: "cash", "bank", "crypto"
Config.UseItemAsMoney = false -- Set to true if players buy using an item (e.g. markedbills)
Config.MoneyItem = "markedbills" -- Item name if UseItemAsMoney is true