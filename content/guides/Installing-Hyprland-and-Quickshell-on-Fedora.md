---
title: "Installing Hyprland and Quickshell on Fedora"
date: 2026-10-28T07:29:17+08:00
lastmod: 2026-10-28T07:29:17+08:00
draft: false
description: "A step-by-step guide to building a Hyprland desktop on Fedora Sway, starting with the COPR repository, package installation and a working Quickshell bar."
tags: [Fedora, Sway, Hyprland, Quickshell,]
---

## Why build it from scratch?

After trying a few preconfigured Hyprland setups, I wanted to build a desktop myself and understand how the pieces fit together. Those ready-made configurations are useful for getting started, and for seeing what is possible, but making changes is easier when you know what is installed and what each configuration file does.

Hyprland has also moved to Lua for its configuration, starting with version 0.55. This seemed like a good opportunity to start fresh and learn the newer approach.

For the desktop components, I have chosen Quickshell. Hyprland manages the windows and workspaces, while Quickshell gives us the tools to build a bar and, later, add things such as menus and desktop controls. We will configure Hyprland using Lua and build the Quickshell components using QML.

This guide follows my setup on a Fedora 44 Sway installation running in a virtual machine. We will begin by enabling the COPR repository, installing the packages and getting a basic Quickshell bar running. I will add further sections as the desktop develops, explaining the changes and fixes along the way.

### This guide is based on  fresh install of Fedora Sway spin.  
Depending on when you do this after the initial release of the *Fedora-Sway*, the update could take a long time. The copr repo at the time of writing seems to be the most active and complete.  

```bash
sudo dnf update 
sudo reboot

sudo dnf copr enable lionheartp/Hyprland
sudo dnf install hyprland quickshell hyprland-guitools hyprlauncher 
```

Once this is completed, log out, you will have to Hyprland options, one preconfigured and another vanilla one. We are using the vanilla one.  

{{< figure src="/images/loginScreen.jpg" caption="Login screen showing 2 Hyprland options" align="center" >}}


Once logged in there is not much to see, to get the top bar working with QuickShell.  

### A short list of keyboard shortcut commands to get you going  

Super is the Windows key.  

|  Shortcut  |     Description  |
|  ---------  |   -----------   |
| Super Q   |   Open Terminal  |
| Super C   |  Close Window  |
| Super M  |  Exit Hyprland |

[Download shell.qml](/downloads/shell.qml)   , Right click, select Save As.

Save this file to `~/.config/quickshell/shell.qml` , you may need to make the `quickshell` directory

Then edit  `nvim ~/.config/hypr/hyprland.lua` , below is an example, I have marked the line I added, and just uncommented the others.  


```qml
cd ~/.config/quickshell
nvim shell.qml

cd ../hyprland
nvim hyprland.lua
   ----------------------------------------------------
-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function ()
hl.exec_cmd("qs")   <--- Add this
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
end)
```
Log out and back in. You should be looking at a screen like below.  

{{< figure src="/images/hyprland-1.jpg" caption="Default Hyprland desktop" align="center" >}}


Don't shoot me for the wallpaper, that's is how it came.



