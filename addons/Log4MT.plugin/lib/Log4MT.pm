package Log4MT;

use strict; use warnings;
use Data::Dumper;
use Carp qw( croak confess longmess );

BEGIN {
    unshift(@INC, "$ENV{MT_HOME}/addons/Log4MT.plugin/lib");
}

use MT::Log::Log4perl qw(l4mtdump);
our $logger = MT::Log::Log4perl->new();


my $log_class = MT->model('log') || 'MT::Log';
$logger->debug("Installing get_logger into $log_class from ".__PACKAGE__);
require Sub::Install;
Sub::Install::reinstall_sub({
    from => 'MT::Log::Log4perl',
    code => 'new',
    into => $log_class,
    as   => 'get_logger',
});        

sub init {
    $logger->trace();
    my $log_class = MT->model('log') || 'MT::Log';        
    $logger->debug("Installing get_logger into $log_class from ".__PACKAGE__.' init()');
    require Sub::Install;
    Sub::Install::reinstall_sub({
        from => 'MT::Log::Log4perl',
        code => 'new',
        into => $log_class,
        as   => 'get_logger',
    });        
}

sub post_init {
    $logger->trace();
    $logger->debug("Installing get_logger into $log_class from ".__PACKAGE__.' post_init()');
}

sub init_request {
    my $plugin = shift;
    my $app = shift;
    my $q = eval { $app->query } || $app->param;
    $logger->debug("Installing get_logger into $log_class from ".__PACKAGE__.' init_request()');

    # my $app = MT->instance();

     if (   $q->param('old_pass')
         or $q->param('hint')
         or $q->param('username') && $q->param('password')) {
         $logger->info('App query: NOT LOGGED DUE TO LOGIN CREDENTIALS, Mode: ', ($app->mode ? $app->mode : 'None'));
     }
     else {
         $logger->info('App query: ', l4mtdump( eval { $app->query } || $app->{query} ));
     }
}

sub show_template_params {
    my ($cb, $app, $param, $tmpl) = @_;
    $logger ||= MT::Log::Log4perl->new();
    unless ( $app->request('Log4MT_template_params_output') ) {
        $logger->debug('Initial outgoing template parameters:');
        $logger->debug(sprintf "     %-30s %s", $_||'', $param->{$_}||'')
            foreach sort keys %$param;
        $app->request('Log4MT_template_params_output', 1);
    }
    $logger->debug(sprintf 'Loading app template "%s"',
        $param->{template_filename}||'[template_filename is NULL]');
}

our ($mtlog);
sub get_logger {
    my $cat = shift;
    require MT::Log::Log4perl;
    import MT::Log::Log4perl qw( l4mtdump );
    return MT::Log::Log4perl->new($cat);
}


sub hdlr_logger {
    my ($ctx, $args) = @_;
    my $logger = get_logger();
    $logger->trace();
    
    my $tag = $ctx->stash('tag');

    # Get logger from category or logger attribute or use default logger
    my $category = join('.', 'MTLogger', 'Template',
            ($args->{logger} || $args->{category} || undef));
    my $tmpl_logger = get_logger($category);

    # Get logger level from level attribute and set.  INFO is default
    my $level = $tmpl_logger->level(uc($args->{level} || 'INFO'));
    # $tmpl_logger->level($level);
    
    # Get logger message from attribute or content of block
    my @msgs = ();
    if ($tag eq 'Logger') {
        push(@msgs, $args->{message});
    }
    else {
        my $compile = (defined $args->{compile})    ? $args->{compile}
                    : (defined $args->{uncompiled}) ? ! $args->{uncompiled}
                                                    : 1;
        my $str = $ctx->stash('uncompiled');
        if ($compile) {
            # Process enclosed block of template code
            my $tokens = MT::Template::Context::_hdlr_pass_tokens(@_);
            if (defined $tokens) {
                if (my $ph = $ctx->post_process_handler) {
                    my $content = $ph->($ctx, $args, $tokens);
                    $str = $content;
                }            
            }
        }
        $str =~ s/(^\s+|\s+$)//g;
    push(@msgs, split(/\n/, $str||''));
    }
    @msgs = map { s/(^\s+|\s+$)//g; $_ } @msgs;

    $tmpl_logger->log($level, $_) foreach @msgs;
    return '';
}

1;
