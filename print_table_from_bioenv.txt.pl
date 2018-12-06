#!/usr/bin/perl -w

sub usage {
    die(
        qq!
Usage:    perl $0 inpute_file > output_file
Author:   yangfenglong: 
\n!
    )
}

&usage unless (@ARGV>0); 

my %h;
my $f=shift;
open(IN,$f);
while(<IN>){
    /size/ && next;
    /correlation/ && last;
    my @tmp=split/\s+/;
    $size=pop @tmp;
    $id=join("_",@tmp);
    $h{$id}{size} =$size;
}

while(<IN>){
    my @tmp=split/\s+/;
    $size=pop @tmp;
    $id=join("_",@tmp);
    $h{$id}{cor} =$size;
}

print "id\tcor\tsize\n";
for ( sort {$h{$a}{size} <=>$h{$b}{size}}  keys %h){
    print "$_\t",$h{$_}{cor},"\t",$h{$_}{size},"\n";
}
