# You should have received a copy of the CC0 Public Domain Dedication along
# with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# base-files version 4.2-3

# /etc/bash.bashrc: executed by bash(1) for interactive shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/bash.bashrc

# Modifying /etc/bash.bashrc directly will prevent
# setup from updating it.

# System-wide bashrc file

# Check that we haven't already been sourced.
[[ -z ${CYG_SYS_BASHRC} ]] && CYG_SYS_BASHRC="1" || return

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Exclude *dlls from TAB expansion
export EXECIGNORE="*.dll"

# Set a default prompt of: user@host and current_directory
PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '

# Uncomment to use the terminal colours set in DIR_COLORS
# eval "$(dircolors -b /etc/DIR_COLORS)"

# export LESS_TERMCAP_mb=$'\E[01;31m'        # begin blinking
# export LESS_TERMCAP_md=$'\E[00;34m'        # begin bold
# export LESS_TERMCAP_me=$'\E[0m'            # end mode
# export LESS_TERMCAP_se=$'\E[0m'            # end standout-mode
# export LESS_TERMCAP_so=$'\E[01;44;33m'     # begin standout-mode - info box
# export LESS_TERMCAP_ue=$'\E[0m'            # end underline
# export LESS_TERMCAP_us=$'\E[00;32m'        # begin underline

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[0;103m' # begin blinking
export LESS_TERMCAP_md=$'\E[0;93m' # begin bold
export LESS_TERMCAP_me=$'\E[0m' # end mode
export LESS_TERMCAP_se=$'\E[0m' # end standout-mode
export LESS_TERMCAP_so=$(tput bold; tput setaf 8; tput setab 3) # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m' # end underline
export LESS_TERMCAP_us=$'\E[04;32m' # begin underline
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

export GREP_OPTIONS='--color=auto'

alias ifconfig="ipconfig"
alias traceroute="tracert"
alias path='echo -e ${PATH//:/\\n}'
alias mc="mc -a"
alias grep="grep $GREP_OPTIONS"
unset GREP_OPTIONS

# Make bash append rather than overwrite the history on disk
shopt -s histappend
shopt -s checkwinsize

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# History Options
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&amp;' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&amp;:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&amp;:[fb]g:exit:ls' # Ignore the ls command as well
export HISTIGNORE=$'[ \t]*:&amp;:[fb]g:exit:ls:w:ls -la:history' 
export CYGWIN=noglob
export VISUAL=vim
export LC_ALL=en_US.UTF-8
