#!/usr/bin/perl
use Getopt::Long;
use Cwd qw(abs_path);
use strict;
use warnings;
@ARGV >= 4 || die"
Description
    Partition The Variation Of Community Matrix By 2, 3, Or 4 Explanatory Matrices
    The function partitions the variation in community data or community dissimilarities with respect to two, three, or four explanatory tables, using adjusted R-squared in redundancy analysis ordination (RDA) or distance-based redundancy analysis.

Usage
    perl $0 <otu_table> <env.list> <vpa.list> <outdir> [-t -deltax]
    otu_table： with header and rownames
    env.list:   row.names are samples
    vpa.list:   goupname1:elements\tgrupname2:elements ... [2 to 4 groups each line]

    multi vpa groups the list should be made like below:
        env1:N,P,K  env2:pH,Humdepth,Baresoil   env3:Ca,Mg,S
        env1:P,K    env2:pH,Humdepth,Baresoil
        e1:N,P,K    e2:pH,Humdepth,Baresoil e3:Ca,Mg
Example
    perl $0 otu_table.even.txt env.list  vpa.list vpa -t

Author: yangfenglong\@novogene.com

References
    https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/varpart
";
my $R3="/PUBLIC/software/public/System/R-3.2.4/bin/R";
my ($spe,$env,$vpag,$outdir) = @ARGV;
my %opt;
GetOptions(\%opt,"t","deltax",);
(-d $outdir) || mkdir($outdir);
$spe = abs_path($spe);
$env = abs_path($env);
$outdir = abs_path($outdir);
(-e "$outdir/plot_vpa.R") &&  `rm $outdir/plot_vpa.R`;

#print vpa.Rscropt
open OUT,">$outdir/plot_vpa.R";
my $R;
if($opt{t} && $opt{deltax}){
  $R =<< "R";
library(vegan)
options(scipen = 20)
spe=read.table("$spe",header=T,row.names=1)
colnames(spe)<- gsub("^(X)", "",colnames(spe))
spe <- spe[,-ncol(spe)];
spe<-decostand(t(spe),"hel")
spe_h=as.data.frame(spe)
env=read.table("$env",header=T,row.names=1)
env_z<-as.data.frame(scale(env))
R

}

print OUT $R;
my $i=1;
for(`less $vpag`){
    chomp;
    my $vars=$_;
    my @names = ($vars =~ /(\S*?):/g);
    my $names = "c(\"".join("\",\"",@names)."\")";
    $vars=~s/(\S*?)://g;
    $vars=~s/,/+/g;
    $vars=~s/\t/,~/g;

    my $Rvpa =<< "R";
vpa <- varpart(spe_h, X=~$vars, data=env_z)
vpa.dbrda <- varpart(spe.dist,X=~$vars, data=env_z)
sink("vpa$i.txt")
vpa
sink()
sink("vpa.dbrda$i.txt")
vpa.dbrda
sink()
pdf(file="vpa$i.pdf")
plot(vpa, cutoff=-Inf, cex=0.7 ,bg=2:5, Xnames=$names, id.size=0.8, digits=2)
dev.off()
pdf(file="vpa.dbrda$i.pdf")
plot(vpa.dbrda, cutoff=-Inf, cex=0.7, bg=2:5, Xnames=$names, id.size=0.8, digits=2)
dev.off()
R

print OUT $Rvpa;
    $i++;
};
close OUT;

`cd  $outdir;
$R3 -f $outdir/plot_vpa.R;
ls *pdf |perl -ne 'chomp;\$_=~/(\.+)\.pdf/;print "convert \$_ \$1\.png\n"'|sh;
`;




