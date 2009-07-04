package Log4MT;

use vars qw($logger);
use MT::Log::Log4perl qw(l4mtdump);
use MT::Log;

BEGIN {
    unshift(@INC, "$ENV{MT_HOME}/addons/Log4MT.plugin/extlib");
}

sub init {
    unless (MT::Log->can('get_logger')) {
        require Sub::Install;
        Sub::Install::install_sub({
           # from => 'MT::Log::Log4perl',
           code => 'get_logger',
           from => 'MT::Log::Log4perl',
           into => 'MT::Log',
          });        
    }
}

sub init_request {
    my $plugin = shift;
    my $app = shift;
    $logger ||= MT::Log::Log4perl->new();
    # my $app = MT->instance();

     if (    $app->param('old_pass')
         or  $app->param('hint')
         or  $app->param('username') && $app->param('password')) {
         $logger->info('App query: NOT LOGGED DUE TO LOGIN CREDENTIALS, Mode: ', ($app->mode ? $app->mode : 'None'));
     }
     else {
         $logger->info('App query: ', l4mtdump($app->{query}));
     }
}

sub show_template_params {
    my ($cb, $app, $param, $tmpl) = @_;
    $logger ||= MT::Log::Log4perl->new();
    $logger->debug(sprintf 'Loading app template "%s" with params:',
        $param->{template_filename});
    unless ( $app->request('Log4MT_template_params_output') ) {
        $logger->debug(sprintf "     %-30s %s", $_, $param->{$_})
            foreach sort keys %$param;
        $app->request('Log4MT_template_params_output', 1);
    }
}

1;