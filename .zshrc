#
# ~/.zshrc
#

neofetch

if [ "$(tty)" = "/dev/tty1" ]; then
	exec dbus-run-session sway
fi

PS1='[ঌ⎛ಲළ൭⎞໒]$ '

xrdb ~/.Xdefaults

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'