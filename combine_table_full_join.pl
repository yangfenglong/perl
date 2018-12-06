#! /usr/bin/perl -w
use strict;
unless (@ARGV ==1) {
	die"Usage: perl $0 <comb.table.list> 
	output:  <combined.tables> \n";
}

for(`less $ARGV[0]`){
	chomp;
	my $inf1 = $_;
	$_=~ s/T_ko_group_tax_abundance/S_ko_group_tax_abundance/;
	my $inf2 = $_;
	$_=~ s/S_ko_group_tax_abundance/combined_ko_group_tax_abundance/;
	my $outf = $_;

	#print combined head
	open(IN1,"$inf1");
	open(OUT,">$outf");
	my $head=<IN1>;
	$head =~ s/\t/_T\t/g; 
	$head =~ s/\n/_T\n/g;
	chomp($head);
	my @heads = split/\t/,$head;
	shift @heads;
	for (@heads){
		$_ =~ s/_T/_S/;
	}
	my $head2 = join("\t",@heads);
	print OUT $head,"\t$head2\n";
	
	#save abuns of tables
	my %spe2abun;
	my @spes;
	while(<IN1>){
		chomp;
		my @temp = split/\t/;
		my $spe = shift @temp;
		push @spes, $spe;
		$spe2abun{$spe} = \@temp;
	}
	close IN1;

	my %spe2abun2;
	open(IN2, "$inf2");
	<IN2>;
	while(<IN2>){
		chomp;
		my @temp = split/\t/;
		my $spe = shift @temp;
		push @spes, $spe;
		$spe2abun2{$spe} = \@temp;
	}
	close IN2;

	my %hash;
	@spes =  grep { ++$hash{$_} < 2 } @spes;
	for(@spes){
		my @temp = ($spe2abun{$_} && $spe2abun2{$_})? 
					join("\t",$_,@{$spe2abun{$_}},@{$spe2abun2{$_}}): 
					($spe2abun{$_} && !$spe2abun2{$_})?
					join("\t",$_,@{$spe2abun{$_}}, (map {$_*0} @{$spe2abun{$_}})):
					(!$spe2abun{$_} && $spe2abun2{$_})?
					join("\t",$_, (map {$_*0} @{$spe2abun2{$_}}), @{$spe2abun2{$_}}): 
					next;
		print OUT join("\t",@temp),"\n";
	}
	close OUT;
}
