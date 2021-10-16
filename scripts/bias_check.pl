#!/usr/bin/perl -wl

my $fh;
my $log;

open ($fh, "<", "../logs/diode.log");
open ($log, ">", "../logs/bias_check.log");

my %dump_hash;

my $line = <$fh>;

my @dump_vars = split " ", $line;

my $counter = 0;

for my $var ( @dump_vars ) {
	$dump_hash{$var} = $counter;
	$counter++;
}

while ( $line = <$fh> ) {
	@dump_vars = split " ", $line;
	for my $dvar (keys %dump_hash) {
		if ( $dvar =~ /\@d.*[vd]/ ) {
			my $voltage = $dump_vars[$dump_hash{$dvar}];
			if ( $voltage < 0 ) {
				print $log "${dvar} is reverse biased at ${voltage}";
			} else {
				print $log "${dvar} is forward biased at ${voltage}";
			}
		}
	}
}

close $fh;
