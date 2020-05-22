# research-scripts

A collection of files by Genevieve Brandt for various functions to format data

# 3col_pairwise_to_matrix.pl
Usage: 3col_pairwise_to_matrix.pl dist_table > dist_matrix
Takes a 3 column comparison (MASH distance) and makes a matrix file

# ANI_matrix_cutoff.pl
Usage: ANI_matrix_cutoff.pl ANI_matrix.txt cutoff > ANI_matrix_cutoff.txt
Keeps all values above the cutoff from an ANI matrix and changes all others to 0

# ANI.file.add.zeros.pl
ANI.file.add.zeros.pl input.file > output.file
Checks line from ANI output (single line of the matrix) and adds zeros where there is no value

# ANI.multiple.comparison.many.pl
ANI.multiple.comparison.many.pl -i input_list -n comparison_file -m method -o output.txt
Compares many many genomes!
Give one file name to compare to a large list
Must be in the current directory
Makes one line of the ANI comparison

# ANI.multiple.comparison.pl
compare_ani.pl -i input_file -m method -o output.txt
Compares genomes to make a large matrix, not a good idea for many many files

# assembly.stats.avg.pl
assembly.stats.avg.pl input.file output.file.name
Gets the average of values from the second column of a file
Perhaps for a file with GC content or Length per contig

# assembly.stats.total.pl
assembly.stats.total.pl input.file output.file.name
This code finds the total value from the second column of a file
Perhaps for a file with GC content or Length per contig

# DAS.to.FastA.pl
DAS.to.FastA.pl -b [binning output file] -c [contig file] -o [output base name]
Gets the fasta output files from the DAS binning output file

# FastaA.filter.length.pl
FastA.filter.length.pl input.file max_length output.file.name
Takes a fasta file as input (containing contigs) and outputs a fasta file with only sequences that pass a certain length threshold

# FastA.length.pl
FastA.length.pl -i [input fasta file] -o [output file, prints length of each sequence, optional] > output.txt
Gets the length of fasta sequences

# FastA.make.DAS.input.pl
FastA.make.DAS.input.pl -i [list of bin fasta filenames] -n [list of bin identifiers] -o [output file name]
Makes the DAS input table, give all the fasta names in a list and all their IDs in another list, makes a table to be concatenated to all others in the group
-i Each fasta filename should be on one line and all files must be in the current directory
-n Each bin identifier should be on one line, corresponding to the input file names, in the same order
-o The output file will be in tab separated format (tsv)
Run this script once for each binning method

# FastA.reformat.oneline.pl
FastA.reformat.oneline.pl -i [input file name] -o [output file name]
Makes sure that the sequences in a fasta file are not in multiple lines (like contigs or genes)

# FastQ.length.pl
FastQ.length.pl -i [input fastq file] -o [optional output file, prints length of each sequence] > output.txt
This script gets the length of fastq sequences

#Get_modularity_class.pl
Get_modularity_class.pl ANI_nodes.csv ANI_edges.csv > output.csv
compares the node file and edges files to get the class

# get.assembly.stats.pl
assembly_statistics.pl output_folder_name ASSEMBLY_1 output_base_name_1 ASSEMBLY_2 output_base_name_2 etc
The program will put all output files into a new statistics folder that it will create

# read.AAI.pl
read.AAI.pl input_file >> output_list.txt
Input file is output from AAI comparison, gets new format

#Updating the github 
