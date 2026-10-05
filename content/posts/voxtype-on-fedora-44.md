---
title: "Voxtype on Fedora 44: F7 Voice Dictation in GNOME"
date: 2026-09-10T22:31:05+08:00
draft: true
description: "Setting up local Voxtype dictation on Fedora 44 GNOME, with F7 to start and stop recording and ydotool to type into the focused application."
tags: [fedora-44, gnome, voxtype, voice-dictation, linux]
---

## Why I wanted it

I have been trying Omarchy, and one thing I liked was Voxtype. There was a keyboard combination to start recording and the same combination to stop. There was also a push-to-talk option: hold F9 while speaking, then release it to transcribe.

I wanted that on my Fedora 44 GNOME desktop, without changing distributions. For this setup I chose **F7 to start recording and F7 again to stop and insert the text**. I did not configure the hold-F9 option.

Installing Voxtype was straightforward. Getting the words to appear in the application was the part that needed extra work. GNOME needs a different typing backend from the one commonly used with Hyprland.

This records what was installed, the relevant commands from my shell history, and the configuration that finally got automatic typing working. It is based on Voxtype **0.7.1**, not a claim that this is the latest release.

## Install Voxtype and choose a model

I downloaded the RPM into `~/Downloads/Temporary`. From that directory, the installation command in my history was:

```bash
cd ~/Downloads/Temporary
sudo dnf install ./voxtype-0.7.1-1.x86_64.rpm ydotool
```

