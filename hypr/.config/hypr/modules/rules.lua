-- Window and layer rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Noctalia surfaces: blur, no compositor animation (Noctalia animates itself)
hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	no_anim = true,
	blur = true,
	blur_popups = true,
	ignore_alpha = 0.05,
})

-- Noctalia settings window floats
hl.window_rule({
	name = "noctalia-settings",
	match = { class = "dev.noctalia.Noctalia" },
	float = true,
	size = "monitor_w*0.5 monitor_h*0.7",
})

-- Apps can't maximize themselves; tiling decides window size
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix dragging issues with XWayland (the action line was missing in the old config)
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Don't lock/blank the screen while anything is fullscreen (games, videos)
hl.window_rule({
	name = "idle-inhibit-fullscreen",
	match = { class = ".*" },
	idle_inhibit = "fullscreen",
})

hl.window_rule({
	name = "file-dialog-portal",
	match = { class = "^xdg-desktop-portal-gtk$" },
	float = true,
	size = "monitor_w*0.5 monitor_h*0.6",
	center = true,
})

hl.window_rule({
	name = "calculator-float",
	match = { class = "^calculator$" },
	float = true,
	size = "monitor_w*0.3 monitor_h*0.4",
	center = true,
})

hl.window_rule({
	name = "sysmon-float",
	match = { class = "^sysmon$" },
	float = true,
	size = "monitor_w*0.8 monitor_h*0.8",
	center = true,
})

hl.window_rule({ name = "scratch-term", match = { class = "^scratch-term$" }, workspace = "special:scratchpad silent" })

hl.window_rule({
	name = "media-scratchpad",
	match = { class = "^(media-rmpc|media-cava|Throne)$" },
	workspace = "special:scratchpad silent",
})

-- Workspaces 1–5 always exist and have names; 6–10 still appear on demand
--local wsNames = { "󰇊", "󰇋", "󰇌", "󰇍", "󰇎", "󰇏" }
--local wsNames = { "󱂈", "󱂉", "󱂊", "󱂋", "󱂌", "󱂍", "󱂎", "󱂏", "󱂐", "󱂑" }
--for i, name in ipairs(wsNames) do
--	hl.workspace_rule({ workspace = tostring(i), default_name = name, persistent = false })
--end
