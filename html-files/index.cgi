#! /usr/bin/perl

##############################################################
# Scans a page off the Guardian, finds the killer sudoku     #
# and runs a script that turns it into a nice pdf with clues #
##############################################################

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use LWP::Simple;

#my $pdf_command = '/home/g/scripts/killer-page.pl';
my $pdf_command = './killer-page.pl';

my $cgi = CGI->new();
my $url = $cgi->param('url');
$url = 'https://www.theguardian.com/lifeandstyle/2018/oct/20/killer-sudoku-628' unless defined($url);

# Let's see if we can get your file
my $page = get($url);
croak "Couldn't get your url" unless defined $page;

# Now we'll read through the file until we've found the link to the image file.
my $picture_url = "";
for my $line(split("\n", $page)){
  next unless $line =~ /Click here to access the print version/ ;
  # Now we've found the line with the picture url in it
  $line =~ /<a href="(.+?)"/;
  $picture_url = $1;
}

my $output_report = '';
if($picture_url){ # then we found something and hopefully we can make a pdf of it
  my $pdf_command_status = system($pdf_command . " '" . $picture_url . "'");
  $output_report .= "The pdf generator exited with a status of $pdf_command_status<br />\n";
  if (system($pdf_command . ' ' . $picture_url)){
    if (open(my $pdf_file, '<', './files/killer.pdf')){
      print $cgi->header(-type => 'application/pdf', -Content_disposition => qq{attachment; filename="killer.pdf"});
      binmode($pdf_file);
      binmode(STDOUT);
      my $buffer;
      my $buffer_size = 4096;
      while( read($pdf_file, $buffer, $buffer_size)){
        print $buffer;
      }
      close $pdf_file;
    }
    else{
      $output_report .= "I couldn't open the pdf to send you\n";
    }
  }
}

# If we get as far as here, then something went wrong, so I'll report it.
print $cgi->header;
print '<html><head><title>Killer</title></head><body>';
print "Hello</br>I don't seem to have a PDF for you.  Sorry about that. Here's what I know:<br />\n";
print "You gave me the url $url<br />\n";
print "Which seems to point us at $picture_url<br />";
print $output_report;
print'</body>';
