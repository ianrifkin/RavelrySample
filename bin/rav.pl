#!/usr/public/bin/perl
use strict;
use LWP::Simple;
use Getopt::Long;
use JSON;

###########################
# ianrifkin@ianrifkin.com #
# v1.0, July 18, 2012     #
###########################

#Parse user and key options. Key from http://www.ravelry.com/help/api
my $usage = "Usage: ./rav.pl --user=YOUR_RAVELRY_USERNAME --key=YOUR_RAVELRY_API_STRING";
my ($user,$key);
unless(GetOptions('user=s' => \$user,
		  'key=s'  => \$key,
		 )) {
    die("Could not parse options: $!\n");
}
unless(defined($user) && defined($key)){
    die($usage);
}

#Get user's project feed and save as hash ref
my $feed_url = 'http://api.ravelry.com/projects/' . $user . '/progress.json?key=' . $key . '&status=in-progress+finished&notes=true';
my $json_text = getFeed($feed_url);
die('Please make sure you supplied the correct username and key.') if ($json_text =~ /Invalid/);
my $json        = JSON->new->utf8;
my $rav_data = $json->decode( $json_text );

#Create separate hashes for finished and unfinished projects for ease of use
my %finished = ();
my %unfinished = ();
for (my $count = 0; $count < length(%$rav_data->{projects}); $count++) {
    if (%$rav_data->{projects}[$count]->{status} eq 'finished') {
	$finished{%$rav_data->{projects}[$count]->{url}} = %$rav_data->{projects}[$count];
    }
    else {
	$unfinished{%$rav_data->{projects}[$count]->{url}} = %$rav_data->{projects}[$count];
    }
}

#Write the actual messages (content depends on how many unfinished projects the user has)
my $msg = "Dear $rav_data->{user}->{name},\n\n";
if (scalar(keys %unfinished) == 0) {
    $msg .= "Wow, you finished all of your crafting projects! Maybe you should take a few minutes to enter your upcoming projects on ravelry.com.";
}
elsif (scalar(keys %unfinished) == 1) {
    $msg .= "It's time to get off the computer and get back to your crafting! You only have one project to work on, but get to it! Who knows what other projects you have in mind that you haven't taken the time to enter into ravelry.com! If you must be on the computer, you should spend that time on ravelry.com.\n";
}
else {
    $msg .= "Whoa! It's seriously time to get off the computer and get back to your crafting! You have " . scalar(keys %unfinished) . " projects you could be working on! And who knows what other projects you have in mind that you haven't taken the time to enter into ravelry.com! If you must be on the computer, you should spend that time on ravelry.com.\nProjects you could be working on:\n";
    while ( my ($url, $project_data) = each(%unfinished) ) {
	$msg .= "\n" . '<a href="' . $url . '">' . %$project_data->{name} . '</a>';
    }
    $msg .= "\n";
}
$msg .= "\nBefore you go, be proud of what you have accomplished:\n";
    while ( my ($url, $project_data) = each(%finished) ) {
	$msg .= "\n" . '<a href="' . $url . '">' . %$project_data->{name} . '</a>';
    }
$msg .= "\nNothing? Don't worry, you'll have something soon. I'm sure of it!" if (scalar(keys %finished) == 0);


$msg .= "\n\nSincerely,\nRavelry\n";

#Print the output of the message to standard out.
print "$msg";


sub getFeed {
    my ($url) = @_;
    my $content = LWP::Simple::get($url);
       die('JSON Feed Unavailable. Are you sure you supplied the correct username?') unless $content;
    return $content;
}
