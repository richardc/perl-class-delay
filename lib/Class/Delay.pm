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
    for my $method (@methods) {
        no strict 'refs';
        *{"$package\::$method"} = sub {
            push @delayed, Class::Delay::Message->new({
                package => $package,
                method  => $method,
                args    => [ @_ ] });
            return 1;
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

=cut
