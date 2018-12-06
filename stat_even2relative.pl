#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my $tax;
GetOptions("tax"=>\$tax);
@ARGV || die"Name: stat_even2relative.pl
Usage: perl $0 <otu_table.txt> > relative.txt
   --tax <str>  the last column is taxonmy message
";

#====================================================================================
my ($otu_tab) = @ARGV;
#my @sums=split/\s+/,`awk -F "\\t" '{for(n=2;n<NF;n++)t[n]+=\$n}END{for(n=2;n<NF;n++)printf t[n]" ";print"\\n"}' $relative_mat`;
my @tag_num;
Tag_stat($otu_tab,\@tag_num); #sum

open IN,$otu_tab || die$!;
my $head =<IN>;
print $head;
while(<IN>){
    chomp;
    my @l = /\t/ ? split /\t/ : split;
    for my $i(0..$#tag_num){$l[$i+1] /= $tag_num[$i];}
    print join("\t",@l),"\n";
}
close IN;

#=======================================================================================================
sub Tag_stat{
    my ($otu_tab,$tag_num) = @_;
    open OTU,$otu_tab || die$!;
	<OTU>;
    while(<OTU>){
        my @l = /\t/ ? split /\t/ : split;
        if($tax){
		    for my $i(1..$#l-1){$tag_num->[$i-1] += $l[$i];}
		}else{
		    for my $i(1..$#l){$tag_num->[$i-1] += $l[$i];}
        }
    }
    close OTU;
}

__END__
