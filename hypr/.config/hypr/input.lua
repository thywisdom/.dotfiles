-- Personal input overrides.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Keyboard layout and options.
hl.config({
  input = {
    kb_layout  = "us",
    kb_options = "compose:caps",  -- ,grp:alt_space_toggle to add layout switching

    -- Keyboard repeat speed.
    repeat_rate  = 40,
    repeat_delay = 600,

    touchpad = {
      natural_scroll = true,    -- Use natural (inverse) scrolling
      scroll_factor  = 0.3,     -- Control the speed of scrolling
    },
  },
})

-- Touchpad gesture: 3-finger horizontal swipe to change workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Scroll faster in the terminal (foot).
o.window("foot", { scroll_touchpad = 1 })


-- Custom settings for Logitech wireless mouse only
--
hl.device({
  name = "logitech-wireless-mouse-pid:4022-1",
  sensitivity = -0.25,
  accel_profile = "adaptive",
  scroll_factor = 0.7,
})
