package MT::Log::Log4perl::Logger;
use strict; use warnings; use Data::Dumper;

use MT::Log::Log4perl::BaseLogger;
use base qw(MT::Log::Log4perl::BaseLogger);
use Log::Log4perl qw(:levels :resurrect );
use MT::Log::Log4perl::Util qw( err emergency_log trace );

use vars qw($trace_wrapper $logger_methods_installed);

sub init {
    my $self = shift;
    my $args = shift;
    trace();
    $self->SUPER::init(@_);
    $self->init_logger($args->{category});
}

sub init_logger {
    my $self = shift;
    my $cat = shift;
    trace();
    err(sprintf "init_logger being called from %s "
        ."with category %s\n", (caller(1))[3], ($cat||'NULL'));
    eval {
        $Log::Log4perl::caller_depth++;
        $self->{logger} = Log::Log4perl::get_logger($cat) or die;
        $Log::Log4perl::caller_depth--;
        $self->{logger} or die;
    };
    if ($@) {
        die "Could not get logger from Log::Log4perl: $@";
    }
    else {
        init_handlers();
    }

    $self->{logger};
}

sub init_handlers {
    return if $logger_methods_installed;
    trace();

    no warnings qw(redefine);
    require Log::Log4perl::Logger;
    $trace_wrapper = \&Log::Log4perl::Logger::trace;
    *Log::Log4perl::Logger::trace = 
        sub {
            my $self = shift;
            my @messages = @_;
            $messages[0] = ' ' if !defined $messages[0] or $messages[0] eq '';
            $Log::Log4perl::caller_depth += 1;
            $trace_wrapper->($self, @messages);
            $Log::Log4perl::caller_depth -= 1;
        };
    
    # Install WARN and DIE signal handlers
    my $prevwarn = ref($SIG{__WARN__}) ? $SIG{__WARN__} : sub { };
    $SIG{__WARN__} = sub {
        $prevwarn->(@_);
        $Log::Log4perl::caller_depth++;
        my $l = Log::Log4perl->get_logger("");
        $l->warn(@_);
        $Log::Log4perl::caller_depth--;
    };

    # my $prevdie = ref($SIG{__DIE__}) ? $SIG{__DIE__} : sub { };
    # $SIG{__DIE__} = sub {
    #     # __DIE__ is called by eval blocks too 
    #     # which don't need to be logged.
    #     if (defined $^S and ! $^S) {
    #         $Log::Log4perl::caller_depth++;
    #         my $l = Log::Log4perl->get_logger(""); # Root logger
    #         print STDERR 'Fatal error caught by Log4perl: '.$_[0]."\n";
    #         $l->fatal(@_);            
    #     }
    #     $prevdie->(@_);
    #     die @_; # NOW die...
    # };

    $logger_methods_installed++;
}
1;
__END__

LATEST CODE

# foreach my $name (@levels) {
#     no strict 'refs';
# 
#     my $localname = __PACKAGE__."::$name";
#     err("Creating anonymous sub $localname");
#     *{$localname} = sub {
#         my ( $self, @messages ) = @_;
#         err('Self: '.ref($self));
#         err("In $name with ".Dumper(\@messages));
#         return unless &{"is_$name"}($self);
#         err("Logging at level $name is enabled");
#         $Log::Log4perl::caller_depth++;
#         my $level = uc($name); $level = $$level;
#         my $rc = eval { $self->log( $level, @messages ) };
#         # Log::Log4perl::Logger::log( $self, $level, @messages );
#         $Log::Log4perl::caller_depth--;
#         return $@ ? emergency_log('Error calling %s(): ', $name, $@)
#                   : $rc;
#     };
# 
#     $localname = __PACKAGE__."::is_$name";
#     err("Creating anonymous sub $localname");
#     *{$localname} = sub {
#         my ( $self ) = @_;
#         # err('In is_'.$name);
#         # my ( $package, $filename, $line ) = caller;
#         # my $logger = $self->get_logger($package);
#         err(sprintf "Checking on %s in package %s", "is_" . $name, ref($self->{logger}));
#         my $rc;
#         eval { 
#             my $fn = $self->{logger}->can("is_" . $name);
#             $fn or die "Logger can't do is_$name";
#             $rc = $fn->();
#         };
#         return $@ ? emergency_log('Error calling is_%s(): ', $name, $@)
#                   : $rc;
#     };
# }
# 
# foreach my $meth (@methods) {
#     no strict 'refs';
#     my $localname = __PACKAGE__."::$meth";
#     err("Creating anonymous sub $localname");
#     *{$localname} = sub {
#         my ( $self ) = @_;
#         my $rc = eval { $self->$meth(@_) };
#         return $@ ? emergency_log('Error calling %s(): ', $meth, $@)
#                   : $rc;
#     };
# 
# }


