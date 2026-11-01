-- hosts/pc.lua — desktop PC
-- Rename this file to match `hostnamectl hostname` on the PC.

local kb = require("modules.keyhelp")
local display = require("modules.monitors")

-- Main monitor at its highest refresh rate. Check the output name with `hyprctl monitors`.
local primary = "DP-1"
require("modules.monitors").setup({
	{ output = "desc:AOC Q3277", mode = "2560x1440@59.95", position = "0x0", scale = 1 },
	{ output = "desc:<TV make model>", mode = "1920x1080@60", position = "auto", scale = 1 },
})
-- TV: picked up by the fallback rule in modules/monitors.lua (extends to the right).
kb.section("Monitors")
kb.bind("SUPER + P", function()
	display.toggle_mirror(primary)
end, "Mirror / extend external display")
