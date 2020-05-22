#!/usr/bin/perl -w
use strict;

$#ARGV>=0 or die "
Usage:
    $0 lofiles... > outfile.tsv
    logfile File from migaproject/daemon/stats/
    The output file will have the file names in the first column
    And summary information about the genome in all other columns
";

for my $fa (@ARGV){
  open FA, "<", $fa or die "Cannot open file: $fa: $!\n";
  print $fa, "\n";
}

exit;






#getopts files
my $fasta_file;
my $blast_file;
my $out_file="output.blast.length";
my $help=0;

#global variables
my %fasta_dictionary;
my @new_blast_lines;
my $fasta_seq_count=0;
my $total_length=0;
my $num_blast=0;
my $num_kept=0;
my $num_dropped=0;

sub initialize {
  GetOptions(
  'i=s' => \$fasta_file,
  'b=s' => \$blast_file,
  'o=s' => \$out_file,
  'h' => \$help,
  ) or die "Incorrect usage!\n";

  #check for help
  if ($help ne 0) {usage(); exit 1;}
  #check for input files
  unless (defined $fasta_file || defined $blast_file) {
    print "You need to enter all input files\n";
    usage(); exit 1;
  }
}

sub usage{
  print "\nHow to run this code:\n";
  print "\n./BlastTab.addlen.pl -i fasta_file -b blast_file -o output_name\n";
  print "The fasta file are the sequences that are being mapped to the subject [query]\n";
  print "The blast must be in tabular blast format\n";
  print "The output will be in tabular blast format with the length of each sequence added\n";
}


sub Readfasta {
  my ($fasta) = @_;
  open (FILE, "<", $fasta) or die "Can't open the file $fasta!!\n";
  my $line; #tmp line variable
  my $k=0; #tmp variable to determine what to look for in a file
  my $id; #store id
  my $length; #store length
  while (<FILE>) {
    $line = $_;
    chomp $line;
    if ($line =~ m/^>/ && $k == 0) {
      $line =~ s/>//g; #get rid of the '>'
      $line =~ s/\s*//g; #get rid of spaces
      $id = $line;
      $k=1; #set this so next time we get the sequence
      $fasta_seq_count++;
    }
    elsif ($k == 1) {
      $line =~ s/\s*//g; #get rid of spaces
      $length = length $line;
      $total_length += $length;
      $fasta_dictionary{$id} = $length;
      $k=0;
    }
  }
  close FILE;
}

sub Addlen {
  open (BLAST, "<", $blast_file) or die "Can't open blast file!!\n";
  open (OUT, ">", $out_file) or die "Can't open the output file!!\n";
  my $line; my @values; #variable to store split file
  my $query; my $qLength; my $aLength; my $pMatch; #variables from the blast output
  my $newline; my $array_length; #values for making output line
  while (<BLAST>) {
    #get the values
    $line = $_;
    chomp $line;
    @values = split('\t', $line);
    $query = $values[0];
    $qLength = $fasta_dictionary{$query};
    $aLength = $values[3];
    $pMatch = ($aLength / $qLength) * 100;
    $num_blast++;

    #calculations
    if ($pMatch >= 90 && $qLength >= 50) {
      $num_kept++;
      $array_length = scalar @values;
      for (my $i=0; $i < $array_length; $i++) {
        print OUT $values[$i], "\t"; #print out the blast line
      }
      print OUT $qLength, "\t", $pMatch, "\n"; #adding the new values
    }
    else {
      $num_dropped++;
    }
  }
  close BLAST;
  close OUT;
}

initialize();
print "Running script BlastTab.addlen.pl -i $fasta_file -b $blast_file -o $out_file\n";
Readfasta($fasta_file);
my $avg = $total_length / $fasta_seq_count;
print "The total number of fasta sequences is $fasta_seq_count\n";
print "The average sequence lenth is $avg\n";
Addlen();
print "The total number of blast hits is $num_blast\n";
print "Blast hits above 50 bp query and above 90% match: $num_kept\n";
print "Blast hits that did not pass filter: $num_dropped\n";






#!/bin/bash


#checks for usage
if [[ "$1" == "" || "$1" == "-h" ]]
then
  echo "
  Usage: ./getHQbinsfromMiga.sh logfile1 logfile2 logfile3 > output.tsv
  logfile       File from migaproject/daemon/stats/
  The output file will have the file names in the first column
  And summary information about the genome in all other columns
  " >&2
  exit 1
