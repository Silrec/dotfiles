-- Capture menu: one Tabler icon per entry; the work is done by ~/.local/bin/capture
local capture = '"$HOME/.local/bin/capture" '

local items = {
  { id = "region",        title = "Screenshot region", subtitle = "Select an area",                        glyph = "crop" },
  { id = "screen",        title = "Screenshot screen", subtitle = "Current monitor",                       glyph = "device-desktop" },
  { id = "window",        title = "Screenshot window", subtitle = "Active window",                         glyph = "app-window" },
  { id = "annotate",      title = "Annotate",          subtitle = "Freeze the screen and draw on it",      glyph = "pencil" },
  { id = "ocr",           title = "OCR region",        subtitle = "Recognise text in an area → clipboard", glyph = "text-recognition" },
  { id = "record",        title = "Record screen",     subtitle = "Current monitor, with system audio",    glyph = "video" },
  { id = "record-region", title = "Record region",     subtitle = "Selected area, with system audio",      glyph = "marquee-2" },
}
local stop = {
  { id = "record", title = "Stop recording", subtitle = "A recording is running", glyph = "player-stop-filled" },
}

local recording = false

local function matches(q, it)
  if q == "" then return true end
  local hay = string.lower(it.title .. " " .. it.subtitle)
  q = string.lower(q)
  if noctalia.fuzzyScore then return noctalia.fuzzyScore(q, hay) ~= nil end
  return string.find(hay, q, 1, true) ~= nil
end

local function publish(text)
  local out = {}
  for _, it in ipairs(recording and stop or items) do
    if matches(text, it) then
      table.insert(out, { id = it.id, title = it.title, subtitle = it.subtitle, glyph = it.glyph })
    end
  end
  launcher.setResults(text, out)
end

function onQuery(text)
  publish(text)                                    -- instant, using the last known state
  noctalia.runAsync("pgrep -x wf-recorder", function(r)
    local now = r.exitCode == 0
    if now ~= recording then
      recording = now
      publish(text)
    end
  end)
end

function onActivate(id)
  -- wait for the launcher to close before capturing the screen
  noctalia.runAsync("sleep 0.3; exec " .. capture .. id)
end
