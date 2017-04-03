#!/usr/bin/perl

use strict;
use warnings;
use JFR::Fasta;
use Data::Dumper;

our $FA = 'fasta.txt';
our $LE = 'leap.txt';

MAIN: {
    my $ra_frog_files = get_file_list($LE);
    my $ra_fa_files   = get_file_list($FA);
    for (my $i = 0; $i < @{$ra_fa_files}; $i++) {
        my $rh_frogs = get_frog_ids($ra_frog_files->[$i]);    
        my $rh_fasta = get_fasta($ra_fa_files->[$i]);    
        my $rh_stats = get_stats($rh_fasta,$rh_frogs);
        my $f_a = $rh_stats->{'frog'}->{'len'} / $rh_stats->{'frog'}->{'count'};
        my $nf_a = $rh_stats->{'nf'}->{'len'} / $rh_stats->{'nf'}->{'count'};
        my @f1 = split /\//, $ra_frog_files->[$i];
        my @f2 = split /\//, $ra_fa_files->[$i];
        print "$f1[-1]\t$f2[-1]\t$rh_stats->{'frog'}->{'count'}\t";
        print "$rh_stats->{'frog'}->{'len'}\t$f_a\t";
        print "$rh_stats->{'nf'}->{'count'}\t";
        print "$rh_stats->{'nf'}->{'len'}\t$nf_a\n";
    }
}

sub get_stats {
    my $rh_fa = shift;
    my $rh_frogs = shift;
    my %stats = ();
    foreach my $def (keys %{$rh_fa}) {
        $def =~ m/^>(\S+)/;
        my $key = $1;
        if ($rh_frogs->{$key}) {
            $stats{'frog'}->{'count'}++;
            $stats{'frog'}->{'len'} += length($rh_fa->{$def});
        } else {
            $stats{'nf'}->{'count'}++;
            $stats{'nf'}->{'len'} += length($rh_fa->{$def});
        }
    }
    return \%stats;
}

sub get_fasta {
    my $file = shift;
    my %fa = ();
    my $fp = JFR::Fasta->new($file);
    while (my $rec = $fp->get_record()) {
        $fa{$rec->{'def'}} = $rec->{'seq'};
    }
    return \%fa;
}

sub get_file_list {
    my $f = shift;
    my @files = ();
    open IN, $f or die "cannot open $f:$!";
    while (my $line = <IN>) {
        chomp $line;
        next if ($line =~ m/^\s*$/);
        push @files, $line;
    }
    return \@files;
}

sub get_frog_ids {
    my $file = shift;
    my %ids = ();
    open IN, $file or die "cannot open $file:$!";
    while (my $line = <IN>) {
        next if ($line =~ m/^Query\t/);
        chomp $line;
        my @f = split /\t/, $line;
        $ids{$f[2]}++;
    }
    return \%ids;
}
