package MT::Log::Log4perl::Util;
# $Id: Util.pm 804 2008-02-14 22:56:05Z jay $
use strict; use warnings; use Data::Dumper;

use strict;

# use Exporter;
# @MT::Log::Log4perl::Util::ISA = qw( Exporter );
use base 'Exporter';
use vars qw( @EXPORT_OK );
@EXPORT_OK = qw( indent makedef err emergency_log l4mtdump );

use File::Spec;
use Carp;

sub indent { return (' 'x5).$_[1] }

sub makedef { return (map { defined $_ ? $_ : '' } @_); }

our $debugging;

sub err {
    require MT::Log::Log4perl;
    return unless MT::Log::Log4perl::VERBOSE;
    my $fn = '';
    my $pkg = caller;
    if (my $caller = (caller(1))[3]) {
        $caller =~ m!(?:.*::)?(.*)!;
        $fn = $1;
    }
    printf STDERR "  * %-10s %-10s %s\n", $pkg, $fn, join(' ',@_); 
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
        # print STDERR "Multiple arguments (array/hash), Converting to array ref\n";
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