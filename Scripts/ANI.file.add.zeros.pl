#!/usr/bin/perl -w
use strict;

#check to see if the arguments are there
if (scalar @ARGV < 1) {
    usage();
    exit 1;
}

#initialize the arguments
my $infile = $ARGV[0];

#open the files
open (IN, "<", $infile) or die "Can't read input file!!\n";

#go through the input file and add to array
my @lines;
while (<IN>) {
    chomp $_;
    push @lines, $_;
}
close IN;

my $size = scalar @lines;
for (my $i=0; $i < $size; $i++) {
  my $line = $lines[$i];
  #go through the string
  my @chars = split(//, $line);
  my $sz = scalar @chars;
  my $newstring;
  for (my $j=0; $j < $sz; $j++) {
    my $char = $chars[$j];

    #if it is a number or period
    if ($char =~ /[a-zA-Z0-9._]/) {
      $newstring = "$newstring$char";
    }

    #if it is the end and a comma
    elsif ($j == ($sz - 1)) {
      if ($char =~ /,/) {
        $newstring = "$newstring,0";
      }
      else {
        print "ERROR 2\n";
      }
    }

    #if it is a comma
    elsif ($char =~ /,/) {
      #if there is not another comma
      if ($chars[$j+1] =~ /[0-9]/) {
        $newstring = "$newstring,";
      }
      #if there is another comma add a zero
      elsif ($chars[$j+1] =~ /,/) {
        $newstring = "$newstring,0";
      }
      else {
        print "ERROR 3\n";
      }
    }

    else {
      print "ERROR 1\n"
    }
  }

  $newstring = "$newstring\n";
  print $newstring;

  #add zeros
  #$newstring =~ s/,,/,0,/g;
  #add zero and new line to last
  #$newstring =~ s/,$/,0/g;
  #$newstring =~ s/,,/,/g;
  #$newstring =~ s/,/\n/g;
  #$newstring = "$newstring\n";
  #print $newstring;
}

sub usage {
    print "How to run this code:\n";
    print "ANI.file.add.zeros.pl input.file > output.file\n";
}