The RPM came from the [Voxtype releases page](https://github.com/peteonrails/voxtype/releases). Fedora already had `wl-clipboard` and `pipewire-alsa` installed on this machine. These provide clipboard support and the ALSA bridge for PipeWire audio capture.

Next, I ran the model selector and enabled the user service:

```bash
voxtype setup model
systemctl --user enable --now voxtype
```

The verified configuration uses local **Whisper**, with the **base.en** model and English language selection. The model was downloaded successfully. This setup does not need a paid transcription service.

### The Parakeet detour

My shell history also contains these commands:

```bash
voxtype setup parakeet --enable
sudo voxtype setup parakeet --enable
systemctl --user restart voxtype
```

Those were attempts during setup, not steps required for the working Whisper configuration. Command history only establishes that I ran them; it does not establish that they succeeded. When checked afterwards, Voxtype still reported Whisper with `base.en`, and no Parakeet model was configured or found. I would leave this detour out when repeating the setup.

## Configure F7 in GNOME

The shortcut runs this command:

```bash
/usr/bin/voxtype record toggle
```

It can be added through GNOME Settings under **Keyboard → Keyboard Shortcuts → Custom Shortcuts**. Give it a name such as **Voxtype — toggle dictation**, use the command above, and assign **F7**.

On this machine the custom shortcut was created with the following commands. There were no existing custom shortcuts at the time.

**Do not blindly run the final command if you already have custom shortcuts:** it replaces the registered list. Use GNOME Settings instead, or preserve your existing entries when adding the new path.

```bash

GNOME handles the key, rather than Voxtype listening directly to keyboard input devices. There was no need to add my account to the `input` group for this toggle shortcut.

The installed configuration at `/etc/voxtype/config.toml` already had the settings needed for external control. These are relevant excerpts, not a replacement for the whole file:

```toml
state_file = "auto"

[hotkey]
enabled = false

[whisper]
model = "base.en"
language = "en"
translate = false

[output]
mode = "type"
fallback_to_clipboard = true
```

The state file lets the toggle command distinguish between recording and idle. Although the configuration also contains a default Scroll Lock key, built-in hotkey detection is disabled, so GNOME's F7 shortcut is what controls recording.

## Fix automatic typing on GNOME

Initially, the transcription was not being inserted into the focused application. Voxtype's check showed that `ydotool` was installed but its daemon was not running. Clipboard fallback was available, but manually pasting was not the experience I wanted.

The fix was to start Fedora's system-level `ydotool` service and give Voxtype access to a specific socket. The socket lets Voxtype ask the daemon to generate keyboard input.

First, check your numeric user and group IDs:

```bash
id -u
id -g
```

Both were **1000** on my machine. The configuration below records my exact setup. If your IDs differ, adjust the socket ownership and use a matching socket path in both files.

### Configure the ydotool service

A staging file was created at:

```text
~/.config/voxtype/ydotool-service-override.conf
```

Its contents are:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/ydotoold --socket-path=/run/ydotool-1000.sock --socket-own=1000:1000 --socket-perm=0600
```

The empty `ExecStart=` clears the packaged service's command before supplying the replacement. The socket belongs to my user and group, with mode `0600`, rather than being writable by everyone on the machine.

These installation and activation commands are in my shell history:

```bash
sudo mkdir -p /etc/systemd/system/ydotool.service.d
sudo install -m 644 ~/.config/voxtype/ydotool-service-override.conf /etc/systemd/system/ydotool.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl enable --now ydotool.service
```

The reload is included so systemd reads the new override before starting the service. If the service is already running when you change its configuration, restart it as well:

```bash
sudo systemctl restart ydotool.service
```

### Point Voxtype at the same socket

A user-service drop-in was created at:

```text
~/.config/systemd/user/voxtype.service.d/typing-socket.conf
```

Its contents are:

```ini
[Service]
Environment=YDOTOOL_SOCKET=/run/ydotool-1000.sock
```

Then the user service was reloaded and restarted:

```bash
systemctl --user daemon-reload
systemctl --user restart voxtype
```

There are two different services here: **ydotool is a system service**, managed with administrator privileges, while **Voxtype is a user service**, managed with the `--user` option.

## Check the result

These commands inspect the services and shortcut without typing anything into an application:

```bash
systemctl status ydotool.service --no-pager
systemctl --user status voxtype --no-pager
systemctl is-enabled ydotool.service
systemctl --user is-enabled voxtype
systemctl --user show voxtype -p Environment

gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype-f7/

voxtype status
```

At the time of writing, both services were **active** and **enabled**. The Voxtype service environment pointed to the custom socket, and GNOME's saved F7 command was correct.

One diagnostic wrinkle: the socket environment variable above belongs to the Voxtype service, not automatically to an ordinary terminal. Running a check from a terminal without it can misleadingly report that the typing daemon is unavailable. Use the same socket explicitly:

```bash
YDOTOOL_SOCKET=/run/ydotool-1000.sock voxtype setup check
```

With that environment variable set, the check confirmed that the ydotool daemon was running and selected for typing. It still complained about a missing user configuration file and warned about `input` group membership. The effective configuration was verified separately with the command below: it loaded `/etc/voxtype/config.toml`. A missing user override does not mean no configuration is loaded, and the input-group warning does not apply to this GNOME-managed shortcut.

```bash
voxtype config
```

For the practical test, click into a blank text document, press **F7**, say a short sentence, and press **F7** again. The text should appear at the cursor. Test in a document before trying a terminal, where unintended keyboard input can have consequences.

After the typing-service fix, it appeared to be working in my initial test. I am still trying it out rather than claiming long-term reliability or accuracy. The installed audio configuration also has a **60-second recording limit**, which is worth knowing before dictating a long passage.

## Australian English: what is actually configured

I wanted Australian English. The current language setting is **English**, using `en`; there is no separate `en-AU` setting in this setup.

An Australian spelling prompt has **not** been added. It would be misleading to call that part finished. If American spellings become a nuisance, the next step is to try a Whisper initial prompt containing Australian spelling examples and check how consistently the model follows them. That is guidance, not a guarantee.

## Where this leaves me

I now have the simple workflow I wanted: F7 to start, F7 to stop, and the transcription inserted into the application. The important Fedora GNOME detail was not the recording shortcut itself; it was getting the typing daemon running and making sure Voxtype knew where to find it.

Useful references:

- [Voxtype installation guide](https://voxtype.io/docs/)
- [Voxtype configuration reference](https://voxtype.io/docs/CONFIGURATION)
- [Voxtype source and releases](https://github.com/peteonrails/voxtype)
