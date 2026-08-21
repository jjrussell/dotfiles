#!/usr/bin/bash
# .bashrc

#umask a=rx,u+w
# set this to see timed output during loading
TIMED=true

# load my borne shell agnostic settings
[ -n "$TIMED" ] && echo "$(date) Loading ~/.jshrc"
# shellcheck source=.jshrc
[ -r ~/.jshrc ] && . ~/.jshrc


# for interactive shells, how long does it take to load this?
[ -n "$TIMED" ] && echo "$(date) Loading .bashrc"

# if ! echo $0 | grep "bash" > /dev/null 2>&1 ; then
#     echo "Skipping .bashrc reading for non bash shell '$0'"
#     return
# fi

# calls title but checks to see if we've explicitly set it yet
# If we have this is a no-op so we can have cool default titles but
# also not have them clobber one we set using title
shell_title ()
{

    if [ -z "$JJR_CUSTOM_TITLE_SET" ]; then
        title $*
    fi
}

title ()
# Sets the title of the terminal
# This is set in setPS1 function now
{
    if [ ! -n "$1" ] ; then
        echo "Usage: title <title>"
        echo -e "\t sets window title"
    fi
# throws errors if using title over ssh so check for display
    # window control on linux
    if which wmctrl > /dev/null 2>&1 && [ -n "$DISPLAY" ] ; then
        wmctrl -r :ACTIVE: -N "$*"
        wmctrl -r :ACTIVE: -I "$*"
    else
        # Standard bash
        if [ "$TERM" = "xterm" -o "$TERM" = "xterm-color" -o "$TERM" = "xterm-256color" ] ; then
            echo -ne "\033]0;$*\007"
        else
            echo "Unsupport terminal type: $TERM"
        fi
    fi
    export JJR_CUSTOM_TITLE_SET=1
}


