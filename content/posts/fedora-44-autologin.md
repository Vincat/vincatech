---
title: "Fedora 44 Autologin"
date: 2026-09-05T19:50:21+08:00
draft: false
description: "Enable autologin on Fedora 44 by editing the GDM configuration, avoiding a second password prompt after unlocking a LUKS-encrypted drive."
tags: [fedora-44, autologin, gnome, GDM]
---

## Scenerio  
I have my HDD encrypted with LUKS + BTRFS. The problem being that when I start my computer, it asks me for the password for the disk, then when I get to the login screen I have to select my user and enter my user password.  

This is painful, and since I am already putting the disk password in, I believe I have authenticated myself sufficiently enough, I should not have to do it twice, so I decided to setup auto login for me since I am the only user of this machine. It turned out to be surprisingly easy.

## Enable Automatic Login
Open the GDM configuration file, you will need sudo for this, then add 2 lines of code under `[daemon]` like the below example. Of course change the `You-the-user` to your actual user name.   

```bash  {title="/etc/gdm/custom.conf"}

[daemon]
AutomaticLoginEnable=True
AutomaticLogin=You-the-user
```

Save the file and reboot.  

After the first reboot, Fedora went directly to my GNOME desktop. GNOME asked me for my normal user password once, which I entered.

I rebooted the computer again to test it, and this time there were no further password prompts after unlocking the LUKS-encrypted drive. Fedora went straight to the desktop.

## Security Note
Enabling automatic login does not disable LUKS encryption, `sudo` password protection or the GNOME screen lock. It simply removes the second password prompt after the encrypted drive has been unlocked during startup.  

This setup is only suitable for a single-user computer, as Fedora will automatically open the nominated user’s account each time it starts.  


