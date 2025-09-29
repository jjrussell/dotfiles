sub jjr_dialog
{
	my ($title, $message) = @_;
	my $something = system("which zenity > /dev/null 2>&1");
    if ( system("which zenity > /dev/null 2>&1") == 0 && $ENV{DISPLAY} ne "" )
	{
		system ( "zenity --title \"$title\" --info --text \"$message\" > /dev/null 2>&1" );
	}
    elsif ( system ("which xmessage > /dev/null 2>&1") == 0 && $ENV{DISPLAY} ne "" )
	{
		system ( "xmessage -bg black -fg green -bd white -center -buttons OK -default OK \"$message\" > /dev/null 2>&1" );
	}
    else
	{
		print "$title: $message\n";
	}
}


sub print_usage
{
    if  ( @_ >= 1)
    {
#        my ($MESSAGE) = @_;
        print "Error: @_\n";
    }
    print "$usage\n";
    exit 1;
}


#----------------------------(  promptUser  )-----------------------------#
#                                                                         #
#  FUNCTION:	promptUser                                                #
#                                                                         #
#  PURPOSE:	Prompt the user for some type of input, and return the    #
#		input back to the calling program.                        #
#                                                                         #
#  ARGS:	$promptString - what you want to prompt the user with     #
#		$defaultValue - (optional) a default value for the prompt #
#                                                                         #
#-------------------------------------------------------------------------#

sub promptUser {

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

   my ($promptString,$defaultValue) = @_;

   #-------------------------------------------------------------------#
   #  if there is a default value, use the first print statement; if   #
   #  no default is provided, print the second string.                 #
   #-------------------------------------------------------------------#

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)


   #------------------------------------------------------------------#
   # remove the newline character from the end of the input the user  #
   # gave us.                                                         #
   #------------------------------------------------------------------#

   chomp;

   #-----------------------------------------------------------------#
   #  if we had a $default value, and the user gave us input, then   #
   #  return the input; if we had a default, and they gave us no     #
   #  no input, return the $defaultValue.                            #
   #                                                                 #
   #  if we did not have a default value, then just return whatever  #
   #  the user gave us.  if they just hit the  key,           #
   #  the calling routine will have to deal with that.               #
   #-----------------------------------------------------------------#

   if ($defaultValue) {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}
