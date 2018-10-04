#!/usr/bin/env perl
use strict;

my $bamFile = shift;
my $fastqFile = shift or &usage();

warn "Step 1: record all mapped reads in memory\n";
my %mapped;
open(M, "samtools view -F 0x4 $bamFile | ") or die $!;
my $counter = 0;
while(<M>)
{
	my $name = (split "\t")[0];
	warn "Unknown format for name [$name]\n"
	unless($name =~ /^(.+)_\d+\:.+$/);
	$name=$1;
	$mapped{$name}++;
	warn "$counter mapped reads are recorded\n"
	if(++$counter % 1000000 == 0);
}
close M;
warn "In total, $counter reads are mapped\n";

warn "Step 2: filter unmapped reads from fastq file\n";
open(R,"zcat $fastqFile | ") or die $!;
$counter = 0;
my $unmapped = 0;
while(my $read = next_read())
{
	warn "$counter reads have been processed\n"
	if(++$counter % 1000000 == 0);
	next if($mapped{$read->{'name'}}); # mapped
	print $read->{'record'};
	$unmapped++;
}
close R;
warn "In total, $unmapped unmapped reads are found\n";
warn "Job is done\n";

exit 0;

sub next_read
{
	return undef if eof(R);
	my $record = '';
	my $name;
	while(<R>)
	{
		next unless /^@/; # start of a new record
		($name) = /^@(\S+)/;
		$record .= $_;
		$record .= <R>;
		$record .= <R>;
		$record .= <R>;
		last;
	}
	return {'name' => $name, 'record' => $record};
}

sub usage
{
	print <<USAGE;
$0 <bam-file> <fastq-file>

This program extracts the unmapped reads from <fastq-file> 
based on the mapping status in the <bam-file>.

USAGE

	exit 1;
}

