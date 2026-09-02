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
-- Keep only your personal keybinding overrides here.
-- Add new bindings or unbind defaults before replacing them.

-- ============================================================
-- UNBINDINGS
-- Remove Omarchy defaults before binding personal overrides.
-- ============================================================

-- SUPER
hl.unbind("SUPER + TAB")             -- Default: Next workspace (repurposed for Overview)
hl.unbind("SUPER + comma")           -- Default: Dismiss last notification (repurposed for VSCodium)
hl.unbind("SUPER + slash")           -- Default: Monitor scaling up (repurposed for Google Search)

-- SUPER + SHIFT
hl.unbind("SUPER + SHIFT + comma")   -- Default: Dismiss all notifications (repurposed for Antigravity)
hl.unbind("SUPER + SHIFT + slash")   -- Default: 1Password (repurposed for Gemini Search)
hl.unbind("SUPER + SHIFT + N")       -- Default: Editor (repurposed for Google Keep)
hl.unbind("SUPER + SHIFT + M")       -- Default: Spotify (repurposed for WhatsApp)

-- SUPER + ALT
hl.unbind("SUPER + ALT + slash")     -- Default: Monitor scaling down
hl.unbind("SUPER + ALT + SPACE")     -- Default: Apps menu (repurposed for Scripts Menu)
hl.unbind("SUPER + ALT + K")         -- Default: Tmux keybindings (repurposed for Keyboard RGB)

-- SUPER + CTRL
hl.unbind("SUPER + CTRL + N")       -- Default: Nightlight toggle (repurposed for custom 3250K/6500K cycle)

-- ============================================================
-- INTERFACE, BARS & CUSTOM SWITCHERS
-- ============================================================

o.bind("ALT + SPACE",             "Apps Menu",           "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE",     "Scripts Menu",        "custom-unified-menu.sh")
o.bind("SUPER + ALT + O",         "Projects Switcher",   "custom-project-open.sh")
o.bind("SUPER + ALT + K",         "Toggle Keyboard RGB", "custom-keyboard-rgb.sh toggle")

-- Workspace visual overview
o.bind("SUPER + TAB",             "Workspace Overview",  "omarchy-shell shell toggle omarchy-overview")

-- ============================================================
-- APPLICATION SHORTCUTS (Primary / Secondary Pairs)
-- ============================================================

-- IDE & Editors (comma)
o.bind("SUPER + comma",           "Editor (VSCodium)",   o.launch("vscodium"))
o.bind("SUPER + SHIFT + comma",   "Editor (Antigravity)","custom-antigravity-launch")

-- Audio & Streaming (period)
o.bind("SUPER + period",          "Spotify",             o.launch("spotify"))
o.bind("SUPER + SHIFT + period",  "YouTube Music",       o.launch_webapp("https://music.youtube.com/"))

-- Web Search & AI Assistant (slash)
o.bind("SUPER + slash",           "Google Search",       o.launch_webapp("https://google.com/"))
o.bind("SUPER + SHIFT + slash",   "Gemini Search",       o.launch_webapp("https://gemini.google.com/app"))

-- AI Chatbots (A)
o.bind("SUPER + A",               "AI (ChatGPT)",        o.launch_webapp("https://chatgpt.com"))
o.bind("SUPER + SHIFT + A",       "AI (Claude)",         o.launch_webapp("https://claude.ai/new"))

-- Development & Containers (D)
o.bind("SUPER + D",               "Discord",             o.launch("discord"))
o.bind("SUPER + SHIFT + D",       "Docker (Lazydocker)", "omarchy-launch-tui lazydocker")

-- Email (E)
o.bind("SUPER + E",               "Email (Primary)",     o.launch_webapp("https://mail.google.com/mail/u/0/"))
o.bind("SUPER + SHIFT + E",       "Email (Personal)",    o.launch_webapp("https://mail.google.com/mail/u/1/"))

-- Notes & Knowledge Base (N)
o.bind("SUPER + N",               "Notes (Obsidian)",    o.launch_sole("obsidian", "obsidian --enable-wayland-ime"))
o.bind("SUPER + SHIFT + N",       "Notes (Google Keep)", o.launch_webapp("https://keep.google.com/u/0/"))

-- Instant Messaging (M)
o.bind("SUPER + M",               "Telegram",            o.launch("telegram-desktop"))
o.bind("SUPER + SHIFT + M",       "WhatsApp",            o.launch_webapp("https://web.whatsapp.com/"))

-- Media & Social Feeds (R / Y)
o.bind("SUPER + R",               "Reddit",              o.launch_webapp("https://reddit.com"))
o.bind("SUPER + Y",               "YouTube",             o.launch_webapp("https://youtube.com/"))

-- ============================================================
-- SPECIAL WORKSPACES & HARDWARE
-- ============================================================

-- Music scratchpad workspace (special:music)
o.bind("SUPER + F1",              "Music Workspace",     "custom-music-workspace")
o.bind("SUPER + ALT + F1",        "Move Window → Music", hl.dsp.window.move({ workspace = "special:music", follow = false }))

-- Custom Nightlight Toggle (3250K Warm / 6500K Daylight)
o.bind("SUPER + CTRL + N",        "Toggle Nightlight (3250K/6500K)", "bash -c 'temp=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE \"[0-9]+\"); if [ \"$temp\" -lt 6000 ]; then hyprctl hyprsunset temperature 6500; else hyprctl hyprsunset temperature 3250; fi'")
