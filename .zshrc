############################################################
##
## Prezto
##
#############################################################

# http://zsh.sourceforge.net/Guide/zshguide02.html
DEBUG=

[ $DEBUG ] && echo "Reading .zshrc"

export HISTFILE=${HOME}/.zhistory
export SAVEHIST=10000
export HISTSIZE=10000
setopt histignorespace 
setopt extendedhistory
setopt histignorealldups
setopt appendhistory     #Append history to the history file (no overwriting)
setopt sharehistory      #Share history across terminals
setopt incappendhistory  #Immediately append to the history file, not just when a term is killed


# source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    [ $DEBUG ] && echo "Initializing zprezto"
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# stop asking me if I can type. If I want your opinion I'll beat it out of you
unsetopt correct_all

# no env vars in paths
unsetopt auto_name_dirs

# http://zsh.sourceforge.net/Intro/intro_16.html
# Clobber files on redirect. I'm an adult.
setopt clobber
[ $DEBUG ] && echo "Sourcing .jshrc"
[ -r ~/.jshrc ] && source ~/.jshrc
[ $DEBUG ] && echo "Finished sourcing .jshrc"
if [ "$TERM" = "screen" ] ; then
    # keeps zsh from clobbering explicitly set window titles in tmux
    export DISABLE_AUTO_TITLE=true
fi

# only works if iTerm has been configured to map command+backspace to send escsape sequence [3~
#bindkey '^[[3~' backward-kill-word

export PATH=$PATH:$HOME/bin/traveling-tjsh

# Added by nex: https://git.hubteam.com/HubSpot/nex
[ -e ~/.hubspot/shellrc ] && . ~/.hubspot/shellrc

