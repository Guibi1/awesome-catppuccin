setxkbmap ca

source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

xss-lock lock &
xautolock -time 4 -locker lock &

export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

export ERRFILE=$XDG_CACHE_HOME/X11/xsession-errors
export GNUPGHOME=$XDG_DATA_HOME/gnupg
export PLATFORMIO_CORE_DIR=$XDG_DATA_HOME/platformio
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export PYTHONSTARTUP=$XDG_CONFIG_HOME/python/pythonrc
export CARGO_HOME=$XDG_DATA_HOME/cargo
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export HISTFILE=$XDG_STATE_HOME/bash/history

export GTK_THEME=Catppuccin-Mocha-Standard-Teal-Dark

exec /usr/bin/awesome
