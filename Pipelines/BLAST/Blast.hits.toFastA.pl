#!/usr/bin/perl -w
use strict;
use Getopt::Long;

#Script to grab reads from a file with read identifiers...or from a blast file and makes fasta of only those reads

#getopts files
my $input_file;
my $sequence_file;
my $blast=0;
my $list=0;
my $id_cutoff=0;
my $length_cutoff=0;
my $bitscore_cutoff=0;
my $output_name="output.fasta";
my $help=0;

#global variables
my $type;
#all the blast ids are in a hash
my %blast_ids;

sub usage {
  print "\nHow to run this code:\n";
  print "\n ./Blast.hits.toFastA.pl -b [OR] -l -i [input file] -s [sequence file, fasta format]-ci -cl -b [blast cutoff (optional)] -o [output file]\n";
  print "-b input is blast output format 6 (tabular)\n";
  print "-l input is a list of contig identifiers (separated by lines)\n";
  print "-i input file\n";
  print "-s sequence fasta file\n";
  print "-ci blast identity cutoff: optional, only if using blast input file\n";
  print "-cl blast length cutoff: optional, only if using blast input file\n";
  print "-cb blast bitscore cutoff: optional, only if using blast input file\n";
  print "-o output fasta file name \n";
  print "\nUse -h to get this message\n\n";
}

sub initialize {
  GetOptions(
    'b' => \$blast,
    'l' => \$list,
    'i=s' => \$input_file,
    's=s' => \$sequence_file,
    'ci=f' => \$id_cutoff,
    'cl=f' => \$length_cutoff,
    'cb=f' => \$bitscore_cutoff,
    'o=s' => \$output_name,
    'h' => \$help,
  ) or die "Incorrect usage!\n";

  #check to see if the help message was activated
  if ($help ne 0) { usage(); exit 1;}
  #check to see which type
  if ($blast ne 0 && $list == 0) { $type = "blast";}
  elsif ($list ne 0 && $blast == 0) { $type = "list";}
  else {print "You need to enter which type of input file you have, either blast (-b) or list (-l)\n";
    usage(); exit 1;}
  #check to make sure they entered input and contig files
  unless (defined $input_file) { print "You need to enter the input file\n";
    usage(); exit 1;}
  unless (defined $sequence_file) { print "You need to enter the sequence fasta file\n";
    usage(); exit 1;}
}

sub openBlast{
  my ($filename) = @_;
  open (FILE, "<", $filename) or die "Can't open the file $filename!!!!\n";
  my $line; #tmp line variable for readability
  my @values; #tmp values variable for splitting
  my $tmp = 0;
  while (<FILE>) {
    $line = $_;
    chomp $line;
    @values = split('\t', $line);
    my $seq = $values[0];
    #my $pident = $values[2];
    #my $length = $values[3];
    #my $bitscore = $values[11];
    #if ($bitscore >= $bitscore_cutoff && $length >= $length_cutoff && $pident >= $id_cutoff) {
    $tmp++;
    $blast_ids{$seq} = 'placeholder';
    #}
  }
  close FILE;
}


sub openFasta{
  #first open the file
  my ($filename) = @_;
  #open the reads file
  open (FILE, "<", $filename) or die "Can't open the file $filename!!!!\n";
  #open the outfile
  open (OUT, ">", $output_name) or die "Can't open the output file $output_name!!\n";
  my $line; #line variable
  my $i; #location variable
  my $k; #tmp variable to store whether or not a match is being printed
  my $fasta_id;
  #read the file
  while (<FILE>) {
    chomp $_;
    my $line = $_;
    #check and see if it's a fasta header
    if ($line =~ m/^>/) {
      $line =~ s/>//g; #get rid of the '>'
      $line =~ s/\s*//g;
      #look for the id in the dictionary
      if (exists $blast_ids{$line}) {
        $k = 0; #this means it is the start of a match
        #print the line header
        print OUT ">";
        print OUT "$line\n";
      }
      else {
        $k = 1;
      }
    }
    #if it's a space
    elsif ($line =~ m/^\s*$/) {
      #nothing
      $k = 1;
    }
    #if it's a normal sequence line
    else {
      #if it's a match
      if ($k==0) {
        print OUT "$line\n";
      }
    }
  }
  close FILE;
  close OUT;
}


initialize();
if ($type eq "list") {
  open (FILE, "<", $input_file) or die "Can't open the file $input_file!!\n";
  while (<FILE>) {
    chomp $_;
    $blast_ids{$_} = 'placeholder';
  }
  close FILE;
}
elsif ($type eq "blast") {
  openBlast($input_file);
}
openFasta($sequence_file);
my $var = keys %blast_ids;
