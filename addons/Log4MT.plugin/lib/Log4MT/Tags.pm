package Log4MT::Tags;

use strict;
use warnings;
use Data::Dumper;
use Carp qw( croak confess longmess );

our ($mtlog);

sub get_logger {
    my $cat = shift;
    require MT::Log::Log4perl;
    import MT::Log::Log4perl qw( l4mtdump );
    return MT::Log::Log4perl->get_logger($cat);
}

sub hdlr_logger {
    my ( $ctx, $args ) = @_;
    return "OH MY GOD.....";
    my $logger = get_logger();
    $logger->trace();

    my $tag = $ctx->stash('tag');

    # Get logger from category or logger attribute or use default logger
    my $category = join( '.',
                         'MTLogger', 'Template',
                         ( $args->{logger} || $args->{category} || undef ) );
    my $tmpl_logger = get_logger($category);

    # Get logger level from level attribute and set.  INFO is default
    my $level = $tmpl_logger->get_level( uc( $args->{level} || 'INFO' ) );

    # $tmpl_logger->level($level);

    # Get logger message from attribute or content of block
    my @msgs = ();
    if ( $tag eq 'Logger' ) {
        push( @msgs, $args->{message} );
    }
    else {
        my $compile
          = ( defined $args->{compile} ) ? $args->{compile}
          : ( defined $args->{uncompiled} ) ? !$args->{uncompiled}
          :                                   1;
        my $str = $ctx->stash('uncompiled');
        if ($compile) {

            # Process enclosed block of template code
            my $tokens = MT::Template::Context::_hdlr_pass_tokens(@_);
            if ( defined $tokens ) {
                if ( my $ph = $ctx->post_process_handler ) {
                    my $content = $ph->( $ctx, $args, $tokens );
                    $str = $content;
                }
            }
        }
        $str =~ s/(^\s+|\s+$)//g;
        push( @msgs, split( /\n/, $str || '' ) );
    } ## end else [ if ( $tag eq 'Logger' )]
    @msgs = map { s/(^\s+|\s+$)//g; $_ } @msgs;
    print STDERR 'YOYOYOYOYOYOYOYOYOY: ' . Dumper( \@msgs );
    $tmpl_logger->log( $level, $_ ) foreach @msgs;
    return '';

} ## end sub hdlr_logger

1;
