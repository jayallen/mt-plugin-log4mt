package MT::Log::Log4perl::Config::file;
use Log::Log4perl::Config::BaseConfigurator;
use base qw(Log::Log4perl::Config::BaseConfigurator);

sub load {
    my ($self, $args) = shift;
    use MT;
    my $config_source = MT->config('log4mtconfig');
    warn "No Log4MT config file specified" unless $config_source;
    if ($config_source and ! -e $config_source) {
        if ($config_source !~ m{[\\/]}) {
            $config_source = "$ENV{MT_HOME}/$config_source";
        }
    }

    return $config_source if -e $config_source;

    warn "Could not locate log4mt configuration file: $config_source";
    return undef;        
}

1;
