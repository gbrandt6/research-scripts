#!/usr/bin/perl -w
use strict;
use Getopt::Long;

#this script takes the input from the binning file and contig file and outputs the bin fasta file

#getopts files
my $bin_input_file;
my $contig_input_file;
my $output_base="cocacola_bin";
my $help=0;

#global variables
my @bin_identifiers;
my @bin_nums;
my $num_bin_lines;
my @contig_lines;
my $num_contig_lines;
#Output hash with bin_num as they key and the output in an array
my %outputs;
my $j=0;

sub usage {
  print "\nHow to run this code:\n";
  print "./make_cocacola_files.pl -b [binning output file] -c [contig file] -o [output base name]\n";
  print "Where the binning output file is the bin file from COCACOLA\n";
  print "Where the contig file is the contig input that you used to run COCACOLA\n";
  print "Where the output base name is what the bins will be named followed by their bin number\n";
  print "Use -h to get this message\n\n";
}

sub initialize {
  GetOptions(
    'b=s' => \$bin_input_file,
    'c=s' => \$contig_input_file,
    'o=s' => \$output_base,
    'h'   => \$help,
  ) or die "Incorrect usage!\n";

  #check to see if the help message was activated
  if ($help ne 0) { usage(); exit 1;}
  #check for the mandatory input files
  unless (defined $bin_input_file) { print "You need to enter the binning file\n";
    usage(); exit 1; }
  unless (defined $contig_input_file) { print "You need to enter the contig file\n";
    usage(); exit 1; }
}


sub openBinFile{
  my ($filename) = @_;
  open (FILE, "<",  $filename) or die "Can't open the file $filename!!!!\n";

  #read the lines
  while (<FILE>) {
    chomp $_;
    #split the line by the comma
    my @values = split(',', $_);
    #put the bin identifiers and the bin numbers into separate arrays
    push @bin_identifiers, $values[0];
    push @bin_nums, $values[1];
  }
  close FILE;
}

sub openContigFile{
  my ($contig) = @_;
  open (FILE, "<", $contig_input_file) or die "Can't open the file $contig_input_file!!!\n";
  while (<FILE>) {
    chomp $_;
    push @contig_lines, $_;
  }
  close FILE;
}



sub getMatch{
  #go through the bin IDs and nums line by line
  my $bin_num;
  my $contig_id;
  for (my $i=0; $i < $num_bin_lines; $i++) {
    $contig_id = $bin_identifiers[$i];
    $bin_num = $bin_nums[$i];
    findContig($contig_id, $bin_num);
  }
}

sub findContig{
  my ($contig_id, $bin_num) = @_;
  #add a space to the contig identifier
  $contig_id .= " ";
  #set temp variable
  my $k;
  #go though contig file
  for (my $i=0; $i < $num_contig_lines; $i++) {
    #if the contig file matches the contig ID
    if (index($contig_lines[$i], $contig_id) != -1) {
      $k = $i;
      #print $k, "\t", $i, "\n";

      while ($k != -1 && $k <= $num_contig_lines) {
        #print $k, "\t", $i, "\n";
        #print "adding...", $contig_lines[$k], "\n";
        push @{$outputs{$bin_num}}, $contig_lines[$k];
        $k++;
        if ($contig_lines[$k] =~ m/^>/ || $contig_lines[$k] =~ m/^\s*$/) {
          $k = -1;
        }
      }

      #if ($j < 20) {
      #  print $contig_lines[$i], "\t", $contig_id, "\n";
      #  $j++;
      #}

      #$k=$i;
      #until ($contig_lines[$k] =~ m/^>/ || $k >= $num_contig_lines) {
      #  print "yes\n";
      #  push @{$outputs{$bin_num}}, $contig_lines[$k];
      #  $k++;
      #}

      last;
    }
  }
}


sub printOutput{
  for my $num (keys %outputs) {
    my $filename = $output_base . "_" . $num . ".fasta";
    open (OUT, ">", $filename) or die "Can't open output file $num!!!\n";
    for my $i (0 .. $#{$outputs{$num}}) {
      print OUT $outputs{$num}[$i], "\n";
    }
  }
}

initialize();
openBinFile($bin_input_file);
$num_bin_lines = scalar @bin_identifiers;
openContigFile($contig_input_file);
$num_contig_lines = scalar @contig_lines;
getMatch();
printOutput();
