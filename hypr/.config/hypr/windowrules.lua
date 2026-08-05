-- ============================================
-- HYPRLAND WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- ============================================

-- Spotify & Music → special:music scratchpad (silent = no auto-focus-switch)
o.window("^(Spotify|spotify)$", { workspace = "special:music silent" })
o.window("^(brave-music\\.youtube\\.com__-Default|chrome-music\\.youtube\\.com__-Default)$", { workspace = "special:music silent" })
o.window({ title = "^(Spotify Premium|YouTube Music)$" }, { workspace = "special:music silent" })

-- Custom floating class (any window launched with class "floating")
o.window("^(floating)$", { float = true, size = "60% 50%", center = true })

-- User scripts launched in terminal (bin-permissions etc.) — float centered
o.window("^(user-script)$", { float = true, size = "80% 60%", center = true })

-- Google search & Gemini search webapps (supports both Chrome and Brave)
o.window("^((chrome|brave)-google\\.com.*|(chrome|brave)-gemini\\.google\\.com.*)$", { float = true, size = "1100 700", center = true })

-- System dialogs (file pickers, portals, OnlyOffice popups)
o.window("^(DesktopEditors|xdg-desktop-portal-gtk|Xdg-desktop-portal-gtk)$", { float = true, size = "60% 50%", center = true })
