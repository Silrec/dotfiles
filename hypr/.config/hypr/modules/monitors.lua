-- monitors: shared fallback rule, per-host rules, mirror/extend helper, hotplug repair.
-- explicit outputs (names, refresh rates) live in hosts/<hostname>.lua and are passed to setup().

-- any display without its own rule (tv, projector): preferred mode, placed to the right.
local FALLBACK = { output = "", mode = "preferred", position = "auto", scale = "auto" }

local m = { rules = {} }

-- apply the fallback plus this host's rules (also used by monitor-fix after a bad hotplug)
function m.reapply()
	hl.monitor(FALLBACK)
	for _, rule in ipairs(m.rules) do
		hl.monitor(rule)
	end
end

-- called once from hosts/<hostname>.lua with that machine's explicit outputs
function m.setup(rules)
	m.rules = rules or {}
	m.reapply()
end

-- toggle every non-primary display between mirroring `primary` and extending the desktop.
-- bound to super+p in the host files.
function m.toggle_mirror(primary)
	local monitors = hl.get_monitors({ all = true })

	local mirrored = false
	for _, mon in ipairs(monitors) do
		if mon.is_mirror then
			mirrored = true
		end
	end

	for _, mon in ipairs(monitors) do
		if mon.name ~= primary then
			hl.monitor({
				output = mon.name,
				mode = "preferred",
				position = "auto",
				scale = "auto",
				mirror = mirrored and "" or primary,
			})
		end
	end
	if mirrored then
		m.reapply() -- back to extend: restore the host's explicit modes/positions
	end

	require("modules.vars").notify("display", mirrored and "extend" or ("mirror " .. primary))
end

-- after an HDMI glitch Hyprland can re-add a monitor with no mode (0x0); monitor-fix repairs it
hl.on("monitor.added", function()
	hl.exec_cmd("~/.local/bin/monitor-fix")
end)

return m
