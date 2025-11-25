# Clearing xfwm4 Keybindings Declaratively

Since setting `null` doesn't work, you need to explicitly clear each binding.

## Step 1: Query current xfwm4 bindings

```bash
xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4 -lv
```

## Step 2: Add each binding to xfconf.settings

For each binding returned, set it to an empty string in your `xfce.nix`:

```nix
xfce4-keyboard-shortcuts = {
    "xfwm4/default/<Up>" = "";
    "xfwm4/default/<Down>" = "";
    "xfwm4/default/<Left>" = "";
    "xfwm4/default/<Right>" = "";
    # ... add all bindings from the query
};
```

## Step 3: Rebuild

```bash
sudo nixos-rebuild switch --flake .#darter-pro
```

## Notes

- The property paths must match exactly what `xfconf-query` returns
- Some keys may have special characters that need escaping
- You may need to log out and back in for changes to take effect
