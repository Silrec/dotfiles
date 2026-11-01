-- Autostart (runs once per session, not on config reload)
-- Noctalia covers bar, notifications, launcher, lock, idle, wallpaper and polkit agent.
-- Under uwsm, apps are launched as their own systemd units; XDG autostart
-- (~/.config/autostart, e.g. KeePassXC's own checkbox) is handled by uwsm.

hl.on("hyprland.start", function()
	-- uwsm runs Hyprland inside its wayland-wm@ unit; known from the first moment
	local f = io.open("/proc/self/cgroup")
	local cg = f and f:read("a") or ""
	if f then
		f:close()
	end
	local uwsm = cg:find("wayland%-wm@", 1) ~= nil

	local function launch(cmd, rules)
		hl.exec_cmd(uwsm and ("uwsm app -- " .. cmd) or cmd, rules)
	end

	if not uwsm then
		launch("noctalia")
	end

	--local scratch = { workspace = "special:scratchpad silent" }
	launch(os.getenv("HOME") .. "/.local/bin/media-layout")
	--launch("kitty --class scratch-term -e cava", scratch)
	--launch("kitty --class scratch-term -e rmpc", scratch)
	--launch("kitty --class scratch-term -e btop", scratch)
end)
