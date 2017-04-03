package JFR::Fasta;

use strict;
use FileHandle;
use IO::Uncompress::Gunzip qw($GunzipError);
use IO::Uncompress::Bunzip2 qw($Bunzip2Error);
use IO::Uncompress::Unzip qw($UnzipError);

# original code by Ken Trout and named NHGRI::FastaParser
$JFR::Fasta::AUTHOR  = 'Joseph Ryan';
$JFR::Fasta::VERSION = '1.04';

sub get_def_w_o_gt {
    my $self = shift;
    my $def = shift;
    $def =~ m/^>(.*)/;
    return $1;
}

sub get_record{
    my $self = shift;
    my @record_lines = ();

    return '' if (! $self->{'filehandle'} );

    my %h;
    my $seq  = '';
    my $line = '';

    my $fh = $ { $self->{'filehandle'} };

    while( $line = $fh->getline() ) {
	chomp $line;
	if ($line =~ m/^(>.+)/) {
            if ($seq) {
		$h{'def'}  = $self->{'stored_def'};
                $h{'seq'} = $seq;
                $self->{'stored_def'} = $1;   
                return \%h;
	    }
	    $self->{'stored_def'} = $1;   
	}   else {
            $seq .= $line;
        }
    }
    $h{'def'}  = $self->{'stored_def'};
    $h{'seq'} = $seq;
    undef $self->{'filehandle'};
    return \%h;
}

sub new {
    my $invocant = shift;
    my $file     = shift;
    my $fh       = {};

    if ($file =~ m/\.gz$/i) {
        $fh = IO::Uncompress::Gunzip->new($file)
            or die "IO::Uncompress::Gunzip of $file failed: $GunzipError\n";
    } elsif ($file =~ m/\.bz2$/i) {
        $fh = IO::Uncompress::Bunzip2->new($file)
            or die "IO::Uncompress::Bunzip2 of $file failed: $Bunzip2Error\n";
    } elsif ($file =~ m/\.zip$/i) {
        $fh = IO::Uncompress::Unzip->new($file)
            or die "IO::Uncompress::Unzip of $file failed: $UnzipError\n";
    } else {
        $fh = FileHandle->new($file,'r');
        die "cannot open $file: $!\n" unless(defined $fh);
    }
    my $class = ref($invocant) || $invocant;
    my $self = { 'filehandle'  => \$fh, 'stored_def' => '' };
    return bless $self, $class;
}

1;

__END__

=head1 NAME

JFR::Fasta - Perl extension for parsing FASTA files. 

=head1 SYNOPSIS

  use JFR::Fasta;

  my $fp = JFR::Fasta->new($fasta_file);

  while (my $rec = $fp->get_record()) {
      print "$rec->{'def'}\n";
      print "$rec->{'seq'}\n";
      my $id = JFR::Fasta->get_def_w_o_gt($rec->{'def'});
  }

=head1 DESCRIPTION

For each record in a FASTA file this module returns a hash that has the
defline and the sequence.

    $h->{'def'};
    $h->{'seq'};

    get_def_w_o_gt - returns $h->{'def'} without the leading '>'

=head1 GZIPPED FASTA FILES

As of version 1.01 JFR::Fasta can handle gzipped FASTA files if they have
a .gz suffix

=head1 AUTHOR

Joseph Ryan <josephryan@yahoo.com>

originally by Ken Trout <troutk@nhgri.nih.gov>

=head1 SEE ALSO

L<JFR::GFF3> - parse GFF3 files

L<JFR::Translate> - Translate DNA and RNA sequences

=cut
