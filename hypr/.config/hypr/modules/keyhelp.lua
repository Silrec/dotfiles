-- Bind helper + Super+F1 keybinding menu
-- The menu opens in Noctalia's launcher (`noctalia dmenu`), so it's searchable and themed.
--
--   kb.section("Windows")                         following binds are listed under this heading
--   kb.bind(keys, action, "Close window", flags)  hl.bind + description, listed in the menu
--   kb.bind(keys, action, "...", { list = false }) description for `hyprctl binds`, not listed
--   kb.bind(keys, action)                          plain bind, not listed
--   kb.doc("Super + 1…0", "Go to workspace")       menu-only row, summarizes binds made in loops
--
-- The list is rebuilt on every config reload, so the menu always matches the config.

local M = {}

local sections, byName = {}, {}
local current = "General"

-- How key names are shown in the menu
local NAMES = {
	SUPER = "Super",
	SHIFT = "Shift",
	CTRL = "Ctrl",
	CONTROL = "Ctrl",
	ALT = "Alt",
	Return = "Enter",
	escape = "Esc",
	Escape = "Esc",
	Tab = "Tab",
	Space = "Space",
	space = "Space",
	left = "←",
	right = "→",
	up = "↑",
	down = "↓",
	grave = "`",
	period = ".",
	comma = ",",
	Print = "PrtSc",
	Delete = "Del",
	["mouse:272"] = "Left-drag",
	["mouse:273"] = "Right-drag",
	mouse_down = "Scroll ↓",
	mouse_up = "Scroll ↑",
}

local function pretty(keys)
	local parts = {}
	for raw in keys:gmatch("[^+]+") do
		local part = raw:match("^%s*(.-)%s*$")
		local name = NAMES[part] or (#part == 1 and part:upper()) or part
		table.insert(parts, name)
	end
	return table.concat(parts, " + ")
end

local function add(keys, desc)
	local s = byName[current]
	if not s then
		s = { name = current, rows = {} }
		byName[current] = s
		table.insert(sections, s)
	end
	table.insert(s.rows, { keys = keys, desc = desc })
end

function M.section(name)
	current = name
end

function M.bind(keys, action, desc, flags)
	local f = {}
	for key, val in pairs(flags or {}) do
		f[key] = val
	end
	local listed = f.list ~= false
	f.list = nil

	if desc then
		f.description = desc
		if listed then
			add(pretty(keys), desc)
		end
	end
	return hl.bind(keys, action, f)
end

function M.doc(keys, desc)
	add(keys, desc)
end

-- Super+F1: write the list, show it in Noctalia's launcher. Pressing again closes it.
function M.show()
	local path = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-keybinds.txt"
	local f = io.open(path, "w")
	if not f then
		return
	end
	for _, s in ipairs(sections) do
		for _, r in ipairs(s.rows) do
			-- tab splits a launcher row into title (keys → action) and subtitle (section)
			f:write(r.keys, "   →   ", r.desc, "\t", s.name, "\n")
		end
	end
	f:close()

	hl.exec_cmd(
		"pgrep -f '^noctalia dmenu' >/dev/null && noctalia msg panel-close || "
			.. "noctalia dmenu -p 'Search keybindings' < '"
			.. path
			.. "' >/dev/null"
	)
end

return M
