package MT::Log::Log4perl::BaseLogger;
use strict; use warnings; use Data::Dumper;

use Carp;
use Log::Log4perl;
use MT::Log::Log4perl::Util qw( err emergency_log  );

our @levels = qw[ trace debug info warn error fatal ];    

our @methods = qw(error_die   logcroak      get_level     
                  error_warn  logcluck      dec_level
                  logcarp     logconfess    inc_level
                  logdie      add_appender  less_logging
                  logwarn     additivity    more_logging  );

my $methods_installed;

sub new {
    my $class = shift;
    my $args = shift;
    MT::Log::Log4perl::Util::trace();
    err('Arguments: '.Dumper({class => $class, args => $args}));
    
    if ($args->{initialized} and $class ne 'MT::Log::Log4perl::Logger') {
        require MT::Log::Log4perl::Logger;
        $class = 'MT::Log::Log4perl::Logger';
    }
    err("Created new $class logger\n");
    my $self = bless {}, $class;
    $self->init($args);
    # err(Dumper($self)."\n");
    # $self;
}


sub init {
    my $self = shift;
    MT::Log::Log4perl::Util::trace();

    unless ( $methods_installed++ ) {
        foreach my $name (@methods, level_variants(@levels)) {
            err("Creating anonymous sub stub for $name");
            no strict 'refs';
            # TODO Check that these work properly
            if ($name =~ /((?<=.)warn)/) {
                *{$name} = sub {  warn @_; };
            }
            elsif ($name =~ /die/) {
                 *{$name} = sub {  die @_; };
            }
            elsif ($name =~ /(confess|cluck|croak|carp)/) {
                 *{$name} = sub {  &{"Carp::".substr($name, 3)}(@_) };
            }
            else {
                *{$name} = sub { };        
            }
        }        
    }

    $self;
}

sub level_variants {
    my @variants;
    foreach my $base (@_) {
        # foreach my $case ($base, uc($base)) {
            foreach my $getset ($base, "is_$base") {            
                push(@variants, $getset)
            }
        # }
    }
    @variants;
}

sub init_logger { trace(); }

sub levels { @levels }
sub methods { @methods }


1;

__END__
# sub get { err((caller(0))[3]."\n");
# }
# sub set { err((caller(0))[3]."\n");
# } 
# sub marker { err((caller(0))[3]."\n");
# }
# *get = \&_getset;
# *set = \&_getset;
# 
# sub _getset {
#     printf STDERR 'In _getset with: %s'."\n", Dumper(\@_);
#     my ($obj, $field) = @_;
#     no strict 'refs';
#     my $logger = $obj->{logger};
#     print STDERR "Response from Log4perl: ".($logger->$field(@_)||'NONE');
#     
# }

# sub mk_methods {
#     my $self = shift;
#     my $args = shift;
#     my $class = ref($self);
# 
#     print STDERR "Creating methods for $class object\n";
# 
#     no strict 'refs';
#     foreach (qw(levels methods)) {        
#         *{$class.'::'.$_} = \&{"$_"};
#     }
# 
#     # Need to trap all possible calls here.  
#     # Probably should use AUTOLOAD, maybe
#     # logger methods
#     #  foo get_logger  indent marker remove_appender  level log 
#     foreach ($class->levels()) {
#         printf STDERR "\tLEVEL: %s\n", $_;
#         *{$class.'::'.$_}     = sub { $class->test(@_) };   # Name subroutines LEVEL
#         printf STDERR "\tLEVEL: is_%s\n", $_;               
#         *{$class.'::is_'.$_}  = sub { $class->test(@_) };   # Name subroutines is_LEVEL
#         printf STDERR "\tLEVEL: %s\n", uc($_);              
#         *{$class.'::'.uc($_)} = sub { $class->test(@_) };   # Scalar variables
#     }
#     foreach ($class->methods()) {
#         print STDERR "\tMETHOD: $_\n";
#         *{$class.'::'.$_} = $class::dead;       # Name subroutines LEVEL
#     }
# }

# sub dead { }
# 
# sub passthru {
#     print STDERR Dumper(\@_);
#     my ($obj, $field) = @_;
#     no strict 'refs';
#     $obj->{logger}->$field(@_);
# }
# 

# Assuming that the logger functions below are called from
# the subroutine CallerPackage::Method()
#       Function call                       Logger category
#       -------------                       ----------------
#       $logger->get_logger('yo')         = yo
#       $logger->get_logger(__PACKAGE__)  = CallerPackage
#       $logger->get_logger()             = CallerPackage.Method
#       $logger->get_logger('::yo')       = CallerPackage.Method::yo
#       $logger->get_logger('')           = root logger
# sub get_logger {
#     my $pkg      = shift;
#     my $category = shift;
#     my @args     = @_;
#     my $self     = ref($pkg) ? $pkg : $pkg->new;
# 
#     err "In get_logger";
# 
#     # If they don't have Log4perl installed,
#     # this is as far as we go
#     return $self unless $HAS_L4P;
#     
#     err sprintf "Pkg: %s, Category: %s",
#         (ref($pkg) ? ref($pkg) : $pkg),
#         ($category ? $category : 'NULL');
# 
#     # Determine the final category for the logger based on the arguments
#     # and the caller's package and method name.
#     my $caller = caller(2) ? (caller(2))[3] : (caller(1))[0];
# 
#     # my ($caller) = @{[caller(1)]} ? (caller(1))[3] : (caller(0))[0];
#     err "FINAL CALLER: $caller";
#     $category = (! defined $category) ? $caller
#               : ($category =~ m/^::/) ? (join '', $caller, $category)
#                                       : $category;
# 
#     # Where's that monkey?!
#     err("Requesting a logger of category ".$category);
#     require Log::Log4perl::Logger;
#     # ($class, $category, $level)
#     # $Log::Log4perl::caller_depth++;
#     # return Log::Log4perl::Logger->get_logger($category, @args);
#     return bless Log::Log4perl::Logger->get_logger($category, @args),
#         ref($self);
# }
# 
# {
#     my $marker_level;
#     sub marker_level {
#         return unless $HAS_L4P;
#         my $self = shift;
#         if ($_[0]) {
#             my $old_level = marker_level();
#             $marker_level = shift if $_[0];
#             return $old_level;
#         }
#         else {
#             $marker_level ||= $INFO;
#         }
#     }
# }
# 
# sub marker {
#     return unless $HAS_L4P;
#     my $self   = shift;
#     my $caller = caller(1) ? (caller(1))[3] : '';
#     my $prev   = caller(2) ? (caller(2))[3] : '';
#     my $trace  = $self->get_logger(join('::','trace',$caller))
#         or return print STDERR "Could not get trace logger";
#     $trace->debug(sprintf("[[ Caller: %s ]] %s", $prev, ($_[0]||'')));
# }
# 
# sub get_level {
#     return unless $HAS_L4P;
#     my ($self, $level) = @_;
#     no strict 'refs';
#     return $$level;
# }
# 
# 
# 1;