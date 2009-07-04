### MT::Log::Log4Perl
# AUTHOR:   Jay Allen, Endevver Consulting
# See README.txt in this package for more details
# $Id: Log4perl.pm 803 2008-02-14 22:52:06Z jay $
package MT::Log::Log4perl;
use strict; use warnings; use Data::Dumper;
no warnings 'redefine';

our $VERSION = "1.2b2"; # $Revision: 803 $

use strict;
use base 'Exporter';
use vars qw( @EXPORT_OK );
@EXPORT_OK = qw( l4mtdump VERBOSE );

*l4mtdump = \&MT::Log::Log4perl::Util::l4mtdump;

sub VERBOSE() { 0 }

# The BEGIN block checks for all dependencies and, if not found, creates
# stubs of anonymous subroutines for all (or at least the most important
# for now) of the Log4perl functions used by MT modules and plugins
our ($HAS_L4P, $L4P_INIT_ERROR);
BEGIN { 
    no strict qw(refs);
    no warnings; 
    eval {
        foreach (qw( Log::Log4perl Params::Validate )) {;
            eval "require $_;";
            $@ and die $@;
        }
    }; 
    $L4P_INIT_ERROR = $@;
} 
if ($L4P_INIT_ERROR) {
    require MT::Log::Log4perl::Util;
    MT::Log::Log4perl::Util::emergency_log(
        "Log::Log4perl logging could not be initialized: $L4P_INIT_ERROR");
}
else { $HAS_L4P = 1 }

sub new {
    my $class = shift;
    my $category = shift;
    @_ and die sprintf("Unhandled arguments in %s: %s",
                        (caller(0))[3], YAML::Dump(\@_));
    my $self = {};
    bless $self, $class;
    my $logger = $self->init($category || ((caller)[0]));
    $logger;
}

sub init {
    my $self     = shift;
    my $category = shift;
    if ($HAS_L4P and ! $Log::Log4perl::Logger::INITIALIZED) {
        require MT::Log::Log4perl::Config;
        if (MT::Log::Log4perl::Config->new(@_)) {
            $Log::Log4perl::Logger::INITIALIZED = 1;
        }
        else { $HAS_L4P = 0 }
    }
    require MT::Log::Log4perl::BaseLogger;
    MT::Log::Log4perl::BaseLogger->new({initialized => $HAS_L4P, 
                                        category => $category});
}

1;
