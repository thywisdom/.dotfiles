-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ============================================================
-- UNBINDINGS
-- Remove omarchy defaults before replacing them.
-- ============================================================

-- SUPER
hl.unbind("SUPER + slash")
hl.unbind("SUPER + TAB")
-- hl.unbind("SUPER + W")


-- SUPER + SHIFT
hl.unbind("SUPER + SHIFT + N")

-- SUPER + ALT
hl.unbind("SUPER + ALT + slash")
hl.unbind("SUPER + ALT + SPACE")
hl.unbind("SUPER + ALT + K")


-- SUPER + CTRL
-- hl.unbind("SUPER + CTRL + N")

-- ============================================================
-- SESSION — SYSTEM CONTROLS
-- ============================================================

-- Window Management
-- o.bind("SUPER + SHIFT + Q", "Kill active window", hl.dsp.window.close())

-- Interface, Bars & Custom Switchers
o.bind("ALT + SPACE", "Apps", "omarchy-menu toggle apps")
o.bind("SUPER + ALT+ O",         "Projects",              "custom-project-open.sh")
o.bind("SUPER+ ALT + Space",     "Scripts Menu",          "custom-unified-menu.sh")
o.bind("SUPER + ALT+ K",         "Toggle Keyboard RGB",   "custom-keyboard-rgb.sh toggle")

-- ============================================================
-- SESSION — SHELL PLUGINS BINDS
-- ============================================================

-- Workspace overview
o.bind("SUPER + TAB",     "Overview",    "omarchy-shell shell toggle omarchy-overview")

-- ============================================================
-- SPECIAL CHARACTER BINDINGS
-- ============================================================

-- Editor
o.bind("SUPER + comma",         "Editor (Code)",        "uwsm app -- vscodium")
o.bind("SUPER + SHIFT + comma", "Editor (Antigravity)", "uwsm app -- custom-antigravity-launch")

-- Music
o.bind("SUPER + period",         "Spotify",       "uwsm app -- spotify changes")
o.bind("SUPER + SHIFT + period", "YouTube Music", o.launch_webapp("https://music.youtube.com/"))

-- Search
o.bind("SUPER + slash",         "Google Search", o.launch_webapp("https://google.com/"))
o.bind("SUPER + SHIFT + slash", "Gemini Search", o.launch_webapp("https://gemini.google.com/app"))

-- ============================================================
-- ALPHABETICAL BINDINGS
-- ============================================================

-- A
o.bind("SUPER + A",         "AI (ChatGPT)", o.launch_webapp("https://chatgpt.com"))
o.bind("SUPER + SHIFT + A", "AI (Claude)",  o.launch_webapp("https://claude.ai/new"))

-- D
o.bind("SUPER + D",         "Discord",            "uwsm app -- discord")
o.bind("SUPER + SHIFT + D", "Docker (Lazydocker)", "uwsm app -- $(omarchy-default-terminal) -e lazydocker")


-- M
o.bind("SUPER + E",         "Email (Primary)",  o.launch_webapp("https://mail.google.com/mail/u/0/"))
o.bind("SUPER + SHIFT + E", "Email (Personal)", o.launch_webapp("https://mail.google.com/mail/u/1/"))

-- N
o.bind("SUPER + N",         "Notes (Obsidian)",    o.launch_sole("obsidian", "obsidian --enable-wayland-ime"))
o.bind("SUPER + SHIFT + N", "Notes (Google Keep)", o.launch_webapp("https://keep.google.com/u/0/"))

-- R
o.bind("SUPER + R", "Reddit", o.launch_webapp("https://reddit.com"))

-- W
o.bind("SUPER + M", "Telegram", "uwsm app -- Telegram %u")
o.bind("SUPER + SHIFT + M", "WhatsApp", o.launch_webapp("https://web.whatsapp.com/"))


-- Y
o.bind("SUPER + Y", "YouTube", o.launch_webapp("https://youtube.com/"))

-- ============================================================
-- SPECIAL KEY BINDINGS
-- ============================================================

-- Music workspace scratchpad (special:music)
o.bind("SUPER + F1",         "Music Workspace (special:music)",    "custom-music-workspace")
o.bind("SUPER + ALT + F1",   "Move Window → Music Workspace",      hl.dsp.window.move({ workspace = "special:music", follow = false }))

-- ============================================================
-- CUSTOM SCRIPTED BINDINGS
-- ============================================================

-- o.bind("SUPER + CTRL + N", "Toggle Nightlight (3000K)", "bash -c 'temp=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE \"[0-9]+\"); if [ \"$temp\" -lt 6000 ]; then hyprctl hyprsunset temperature 6500; else hyprctl hyprsunset temperature 3250; fi'")

