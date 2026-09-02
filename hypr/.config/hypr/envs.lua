-- User environment overrides.
-- Loaded after Omarchy's default/hypr/envs.lua.
-- Omarchy automatically handles:
--   - PATH (~/.local/bin, mise shims, omarchy bin)
--   - Wayland backends (GDK, Qt, Firefox, Electron/Chromium Ozone)
--   - GTK/Qt themes and cursor sizes (24px)
--   - Dynamic Nvidia detection (default/hypr/nvidia.lua)
--   - System editor (omarchy-launch-editor)

local paths = require("default.hypr.paths")

-- ===========================================================================
-- 1. ADDITIONAL TOOLCHAIN PATHS (Optional)
-- ===========================================================================
-- ~/.local/bin and ~/.local/share/mise/shims are ALREADY in PATH via Omarchy's UWSM env.
-- Add non-mise toolchain directories here if you use them:

local cargo_bin = paths.home .. "/.cargo/bin"
local current_path = os.getenv("PATH") or ""

if not current_path:find(cargo_bin, 1, true) then
  hl.env("PATH", current_path .. ":" .. cargo_bin)
end

-- ===========================================================================
-- 2. TOOLKIT & WINDOW TWEAKS (Optional)
-- ===========================================================================

-- Prevent Qt applications from drawing duplicate client-side titlebars in tiling mode
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Custom screenshot annotation editor (if using tensaku or custom tool)
-- hl.env("OMARCHY_SCREENSHOT_EDITOR", "/usr/bin/tensaku-edit")

-- ===========================================================================
-- 3. HARDWARE & COMPOSITOR REFERENCE (For documentation only)
-- ===========================================================================
-- Omarchy automatically configures Nvidia hardware via /usr/share/omarchy/default/hypr/nvidia.lua.
-- Manual overrides are NOT needed unless troubleshooting specific GPU issues:
--
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
