#!/usr/bin/perl -s

#use warnings;
use strict;
use LWP::Simple;
use File::Basename;
############################################################
#
# Configuration
#
############################################################

# Directory where you would like the page to be stored.
# Also used for temp directory if we are downloading the
# images ( -d arg )
my $comicDir = "/tmp/comics";

############################################################
#
# Internals
#
############################################################


# See if the user is asking for help
if ($main::h)
{
	print "Usage: " . basename($0). " [options]\n";
	print "Options:\n";
	print "\t-h: print this help message\n";
	print "\t-dir=<directory>: output comics page in <directory>\n";
	print "\t\t default is /tmp/comics\n";
	print "\t-download: If this arg is present, actually download the \n";
	print "\t\tthe comic images.  If not, just link to them.\n\n";
	exit 1;
}

# Check for directory on the command line
if ($main::dir)
{
	$comicDir = $main::dir;
}

# Directory for images if we are downloading them
my $imageDir = "$comicDir/images";

# Create the directories if they don't exist
if ( ! -d $comicDir )
{
    mkdir ($comicDir) or die ("Error creating $comicDir: $!");
}

# Create the comics array of hashes.  Defines all the comics we get.
my $comics = init_comics();

my $download = 0;

# # Should we download the images or just link to them?
if ($main::download)
{
    $download = 1;
	# only create image dir if we are downloading images.
	if ( ! -d $imageDir )
	{
		mkdir ($imageDir) or die ("Error creating $imageDir: $!");
	}
}
 print ("Getting the comics for " . localtime() . "\n");

# Go get the comic pages
foreach my $com (@$comics)
{
    get_comic($com, $download);
}

#create the index.html page
render_page($comics, $download);



sub get_comic
{
    my ($comic, $download) = @_;
    my $comic_count = 0;

    print("Retrieving comic url from " . $comic->{request}."\n");
    my $response = get $comic->{request};

    $response =~ /$comic->{regexp}/;

    my $image_relative = "";
    $image_relative = $1;

#    print ("this is what we got: $1\n");
    my $command;
    my $image_url =  "";
    if (! $image_relative eq "")
    {
        $image_url = $comic->{request_root} . $image_relative;
        $comic->{image_url} = $image_url;
        if ( $download )
        {
            $command = "wget -O " . $comic->{tmpfile} . " $image_url";
            print ("Getting comic\n\t$command\n");
            my $image_file = `$command`;
        }
    }
    else
    {
        print("\n********************\n");
        print("*\n");
        print("* No image found... skipping " . $comic->{tmpfile} . "\n");
        print("*\n");
        print("********************\n\n");
    }


}

sub render_page
{
    my ($comics, $downloaded) = @_;

    my $now_string = localtime;
    print("\n Creating page\n");
    open(FILE, ">$comicDir/index.html");
#    opendir(IMAGES, "$imageDir");

 #   my @images = readdir(IMAGES);

    print(FILE "<HTML><BODY>\n");
    print(FILE "<H1>Comics for $now_string</H2>\n");


    foreach my $comic (@$comics)
    {
        print(FILE "<a href=\"" . $comic->{request} . "\">");
        print(FILE $comic->{request} . "</a><br><br>\n");
        if ($downloaded)
        {
            if ( -f $comic->{tmpfile})
            {
                print(FILE "<img src=\"" .$comic->{tmpfile} . "\"/><br><br>\n");
            }
        }
        elsif ($comic->{image_url} ne "")
        {
            print(FILE "<img src=\"" .$comic->{image_url} . "\"/><br><br>\n");
        }
        else
        {
            print("Didn't find comic for " . $comic->{request} . "\n");
        }
                print(FILE "<hr>\n");
    }

    print(FILE "</BODY></HTML>");
    close (FILE);
    print("\n Done.\n");
}

