use strict;
package Class::Delay::Message;
use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw( package method args ));

sub resume {
    my $self = shift;
    my @args = @{ $self->args };
    my $invocant = shift @args;
    my $method   = $self->method;
    $invocant->$method( @args );
}

1;
