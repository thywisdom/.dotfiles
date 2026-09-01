-- ============================================
-- HYPRLAND WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- ============================================

-- Spotify & Music → special:music scratchpad (silent = no auto-focus-switch)
--o.window("^(Spotify|spotify)$", { workspace = "special:music silent" })
--o.window("^(brave-music\\.youtube\\.com__-Default|chrome-music\\.youtube\\.com__-Default)$", { workspace = "special:music silent" })
--o.window({ title = "^(Spotify Premium|YouTube Music)$" }, { workspace = "special:music silent" })

-- Custom floating class (any window launched with class "floating")
o.window("^(floating)$", { float = true, size = { 920, 432 }, center = true })

-- Custom scripts launched in terminal (custom-bin-permissions, custom-system-cleanup, etc.) — large floating centered rectangle
o.window("^((custom|user)-scripts?)$", { float = true, size = { 1350, 708 }, center = true })

-- Google search & Gemini search webapps (supports both Chrome and Brave)
o.window("^((chrome|brave)-google\\.com.*|(chrome|brave)-gemini\\.google\\.com.*)$", { float = true, size = { 1100, 700 }, center = true })

-- System dialogs (file pickers, portals, OnlyOffice popups)
o.window("^(DesktopEditors|xdg-desktop-portal-gtk|Xdg-desktop-portal-gtk)$", { float = true, size = { 920, 432 }, center = true })


-- Disable all transparency on all windows
-- o.window(".*", { opacity = "1.0 override 1.0 override" })


hl.workspace_rule({
    workspace = 5,
    monitor = "eDP-1",
    default = true,
})