sub init_comics
{
    my $comics = [];
    my $comic = {};

###regular comics

	$comic = {tmpfile => "$imageDir/brevity.jpg",
              request_root => "http://www.comics.com",
              request => "http://www.comics.com/comics/brevity",
              regexp => 'SRC="([^"]*brevity[\d]+\.jpg).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/dilbert.gif",
              request_root => "http://www.dilbert.com",
              request => "http://www.dilbert.com/",
              regexp => 'SRC="([^"]*dilbert[\d]+\.(gif|jpg)).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/peanuts.gif",
              request_root => "http://www.snoopy.com",
              request => "http://www.snoopy.com/",
              regexp => 'SRC="([^"]*peanuts[\d]+\.(gif|jpg)).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/doonesbury.gif",
                 request_root => "",
                 request => "http://www.ucomics.com/doonesbury",
                 regexp => 'src="(.*db[\d]+\.gif).*'
                };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/nonseq.gif",
                 request_root => "",
                 request => "http://www.ucomics.com/nonsequitur/",
                 regexp => 'src="(.*nq[\d]+\.gif).*'
                };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/foxtrot.gif",
                 request_root => "",
                 request => "http://www.foxtrot.com",
                 regexp => 'src="(.*ft[\d]+\.gif).*'
                };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/getfuzzy.gif",
                 request_root => "http://www.comics.com",
                 request => "http://www.comics.com/comics/getfuzzy/",
                 regexp => 'SRC="(.*getfuzzy[\d]+\.(gif|jpg)).*'
                };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/bornloser.gif",
                 request_root => "http://www.comics.com",
                 request => "http://www.comics.com/comics/bornloser/index.html",
                 regexp => 'SRC="(.*bornloser[\d]+\.(gif|jpg)).*'
                };
    push (@$comics, $comic);

  $comic = {tmpfile => "$imageDir/redandrover.gif",
              request_root => "http://www.comics.com",
              request => "http://www.comics.com/creators/wizardofid/index.html",
              regexp => 'SRC="(.*wizardofid[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/redandrover.gif",
              request_root => "http://www.comics.com",
              request => "http://www.comics.com/wash/redandrover/index.html",
              regexp => 'SRC="(.*redandrover[\d]+\.gif).*'
             };
    push (@$comics, $comic);

     $comic = {tmpfile => "$imageDir/pearls.gif",
              request_root => "http://www.comics.com",
              request => "http://www.comics.com/comics/pearls/index.html",
              regexp => 'SRC="(.*pearls[\d]+\.(gif|jpg)).*'
             };
    push (@$comics, $comic);


####Editorials


    $comic = {tmpfile => "$imageDir/stuartcarlson.gif",
              request_root => "",
              request => "http://www.ucomics.com/stuartcarlson/",
              regexp => 'src="([^"]*sc[\d]+\.gif).*'
             };
    push (@$comics, $comic);

#     $comic = {tmpfile => "$imageDir/bish.gif",
#               request_root => "http://www.unitedmedia.com",
#               request => "http://www.unitedmedia.com/editoons/bish",
#               regexp => 'src="([^"]*bish[\d]+\.jpg).*'
#              };
#     push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/asay.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/asay",
              regexp => 'src="([^"]*asay[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/ariail.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/ariail",
              regexp => 'src="([^"]*ariail[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/benson.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/benson",
              regexp => 'src="([^"]*benson[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/luckovich.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/luckovich",
              regexp => 'src="([^"]*luckovich[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/schorr.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/schorr",
              regexp => 'src="([^"]*schorr[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/varvel.gif",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/varvel",
              regexp => 'src="([^"]*varvel[\d]+\.gif).*'
             };
    push (@$comics, $comic);

    $comic = {tmpfile => "$imageDir/day.jpg",
              request_root => "http://www.unitedmedia.com",
              request => "http://www.unitedmedia.com/editoons/day",
              regexp => 'src="([^"]*day[\d]+\.gif).*'
             };
    push (@$comics, $comic);

#editorial template
#     $comic = {tmpfile => "$imageDir/___.gif",
#               request_root => "http://www.unitedmedia.com",
#               request => "http://www.unitedmedia.com/editoons/___",
#               regexp => 'src="([^"]*___[\d]+\.gif).*'
#              };
#     push (@$comics, $comic);

    return $comics;
}
