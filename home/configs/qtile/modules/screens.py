from .widgets import init_widgets

from libqtile import bar
from libqtile.config import Screen

screens = [
    Screen(
        # name="HDMI-A-1",
        wallpaper='~/Pictures/current_wallpaper.jpg',
        wallpaper_mode="fill"
    ),
    Screen(
        # name="eDP-1",
        top=bar.Bar(
            widgets=init_widgets(1),
            background='#0000003f',
            margin=0,
            size=30,
            opacity=0.9
        ),
        wallpaper='~/Pictures/current_wallpaper.jpg',
        wallpaper_mode="fill"
    ),
    Screen(
        # name="DP-7",
        top=bar.Bar(
            widgets=init_widgets(1),
            background='#0000003f',
            margin=0,
            size=30,
            opacity=0.9
        ),
        wallpaper='~/Pictures/current_wallpaper.jpg',
        wallpaper_mode="fill"
    ),
    Screen(
        # name="DP-6",
        top=bar.Bar(
            widgets=init_widgets(1),
            background='#0000003f',
            margin=0,
            size=30,
            opacity=0.9
        ),
        wallpaper='~/Pictures/current_wallpaper.jpg',
        wallpaper_mode="fill"
    ),
]