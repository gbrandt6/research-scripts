#!/usr/bin/perl -w
use strict;
use Getopt::Long;

#this script is input nucleotide or protein fasta files (by option)
#the script runs ANI/AAI against everything
#It creates a temp file with the output
#It reads the temp file and puts into a table
my $input_file;
my $method="none";
my $output="output.txt";
my $help=0;
my @files;
my $num_files;


sub usage {
  print "\nUsage:\n";
  print "You must have blast loaded, either in your path or load the module\n";
  print "Ex: module load ncbi_blast/2.2.29\n";
  print "\nHow to run this code:\n";
  print "./compare_ani.pl -i input_file -m method -o output.txt\n";
  print "Where input_file is a file with each fasta that will be compared (nucleotide or amino acid) ";
  print "is on a separate line\n";
  print "Where method is ani or aai\n";
  print "Use -h to get this message\n";
  print "\nExample of 2 lines of input file:\n";
  print "\$HOME/data/sequence1.fasta\n\$HOME/data/sequence2.fasta\n\n";
}

sub initialize {
  GetOptions(
    'i=s' => \$input_file,
    'm=s' => \$method,
    'o=s' => \$output,
    'h'   => \$help,
  ) or die "Incorrect usage!\n";

  if ($help ne 0) { usage(); exit 1;}
  unless (defined $input_file) { print "You need to enter the input file\n";
    usage(); exit 1; }
  $method = lc $method;
  unless ($method eq "aai" or $method eq "ani") { print "You must enter a valid method, either aai or ani\n";
    usage (); exit 1; }
}

sub openfile{
  my ($filename) = @_;
  open (FILE, "<",  $filename) or die "Can't open the file $filename!!!!\n";

  #read the lines
  while (<FILE>) {
    chomp $_;
    push @files, $_;
  }
  close FILE;
}

sub run_script{
  #get the input
  my ($first_file, $second_file) = @_;
  #check for the method
  if ($method eq 'ani') {
    system("ani.rb -1 $first_file -2 $second_file -a -q > temp");
  }
  elsif ($method eq 'aai') {
    system("aai.rb -1 $first_file -2 $second_file -a -q > temp");
  }
  #run the subroutine to get the value for the table
  my $ani_value;
  $ani_value = get_value();
  system("rm temp");
  return $ani_value;
}

sub get_value{
  my $return_value;
  #check if there is no value
  if (-z "temp") {
    $return_value = "NULL";
  }
  open (TMP, "<", "temp") or die "Problem reading the temp file created by ani/aai\n";
  while (<TMP>) {
    chomp $_;
    $return_value = $_;
  }
  close TMP;
  return $return_value;
}

sub print_output{
  #open the output file
  open (OUT, ">",  $output);
  #print the first row (identifiers)
  print OUT "files\t";
  for (my $i=0; $i < $num_files; $i++) {
    print OUT $files[$i], "\t";
  }
  print OUT "\n";
  #do the comparisons row by row
  for (my $i=0; $i < $num_files; $i++) {
    #print the first identifier
    print OUT $files[$i], "\t";
    for (my $j=0; $j < $num_files; $j++) {
      my $ani = run_script($files[$i], $files[$j]);
      print OUT $ani, "\t";
    }
    print OUT "\n";
  }
  close OUT;
}

initialize();
openfile($input_file);
$num_files = scalar @files;
print_output();



#To do: make it so that you can have the name of the comparison on the same line as the name of the file
