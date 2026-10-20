-- Keyboard, mouse, touchpad, gestures
-- https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
	input = {
		-- kb_layout = "us",
		-- Second layout, when you decide on a switch key
		-- (grp:win_space_toggle would clash with the Super+Space launcher):
		kb_layout = "us,ru",
		kb_variant = ",",
		kb_options = "grp:win_space_toggle,custom:kpdigits",

		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 = no change

		touchpad = {
			natural_scroll = true,
		},
	},
})

-- Laptop: 3-finger horizontal swipe switches workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Numlock by default
hl.device({ name = "sonix-montech-mk108", numlock_by_default = true })
hl.device({ name = "sonix-montech-mk108-keyboard", numlock_by_default = true })
