use strict;
package Class::Delay;
require Class::Delay::Message;

our $VERSION = '0.01';

sub import {
    my $package = caller;
    my $class   = shift;
    my %args    = @_;

    my @delayed;
    my @methods = @{ $args{methods} };
    my $return  = $args{return} || 1;
    for my $method (@methods) {
        no strict 'refs';
        *{"$package\::$method"} = sub {
            push @delayed, Class::Delay::Message->new({
                package => $package,
                method  => $method,
                args    => [ @_ ] });
            return $return;
        };
    }

    my @triggers = @{ $args{release} };
    for my $method (@triggers) {
        my $sub = sub {
            my $self = shift;
            # delete our placeholders
            for my $method (@methods, @triggers) {
                no strict 'refs';
                local *newglob;
                *{"$package\::$method"} = *newglob;
            }

            # redispatch all the old stuff
            $_->resume for @delayed;

            # and redispatch the triggering event
            $package->$method(@_);
        };

        no strict 'refs';
        *{"$package\::$method"} = $sub;
    }
}

1;
__END__

=head1 NAME

Class::Delay - delay method dispatch until a trigerring event

=head1 SYNOPSIS

 package PrintOut;
 sub write {
    my $self = shift;
    print "printing: ", @_, "\n";
 }
 sub flush {
    print "flushed\n";
 }

 package DelayedPrint;
 use base 'PrintOut';
 use Class::Delay
    methods => [ 'write' ],
    release => [ 'flush' ];

 package main;

 DelayedPrint->write( "we'll write this later" ); # won't get through
                                                  # to PrintOuts 'write' yet
 DelayedPrint->write( "this too" );
 DelayedPrint->flush;  # all of the queued call are dispatched
 DelayedPrint->write( "this won't be delayed" );

=head1 DESCRIPTION

Class::Delay provides a mechanism for the delay of method dispatch
until a triggering method is called.

You simply define a proxy class, and then call on the module to set up
a set of methods that will defer.

=head2 Options

The use statement takes the following options when generate the
proxying behaviour.

=over

=item methods

An array reference naming the methods to delay until a trigger event.

=item return

What a delayed method will return, defaults to 1.

=item release

An array reference naming the methods to ise as triggering events.

=back

An extended example of this module is in L<Mariachi::DBI> which uses
the module to delay database setup until the final of the database is
known.

=head1 AUTHOR

Richard Clamp <richardc@unixbeard.net>

=head1 COPYRIGHT

Copyright (C) 2003 Richard Clamp. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
