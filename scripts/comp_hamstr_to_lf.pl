#!/usr/bin/perl

# author: Joseph Ryan <joseph.ryan@whitney.ufl.edu>
# Jan 24, 2017

use strict;
use warnings;
use Data::Dumper;

our $VERSION = 1.00;  # this is the version used in the leapfrog paper

# $DIR = hmm_search_<YourTaxonName>_<YourCoreOrthologSet> 
#    This directory contains the output files of the individual hmmer searches.
our $DIR = 'hmm_search_Smed_modelorganisms_hmmer3';

# this is a list of putative hidden orthologs from leapfrog
our $LF = 'Smed.dd.leapfrog';

MAIN: {
    my $rh_data = get_data($DIR);
    my $ra_ids = get_lf($LF);
    my $hit = 0;
    my $miss = 0;
    foreach my $id (@{$ra_ids}) {
        if ($rh_data->{$id}) {
            $hit++;
        } else {
            $miss++;
        }
    }
    print "\$hit = $hit\n\$miss = $miss\n";
}

sub get_lf {
    my $file = shift;
    my @ids = ();
    open IN, $file or die "cannot open $file:$!";
    my $header = <IN>;
    while (my $line = <IN>) {
        chomp $line;
        my @f = split /\t/, $line;
        push @ids, $f[2];
    }
    return \@ids;
}

sub get_data {
    my $dir = shift;
    my %data = ();
    opendir DIR, $dir or die "cannot opendir $dir:$!";
    my @files = grep { /\.out$/ } readdir DIR;
    foreach my $f (@files) {
        open IN, "$dir/$f" or die "cannot open $dir/$f:$!";
        my $flag = 0;
        while (my $line = <IN>) {
            chomp $line;
            $flag = 1 if ($line =~ m/^\s*[ -]+$/);
            next unless ($flag == 1);
            next if ($line =~ m/^\s*$/ || $line =~ m/^\s*[ -]+$/);
#            last if ($line =~ m/------ inclusion threshold ------/);
            next if ($line =~ m/------ inclusion threshold ------/);
            last if ($line =~ m/Domain annotation/);
            last if ($line =~ m/No hits detected/);
            my @f = split /\s+/, $line;
            die "unexpected $line\n-->$f[9]<--" unless ($f[9] =~ m/^dd/);
            $data{$f[9]}++;
        }
    }
    return \%data;
}
