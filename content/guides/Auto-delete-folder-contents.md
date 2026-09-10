---
title: "Auto Delete Folder Contents"
date: 2026-08-29T14:52:11+08:00
lastmod: 2026-08-29T14:52:11+08:00
draft: true
description: "How To Auto-delete a Folders Content"
tags: [Fedora, Linux, systemD]
---

## Scenerio

 If you are like me then the `~/Downloads` over time gets bigger and bigger, it's not until you get the **Running out of Disk Space** warning that you actually have to spend time trying to figure out what is eating up your hdd. When this happens to me the first thing I do is go to the Downloads folder and see what i can delete.  

 This is a builtin SystemD system, not a add on script. Any Linux distro that used SystemD (the majority) can use this script. Also the, an important thing to keep in mind is that the files/folders are deleted permenantly, there is no going to trash to restore them. 

 Below is an example setup on `~/Downloads/Temporary` folder.

## Automatic Delete After X Days

```bash
mkdir -p ~/Downloads/Temporary
mkdir -p ~/.config/user-tmpfiles.d

----------------------------------------------------------
nvim ~/.config/user-tmpfiles.d/downloads.conf

e %h/Downloads/Temporary 0700 - - 30d -

----------------------------------------------------------

systemd-tmpfiles --user --create

--------------------------------------------------------
systemctl --user status systemd-tmpfiles-clean.timer
● systemd-tmpfiles-clean.timer - Daily Cleanup of User s Temporary Directories
     Loaded: loaded (/usr/lib/systemd/user/systemd-tmpfiles-clean.timer; enabled; preset: enabled)
     Active: active (waiting) since Sat 2026-08-29 12:27:26 AWST; 3h 2min ago
 Invocation: 4939d8a856164660aaadc0d5bd0764b0
    Trigger: Sun 2026-08-30 12:32:27 AWST; 21h left
   Triggers: ● systemd-tmpfiles-clean.service
       Docs: man:tmpfiles.d(5)
             man:systemd-tmpfiles(8)
-------------------------------------------------------

## See what will be removed with the below command --
systemd-tmpfiles --user --clean --dry-run
```

This uses Fedora’s existing cleanup system rather than another script or cron job.

The 30d can be any number you decide, can be 90d, 1w, 7h.  


