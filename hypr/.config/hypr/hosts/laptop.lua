-- hosts/laptop.lua — laptop
-- Rename this file to match `hostnamectl hostname` on the laptop.

local kb = require("modules.keyhelp")
local display = require("modules.monitors")

local primary = "eDP-1" -- built-in panel; confirm with `hyprctl monitors`
hl.monitor({ output = primary, mode = "preferred", position = "0x0", scale = "auto" })

-- Projectors/external displays mirror the laptop by default (overrides the shared fallback)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto", mirror = primary })

kb.section("Monitors")
kb.bind("SUPER + P", function()
	display.toggle_mirror(primary)
end, "Mirror / extend external display")
