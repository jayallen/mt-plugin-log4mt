package MT::Log::Log4perl::Config::file;

use strict; use warnings; use Data::Dumper;
use base qw(Log::Log4perl::Config::BaseConfigurator);
use File::Spec;

use MT::Log::Log4perl::Util qw( err emergency_log trace );

use constant DEFAULT_CONFIG_FILE => 'log4mt.conf';

sub load {
    my $default = File::Spec->catfile( ($ENV{MT_HOME} || '.'),
                                        DEFAULT_CONFIG_FILE);
    return (-e $default) ? $default : '';
}

=pod

    # I had to disable the method below because it was triggering
    # a premature or accelrated botstrapping of MT.  See end of module

sub load {
    my ($self, $args) = shift;
    trace();
    use MT;
    my $default = File::Spec->catfile( $ENV{MT_HOME},
                                        DEFAULT_CONFIG_FILE );
    my $config_source;

    FILETEST: {        
        # Pull config_source from mt-config.cgi the first time around
        $config_source ||= MT->config('log4mtconfig') if MT->can('config');                                            
            
        # Fill default if none specified.
        $config_source ||= $default;

        # Append MT_HOME if only a filename is given
        $config_source = File::Spec->catfile(   ($ENV{MT_HOME} || '.'),
                                                $config_source)
            unless $config_source =~ m{[\\/]};

        # If user-specified config isn't found, fallback to default and retest
        if ( ! -e $config_source) {
            last FILETEST if $config_source eq $default;
            $config_source = $default;
            next FILETEST;
        }
    }

    return $config_source if -e $config_source;

    warn "Could not locate log4mt configuration file: $config_source";
    return undef;        
}
=cut
1;

__END__


The following is the debugging out that I collected once I encountered the issue. (Have to reprodi)

 STACK TRACE:  at lib/MT.pm line 1224
       MT::init_addons('MT=HASH(0x9eea18)') called at lib/MT.pm line 1152
       MT::init('MT=HASH(0x9eea18)') called at lib/MT.pm line 276
       MT::construct('MT') called at lib/MT.pm line 252
       MT::app('MT') called at lib/MT.pm line 420
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
       MT::config('MT', 'log4mtconfig') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl/Config/file.pm line 12
       MT::Log::Log4perl::Config::file::load('MT::Log::Log4perl::Config::file', 'HASH(0x90bac8)') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl/Config.pm line 32
       eval {...} called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl/Config.pm line 27
       MT::Log::Log4perl::Config::init('MT::Log::Log4perl::Config=HASH(0x9ebb98)', 'HASH(0x90bac8)') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl/Config.pm line 17
       MT::Log::Log4perl::Config::new('MT::Log::Log4perl::Config', 'HASH(0x90bac8)') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl.pm line 103
       MT::Log::Log4perl::init('MT::Log::Log4perl=HASH(0x90bb28)', 'HASH(0x90bac8)') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/extlib/MT/Log/Log4perl.pm line 94
       MT::Log::Log4perl::new('MT::Log') called at addons/Community.pack/lib/MT/App/Community.pm line 23
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
       require MT/App/Community.pm called at lib/MT/Bootstrap.pm line 71
       eval '# line 71 lib/MT/Bootstrap.pm
 require MT::App::Community; 1;' called at lib/MT/Bootstrap.pm line 71
       eval {...} called at lib/MT/Bootstrap.pm line 68
       MT::Bootstrap::import('MT::Bootstrap', 'App', 'MT::App::Community') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/mt-cp.cgi line 13
       main::BEGIN() called at lib/MT/Plugin.pm line 0
       eval {...} called at lib/MT/Plugin.pm line 0
 PLUGINS FOUND: [
   '.',
   '..',
   'Commercial.pack',
   'Community.pack',
   'Developer.pack',
   'Log4MT.plugin'
 ]
 Adding plugin Professional Pack
 Adding plugin Community Pack
 Adding plugin Movable Type Developer Pack
 Adding plugin Log4MT

 STACK TRACE:  at lib/MT.pm line 1224
       MT::init_addons('MT::App::Community=HASH(0x90bac8)', 'App', 'MT::App::Community') called at lib/MT.pm line 1152
       MT::init('MT::App::Community=HASH(0x90bac8)', 'App', 'MT::App::Community') called at lib/MT/App.pm line 650
       MT::App::init('MT::App::Community=HASH(0x90bac8)', 'App', 'MT::App::Community') called at addons/Community.pack/lib/MT/App/Community.pm line 29
       MT::App::Community::init('MT::App::Community=HASH(0x90bac8)', 'App', 'MT::App::Community') called at lib/MT.pm line 276
       MT::construct('MT::App::Community', 'App', 'MT::App::Community') called at lib/MT.pm line 269
       MT::instance_of called at lib/MT.pm line 262
       MT::new('MT::App::Community', 'App', 'MT::App::Community') called at lib/MT/App.pm line 641
       MT::App::new('MT::App::Community', 'App', 'MT::App::Community') called at lib/MT/Bootstrap.pm line 103
       eval {...} called at lib/MT/Bootstrap.pm line 68
       MT::Bootstrap::import('MT::Bootstrap', 'App', 'MT::App::Community') called at /Users/jay/Sites/hugger.local/sockfish/html/mt/mt-cp.cgi line 13
       main::BEGIN() called at lib/MT.pm line 13
       eval {...} called at lib/MT.pm line 13
 PLUGINS FOUND: [
   '.',
   '..',
   'Commercial.pack',
   'Community.pack',
   'Developer.pack',
   'Log4MT.plugin'
 ]
 Adding plugin Professional Pack
