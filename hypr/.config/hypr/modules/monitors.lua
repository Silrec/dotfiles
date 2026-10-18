-- Monitors: shared fallback rule + mirror/extend helper.
-- Explicit outputs (names, refresh rates) live in hosts/<hostname>.lua.

-- Any display without its own rule (TV, projector): preferred mode, placed to the right.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local M = {}

-- Toggle every non-primary display between mirroring `primary` and extending the desktop.
-- Bound to Super+P in the host files.
function M.toggle_mirror(primary)
	local monitors = hl.get_monitors({ all = true })

	local mirrored = false
	for _, m in ipairs(monitors) do
		if m.is_mirror then
			mirrored = true
		end
	end

	for _, m in ipairs(monitors) do
		if m.name ~= primary then
			hl.monitor({
				output = m.name,
				mode = "preferred",
				position = "auto",
				scale = "auto",
				mirror = mirrored and "" or primary,
			})
		end
	end

	require("modules.vars").notify("Display", mirrored and "Extend" or ("Mirror " .. primary))
end

return M
