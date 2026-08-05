-- Extra autostart processes.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- o.launch_on_start("my-service")

o.exec_on_start("sleep 2 && ~/.config/hypr/scripts/nightlight.sh")
