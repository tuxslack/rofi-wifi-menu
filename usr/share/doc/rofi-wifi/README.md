# rofi-wifi-menu

A Wi-Fi menu written in bash. Uses rofi and nmcli. Forked from [zbaylin](https://github.com/zbaylin/rofi-wifi-menu) because it was unmaintained and incompatible with modern versions of rofi. Additional contributions from [vlfldr](https://github.com/vlfldr/rofi-wifi-menu)'s fork.

![Screenshot of rofi-wifi-menu](usr/share/doc/rofi-wifi/rofi-wifi-menu.png)

https://www.youtube.com/watch?v=v8w1i3wAKiw

### Installation

Install `nmcli` and `rofi` with your package manager. If you want to use the icons, set your Rofi font to a [Nerd Font](https://github.com/ryanoasis/nerd-fonts). Then run the following commands:

```
git clone https://github.com/tuxslack/rofi-wifi-menu.git
cd rofi-wifi-menu
bash "./rofi-wifi-menu.sh"
```

You'll probably want to put the script in your `$PATH` so you can run it as a command and map a keybinding to it.

### Troubleshooting

PopOS! does not have the notify-send library installed by default. You can install it with the following command (according to this [thread](https://unix.stackexchange.com/questions/685247/what-is-the-notify-send-alternative-command-in-pop-os)):
  
  ```bash
  sudo apt install libnotify-bin
  ```

### Rofi Theme

Back up the original config.rasi file. <br>

Copy the config.rasi file to the ~/.config/rofi/ folder

  ```bash
$ mv -i ~/.config/rofi/config.rasi ~/.config/rofi/config-backup.rasi

$ cp config.rasi ~/.config/rofi/
  ```
This Rofi theme uses the font "Hack Nerd Font Medium"
Download: https://www.nerdfonts.com/


### Window managers use:

Start the notification daemon

OpenBox

$ nano ~/.config/openbox/autostart

dunst &

i3wm

$ nano ~/.config/i3/config

exec --no-startup-id dunst

FluxBox

$ nano ~/.fluxbox/startup

pkill dunst ; dunst &


