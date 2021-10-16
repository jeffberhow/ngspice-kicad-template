#/usr/bin/perl -w
#
#	Description: 	This script generates a .control file that can be run to 
#			save diode voltages. The .control file is then inserted into
#			the circuit netlist 

use Getopt::Long;

my $circuit;

GetOptions ("circuit=s" => \$circuit) or die("Error in command line arguments\n");

my $fh;
my $out;
my @diodes;
my @lines;

open( $fh, "<", $circuit );

open ( $out, ">", "../netlists/diode.sim" );

print $out ".control\nop\nset wr_singlescale\nset wr_vecnames\noption numdgt=2\n";

while ( my $line = <$fh> ) {
	push @lines, $line;
	if ( $line =~ /^(d\w+)/i ) {
		my $diode_vd = "\@" . lc($1) . "[vd]";
		print $out "save ${diode_vd}\n";
		push @diodes, $diode_vd;
	}
}

print $out "wrdata ../logs/diode.log ";

for my $diode_vd ( @diodes ) {
	print $out "${diode_vd} ";
}

print $out "\n.endc";

close $fh;
close $out;

open( $fh, ">", $circuit );

for my $cir_line ( @lines ) {
	if ( $cir_line =~ /\.title/ ) {
		print $fh "${cir_line}.include \"diode.sim\"\n";
	} elsif ( $cir_line =~ /diode\.sim/ ) {

	} else {
		print $fh "${cir_line}";
	}
}

close $fh;
