shortcut.setLabel("Picker")
shortcut.setIcon("color-picker")

function onClick()
  -- close the control center first, otherwise it ends up in hyprpicker's frozen screen
  noctalia.runAsync([[noctalia msg panel-close; sleep 0.3; c=$(hyprpicker -a) && noctalia msg notification-show "Color copied" "$c"]])
end
