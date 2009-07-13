package MT::Log::Log4perl::Util;
# $Id: Util.pm 804 2008-02-14 22:56:05Z jay $
use strict; use warnings; use Data::Dumper;

use strict;

# use Exporter;
# @MT::Log::Log4perl::Util::ISA = qw( Exporter );
use base 'Exporter';
use vars qw( @EXPORT_OK );
@EXPORT_OK = qw( indent makedef err emergency_log l4mtdump trace );

use File::Spec;
use Carp;
use YAML;

sub indent { return (' 'x5).$_[1] }

sub makedef { return (map { defined $_ ? $_ : '' } @_); }

our $debugging;

sub err {
    MT::Log::Log4perl::VERBOSE() or return;

    # my $debugout = sub {
    #     printf STDERR "$_[0]>>> %-40s %-40s %s\n",
    #         "Pkg: $_[1]", "Function: $_[2]", "Line: $_[3]";
    # };

    ############ CALLER RETURN VALUES #############
    # $pkg,     $file,      $line,     $subroutine,
    # $hasargs, $wantarray, $evaltext, $is_require,
    # $hints,   $bitmask,   $hinthash
    my @caller = caller(1);
    my ($pkg, $line, $fn) = map { defined $_ ? $_ : '' } @caller[0,2,3];

    # return unless '(eval)' eq $fn;

    # For any call from an exported method, the pkg and line point
    # to the origin of the call but we need to go back one more
    # frame to get the function
    my $was_trace = 0;
    if ( __PACKAGE__.'::trace' eq ( $fn || '') ) {
        # $debugout->(1, $pkg, $fn, $line);
        $fn = (caller(2))[3];
        $was_trace = 1;
    }

    # $debugout->(2, $pkg, $fn, $line);
    if ( $fn =~ m{^${pkg}\Q::\E([^:]+)$}) {
        $fn = $1;
    }
    elsif ( $fn =~ m{(.*?)(::)?([^:]+)$} ) {
        $pkg = $1 || $pkg;
        $fn = $3;
    }
    # $debugout->(3, $pkg, $fn, $line);

    printf STDERR
        $was_trace ? ("  * %s\n", join(' ',@_))
                   : ("  * %-30s %-10s %s\n", $pkg,$fn,join(' ',@_)); 
}

my $banner = '---------------------';
sub trace {
    err( join ' ', $banner, (caller(1))[3], $banner );
    err($_) foreach @_;
}

sub emergency_log {
    my (@messages) = @_;
    my $pretext = 'Error in MT::Log::Log4perl: ';
    my $err = $pretext.sprintf(shift @messages, @messages);
    print STDERR $err, "\n";
    if (eval "require MT;") {
        require MT::Log;
        MT->log({
            message => $err,
            level => MT::Log::ERROR(),
            class => 'log',
            category => 'logging',
        });
    } elsif ($@) { print STDERR $pretext.$@ }
    return undef;
}

# Usage:
#  $logger->debug('VAR: ', l4mtdump(\reference));
sub l4mtdump { 
    my $filter = \&Data::Dumper::Dumper;
    my $ref;
    if (@_ > 1) {
        # print STDERR  'Multiple arguments (array/hash), '
        #                ."Converting to array ref\n";
        my @tmp = map { \$_ } @_;
        $ref = \@tmp;
    }
    elsif ( ref($_[0]) ) {
        # printf STDERR "Found reference. Ref: %s\n", ref($_[0]);
        $ref = shift;
    }

    return $ref ? { value => $ref, filter => $filter }
                : shift;
}

1;