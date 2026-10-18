-- Autostart (runs once per session, not on config reload)
-- Noctalia covers bar, notifications, launcher, lock, idle, wallpaper and polkit agent.

hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia")
	hl.exec_cmd("kanshi")
end)
