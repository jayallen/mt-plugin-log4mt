# Log4MT - A plugin for Movable Type v4 and Melody #

* **AUTHOR:**     Jay Allen, Endevver Consulting, http://endevver.com
* **LICENSE:**    GNU Public License v2
* **VERSION:**    1.7
* **DATE:**       05/18/2010

The Log4MT plugin enhances Movable Type with the [fantastic and ultra-powerful Log4Perl logging framework][Log4perl]. Like Log4perl, Log4MT enables you to debug your code, handle exceptions or send notifications with one of six priorities (trace, debug, info, warn, error, fatal).

[Log4perl]: http://log4perl.sourceforge.net/

The output of those messages can go to any of the following:

* The webserver error log
* An arbitrary file
* Any database
* Any socket
* One or more arbitrary email addresses
* The syslog
* ...and many more! 

What's more, with Log4MT you can completely control not only the formatting of those messages but also exert granular control over what messages should trigger output, which output methods they should trigger or which messages should be ignored altogether.

For an overview on Log4MT's capabilities, see the excellent overview of Log::Log4perl "[Retire your debugger, log smartly with Log::Log4perl!][]"

[Retire your debugger, log smartly with Log::Log4perl!]: http://www.perl.com/pub/a/2002/09/11/log4perl.html

## VERSION ##

1.7 (released May 18th, 2010)

## REQUIREMENTS ##

* [Movable Type 4.x][mt] or any version of [Melody][]
* Log::Log4perl (included in the distribution)
* Log::Dispatch (included in the distribution)
* Sub::Install (included in the distribution) 


## LICENSE ##

This program is distributed under the terms of the GNU General Public License, version 2.

## INSTALLATION ##

1. Clone the repository or [download the latest version](https://github.com/endevver/mt-plugin-log4mt/downloads) and unpack the archive
2. Copy the contents of the `addons` and `extlib` directories in the archive into the respective directories in your [MT][]/[Melody][] application directory. In the case of `extlib/MT`, the directory already exists but the files being added are new.
3. Copy the `log4mt.conf` file to the root of your MT directory
4. Modify the `log4mt.conf` file to specify the desired absolute path to your log file. There are instructions inside the file which will guide you.

And that's it!

## USAGE ##

Using Log4MT in a basic way (i.e. to log messages to a file) is simple. Follow the installation instructions linked to above and then do:

    # Instantiate the logger object from MT::Log
    my $logger = MT::Log->get_logger();

    # Send information about this location to the logs
    $logger->trace();

    # Just say howdy!
    $logger->debug('HOWDY!');    

    # Log some information to the log
    $logger->info('FWIW, this is interesting...');

    # Warn about a possible issue
    $logger->warn('User doesn't have a display name: ', $author->name);

    # Report on internal errors and dump out objects or complex data
    $logger->error('Ran into an error saving entry: ', l4mtdump($entry));

    # Log serious errors
    $logger->fatal(sprintf 'Application %s died with error "%s"',
        ref($app), ($app->errstr || $@));

## CONFIGURATION ##

For most users, the basic configuration is enough to get you started logging. If, however, you want to turn down the logging level without removing your logging statements or do some more exotic things, the log4mt.conf file is the heart of the an incredible amount of functionality.

Everything you can do with the config file to customize Log4MT is documented in the [Log::Log4perl documentation][].

## FURTHER READING ##

* [Retire your debugger, log smartly with Log::Log4perl!](http://www.perl.com/pub/a/2002/09/11/log4perl.html)
* [Log::Log4perl documentation][]
* [The exhaustive Log::Log4perl FAQ](http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/FAQ.html)
* POD documentation forthcoming 

## VERSION HISTORY ##

Full details can be found in the [commit logs](http://github.com/endevver/mt-plugin-log4mt/commits/master) but briefly:

* 2010/05/18 - Release of v1.7
* 2008/11/03 - Release of v1.5
* 2008/04/03 - Release of v1.2 beta 2, small but critical bug fix in the configuration file
* 2008/04/02 - Initial public release of v1.2-beta 

## AUTHOR ##

This plugin was brought to you by [Jay Allen][], Principal and Chief Architect of [Endevver Consulting][]. I hope that you get as much use out of it as I have.

[Retire your debugger, log smartly with Log::Log4perl!]: http://www.perl.com/pub/a/2002/09/11/log4perl.html
[Log::Log4perl documentation]: http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl.html
[The exhaustive Log::Log4perl FAQ]: http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/FAQ.html
[Jay Allen]: http://jayallen.org
[Endevver Consulting]: http://endevver.com
[Melody]: http://openmelody.org
[MT]: http://movabletype.org
