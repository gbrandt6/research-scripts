#!/usr/bin/perl -w
use strict;
use Getopt::Long;

sub usage {
  print "\nHow to run this code:\n";
  print "./FastA.make.DAS.input.pl -i [list of bin fasta filenames] -n [list of bin identifiers] -o [output file name]\n";
  print "-i\t\tEach fasta filename should be on one line and all files must be in the current directory\n";
  print "-n\t\tEach bin identifier should be on one line, corresponding to the input file names, in the same order\n";
  print "-o\t\tThe output file will be in tab separated format (tsv)\n";
  print "Run this script once for each binning method\n";
  print "Use -h to get this message\n\n";
}

#initializing getopts options
my $bin_list;
my $bin_id_list;
my $output_file="out.tsv";
my $help=0;

#global variables
my @bin_files;
my @bin_ids;
my @output_contigs;
my @output_bin;
my $num_bins = 0;

sub initialize {
  GetOptions(
    'i=s' => \$bin_list,
    'n=s' => \$bin_id_list,
    'o=s' => \$output_file,
    'h'   => \$help,
  ) or die "Incorrect usage!!\n";

  #check for the help message
  if ($help ne 0) { usage(); exit 1;}
  #check for the mandatory input files
  unless (defined $bin_list) { print "You need to enter the bin list file\n";
    usage(); exit 1; }
  unless (defined $bin_id_list) { $bin_id_list=$bin_list; }
}

sub openFile{
  my ($filename) = @_;
  my @return;
  open (FILE, "<", $filename) or die "Can't open the file $filename!!!!\n";
  while (<FILE>) {
    chomp $_;
    push @return, $_;
  }
  close FILE;
  return @return;
}


sub getContigs{
  #get the name of the file from the for loop and open the file
  my ($filename, $bin_id) = @_;
  my @lines = openFile($filename);
  my $file_length = scalar @lines;

  #check to see if the lines are contig identifiers
  for (my $i=0; $i<$file_length;$i++) {
    my $result = checkLine($lines[$i]);
    if ($result ne "none") {
      my $newresult = substr $result, 1;
      push @output_contigs, $newresult;
      push @output_bin, $bin_id;
    }
  }
}

sub checkLine{
  my ($line) = @_;
  if ($line =~ m/^>/) {
    return $line;
  }
  else {
    return "none";
  }
}

sub printOutput{
  my ($filename) = @_;
  open (OUT, ">", $filename) or die "Can't open output file $filename!!!!\n";
  my $file_length = scalar @output_contigs;
  for (my $i=0; $i < $file_length; $i++) {
    my $line = getLine($output_contigs[$i], $output_bin[$i]);
    print OUT $line, "\n";
  }
  close OUT;
}

sub getLine{
  my ($contig, $bin) = @_;
  my $return = $contig . "\t" . $bin;
  return $return;
}

initialize();
#get all the identifiers
@bin_files = openFile($bin_list);
@bin_ids = openFile($bin_id_list);
#get the number of bins
if (scalar @bin_files == scalar @bin_ids) {
  $num_bins = scalar @bin_files;
}
else {
  print "Your two input files do not have the same number of lines!! Please try again.\n";
  usage(); exit 1;
}
#get the output for each bin one by one
for (my $i = 0; $i < $num_bins; $i++) {
  getContigs($bin_files[$i], $bin_ids[$i]);
}
printOutput($output_file);
