function jjr-dialog ()
{
    if [ -e `which zenity > /dev/null 2>&1` ] && [ -n "$DISPLAY" ]  ; then
	zenity --title "$1" --info --text "$2" > /dev/null 2>&1
    elif [ -e `which xmessage > /dev/null 2>&1` ] && [ -n "$DISPLAY" ] ; then
	xmessage -bg black -fg green -bd white -center \
	    -buttons OK -default OK "$2" > /dev/null 2>&1
    else
	echo "$1: $2"
    fi
}


