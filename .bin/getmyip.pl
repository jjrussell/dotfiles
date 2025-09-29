#!/usr/bin/perl -w

use strict;
use LWP::Simple;


my $TEST_REQUEST = "http://automation.whatismyip.com/n09230945.asp";
my $testpage = "";

if (defined $ARGV[0] && "$ARGV[0]" eq "--ping")
{#Use ping to see what dns thinks our ip address should be
    $testpage = `ping -c 1 russellcentral.2y.net`;
}
else
{
    #use http://whatismyipaddress.com/ to see what our address
    #actually is
    # we have to set the user-agent string because the site is mean
    $testpage = `wget -U "Mozilla" -q -O - $TEST_REQUEST`;
}

#get the ip address from the output
if ($testpage)
{
    $testpage =~ /(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)/;
    if ($1)
    {
	print $1;
    }
    else
    {
	print -1;
    }
}
else
{
    print -1;
}




