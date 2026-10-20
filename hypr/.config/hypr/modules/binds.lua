-- Keybinds
-- Modifier logic:
--   SUPER         everyday actions
--   SUPER+SHIFT   "move it" / stronger version
--   SUPER+CTRL    workspace / monitor level
--   SUPER+ALT     toggles and modes
-- Host-specific binds (Super+P mirror/extend) live in hosts/<hostname>.lua.
-- Super+F1 lists every bind that has a description (see modules/keyhelp.lua).

local v = require("modules.vars")
local kb = require("modules.keyhelp")
local bind, doc, section = kb.bind, kb.doc, kb.section
local n = v.noctalia

local function k(keys)
	return v.mod .. " + " .. keys
end

---------------
---- SHELL ----
---------------
section("Shell")

bind(k("F1"), kb.show, "Keybindings (this menu)")
bind(k("Escape"), n("panel-toggle launcher"), "App launcher")
bind(k("A"), n("panel-toggle control-center"), "Control center")
bind(k("N"), n("panel-toggle control-center notifications"), "Notification history") -- tab name: verify with your version
bind(k("I"), n("settings-toggle"), "Noctalia settings")
bind(k("V"), n("panel-toggle clipboard"), "Clipboard history")
bind(k("period"), n('panel-toggle launcher "/emo "'), "Emoji picker")
bind(k("L"), n("session lock"), "Lock screen")
bind(k("X"), n("panel-toggle session"), "Session menu")
bind("CTRL + ALT + Delete", n("panel-toggle session"), "Session menu")
bind("ALT + Tab", n("window-switcher"), "Window switcher")
bind(k("Pause"), hl.dsp.exec_cmd("pkill -x noctalia; sleep 1; noctalia"), "Restart Noctalia")

-----------------
---- WINDOWS ----
-----------------
section("Windows")

bind(k("Q"), hl.dsp.window.close(), "Close window")
--bind("ALT + F4", hl.dsp.window.close(), "Close window")
bind(k("SHIFT + Q"), hl.dsp.window.kill(), "Force-kill frozen window")

