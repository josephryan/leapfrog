#!/usr/bin/perl

# Author: Joseph Ryan - <joseph.ryan@whitney.ufl.edu>
#         Wed Aug 24 18:42:39 EDT 2016

# Copyright (C) 2016  Joseph F. Ryan

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program in the file LICENSE. If not, see 
# http://www.gnu.org/licenses/.
 
use strict;
use warnings; 
use Data::Dumper;
use List::Util 'shuffle';

our $VERSION = 0.02;
our $SRAND = 42;
our $ITERATIONS = 100000;
our $HUMREF = 'HumRef2015.fa'; # https://github.com/josephryan/reduce_refseq

our $bg   = 'BIOGRID-ORGANISM-Homo_sapiens-3.4.139.tab2.txt';
our $smed = 'smed.leapfrog';
our $gene = 'Homo_sapiens.gene_info';

MAIN: {
    srand($SRAND);
    my $rh_ids = get_ids($smed);
    fix_changed_names($rh_ids);
    my $rh_bgdat = get_bg_dat($bg);
    my $rh_gene  = get_gene_dat($gene);
    my $rh_hits  = get_hits($rh_ids,$rh_bgdat,$rh_gene);
    my $count = scalar(keys %{$rh_hits});
    my $ra_rand_counts = get_rand_counts($rh_ids,$rh_bgdat,$rh_gene);
    my $gte = 0;
    foreach my $val (@{$ra_rand_counts}) {
        $gte++ if ($val >= $count);
    }
    my $pval = $gte / $ITERATIONS;
    print "$0 VERSION $VERSION\n";
    print "Random seed: $SRAND\n";
    print "Performing a one-tailed test\n";
    print "$ITERATIONS random counts generated\n";
    print "identified $count interactions in Smed\n";
    print "identified $gte random datasets with >= $count interactions\n";
    print "P-value: $pval\n";
}

sub get_rand_counts {
    my $rh_ids = shift;
    my $rh_bgdat = shift;
    my $rh_gene = shift;
    my $rh_humref_genes = _get_humref_genes($rh_gene,$HUMREF);
    my @rand_counts = ();
    my @g_ids = keys %{$rh_humref_genes};
    for (1..$ITERATIONS) {
        my @shuffled = shuffle(@g_ids);
        my %rand_ids = ();
        for (my $i = 0; $i < scalar(keys %{$rh_ids}); $i++) {
            $rand_ids{$shuffled[$i]}++; 
        }
        my $rh_rhits = get_hits(\%rand_ids,$rh_bgdat,$rh_gene);
        push @rand_counts, scalar(keys %{$rh_rhits});
    }
    return \@rand_counts;
}

sub _get_humref_genes {
    my $rh_g = shift;
    my $hr = shift;
    my %hr_genes = ();
    open IN, $hr or die "cannot open $hr:$!";
    while (my $line = <IN>) {
        chomp $line;
        next unless ($line =~ m/^>/);
        #fix messed up line in HumRef2015
        $line = '>FOXO6 NP_001278210.1' if ($line =~ m/^> NP_001278210.1/);
        $line =~ m/>(\S+)\s/ or die "unexpected: $line";
        $hr_genes{$1}++ if ($rh_g->{$1});
    }
    return \%hr_genes;
}

sub fix_changed_names {
    my $rh_ids = shift;
    my @add = qw(PRUNE1 FAM234B CRAMP1);
    my @del = qw(PRUNE KIAA1467 CRAMP1L LOC105375007);
    foreach my $de (@del) {
        delete $rh_ids->{$de};
    }
    foreach my $ad (@add) {
        $rh_ids->{$ad}++;
    }
}

sub get_hits {
    my $rh_ids = shift;
    my $rh_bg  = shift;
    my $rh_g   = shift;
    my %hits   = ();
    foreach my $id (keys %{$rh_ids}) {
        my $gid = $rh_g->{$id};
        die "unexpected: no such id $id" unless ($gid);
        next unless ($rh_bg->{$gid});
        foreach my $jd (keys %{$rh_ids}) {
            next if ($id eq $jd);
            if ($rh_bg->{$gid}->{$rh_g->{$jd}}) {
                my $name = _sort_2names($id,$jd);
                $hits{$name}++;
            }
        }
    }
    return \%hits;
}

sub _sort_2names {
    my $one = shift;
    my $two = shift;
    my @sorted = sort($one,$two);
    return "$sorted[0]_$sorted[1]";
}

sub get_gene_dat {
    my $file = shift;
    my %dat  = ();
    open IN, $file or die "cannot open $file:$!";
    while (my $line = <IN>) {
        my @f = split /\t/, $line;
        $dat{$f[2]} = $f[1];
    }
    return \%dat;
}

sub get_bg_dat {
    my $file = shift;
    my %dat = ();
    open IN, $file or die "cannot open $file:$!";
    while (my $line = <IN>) {
        chomp $line;
        my @f = split /\t/, $line;
        # only consider physical interactions
        next unless ($f[11] eq 'Affinity Capture-Luminescence' ||
                     $f[11] eq 'Affinity Capture-MS' ||
                     $f[11] eq 'Affinity Capture-RNA' ||
                     $f[11] eq 'Affinity Capture-Western' ||
                     $f[11] eq 'Biochemical Activity' ||
                     $f[11] eq 'Co-crystal Structure' ||
                     $f[11] eq 'Co-fractionation' ||
                     $f[11] eq 'Co-localization' ||
                     $f[11] eq 'Co-purification' ||
                     $f[11] eq 'FRET' ||
                     $f[11] eq 'Far Western' ||
                     $f[11] eq 'PCA' ||
                     $f[11] eq 'Protein-RNA' ||
                     $f[11] eq 'Protein-peptide' ||
                     $f[11] eq 'Proximity Label-MS' ||
                     $f[11] eq 'Reconstituted Complex' ||
                     $f[11] eq 'Two-hybrid');
        $dat{$f[1]}->{$f[2]}++;
        $dat{$f[2]}->{$f[1]}++;
    }
    return \%dat;
}

sub get_ids {
    my $file = shift;
    my %ids = ();
    open IN, $file or die "cannot open $file:$!";
    while (my $line = <IN>) {
        next if ($line =~ m/^\s*$/);
        chomp $line;
        $ids{$line}++;
    }
    return \%ids;
}
