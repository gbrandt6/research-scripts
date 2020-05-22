#!/bin/bash

#checks for usage
if [[ "$1" == "" || "$1" == "-h" || "$2" == ""  || "$3" == "" ]]
then
   echo "
   Usage: ./RUNME.bash assembly.fa reads.fq output_name

   assembly.fa  The assembly file in fasta format
   reads.fa     Raw reads in interleaved fastq format
   output_name  Base name for the output files
   " >&2
   exit 1
fi

#gets current working directory
script_dir=$(dirname $(readlink -f $0))
current_dir=$(pwd)

#stores file names
assembly=$1
reads=$2
output=$3

#checks for the files
if [[ ! -e $assembly || ! -e $reads ]] ; then
  echo "Cannot locate your input files, aborting..." >&2
  exit 1
fi

#Comment out the queue you do not want
#QUEUE="-q iw-shared-6 -l walltime=12:00:00"
QUEUE="-q microcluster -l walltime=120:00:00"

#get the arguments
OPTS="DIR=$current_dir,ASSEMBLY=$assembly,READS=$reads,OUTPUT=$output"

#job name
name=$(basename $assembly)

#launch the job
job_id=$(qsub -v "$OPTS" -N "Metabat-$name" -l "mem=4gb"  \
        $QUEUE $script_dir/metabat.pbs | grep .)
echo "$job_id"
