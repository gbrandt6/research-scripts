#!/bin/bash

#this script needs to run dos2unix before running if transferring from local machine
#improvements: install maxbin on the cluster correctly

#checks for usage
if [[ "$1" == "" || "$1" == "-h" || "$2" == ""  || "$3" == "" ]]
then
   echo "
   Usage: ./RUNME.bash assembly.fa reads.fa output_name

   assembly.fa  The assembly file in fasta format
   reads.fa     Trimmed reads in fasta format. Interleaved reads are the best
                option but you may also submit either forward OR reverse reads,
                not both.
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
#arguments: assembly = assembly
#reads = reads
#output = output
OPTS="DIR=$current_dir,ASSEMBLY=$assembly,READS=$reads,OUTPUT=$output"

#job name
name=$(basename $assembly)

#launch the job
job_id=$(qsub -v "$OPTS" -N "Maxbin-$name" -l "mem=4gb"  \
        $QUEUE $script_dir/maxbin.pbs | grep .)
echo "$job_id"
