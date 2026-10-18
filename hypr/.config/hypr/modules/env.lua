-- Environment variables
-- With uwsm, the real source is ~/.config/uwsm/env and env-hyprland (systemd-launched apps need them there).
-- Kept here as well for the "Hyprland (no uwsm)" fallback session; keep both in sync.

hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
