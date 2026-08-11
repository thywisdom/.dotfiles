-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "eDP-1", mode = "1920x1080@90", position = "auto", scale =omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })



-- Old monitor.conf reference
--env     = GDK_SCALE,1
--monitor = eDP-1,    1920x1080@90,  auto,   1.25
--monitor = HDMI-A-1, 1920x1080@60,  1920x0, 1.25
--workspace = 5, monitor:eDP-1, default:true
