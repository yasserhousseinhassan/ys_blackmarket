# 🖤 YS Blackmarket

A secure, modern, and highly configurable blackmarket resource for **FiveM** with a futuristic NUI interface. Built with native support for both **ESX Legacy** and **QBCore** frameworks, as well as multiple inventory systems.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-red.svg)

---

## ✨ Features

- **Futuristic NUI Interface** — Clean, modern, and fully responsive UI
- **Multi-Framework Support** — Works out-of-the-box on **ESX** and **QBCore** (fully auto-detected!)
- **Multi-Inventory Support** — Compatible with **ox_inventory**, QBCore default inventory, ESX standard inventory, or your own custom inventory export
- **Flexible Payments** — Buy items using cash, bank accounts, dirty money accounts (`black_money`), or using any item (e.g. marked bills, gold coins) as currency
- **Dynamic Customization** — Change UI titles, icons, warnings, and copyright footers directly from `config.lua` without touching HTML/JS files!
- **Category-based Navigation** — Pistols, Rifles, Tools, Medical, and more
- **ox_inventory/QB Integration** — Full support with weapon metadata, durability, and configurable serial number prefixes
- **Anti-Spam Protection** — Built-in purchase cooldown system
- **Static NPC Dealer** — One persistent NPC with smoking animation
- **3D Interaction Text** — Press [E] to open the blackmarket (standalone 3D rendering)
- **Admin Commands** — Reset cooldowns and give items directly
- **Fully Configurable** — Easy to add/remove items and locations

---

## 📦 Dependencies

| Resource       | Required | Notes                              |
|----------------|----------|------------------------------------|
| **es_extended** or **qb-core**    | ✅ Yes   | Auto-detected framework            |
| **ox_inventory** (Optional)  | ❌ No    | Supported; can also use default framework inventory |

---

## 🚀 Installation

1. **Download** the latest release or clone the repository
2. **Extract** the folder into your `resources` directory
3. **Rename** the folder to `ys_blackmarket`
4. **Add** the following to your `server.cfg` (after your framework resources):

```cfg
ensure ys_blackmarket
```

5. **Configure** the script (see Configuration section below)
6. **Restart** your server

---

## ⚙️ Configuration

All settings are located in `config.lua`.

### Framework & Inventory Settings

```lua
Config.Framework = "auto" -- "auto" (detect automatically), "esx", "qb"
Config.Inventory = "auto" -- "auto" (detect automatically), "ox", "qb", "esx", "custom"
```

### Payment and Currency Settings

```lua
Config.MoneyType = "black_money" -- For ESX: "black_money", "money". For QBCore: "cash", "bank", "crypto"
Config.UseItemAsMoney = false -- Set to true if players buy using an item (e.g. markedbills)
Config.MoneyItem = "markedbills" -- Item name if UseItemAsMoney is true
```

### UI and Branding Settings

```lua
Config.UITitle = "YS BLACKMARKET"
Config.UILogoIcon = "fa-skull-crossbones"
Config.UIWarning = "All transactions are final and anonymous. No refunds."
Config.UICopyright = "Storm Development © 2026 - Blackmarket System v1.0"
Config.SerialPrefix = "YS-"
```

### Blackmarket Location

```lua
Config.BlackmarketPoints = {
    { coords = vector3(-1015.8478, 858.5199, 155.1159) }
}
```

### NPC Settings

```lua
Config.NPCModel = "g_m_m_chicold_01"
Config.NPCScenario = "WORLD_HUMAN_SMOKING"
Config.InteractDistance = 2.0
Config.InteractKey = 38 -- E key
```

### Adding New Items

Items must match **exactly** with your inventory items list:

```lua
{
    id = "weapon_assaultrifle",
    name = "Assault Rifle",
    description = "Standard assault rifle for combat situations.",
    price = 15000,
    category = "rifles",
    itemType = "weapon",
    ammo = 180,
    image = "assets/images/weapons/weapon_assaultrifle.png"
}
```

### Categories

Edit `Config.Categories` to add/remove categories.

---

## 🛠️ Admin Commands

| Command                | Permission                  | Description                          |
|------------------------|-----------------------------|--------------------------------------|
| `/ys_reset`            | `command.ys_reset`          | Reset all purchase cooldowns         |
| `/ys_give [id] [item] [qty]` | `command.ys_give`     | Give item directly to player         |

---

## 📁 File Structure

```
ys_blackmarket/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
├── html/
│   ├── index.html
│   ├── css/style.css
│   └── js/script.js
└── html/assets/
    ├── images/weapons/
    └── images/items/
```

---

## 🔧 Troubleshooting

- **Items not showing** → Verify item IDs match exactly in your inventory database list
- **NPC not appearing** → Check coordinates and ensure the resource started correctly

---

## 📝 License

MIT License — Feel free to modify and use in your server.

---

## 👤 Author

**Yasser (Storm Development)** — Created with ❤️ for the FiveM community
