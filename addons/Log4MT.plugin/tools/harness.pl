#!/usr/bin/perl -w
### Log4perl harness script

use strict;
use warnings;

BEGIN {
    my @libs
      = qw(lib extlib addons/Log4MT.plugin/lib addons/Log4MT.plugin/extlib);
    if ( -e "$ENV{PWD}/mt-config.cgi" ) {
        unshift( @INC, $_ ) foreach @libs;
    }
    elsif ( $ENV{MT_HOME} and -d $ENV{MT_HOME} ) {
        unshift( @INC, $ENV{MT_HOME} . "/$_" ) foreach (@libs);
    }
    else {
        die 'Please set your MT_HOME shell environment variable '
          . 'to point to your MT directory.';
    }
}
use MT::Bootstrap::CLI ( App => 'Log4perl::App::CLI::Log4perl' );

__END__

http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/FAQ.html
http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl.html
http://www.perl.com/pub/a/2002/09/11/log4perl.html
http://www.perl.com/pub/a/2004/05/14/affrus.html
http://www.latenightsw.com/affrus/index.html
http://www.google.com/search?q=affrus&hl=en&client=safari&rls=en&pwst=1&start=20&sa=N
