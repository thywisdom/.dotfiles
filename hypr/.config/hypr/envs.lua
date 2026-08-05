-- User environment overrides.
-- Loaded after Omarchy's default/hypr/envs.lua (via require("default.hypr.omarchy")).
-- Only variables that differ from or extend Omarchy's defaults belong here.

local paths = require("default.hypr.paths")

-- ---------------------------------------------------------------------------
-- PATH — add personal bin directory.
-- Omarchy's envs.lua prepends its own bin dir first. We insert ~/.local/bin
-- immediately after Omarchy's bin so personal scripts take precedence over
-- system paths but yield to Omarchy's own tooling.
-- ---------------------------------------------------------------------------
local personal_bin = paths.home .. "/.local/bin"
local omarchy_bin  = paths.omarchy_path .. "/bin"

-- Rebuild PATH: omarchy_bin first, then personal_bin, then system paths deduped.
local seen    = {}
local ordered = {}

for _, dir in ipairs({ omarchy_bin, personal_bin }) do
  if not seen[dir] then
    seen[dir] = true
    table.insert(ordered, dir)
  end
end

for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin:/usr/sbin:/bin"):gmatch("[^:]+") do
  if not seen[entry] then
    seen[entry] = true
    table.insert(ordered, entry)
  end
end

hl.env("PATH", table.concat(ordered, ":"))

-- ---------------------------------------------------------------------------
-- Chromium / Electron backend — intentional override of Omarchy's "wayland".
-- "auto" lets the apps detect the best backend; safer for mixed Wayland +
-- XWayland setups and avoids forced-wayland breakage on some apps.
-- ---------------------------------------------------------------------------
hl.env("OZONE_PLATFORM", "auto")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ---------------------------------------------------------------------------
-- Tensaku screenshot editor (wired by `tensaku --wire-omarchy`).
-- ---------------------------------------------------------------------------
hl.env("OMARCHY_SCREENSHOT_EDITOR", "/usr/bin/tensaku-edit")
