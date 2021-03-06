#!/usr/public/bin/perl
use strict;
use LWP::Simple;
use Getopt::Long;
use JSON;

############################
# Created by IanRifkin.com #
# v1.0, July 18, 2012      #
############################

#Parse user and key options. Key from http://www.ravelry.com/help/api
my $usage = "Usage: ./rav.pl --user=YOUR_RAVELRY_USERNAME --key=YOUR_RAVELRY_API_STRING";
my ($user,$key,$email);
unless(GetOptions('user=s' => \$user,
		  'key=s'  => \$key,
		  'email=s'  => \$email,
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
my $msg = "<p>Dear $rav_data->{user}->{name},</p>\n\n";
if (scalar(keys %unfinished) == 0) {
    $msg .= "<p>Wow, you finished all of your crafting projects! Maybe you should take a few minutes to enter your upcoming projects on ravelry.com.</p>";
}
elsif (scalar(keys %unfinished) == 1) {
    $msg .= "<p>It's time to get off the computer and get back to your crafting! You only have one project to work on, but get to it! Who knows what other projects you have in mind that you haven't taken the time to enter into ravelry.com! If you must be on the computer, you should spend that time on ravelry.com.</p>\n";
}
else {
    $msg .= "<p>Whoa! It's seriously time to get off the computer and get back to your crafting! You have " . scalar(keys %unfinished) . " projects you could be working on! And who knows what other projects you have in mind that you haven't taken the time to enter into ravelry.com! If you must be on the computer, you should spend that time on ravelry.com.\nProjects you could be working on:</p>\n<ul>\n";
    while ( my ($url, $project_data) = each(%unfinished) ) {
	$msg .= "\n<li>" . '<a href="' . $url . '">' . %$project_data->{name} . '</a></li>';
    }
    $msg .= "</ul>\n";
}
$msg .= "\n<p>Before you go, be proud of what you have accomplished:</p><ul>\n";
while ( my ($url, $project_data) = each(%finished) ) {
    $msg .= "\n<li>" . '<a href="' . $url . '">' . %$project_data->{name} . '</a></li>';
}
$msg .= "\n<li>Nothing? Don't worry, you'll have something soon. I'm sure of it!</li>" if (scalar(keys %finished) == 0);
$msg .= "</ul>\n";

$msg .= "\n\n<br /><p>Sincerely,\n<br />Ravelry</p>\n";

#Send the output of the message using sendmail
sendMail($email,$msg);





sub getFeed {
    my ($url) = @_;
    my $content = LWP::Simple::get($url);
       die('JSON Feed Unavailable. Are you sure you supplied the correct username?') unless $content;
    return $content;
}

sub sendMail {
    my ($email,$msg) = @_;
    my $from= 'DoNotReply@ravelry.com';
    my $subject='Ravelry Project Update';
 
    open(MAIL, "|/usr/sbin/sendmail -t") or die("Cannot send mail. Cannot access /usr/sbin/sendmail: $!");
    print MAIL "To: $email\n";
    print MAIL "From: $from\n";
    print MAIL "Subject: $subject\n";
    print MAIL "MIME-Version: 1.0\n";
    print MAIL "Content-Type: text/html\n\n";
    print MAIL $msg;
    close(MAIL);
}
