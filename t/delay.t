#!perl -w
use strict;
use Test::More tests => 5;

my @done;
my @methods;
BEGIN { @methods = qw( foo bar baz ) }

# testing packages
package Doer;

for (@methods, 'doit') {
    no strict 'refs';
    *{"Doer::$_"} = sub { push @done, $_ };
}

package Waiter;
our @ISA = 'Doer';
use Class::Delay
  methods => \@methods,
  release => [qw( doit )];

package main;
# the actual tests


for (@methods) {
    can_ok('Waiter', $_ );
    ok( Waiter->$_(), "did $_" );
}
is( scalar @done, 0, "didn't actually do it yet" );

can_ok( Waiter => 'doit' );
ok( Waiter->doit, "triggering event" );
is_deeply( \@done, [ @methods, 'doit' ], "things are now done" );
