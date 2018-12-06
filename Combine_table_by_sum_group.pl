#!/usr/bin/perl -w
use strict;
@ARGV==2 || die"usage: perl Combine_table.pl <in.table> <in.group> > out.combine.table.xls\n";
for (@ARGV){
	(-s $_) || die$!;
}
my ($intable,$group) = @ARGV;
my %uniq_group;
my %sample2id;
my @group_name;
# save samples in groups
for (`less $group`){
	chomp;
	my @l = split/\t/;#sample group_anme
	push  @{$uniq_group{$l[1]}}, $l[0];
	push @group_name,$l[1] if !grep {$_ eq  $l[1]} @group_name; # for group_orders in group.list
}
#my @group_name = sort keys %uniq_group;

# sample2 id in table 
open IN,$intable || die$!;
chomp(my $head = <IN>);
my @head = ($head=~/\t/) ? split/\t/,$head : split/\s+/,$head;
for my $i(0 .. $#head){
	$sample2id{$head[$i]} = $i;	
}

# save ids in  table for groups 
my %group2ids; # ids in group
for(@group_name){
	my $gi = $_;
	for(@{$uniq_group{$gi}}){
		if($sample2id{$_}){
			push @{$group2ids{$gi}}, $sample2id{$_};	
		}
	}
}

#duplicate samples
my @rank_num =split /\s+/, (`wc -l $group`);
my $sample_num = $rank_num[0];
if($sample_num==@head-2){ # for table with last taxonmy column 
   print join("\t",$head[0],@group_name,$head[-1]),"\n";
   while(<IN>){
	   chomp;
	   my @l = /\t/ ? split /\t/ : split;
	   my @out = map avg_sd(@l[@{$group2ids{$_}}]), @group_name;
	   print join("\t",$l[0],@out,$l[-1]),"\n";
	}
}else{
	print join("\t",$head[0],@group_name),"\n";
	while(<IN>){
		chomp;
		my @l = /\t/ ? split /\t/ : split;
		my @out = map avg_sd(@l[@{$group2ids{$_}}]),  @group_name;
		print join("\t",$l[0],@out),"\n";
	}
}
close IN;

#================
sub avg_sd{
	my ($avg,$sd);
#	my $num = @_;
	for(@_){
		$avg += $_;
#	   $sd += $_**2;
	}
#	$avg /= $num; #for sum group members
##	my $i=$sd/$num - $avg**2;
#	warn "$sd\t$num\t$avg\n" if($i < 0);
#	warn "$sd\n" if($sd < 0 || $num <0 || $avg <0);
##	$sd = sprintf("%.6f",sqrt($sd/$num - $avg**2));
	$avg = sprintf("%.6f",$avg);
	return("$avg");  #return("$avg:$sd") ->return("$avg")
}
