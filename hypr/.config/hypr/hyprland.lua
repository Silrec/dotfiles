-- ~/.config/hypr/hyprland.lua — entry point
-- Each require() runs in its own scope: an error in one module does not stop the others.
-- Shared values (mod key, apps, helpers) live in modules/vars.lua.

require("modules.env")
require("modules.autostart")
require("modules.monitors")
require("modules.input")
require("modules.appearance")
require("modules.layouts")
require("modules.rules")
require("modules.binds")

-- Machine-specific settings: hosts/<hostname>.lua  (check yours: `hostnamectl hostname`)
-- Same repo on PC and laptop; each machine loads its own file automatically.
local f = io.open("/etc/hostname", "r")
local host = f and f:read("*l")
if f then
	f:close()
end

if host then
	host = host:gsub("%s+", "")
	hl.env("NOCTALIA_HOST", host) -- Noctalia inherits this and loads hosts/${NOCTALIA_HOST}.toml
	local ok, err = pcall(require, "hosts." .. host)
	if not ok then
		hl.notification.create({
			text = "No host config loaded for '" .. host .. "': " .. tostring(err):match("[^\n]+"),
			timeout = 8000,
			icon = "warning",
		})
	end
end




-- For Noctalia Color templates
require("noctalia").apply_theme()
