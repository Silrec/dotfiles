-- Tiling layouts. Super+Z switches dwindle <-> master at runtime.
-- https://wiki.hypr.land/Configuring/Layouts/

hl.config({
	general = {
		no_focus_fallback = false, -- set to true to disable focus looping
	},
	dwindle = {
		force_split = 2,
		use_active_for_splits = true,
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
