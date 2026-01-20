import os
import subprocess

from libqtile import hook, qtile

# Startup applications
@hook.subscribe.startup_once
def autostart():
   # if qtile.core.name == "x11":
   #    autostartscript = "~/.dotfiles/home/configs/qtile/scripts/x11-autostart.sh"
   if qtile.core.name == "wayland":
      autostartscript = "~/.dotfiles/home/configs/qtile/scripts/wayland-autostart.sh"

   home = os.path.expanduser(autostartscript)
   subprocess.Popen([home])

# Screen reconfiguration on monitor changes
@hook.subscribe.screen_change
def reconfigure_on_randr(event):
   """Trigger screen reconfiguration when monitors change."""
   qtile.reconfigure_screens()

# Temporarily disabled due to Qtile 0.34.1 bug causing input freezes
@hook.subscribe.screens_reconfigured
def reconfigure_bars():
   """Force bars to redraw after screen reconfiguration to prevent artifacts."""
   # Force all bars to redraw
   for screen in qtile.screens:
      if hasattr(screen, 'top') and screen.top:
         screen.top.draw()
      if hasattr(screen, 'bottom') and screen.bottom:
         screen.bottom.draw()
   