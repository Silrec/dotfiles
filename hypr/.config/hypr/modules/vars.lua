-- Shared values and helpers. Other modules: local v = require("modules.vars")
local M = {}

M.mod = "SUPER"

M.terminal = "kitty"
M.fileManager = "xdg-open " .. os.getenv("HOME")
M.browser = "firefox" -- change to the browser you use

M.ipc = "noctalia msg "

-- Dispatcher that runs a Noctalia IPC command, e.g. v.noctalia("panel-toggle launcher")
function M.noctalia(cmd)
	return hl.dsp.exec_cmd(M.ipc .. cmd)
end

-- Noctalia-styled notification. Use plain text without single quotes.
function M.notify(summary, body)
	local cmd = M.ipc .. "notification-show '" .. summary .. "'"
	if body then
		cmd = cmd .. " '" .. body .. "'"
	end
	hl.exec_cmd(cmd)
end

return M
