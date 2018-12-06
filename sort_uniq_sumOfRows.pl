#!/usr/bin/perl -w
@ARGV || die "usage: perl $0 <gene_table.txt> > <output: uniq.gene_table.txt>
 Contactor: yangfenglong[AT]novogene.com\n\n";

open IN, $ARGV[0] || die $!;
open OUT,">$ARGV[1]" || die $!;

#print head
my $head = <IN>;
print OUT $head;

#uniq rows
my %gene2samp;
my @genes;
while(<IN>){
	chomp;
	my @temp = split/\t/,$_;
	my $gene = shift @temp;
	push (@genes,$gene);
	$gene2samp{$gene} = $gene2samp{$gene} ? 
						[map { $gene2samp{$gene}->[$_] + $temp[$_] } 0..$#temp] :
						[@temp] ;
}

#print rows
my %hash;
@genes =  grep { ++$hash{$_} < 2 } @genes; 
for (@genes){
	print OUT join("\t",$_,@{$gene2samp{$_}}),"\n";	
}

close IN;
close OUT;

__END__