bind(k("F"), hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen (covers the bar)")
bind(k("SHIFT + F"), hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximize (keeps the bar)")
bind(k("T"), hl.dsp.window.float({ action = "toggle" }), "Toggle floating / tiling")
if hl.get_config("general.layout") == "master" then
	bind(k("J"), hl.dsp.layout("togglesplit"), "Toggle split direction (dwindle)")
end
bind(k("Z"), function()
	local layout = hl.get_config("general.layout") == "dwindle" and "master" or "dwindle"
	hl.config({ ["general.layout"] = layout })
	v.notify("Layout", layout)
end, "Switch layout: dwindle / master")

--bind(k("G"), hl.dsp.group.toggle(), "Group windows into tabs / ungroup")
--bind(k("grave"), hl.dsp.group.next(), "Next tab in group") -- grave is `

--bind(k("M"), hl.dsp.window.move({ workspace = "special:minimized", follow = false }), "Minimize window")
--bind(k("SHIFT + M"), hl.dsp.workspace.toggle_special("minimized"), "Show / hide minimized windows")

-- Focus / move (moving past a screen edge continues to the next monitor)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
	bind(k(dir), hl.dsp.focus({ direction = dir }), "Focus " .. dir, { list = false })
	bind(k("SHIFT + " .. dir), hl.dsp.window.move({ direction = dir }), "Move window " .. dir, { list = false })
end
doc("Super + ←↑→↓", "Move focus")
doc("Super + Shift + ←↑→↓", "Move window (continues onto the next monitor)")

bind(k("mouse:272"), hl.dsp.window.drag(), "Move window with mouse", { mouse = true })
bind(k("mouse:273"), hl.dsp.window.resize(), "Resize window with mouse", { mouse = true })

-- Resize by a fraction of the current monitor, so a step feels the same on any screen
local RESIZE_STEP = 0.025 -- 2.5% of the screen per press

local function resizeBy(dx, dy)
	return function()
		local mon = hl.get_active_monitor()
		if not mon then
			return
		end
		-- width/height are physical pixels; resize works in logical ones
		local w, h = mon.width / mon.scale, mon.height / mon.scale
		hl.dispatch(hl.dsp.window.resize({ x = dx * w * RESIZE_STEP, y = dy * h * RESIZE_STEP, relative = true }))
	end
end

bind(k("R"), hl.dsp.submap("resize"), "Resize mode (arrows resize, Esc / Enter exits)")
hl.define_submap("resize", function()
	bind("right", resizeBy(1, 0), nil, { repeating = true })
	bind("left", resizeBy(-1, 0), nil, { repeating = true })
	bind("down", resizeBy(0, 1), nil, { repeating = true })
	bind("up", resizeBy(0, -1), nil, { repeating = true })
	bind("escape", hl.dsp.submap("reset"))
	bind("Return", hl.dsp.submap("reset"))
	bind("KP_Enter", hl.dsp.submap("reset"))
	bind(k("R"), hl.dsp.submap("reset"))
end)

-- Red border on the focused window while resize mode is active
local resizeBorder = hl.window_rule({
	name = "resize-mode-border",
	match = { focus = true }, -- only the window being resized
	border_color = "rgb(ff5555)",
	-- border_size = 3,           -- optional: thicker border to make it stand out more
})
resizeBorder:set_enabled(false) -- off until you enter resize mode

hl.on("keybinds.submap", function(name)
	resizeBorder:set_enabled(name == "resize")
end)

--------------------
---- WORKSPACES ----
--------------------
section("Workspaces")

-- Numpad keycodes for 1…9, 0 (physical keys, independent of NumLock/Shift state)
local KP = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

for i = 1, 10 do
	local key = tostring(i % 10) -- workspace 10 is key 0
	local kp = "code:" .. KP[i]
	for _, kk in pairs({ key, kp }) do
		bind(k(kk), hl.dsp.focus({ workspace = i }), "Workspace " .. i, { list = false })
		bind(
			k("SHIFT + " .. kk),
			hl.dsp.window.move({ workspace = i, follow = true }),
			"Move window to workspace " .. i,
			{ list = false }
		)
		bind(
			k("ALT + " .. kk),
			hl.dsp.window.move({ workspace = i, follow = false }),
			"Send window to workspace " .. i,
			{ list = false }
		)
	end
end
doc("Super + 1…0", "Go to workspace 1–10")
doc("Super + Shift + 1…0", "Move window to workspace and follow")
doc("Super + Alt + 1…0", "Send window to workspace")

bind(k("Tab"), hl.dsp.focus({ workspace = "previous" }), "Back to previous workspace")
bind(k("CTRL + left"), hl.dsp.focus({ workspace = "m-1" }), "Previous workspace")
bind(k("CTRL + right"), hl.dsp.focus({ workspace = "m+1" }), "Next workspace")
bind(
	k("CTRL + SHIFT + left"),
	hl.dsp.window.move({ workspace = "r-1", follow = true }),
	"Move window to previous workspace and follow"
)
bind(
	k("CTRL + SHIFT + right"),
	hl.dsp.window.move({ workspace = "r+1", follow = true }),
	"Move window to next workspace and follow"
)
bind(
	k("CTRL + ALT + left"),
	hl.dsp.window.move({ workspace = "r-1", follow = false }),
	"Send window to previous workspace"
)
bind(
	k("CTRL + ALT + right"),
	hl.dsp.window.move({ workspace = "r+1", follow = false }),
	"Send window to next workspace"
)
bind(k("mouse_down"), hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(k("mouse_up"), hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind(k("D"), hl.dsp.focus({ workspace = "emptym" }), "Go to an empty workspace")

bind(k("S"), hl.dsp.workspace.toggle_special("scratchpad"), "Show / hide scratchpad")
bind(k("CTRL + S"), hl.dsp.window.move({ workspace = "special:scratchpad" }), "Send window to scratchpad")

bind(k("CTRL + SHIFT + left"), hl.dsp.workspace.move({ monitor = "l" }), "Move workspace to left monitor")
bind(k("CTRL + SHIFT + right"), hl.dsp.workspace.move({ monitor = "r" }), "Move workspace to right monitor")

--------------
---- APPS ----
--------------
section("Apps")

bind(k("Return"), hl.dsp.exec_cmd(v.terminal), "Terminal")
--bind("CTRL + ALT + T", hl.dsp.exec_cmd(v.terminal), "Terminal")
bind(
	k("SHIFT + Return"),
	hl.dsp.exec_cmd(v.terminal, { float = true, size = { 1100, 700 }, center = true }),
	"Floating terminal"
)
bind(k("KP_Enter"), hl.dsp.exec_cmd(v.terminal), "Terminal", { list = false })
bind(
	k("SHIFT + KP_Enter"),
	hl.dsp.exec_cmd(v.terminal, { float = true, size = { 1100, 700 }, center = true }),
	"Floating terminal",
	{ list = false }
)
bind(k("E"), hl.dsp.exec_cmd(v.fileManager), "File manager")
bind(k("B"), hl.dsp.exec_cmd(v.browser), "Browser")
bind(k("grave"), hl.dsp.exec_cmd(v.terminal .. " --class sysmon -e btop"), "System monitor")

-------------------------------
---- SCREENSHOTS AND TOOLS ----
-------------------------------
section("Screenshots and tools")
kb.section("Capture")
bind("Print", n("screenshot-fullscreen"), "Screenshot: full screen")
local cap = os.getenv("HOME") .. "/.local/bin/capture "
--kb.bind("Print", hl.dsp.exec_cmd(cap .. "menu"), "Capture menu")
bind(k("Print"), n("screenshot-region"), "Screenshot: region")
kb.bind(k("SHIFT + Print"), hl.dsp.exec_cmd(cap .. "menu"), "Capture menu")
-- Active window -> clipboard (needs grim, wl-clipboard)
--bind("ALT + Print", function()
--	local w = hl.get_active_window()
--	if not w then
--		return
--	end
--	local geo = string.format("%d,%d %dx%d", w.at.x, w.at.y, w.size.x, w.size.y)
--	hl.exec_cmd('grim -g "' .. geo .. '" - | wl-copy')
--	v.notify("Screenshot", "Window copied to clipboard")
--end, "Screenshot: active window to clipboard")

-- needs grim, slurp, tesseract, tesseract-data-eng, wl-clipboard
--bind(
--	k("SHIFT + T"),
--	hl.dsp.exec_cmd('grim -g "$(slurp)" - | tesseract stdin stdout -l eng 2>/dev/null | wl-copy'),
--	"Copy text from screen region (OCR)"
--)

-- needs hyprpicker
--bind(k("SHIFT + C"), hl.dsp.exec_cmd("hyprpicker -a"), "Color picker (copies hex)")

-- needs wf-recorder
bind(
	k("ALT + R"),
	hl.dsp.exec_cmd(
		"pkill -INT -x wf-recorder && "
			.. v.ipc
			.. "notification-show 'Recording saved' || "
			.. "(mkdir -p ~/Videos && "
			.. v.ipc
			.. "notification-show 'Recording started' && "
			.. 'wf-recorder -f "$HOME/Videos/rec_$(date +%F_%H-%M-%S).mp4")'
	),
	"Screen recording start / stop"
)

-----------------
---- TOGGLES ----
-----------------
section("Toggles")

bind(k("ALT + D"), n("notification-dnd-toggle"), "Do Not Disturb")
--bind(k("ALT + N"), n("nightlight-force-toggle"), "Night light")
bind(k("ALT + C"), n("caffeine-toggle"), "Caffeine (block idle / lock)")
--bind(k("ALT + B"), n("bar-toggle"), "Show / hide bar")
--bind(k("ALT + T"), n("theme-mode-toggle"), "Dark / light theme")
bind(k("ALT + K"), n("mic-mute"), "Mute microphone")
--bind(k("CTRL + R"), hl.dsp.exec_cmd("hyprctl reload"), "Reload Hyprland config")
--bind(k("Space"), hl.dsp.exec_cmd("hyprctl switchxkblayout current next"), "Switch keyboard layout")

-- Game mode: animations, blur and shadows off (reset on config reload)
--local gameMode = false
--bind(k("ALT + G"), function()
--	gameMode = not gameMode
--	hl.config({
--		["animations.enabled"] = not gameMode,
--		["decoration.blur.enabled"] = not gameMode,
--		["decoration.shadow.enabled"] = not gameMode,
--	})
--	v.notify("Game mode", gameMode and "On" or "Off")
--end, "Game mode (animations, blur, shadows off)")

-- Pass-through: disables every bind except this one and the media keys (for games/VMs)
--bind(k("ALT + escape"), function()
--	hl.dispatch(hl.dsp.submap("passthrough"))
--	v.notify("Keybinds disabled", "Super+Alt+Esc to restore")
--end, "Pass-through: disable all keybinds (press again to restore)")
--hl.define_submap("passthrough", function()
--	bind(k("ALT + escape"), function()
--		hl.dispatch(hl.dsp.submap("reset"))
--		v.notify("Keybinds restored")
--	end)
--end)

---------------------------
---- MEDIA / HARDWARE ----
---------------------------
section("Media keys")
-- submap_universal: these keep working in resize/pass-through mode

local media = { locked = true, submap_universal = true, list = false }
local mediaRepeat = { locked = true, repeating = true, submap_universal = true, list = false }

local vstep = os.getenv("HOME") .. "/.local/bin/volume-step "
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(vstep .. "up"), "Volume up", mediaRepeat)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(vstep .. "down"), "Volume down", mediaRepeat)
bind(k("XF86AudioRaiseVolume"), n("volume-up 1"), "Volume up 1%", mediaRepeat)
bind(k("XF86AudioLowerVolume"), n("volume-down 1"), "Volume down 1%", mediaRepeat)
bind("XF86AudioMute", n("volume-mute"), "Mute", media)
bind("XF86AudioMicMute", n("mic-mute"), "Mute microphone", media)

bind("XF86MonBrightnessUp", n("brightness-up"), "Brightness up", mediaRepeat)
bind("XF86MonBrightnessDown", n("brightness-down"), "Brightness down", mediaRepeat)

bind("XF86AudioPlay", n("media toggle"), "Play / pause", media)
bind("XF86AudioPause", n("media toggle"), "Play / pause", media)
bind("XF86AudioStop", n("media stop"), "Stop", media)
bind("XF86AudioNext", n("media next"), "Next track", media)
bind("XF86AudioPrev", n("media previous"), "Previous track", media)
bind("XF86Calculator", hl.dsp.exec_cmd(v.terminal .. " --class calculator -e qalc"), "Calculator", media)

doc("Calculator key", "Calculator")
doc("Volume keys", "Volume up / down / mute")
doc("Brightness keys", "Brightness up / down")
doc("Media keys", "Prev, play / pause, stop, next")
