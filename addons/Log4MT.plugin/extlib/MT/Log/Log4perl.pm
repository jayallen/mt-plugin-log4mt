### MT::Log::Log4Perl
# AUTHOR:   Jay Allen, Endevver Consulting
# See README.txt in this package for more details
# $Id: Log4perl.pm 803 2008-02-14 22:52:06Z jay $
package MT::Log::Log4perl;
use strict; use warnings; use Data::Dumper;
no warnings 'redefine';

our $VERSION = "1.7"; # $Revision: 803 $

use strict;
use base 'Exporter';
use vars qw( @EXPORT_OK %EXPORT_TAGS );
@EXPORT_OK = qw( l4mtdump VERBOSE );
# %EXPORT_TAGS = qw( :resurrect );

use MT::Log::Log4perl::Util qw( err trace emergency_log );

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
        foreach (qw( Log::Log4perl Params::Validate )) {
            eval "require $_;";
            $@ and die $@;
        }
    }; 
    $L4P_INIT_ERROR = $@;
} 
if ($L4P_INIT_ERROR) {
    emergency_log(
        "Log::Log4perl logging could not be initialized: $L4P_INIT_ERROR");
}
else {
    $HAS_L4P = 1;
    init_mt_log();
    err('Log::Log4perl is installed.');
}

=head 2 new

RIGHT WAYS to instantiate this module:
  Just a class name MT::Log->get_logger()     or MT::Log::Log4perl->new()
  Class and cat     MT::Log->get_logger($cat) or MT::Log::Log4perl->new($cat)
  Class and args    MT::Log->get_logger({})   or MT::Log::Log4perl->new({})

WRONG WAYS to instantiate this module:
  No args:     MT::Log::get_logger()        or MT::Log::Log4perl()
  Cat only:    MT::Log::get_logger($cat)    or MT::Log::Log4perl($cat)
  Args only:   MT::Log::get_logger({...})   or MT::Log::Log4perl({...})

FIXME: I should try to catch the last group and return an error


(/MT::Log(::Log4perl)?/)
(/MT::Log(::Log4perl)?/) CAT
(/MT::Log(::Log4perl)?/) ARGHASH
(bless MT::Log)
(bless MT::Log) CAT
(bless MT::Log) ARGHASH

=cut
sub new {
    my ($pkg, $args) = @_;
    my $caller       = caller;
    trace();

    if ( ! defined $args or ! ref($args) ) {
        $args = {   category => ( $args || $caller ),
                    caller   => $caller,
                };
    }
    $args->{l4mtdump} = 1 unless defined $args->{l4mtdump};
    
    my $self = {};
    bless $self, __PACKAGE__;

    return $self->init($args);
}

sub init {
    my $self = shift;
    my $args = shift;
    trace();
    err('Arguments to init(): ' .Dumper($args));
    err('$HAS_L4P: '            .$HAS_L4P);
    err('$Log::Log4perl::Logger::INITIALIZED: '
        . ($Log::Log4perl::Logger::INITIALIZED ? 1 : 0));

    # Install the l4mtdump helper method into the calling package 
    # unless we were asked specifically not to by the nice user
    install_l4mtdump( $args->{caller} ) unless $args->{l4mtdump} == '0';

    if ($HAS_L4P and ! $Log::Log4perl::Logger::INITIALIZED) {
        err('Starting the configuration process.');
        require MT::Log::Log4perl::Config;
        if ( MT::Log::Log4perl::Config->new( $args ) ) {
            $Log::Log4perl::Logger::INITIALIZED = 1;
        }
        else { $HAS_L4P = 0 }
    }
    $args->{initialized} = $HAS_L4P;

    require MT::Log::Log4perl::BaseLogger;
    return MT::Log::Log4perl::BaseLogger->new($args);
}

sub init_mt_log {
    require MT;
    my $log_class = MT->model('log') || 'MT::Log';
    eval "require $log_class;";
    return if $log_class->can('get_logger');
    require Sub::Install;
    Sub::Install::reinstall_sub({
        code => \&MT::Log::Log4perl::new,
        into => $log_class,
        as   => 'get_logger',
    });
}

sub install_l4mtdump {
    shift if $_[0] eq __PACKAGE__ or ref($_[0]) eq __PACKAGE__;
    my $pkg = shift || '';
    err('install_l4mtdump requested for: ' . $pkg);
    return if $pkg =~ m!^(\(eval\))?$!; # Empty string or (eval) go bye-bye
    
    eval "require $pkg;";
    if ($@) {
        err("Error requiring package $pkg: $@");
        return;
    }

    require Sub::Install;
    Sub::Install::reinstall_sub({
        # from => 'MT::Log::Log4perl::Util',
        code => 'l4mtdump',
        into => $pkg,
    });
}

# sub _get_logger {
#     shift if ($_[0]||'') eq 'MT::Log' or (ref($_[0])||'') eq 'MT::Log';
#     my $args = shift;
#     my $caller = ((caller)[0]);
#     if ( $caller and ! $caller->can('l4mtdump') ) {
#         require Sub::Install;
#         Sub::Install::install_sub({
#             code => 'l4mtdump',
#             into => $caller,
#         });
#     }
#     my $logger = __PACKAGE__->new(shift || $caller);
# }

1;