truncate_path ()
{
    local path="$1"

   # It truncates the length of the prompt so it doesn't get ridiculous
    # in deep directories. Also replaces $HOME with ~.  /w does this too
    # but it doesn't work with the truncating so we had to fudge it.
    # Ideas from http://www.dreaming.org/~giles/bashprompt/prompts/rprom.html

        # How many characters of the $PWD should be kept
    if [ -n "$2" ] ; then
        local path_length=$2
    else
        local path_length=60
    fi

        #replace home dir with ~. The # is so that it only matches $HOME
        #at the beginning of PWD, not anywhere in the middle
    local PATH_TRUNC=${path/#${HOME}/\~}

        #Then truncate PWD do path_length characters starting with ...
    # some small environments like ipods don't have tr which we use to truncate
    if which tr >/dev/null 2>&1  && [ $(echo -n $PATH_TRUNC | wc -c | tr -d " ") -gt $path_length ] ; then
        echo -n "...$(echo -n "$PATH_TRUNC" |sed -e "s/.*\(.\{$path_length\}\)/\1/")"
    else
        echo -n $PATH_TRUNC
    fi
}

[ -n "$TIMED" ] && echo "$(date) Finished Loading functions"

# Test for an interactive shell.  There is no need to perform some stesp
# for non-interactive shells like scp and rcp, and it's important
# to refrain from outputting anything in those cases.
# if [ $- == *i* ] ; then
INTERACTIVE="yes"
# # else
# #     return
# fi

if [ -n "$INTERACTIVE" ] ; then
    if [ -z "$JJR_CUSTOM_TITLE_SET" ] ; then
        case $TERM in
            *term | xterm-color | rxvt | screen | xterm-256color)
                if [ -z "$SSH_CONNECTION" ] ; then
                    TITLEBAR='$(shell_title $(truncate_path "$PWD" 50))'
                else
                    TITLEBAR='$(shell_title \h - $(truncate_path "$PWD" 50))'
                fi
                ;;
            *)
                TITLEBAR=""
                ;;
        esac
    fi

    # command that bash runs every time it displays the prompt for dynamic updates
    PROMPT_COMMAND="setPS1"

        # If we are using bash version 3 or better, than use the internal bash
        # date formatting.  Otherwise just call date
    DATE_FORMAT="%G-%m-%d %T"
    DATE_FORMAT="%a %b %d, %I:%M:%S"
    PROMPT_DATE="\D{$DATE_FORMAT}"

    if [ -n "$BASH_VERSION" ] && [ ${BASH_VERSION:0:1} -lt "3" ] ; then
    # All the escaping is so that the command gets run for each prompt
    # and not just once at login
        PROMPT_DATE="\`date +\"$DATE_FORMAT\"\`"
    fi

    setPS1() {
# This beast is here more for reference than anything else.
# It has two completely redundant ways of setting colors
# in the terminal.  I only uncomment the ones that I'm actually
# using.  The rest are there so I don't forget.
# Ideas from http://www.dreaming.org/~giles/bashprompt/prompts/rprom.html

#colors
# Black       0;30     Dark Gray     1;30
# Red         0;31     Light Red     1;31
# Green       0;32     Light Green   1;32
# Brown       0;33     Yellow        1;33
# Blue        0;34     Light Blue    1;34
# Purple      0;35     Light Purple  1;35
# Cyan        0;36     Light Cyan    1;36
# Light Gray  0;37     White         1;37

#     if [ which tput > /dev/null 2>&1 ] && [ "$TERM" != "dtterm" ] ; then
    #alternate way of setting colors in the shell
#         local RESET_COLORS="\[\$(tput sgr0)\]"

        #         local BLACK="\[\$(tput setaf 0)\]"
#         local BLACKBG="\[\$(tput setab 0)\]"
#         local DARKGREY="\[\$(tput bold ; tput setaf 0)\]"

#         local RED="\[\$(tput setaf 1)\]"
#         local REDBG="\[\$(tput setab 1)\]"
#         local BOLD_RED="\[\$(tput bold ; tput setaf 1)\]"

#         local GREEN="\[\$(tput setaf 2)\]"
#         local GREENBG="\[\$(tput setab 2)\]"
#         local BOLD_GREEN="\[\$(tput bold ; tput setaf 2)\]"

#         local BROWN="\[\$(tput setaf 3)\]"
#         local BROWNBG="\[\$(tput setab 3)\]"
#         local YELLOW="\[\$(tput bold ; tput setaf 3)\]"

#         local BLUE="\[\$(tput setaf 4)\]"
#         local BLUEBG="\[\$(tput setab 4)\]"
#         local BOLD_BLUE="\[\$(tput bold ; tput setaf 4)\]"

#         local PURPLE="\[\$(tput setaf 5)\]"
#         local PURPLEBG="\[\$(tput setab 5)\]"
#         local PINK="\[\$(tput bold ; tput setaf 5)\]"

#         local CYAN="\[\$(tput setaf 6)\]"
#         local CYANBG="\[\$(tput setab 6)\]"
#         local BOLD_CYAN="\[\$(tput bold ; tput setaf 6)\]"

#         local LIGHTGREY="\[\$(tput setaf 7)\]"
#         local LIGHTGREYBG="\[\$(tput setab 7)\]"
#         local WHITE="\[\$(tput bold ; tput setaf 7)\]"

#     else
#        local BLACK="\[\033[0;30m\]"
#        local DARKGREY="\[\033[1;30m\]"

#        local RED="\[\033[0;31m\]"
        local BOLD_RED="\[\033[1;31m\]"

        local GREEN="\[\033[0;32m\]"
#        local BOLD_GREEN="\[\033[1;32m\]"

        local BROWN="\[\033[0;33m\]"
        local YELLOW="\[\033[1;33m\]"

        local BLUE="\[\033[0;34m\]"
#        local BOLD_BLUE="\[\033[1;34m\]"

        local PURPLE="\[\033[0;35m\]"
#        local PINK="\[\033[1;35m\]"

#        local CYAN="\[\033[0;36m\]"
        local BOLD_CYAN="\[\033[1;36m\]"

#        local LIGHTGREY="\[\033[0;37m\]"
#        local WHITE="\[\033[1;37m\]"

        local RESET_COLORS="\[\033[0m\]"
#    fi

    # old PS1 that used prompt_command function
        local OPEN_BRACKET="${RESET_COLORS}${BLUE}[${RESET_COLORS}"
        local CLOSE_BRACKET="${RESET_COLORS}${BLUE}]${RESET_COLORS}"
        local PROMPT_COLOR=${BOLD_CYAN}
        local PROMPT_CARROT=">"

    # make prompt unique for root
        if [ "$USER" = "root" ] || [ $UID = 0 ] ; then
            PROMPT_COLOR=${BOLD_RED}
            PROMPT_CARROT="#"
        fi

    # Set this the PROMPT_COMMAND environment variable to run this funciton
    # It truncates the length of the prompt so it doesn't get ridiculous
    # in deep directories. Also replaces $HOME with ~.  /w does this too
    # but it doesn't work with the truncating so we had to fudge it.
    # Ideas from http://www.dreaming.org/~giles/bashprompt/prompts/rprom.html

        # How many characters of the $PWD should be kept
        newPWD="$(truncate_path "$PWD" 60)"

        PS1="\n${TITLEBAR}${GREEN}\u@\h${RESET_COLORS} ${BLUE}\!${RESET_COLORS} $OPEN_BRACKET${PURPLE}${PROMPT_DATE}$CLOSE_BRACKET ${OPEN_BRACKET}${YELLOW}\$(type git_prompt_info >/dev/null 2>&1 && git_prompt_info)${CLOSE_BRACKET} ${OPEN_BRACKET}$(type ps1_rvm >/dev/null 2>&1 && ps1_rvm)${CLOSE_BRACKET}\n${PROMPT_COLOR}\${newPWD}${PROMPT_CARROT}${RESET_COLORS} "

    }
fi

# if we are root then set root timeout
if [ "$USER" = "root" ] || [ $UID = 0 ] ; then
    #Logout root if idle for more than 5 minutes
    TMOUT=600
fi

############################################################
##  Cool bash features
############################################################

## Set bash_completion location and
## source bash_completion after setting $PATH
## use the one I carry around first.  If its not there, use the system
## wide one.  If that isn't there... go stick your head in a pig
[ -n "$TIMED" ] && echo "$(date) Before bash_completion"
if [ -n "$INTERACTIVE" ] ; then
    if [ -f ${JJR_ENV}/etc/bash_completion ] ; then
        if [ -z $BASH_COMPLETION ] ; then
            BASH_COMPLETION=${JJR_ENV}/etc/bash_completion
        fi
        if [ -z $BASH_COMPLETION_DIR ] ; then
            BASH_COMPLETION_DIR=${JJR_ENV}/etc/bash_completion.d
        fi
        . $BASH_COMPLETION
    elif [ -f /etc/bash_completion ] ; then
        . /etc/bash_completion
    fi
fi

# Cool bash options, check man bash for descriptions
shopt -s checkwinsize no_empty_cmd_completion \
    nocaseglob histverify dotglob cdspell 2> /dev/null

[ -n "$TIMED" ] && echo "$(date) Loading .bashrc completed"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Added by nex: https://git.hubteam.com/HubSpot/nex
[ -e ~/.hubspot/shellrc ] && . ~/.hubspot/shellrc

# Added by nex: https://git.hubteam.com/HubSpot/nex
. ~/.hubspot/shellrc


# Added by Antigravity CLI installer
export PATH="/Users/jjrussell/.local/bin:$PATH"
