use strict;
package Class::Delay;

our $VERSION = '0.01';

my @deferred;
sub import {
    my $package = caller;
    my $class   = shift;
    my %args    = @_;

    for my $method (@{ $args{methods} }) {
        no strict 'refs';
        *{"$package\::$method"} = sub {
            push @deferred, {
                method  => $method,
                args    => [ @_ ] };
            return 1;
        };
    }

    for my $method (@{ $args{release} }) {
        my $sub = sub {
            my $self = shift;
            # delete our placeholders


            # redispatch all the old stuff
            use Data::Dumper;
            for my $delayed (@deferred) {
                warn Dumper $delayed;
                my $invocant = shift @{ $delayed->{args} };
                my $method   = $delayed->{method};
                $invocant->$method( @{ $delayed->{args} } );
            }

            # splice ourselves out of the isa

            # and redipatch the triggering event
            return 1;
        };

        no strict 'refs';
        *{"$package\::$method"} = $sub;
    }
}



1;