fi






ARGS=("$@")
for var in "${ARGS[@]}"
do
  echo "$var"
done







exit
for var in "$@"
do
  let log${count}="$var"
  echo log${count}
  (( count++ ))
  (( accum += ${#var} ))
done
#stores file names
database=$1
reads=$2
output=$3

#variables
enveomics="/Users/gbrandt6/bin/enveomics"
metagenomes_scripts="/Users/gbrandt6/Documents/metagenomes-scripts"
BLAST=0

#Reformat fastas
if [[ -s $database.reformatted ]]
then
  database=$database.reformatted
else
  #check if file needs it
  num_lines=$(wc -l $database | head -n1 | awk '{print $1;}')
  num_headers=$(grep ">" $database | wc -l)
  num_headers=$((num_headers * 2))
  if [[ $num_headers -eq $num_lines ]]
  then
    echo "The $database file is in correct format..."
  else
    #reformat the fasta and rename the variable
    echo "Reformatting the $database file so seqs are on one line..."
    $metagenomes_scripts/Scripts/FastA.reformat.oneline.pl -i $database -o $database.reformatted
    echo "Done reformatting $database..."
    database=$database.reformatted
  fi
fi

if [[ -s $reads.reformatted ]]
then
  reads=$reads.reformatted
else
  #Check reformatting the other file
  num_lines=$(wc -l $reads | head -n1 | awk '{print $1;}')
  num_headers=$(grep ">" $reads | wc -l)
  num_headers=$((num_headers * 2))
  if [[ $num_headers -eq $num_lines ]]
  then
    echo "The $reads file is in correct format..."
  else
    #reformat the fasta and rename the variable
    echo "Reformatting the $reads file so seqs are on one line..."
    $metagenomes_scripts/Scripts/FastA.reformat.oneline.pl -i $reads -o $reads.reformatted
    echo "Done reformatting $reads..."
    reads=$reads.reformatted
  fi
fi

#Check to see if the final blast file is present
if [[ -s $output.blst ]]
then
  echo "Final blast file found. Not running blast again or filtering..."
  echo "Now running recruitment plot scripts..."
  BLAST=1
else
  #Run blast
  echo "Making BLAST database..."
  makeblastdb -in $database -dbtype nucl
  echo "Running BLAST with 70% identity cutoff..."
  blastn -db $database -query $reads -outfmt 6 -out $output.tmp.orig.blst -perc_identity 70
  echo "Done with BLAST..."
  #Filter for length
  echo "Adding length of query to blast result and filtering for 90% match"
  $metagenomes_scripts/Pipelines/recruitmentPlot/BlastTab.addlen.pl -i $reads -b $output.tmp.orig.blst -o $output.tmp.length.blst
  #Filter for best match
  echo "Only keeping best match from BLAST results..."
  $metagenomes_scripts/Pipelines/recruitmentPlot/BlastTab.besthit.pl -b $output.tmp.length.blst -o $output.blst
fi

#Recruitment plot scripts
echo "Building recruitment plot..."
$enveomics/Scripts/BlastTab.catsbj.pl $database $output.blst
$enveomics/Scripts/BlastTab.recplot2.R --prefix $output.blst $output.recruitment.out $output.recruitment.pdf

#print statistics
if [[ $BLAST -eq 0 ]]
then
  num_orig=$(wc -l $output.tmp.orig.blst | head -n1 | awk '{print $1;}')
  num_length=$(wc -l $output.tmp.length.blst | head -n1 | awk '{print $1;}')
  num_best=$(wc -l $output.blst | head -n1 | awk '{print $1;}')
  echo "
      Original number of blast hits:                            $num_orig
      Number of blast hits after filter for length of match:    $num_length
      Number of blast hits after filter for best match:         $num_best"

  #remove temporary files
  rm $output.tmp.orig.blst
  rm $output.tmp.length.blst
  rm $output.blst.lim
  rm $output.blst.rec
else
  num_best=$(wc -l $output.blst | head -n1 | awk '{print $1;}')
  echo "
    Number of blast hits:         $num_best"
fi
echo "
    Script is finished. Output files:
    $output.blst
    $output.recruitment.out
    $output.recruitment.pdf"

#Things to add
#Finding the average sequencing depth
