package Log4perl::App::CLI::Log4perl;

use strict;
use Data::Dumper;


use MT;
use Log4perl::App::CLI;
use base 'Log4perl::App::CLI';

use MT::Log::Log4perl qw(l4mtdump);
use vars qw($logger);
$logger = MT::Log::Log4perl->new();

sub init {

    # $logger->trace();
    my $app = shift;
    $app->SUPER::init(@_) or return;
    $app;
}

sub init_request {
    my $app = shift;
    $app->SUPER::init_request(@_) or return;
    my $mode;
    if ( $mode = $app->{query}->param('mode') ) {
        print STDERR "Setting mode to $mode\n";
        $app->mode($mode);
    }
}

# sub pre_run {
#     my $app = shift;
#     $app->SUPER::pre_run(@_);
# }

sub mode_default {
    my $app = shift;
    print STDERR "In mode_default\n";
    return $app->error('No mode specified via mode=MODE.');
}

sub mode_levels {
    my $app = shift;
    $app->print("Getting new logger\n");
    $logger->debug('This is debug');
    $logger->info('This is info');
    $logger->warn('This is warn');
    $logger->error('This is error');
    $logger->fatal('This is fatal');
    $app->print("Finished with level test\n");
}

sub runner {
    my $app    = shift;
    my $method = shift;

    # $logger->trace();
    return 'howdy';
}

1;
