RavelrySample
=============

Sample Ravelry Project
by Ian Rifkin (ianrifkin@ianrifkin.com)
v1.0 July 18, 2012

Dependencies: LWP::Simple, Getopt::Long, JSON;

Command line perl script that will output a custom reminder 
message about what projects you have to work on and to come
back to ravelry.com. It takes two arguments: the user and the user's API key.

This could be scheduled as a cron job to email the results regularly.

This is a small proof of concept to show ease of formatting/outputting the project JSON feed.

Future ideas:
  (1) Separate email content info separate text file for easier configuration
  (2) oAuth support
  (3) Web app to display info on an HTML page
  (4) Web app to schedule the reminder emails