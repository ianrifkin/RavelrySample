RavelrySample
=============

Sample Ravelry Project
by Ian Rifkin (ianrifkin@ianrifkin.com)
v1.0 July 18, 2012

Dependencies: LWP::Simple, Getopt::Long, JSON, /usr/sbin/sendmail;

Command line perl script that will output a custom reminder 
message about what projects you have to work on and to come
back to ravelry.com. It takes two arguments: the user and the user's API key.

This could be scheduled as a cron job to email the results regularly.

The idea is to remind users about their love of crafting and ravelry with the
implied goal of increasing return visits back to ravelry.com. Mostly this is 
simply a small proof of concept to show ease of formatting/outputting the 
project JSON feed.

Tested using perl 5.8.8 on irifkin and vsmedile ravelry accounts.

Future ideas:
  (1) Separate email content info separate text file for easier configuration
      Consider using HTML::Template
  (2) Flag for text or html email content
  (3) oAuth support
  (4) Web app to display info on an HTML page
  (5) Web app to schedule the reminder emails