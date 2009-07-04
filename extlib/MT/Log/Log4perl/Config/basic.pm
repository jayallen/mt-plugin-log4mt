package MT::Log::Log4perl::Config::basic;

sub load {
    my ($self, $args) = @_;
    return {
        'log4perl.logger'             => "DEBUG, Screen", # TODO Change to warn
        'log4perl.appender.Screen'        => 'Log::Log4perl::Appender::Screen',
        'log4perl.appender.Screen.stderr' => 1,
        'log4perl.appender.Screen.layout.ConversionPattern' => '%p> %c | %m%n',
        'log4perl.appender.Screen.layout'
                                    => 'Log::Log4perl::Layout::PatternLayout',
    };
}

1;

