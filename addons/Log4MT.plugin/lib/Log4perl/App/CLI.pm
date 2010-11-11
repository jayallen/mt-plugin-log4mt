package Log4perl::App::CLI;

use strict;
use Data::Dumper;
use Carp qw(longmess);

use MT;
use MT::App;
use base 'MT::App';
use CGI;

use vars qw($logger);
use MT::Log::Log4perl qw(l4mtdump);
$logger = MT::Log::Log4perl->new();

sub init {
    my $app = shift;
    $app->SUPER::init(@_) or return;

    # $app->{no_print_body} = 1;
    $app;
}

sub init_request {
    my $app = shift;
    $app->{init_request} or $app->SUPER::init_request(@_);
}

sub init_plugins {
    my $app = shift;
    $app->SUPER::init_plugins(@_);
}

sub pre_run {
    my $app = shift;
    $app->SUPER::pre_run(@_);
}

sub post_run {
    my $app = shift;
    $app->print( ( 'OUTPUT-----' x 10 ), "\n" );
    $app->SUPER::post_run(@_);
    if ( $app->{trace}
         && ( !defined $app->{warning_trace} || $app->{warning_trace} ) )
    {
        my $trace = '';
        foreach ( @{ $app->{trace} } ) {
            $trace .= "MT DEBUG: $_\n";

            # $trace .= $logger->indent("MT DEBUG: $_\n");
        }
        $app->print_trace($trace);
    }

    # $app->{query}->save(\*STDOUT);
}

sub print_trace {
    my ( $app, $trace ) = @_;
    my $del = 'TRACE------' x 10;
    $app->print( "\n", join( "\n", $del, $trace, $del ), "\n" );

}

sub show_error {
    my $app   = shift;
    my $error = $_[0]->{error};
    my $stack = $error ? longmess() : '';

    $app->print( "FATAL> $error (" . ( caller(0) )[3] . ')' . $stack );
    return;
}

sub send_http_header { }

sub takedown {
    my $app = shift;
    $app->SUPER::takedown(@_);
    $app->print("\n");
    return;
}


1;
