-- hosts/pc.lua — desktop PC
-- Rename this file to match `hostnamectl hostname` on the PC.

local kb = require("modules.keyhelp")
local display = require("modules.monitors")

-- Main monitor at its highest refresh rate. Check the output name with `hyprctl monitors`.
local primary = "DP-1"
hl.monitor({ output = primary, mode = "highrr", position = "0x0", scale = 1 })

-- TV: picked up by the fallback rule in modules/monitors.lua (extends to the right).
kb.section("Monitors")
kb.bind("SUPER + P", function()
	display.toggle_mirror(primary)
end, "Mirror / extend external display")
