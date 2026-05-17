# 🖤 Bashaal Blackmarket

A secure, modern blackmarket resource for **FiveM** with a futuristic NUI interface. Built for **ESX Legacy** + **ox_inventory**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-red.svg)

---

## ✨ Features

- **Futuristic NUI Interface** — Clean, modern, and fully responsive UI
- **Category-based Navigation** — Pistols, Rifles, Tools, Medical, and more
- **ox_inventory Integration** — Full support with metadata, durability, and serial numbers
- **Black Money Payments** — Uses ESX black_money account
- **Anti-Spam Protection** — Built-in purchase cooldown system
- **Static NPC Dealer** — One persistent NPC with smoking animation
- **3D Interaction Text** — Press [E] to open the blackmarket
- **Admin Commands** — Reset cooldowns and give items directly
- **Fully Configurable** — Easy to add/remove items and locations

---

## 📦 Dependencies

| Resource       | Required | Notes                              |
|----------------|----------|------------------------------------|
| **es_extended**    | ✅ Yes   | ESX Legacy recommended             |
| **ox_inventory**   | ✅ Yes   | Required for item handling         |

---

## 🚀 Installation

1. **Download** the latest release or clone the repository
2. **Extract** the folder into your `resources` directory
3. **Rename** the folder to `bashaal_blackmarket` (if needed)
4. **Add** the following to your `server.cfg`:

```cfg
ensure es_extended
ensure ox_inventory
ensure bashaal_blackmarket
```

5. **Configure** the script (see Configuration section below)
6. **Restart** your server

---

## ⚙️ Configuration

All settings are located in `config.lua`.

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

Items must match **exactly** with your `ox_inventory/items.lua`:

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
| `/bashaal_reset`       | `command.bashaal_reset`     | Reset all purchase cooldowns         |
| `/bashaal_give [id] [item] [qty]` | `command.bashaal_give` | Give item directly to player         |

---

## 📁 File Structure

```
bashaal_blackmarket/
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

- **ox_inventory not detected** → Make sure `ox_inventory` is started before this resource
- **Items not showing** → Verify item IDs match exactly in `ox_inventory/items.lua`
- **NPC not appearing** → Check coordinates and ensure the resource started correctly

---

## 📝 License

MIT License — Feel free to modify and use in your server.

---

## 👤 Author

**YASSER** — Created with ❤️ for the FiveM community

---

*For support or feature requests, open an issue on GitHub.*
