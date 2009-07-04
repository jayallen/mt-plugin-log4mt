package MT::Log::Log4perl::Config::mtconfig;
use Log::Log4perl::Config::BaseConfigurator;
use base qw(Log::Log4perl::Config::BaseConfigurator);

sub load {
    my ($self, $args) = shift;
    use MT;
    my $config_source = MT->config('log4mtconfig');
    my $data = '';
    return $data;
}

1;