OLDER CODE


# sub init {
#     printf STDERR "In %s::init with: %s", __PACKAGE__, Dumper(\@_);
#     my $self = shift;
#     my $args = shift || {};
#     my $class = ref($self);
# 
#     $self->SUPER::init($args);
#     return $self;
# }

# sub mk_methods {
#     my $self = shift;
#     my $args = shift;
#     my $class = ref($self);
# 
#     no strict 'refs';
# 
#     # $self->SUPER::mk_methods($args);
# 
#     print STDERR "Creating methods for $class object\n";
# 
#     # *{$class.'::'.$meth} = sub { $self->passthru(@_); };
#     # *{$class.'::'.$variant} = sub { $self->passthru(@_); };
# 
#     foreach my $base ($class->levels()) {
#         foreach my $getset ($base, "is_$base") {            
#             foreach my $method ($getset, uc($getset)) {
#                 print STDERR "------> LEVEL: $method\n";
#                 # push(@accessors, $method)
#             }
#         }
#     }
#     foreach my $method ($class->methods()) {
#         # print STDERR "------->METHOD: $meth\n";
#         # push(@accessors, $method)
#     }
#     __PACKAGE__->mk_accessors(@accessors);
#     
#     $self->debug('Helllllo!');
# }

# $log = Log::Log4perl->get_logger($module_name);


# my @levels = qw[ debug info warn error fatal ];    
# 
#     my @levels = qw[ debug info warn error fatal ];
#     my @methods = qw(error_die   logcroak      get_level 
#                      error_warn  logcluck      dec_level
#                      logcarp     logconfess    inc_level
#                      logdie      add_appender  less_logging
#                      logwarn     additivity    more_logging  );

#     is_trace
#     # Need to trap all possible calls here.  
#     # Probably should use AUTOLOAD, maybe
#     # logger methods
#     #  foo get_logger  indent marker remove_appender  level log 
#     foreach (@levels) {
#         *{__PACKAGE__.'::'.uc($_)} = sub { };       # Scalar variables
#         *{__PACKAGE__.'::'.lc($_)} = sub { };       # Name subroutines LEVEL
#         *{__PACKAGE__.'::is_'.lc($_)} = sub { };    # Name subroutines is_LEVEL
#     }
# 
# my @levels = qw[ debug info warn error fatal ];    
# for ( my $i = 0; $i < @levels; $i++ ) {
#     my $name  = $levels[$i];
#     my $level = 1 << $i;
#     err("Creating anonymous sub for $name and is_$name");
#     no strict 'refs';
# 
#     *{$name} = sub {
#         my ( $self, @messages ) = @_;
#         err("In $name with ".Dumper(\@messages));
#         return unless &{"is_$name"}($self);
#         $Log::Log4perl::caller_depth++;
#         my $level = uc($name); $level = $$level;
#         my $rc = eval { $self->log( $level, @messages ) };
#         # Log::Log4perl::Logger::log( $self, $level, @messages );
#         $Log::Log4perl::caller_depth--;
#         return $@ ? emergency_log('Error calling %s(): ', $name, $@)
#                   : $rc;
#     };
# 
#     *{"is_$name"} = sub {
#         my ( $self ) = @_;
#         # err('In is_'.$name);
#         # my ( $package, $filename, $line ) = caller;
#         # my $logger = $self->get_logger($package);
#         my $func   = "SUPER::is_" . $name;
#         my $rc = eval { $self->$func() };
#         return $@ ? emergency_log('Error calling is_%s(): ', $name, $@)
#                   : $rc;
#     };
# }
# 
# $SIG{__DIE__} = sub {
#     # __DIE__ is called by eval blocks too 
#     # which don't need to be logged.
#     if (defined $^S and ! $^S) {
#         $Log::Log4perl::caller_depth++;
#         my $l = __PACKAGE__->get_logger(""); # Root logger
#         print STDERR 'Fatal error caught by Log4perl: '.$_[0];
#         $l->fatal(@_);            
#     }
#     die @_; # NOW die...
# };
# 
# 1;