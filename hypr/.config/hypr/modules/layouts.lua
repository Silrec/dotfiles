-- Tiling layouts. Super+Z switches dwindle <-> master at runtime.
-- https://wiki.hypr.land/Configuring/Layouts/

hl.config({
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
