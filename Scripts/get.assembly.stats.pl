#!/usr/bin/perl -w
use strict;

#This program finds the assembly statistics for assembly files
#look at usage for more information
#you must specify the location of enveomics when you first use the script if not as written

sub usage {
  print "How to run this code\n";
  print "You may specify as many assemblies as you wish, but the order must be as folllows:\n";
  print "./assembly_statistics.pl output_folder_name ASSEMBLY_1 output_base_name_1 ASSEMBLY_2 output_base_name_2 etc\n";
  print "All assemblies must be entered with the output base name\n";
  print "The program will put all output files into a new statistics folder that it will create\n";
}

#put the arguments into an array
my @arguments;
for my $value (@ARGV) {
  push @arguments, $value;
}
my $size = scalar @arguments;
my $location_of_enveomics = "~/data/apps/";
my $file = $arguments[0];

sub check_input {
  if (($size % 2) != 1 || $size == 1) {
    print "You have an invalid number of arguments\n";
    print "You must specify first the output folder name\n";
    print "followed by an assembly and a base name for the statistics file\n";
    print "the assembly and statistics file base name may be repeated\n\n";
    usage();
    exit 1;
  }

  unless (-e $file) {
    #print "Your statistics file folder name already exists.\n";
    #print "Please re-run the program with a new file folder name\n";
      system("mkdir $file");
  }

  my $i=1;
  while ($i < $size) {
    unless (-e $arguments[$i]) {
      print "Your assembly file does not exist. Please enter correct file and path.\n\n";
      usage();
      exit 1;
    }

    $i += 2;
  }
}
check_input();

sub get_arguments {
#  system("mkdir $file");
  my $i = 1;
  my $assembly;
  my $file_name;
  while ($i < $size) {
    $assembly = $arguments[$i];
    $file_name = $arguments[$i+1];
    run_statistics($assembly, $file_name);
    $i += 2;
  }
}

get_arguments();

sub run_statistics {
  my ($assembly, $file_name) = @_;
  system("echo Average GC content > $file/$file_name.txt");
  system("~/data/apps/enveomics/Scripts/FastA.gc.pl $assembly > $file/tmp");
  system("~/data/apps/Genevieve_scripts/Scripts/assembly.stats.avg.pl $file/tmp $file/$file_name.txt");
  system("echo >> $file/$file_name.txt");
  system("echo N50 information >> $file/$file_name.txt");
  system("~/data/apps/enveomics/Scripts/FastA.N50.pl $assembly >> $file/$file_name.txt");
  system("echo >> $file/$file_name.txt");
  system("echo Quartile data >> $file/$file_name.txt");
  system("~/data/apps/enveomics/Scripts/FastA.qlen.pl $assembly >> $file/$file_name.txt");
  system("rm $file/tmp");
}
