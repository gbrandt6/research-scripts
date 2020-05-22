#!/bin/bash

#checks for usage
if [[ "$1" == "" || "$1" == "-h" || "$2" == "" || "$3" == "" ]]
then
  echo "
  Usage: ./makeRecruitmentPlot.sh database.fa query.fa output_base

  database.fa   Fasta file which will be the database [most likely your longer sequence]
  query.fa      Fasta file that will be mapped to the database [most likely your reads]
  output_base   Base name for the blast output and recruitment plots
                blast output:         output_base.blst [Unique matches with over 70% coverage and 50 bp match]
                recruitment object:   output_base.recruitment.out
                recruitment pdf:      output_base.recruitment.pdf
  " >&2
  exit 1
fi

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
