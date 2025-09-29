# .bash_profile

# User specific environment and startup programs
# Get the aliases and functions
#[ -f ~/.bashrc ] && . ~/.bashrc
##
# Your previous /Users/jorussel/.profile file was backed up as /Users/jorussel/.profile.macports-saved_2009-02-26_at_10:18:39
##

[ $DEBUG ] && echo "Reading .profile"
# MacPorts Installer addition on 2009-02-26_at_10:18:39: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH=/opt/local/share/man:$MANPATH
# Finished adapting your MANPATH environment variable for use with MacPorts.
export PATH=$PATH:$HOME/bin/traveling-tjsh
