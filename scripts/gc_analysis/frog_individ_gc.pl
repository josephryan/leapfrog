#!/usr/bin/perl

use strict;
use warnings;
use JFR::Fasta;
use Data::Dumper;

MAIN: {
    my $frogs = $ARGV[0] or die "usage: $0 FROGFILE FASTAFILE NAME\n";
    my $fa    = $ARGV[1] or die "usage: $0 FROGFILE FASTAFILE NAME\n";
    my $name  = $ARGV[2] or die "usage: $0 FROGFILE FASTAFILE NAME\n";

    my $rh_frogs = get_frogs($frogs);
    my $rh_gc = get_gc($fa);
    print_gc_and_stretch($rh_gc,$rh_frogs,$name);
}

sub print_gc_and_stretch {
    my $rh_gc = shift;
    my $rh_frogs = shift;
    my $name = shift;
    open FOUT, ">${name}.frog_gc" or die "cannot open >${name}.frog_gc:$!";
    open AOUT, ">${name}.all_gc" or die "cannot open >${name}.all_gc:$!";
    foreach my $key (keys %{$rh_gc}) {
        my @stretches = ();
        foreach my $stretch (@{$rh_gc->{$key}->[2]}) {
            push @stretches, $stretch;
        }
        my $avg_gc = $rh_gc->{$key}->[0] / $rh_gc->{$key}->[1];
        my $avg_stretch = get_avg(\@stretches);
        if ($rh_frogs->{$key}) {
            print FOUT "$avg_gc\t$avg_stretch\n";
        } else {
            print AOUT "$avg_gc\t$avg_stretch\n";
        }
    }
}

sub get_avg {
    my $ra_vals = shift;
    return 0 unless ($ra_vals->[0]);
    my $sum = 0;
    my $count = 0;
    foreach my $val (@{$ra_vals}) {
        $count++;
        $sum += $val;
    }
    my $avg = $sum/$count;
    return $avg;
}

sub get_gc {
    my $file = shift;
    my %gc   = ();
    my $fp  = JFR::Fasta->new($file);
    while (my $rec = $fp->get_record()) {
        my $id = JFR::Fasta->get_def_w_o_gt($rec->{'def'});
        $id =~ m/^(\S+)/ or die "unexpected defline";
        $id = $1;
        my @nts = split /|/, $rec->{'seq'};
        my @stretches = ();
        my $total_count = 0;
        my $gc_count = 0;
        my $last_gc = 0;
        foreach my $nt (@nts) {
            $total_count++;
            if ($nt =~ m/[GgCc]/) {
               $gc_count++;
               $last_gc++;
            } else {
               next unless ($last_gc);
               push @stretches, $last_gc if ($last_gc >= 3);
               $last_gc = 0;
            }
        }
        push @stretches, $last_gc if ($last_gc >= 3);
        $gc{$id} = [$gc_count,$total_count,\@stretches];
    }
    return \%gc;
}

sub get_frogs {
    my $file = shift;
    my %frogs = ();
    open IN, $file or die "cannot open $file:$!";
    my $first_line = <IN>;  # ignore header
    while (my $line = <IN>) {
        my @f = split /\t/, $line;
        $frogs{$f[2]}++;
    }
    return \%frogs;
}

