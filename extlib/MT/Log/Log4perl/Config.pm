package MT::Log::Log4perl::Config;
# $Id: Config.pm 804 2008-02-14 22:56:05Z jay $

use strict; use warnings; use Data::Dumper;

use MT::Log::Log4perl::Util qw( err emergency_log );

our $INITIALIZED;
sub initialized {
    $_[0]->{initialized} = $INITIALIZED = $_[1];
}

sub new {
    my $class = shift;
    err((caller(0))[3]);
    my $self = bless {}, $class;
    $self->init(@_);
    $self;
}

sub init {
    my ($self, $args) = @_;
    err((caller(0))[3]);

    my ($config, $config_response, $class, @eval_msgs);
    foreach my $type (qw(file mtconfig webui basic)) {
        eval {
            $config = '';
            $class = "MT::Log::Log4perl::Config::$type";
            push @eval_msgs, "Trying $class configuration";
            eval "require $class;";
            if ($config = $class->load($args)) {
                push @eval_msgs, "CONFIG: $config";
                require Log::Log4perl::Config;
                Log::Log4perl::Config->init($config)
                    or die "Configuration rejected by Log::Log4perl";
            }
        };
        err($_) foreach @eval_msgs;
        if ($@) { warn "Warning: $@" and next; } else { $config_response++ }                
        last if $config_response;
    }
    err("Config class being used: $class") if $config_response;
    err("\$config_response = $config_response");
    return $config_response ? $self : undef;
    # return $self if $self->initialized;
    
    # First look for a config_file argument, then a config
    if (   $self->config_file($args->{config_file})
        or $self->config_data($args->{config})) {
        $self->initialized(1);
    }
}

sub config_file {
    my ($self, $file) = @_;
    err((caller(0))[3]);

    # Return previously defined config file if the caller is asking for it
    return $self->{_config_file} if ! defined $file or $file eq '';

    my $cfg;

    # Prepend the MT config directory if relative path
    if (substr($file, 0, 1) ne '/') {
        require File::Spec;
        $file = File::Spec->catfile($self->mt_cfg_dir, $file);
    }
    # Check file and send to Log::Log4perl::Config if valid
    if ($file = can_read_file($file)) {
        # Eval the procedure to catch any errors locally
        local $@;
        eval {  die 'No valid config file found' unless defined $file;
                require Log::Log4perl::Config;
                Log::Log4perl::Config->init_and_watch($file);
                1;
            };
        # In case of error, log and return
        if ($@) {
            emergency_log("Error loading config file: $@");
            return undef;
        }
    }
    # Config file loaded successfully. Set the attribute
    $self->{_config_file} = $file;
}

sub config_data {
    my $self = shift;
    my $data = (@_ > 1) ? { @_ } : shift;
    err((caller(0))[3]);

    if (! defined $data) {
        # Return previously defined config file if
        # the caller is asking for it
        return $self->{_config} if $self->{_config};

        # No data previously defined or passed in.
        # Fall back to basics.
        $data = $self->basic_config;
    }

    $data = \$data unless ref($data);

    # Eval the procedure to catch any errors locally
    local $@;
    eval {  die 'No valid config data found' unless defined $data;
            require Log::Log4perl::Config;
            Log::Log4perl::Config->init($data);
            1;
        };
    # In case of error, log and return
    if ($@) {
        emergency_log("Error loading config data: $@");
        return undef;
    }
    $self->{_config} = $data;
}

sub mt_cfg_dir {
    eval "require MT;";
    return if $@;

    my $mt = MT->instance;
    if (! $mt) {
        emergency_log('Could not retrieve MT or MT app instance: '.MT->errstr);
        return;
    }

    my $cfg_dir;
    foreach ($mt->config_dir, $mt->mt_dir, $ENV{MT_HOME}) {
        $cfg_dir = can_read_dir($_);
        last if $cfg_dir;
    }
    $cfg_dir;
}

sub can_read_file { _can_read('f', @_) }
sub can_read_dir  { _can_read('d', @_) }
sub _can_read   { 
    shift if ref($_[0]);
    my ($type, $item) = @_;
    return unless defined $item and defined $type;
    my $is_type = ($type eq 'd' and -d $item) ? 1
                : ($type eq 'f' and -f $item) ? 1
                                              : 0;
    return $item if $is_type and -r $item;
}


1;

__END__

# sub _config {
#     return unless $HAS_L4P;
#     my $self = shift;
#     my $args = shift || {};
# 
#     my $config;
#     if (my $cfg_data = $args->{config}) {
#         $cfg_data = \$cfg_data
#             unless ((ref($cfg_data) || '') =~ m!(SCALAR|HASH)!);
#         $config = $cfg_data;
#         if ($config) { VERBOSE and err "CONFIG CODE GIVEN"; }
#     }
#     elsif ( ($args->{config_file}||'') =~ m!^/! ) {
#         $config = $args->{config_file} if can_read_file($args->{config_file});
#         if ($config) { VERBOSE and err "VALID CONFIG FILE GIVEN\n" }
#     }
# 
#     if (!$config) {
#         my $cfg_dir = $self->_get_config_dir() || '';
#         VERBOSE and err "CFG_DIR: $cfg_dir";
#         require File::Spec;
#         VERBOSE and err "Looking at files:";
#         foreach (($args->{config_file} || ''), 'log4perl.conf') {
#             VERBOSE and err "\n\t* $_ ";
#             my $test = File::Spec->catfile($cfg_dir, $_);
#             VERBOSE and err "\n\t\t * Coverted to $test";
#             next unless $_ and _can_read_file($test);
#             VERBOSE and err "\n\t * THIS IS OUR FILE!";
#             $config = $test;
#             last;
#         }
#         if ($config) {
#             VERBOSE and err "\nFound config file and loaded: $config";
#         }
#     }
#     return $config;
# }




# my $cfg_ok;
# my $errmsg = 'Error initializing Log::Log4perl using %s: %s';
# 
# if ($config) {
#     my $msg = 'Config exists, loading...';
#     if ( ref($config) ) {
#         VERBOSE and err $msg, " with init()";
#         $cfg_ok = eval { Log::Log4perl::Config->init($config); 1 };
#         if (! $cfg_ok or $@) {
#             $cfg_ok = 0;
#             emergency_log($errmsg, 'init()', $@); }
#     } else {
#         VERBOSE and err $msg, " with init_and_watch()";
#         $cfg_ok = eval {Log::Log4perl::Config->init_and_watch($config);1};
#         if (! $cfg_ok or $@) {
#             $cfg_ok = 0;
#             emergency_log($errmsg, 'init_and_watch()', $@);
#         }
#     }
# }
# 
# if (! ($config && $cfg_ok)) {
#     if (defined $config and defined $cfg_ok) {
#         print STDERR 'Attempting to initialize Log::Log4perl '
#                     ."with basic config.\n";
#     }
#     # my $msg = 'No config file... Using the default config';
#     # err($msg, Dumper(basic_config()));
#     $cfg_ok = eval { Log::Log4perl::Config->init(basic_config()) };
#     if (! $cfg_ok or $@) {
#         return emergency_log($errmsg, 'init_and_watch()', $@);
#     }
#     if (defined $config and defined $cfg_ok) {
#         print STDERR "Running Log::Log4perl with basic config.\n";
#     }
# }
