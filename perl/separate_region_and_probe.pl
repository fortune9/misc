#!/usr/bin/env perl
use strict;

my $inFile = shift;
my $outBase = shift or &usage();

open(I, "< $inFile") or die $!;
open(R,"> $outBase.regions.tsv") or die $!;
open(P,"> $outBase.probes.tsv") or die $!;
print R join("\t", qw/#chr start end region regionSeq/), "\n";
print P join("\t", qw/#chr start end probe region GC seq/), "\n";
my $regionSeq;
my $chr; 
my $start; # region start
my $rId; # region id
my $i=0;
my $j = 0;
while(<I>)
{
	$j++;
	chomp;
	my @fields = split "\t";
	if($fields[2] =~ /^\d+$/) # region line
	{
		$rId = "r.".++$i;
		$regionSeq=$fields[4];
		$chr=$fields[1] if($fields[1] ne "");
		$start=$fields[2];
		print R join("\t", $chr, @fields[2,3], $rId, $fields[4]), "\n";
	}

	# output probe too
	next unless($fields[2] =~ /^\s*$/ or 
		$fields[2] =~ /^\d+$/); # probe/region line

	my ($pStart, $pEnd) = match_pos($fields[5],$regionSeq);
	$pStart += $start;
	$pEnd   += $start;
	print P join("\t",     $chr,
						   $pStart,
						   $pEnd,
						   $fields[0],
						   $rId,
						   $fields[6], # GC content
						   $fields[5] # sequence
					   ), "\n";
}
close I;
close R;
close P;

warn "Job done\n";

exit 0;

sub match_pos
{
	my ($rex, $s) = @_;
	die $! if not $s =~ /$rex/i;
	return ($-[0], $+[0]-1);
}

sub usage
{
	print <<USAGE;
Usage: $0 <design-file> <output-basename>

This program will read the probe design file and
output the regions and probes into different files.

E.g.: $0 Mouse_enhancer_20180520_design.tsv Mouse_enhancer_20180520

Created: Wed Sep 19 16:52:41 EDT 2018

USAGE
	exit 1;
}
