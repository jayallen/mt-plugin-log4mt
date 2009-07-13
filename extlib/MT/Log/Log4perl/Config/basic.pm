package MT::Log::Log4perl::Config::basic;

*load = *append_stderr;

sub append_stderr {{
  'log4perl.category.Bar.Twix'      => 'DEBUG, Screen',
  'log4perl.appender.Screen'        => 'Log::Log4perl::Appender::Screen',
  'log4perl.appender.Screen.stderr' => 1,
  'log4perl.appender.Screen.layout' => 'Log::Log4perl::Layout::PatternLayout',
  'log4perl.appender.Screen.layout.ConversionPattern' => '%p> %c | %m%n',
}}

sub append_stdout {{
  'log4perl.category.Bar.Twix'      => 'DEBUG, Screen',
  'log4perl.appender.Screen'        => 'Log::Log4perl::Appender::Screen',
  'log4perl.appender.Screen.stderr' => '0',
  'log4perl.appender.Screen.layout' => 'Log::Log4perl::Layout::PatternLayout',
  'log4perl.appender.Screen.layout.ConversionPattern' => '%d %m %n',
}}

sub append_logfile {
    'log4perl.logger.Bar.Twix'      => 'DEBUG, A1',
    'log4perl.appender.A1'          => 'Log::Log4perl::Appender::File',
    'log4perl.appender.A1.filename' => 'test.log',
    'log4perl.appender.A1.mode'     => 'append',
    'log4perl.appender.A1.layout'   => 'Log::Log4perl::Layout::PatternLayout',
    'log4perl.appender.A1.layout.ConversionPattern' = '%d %m %n'    
}

1;

