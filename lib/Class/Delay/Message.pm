package Class::Delay::Message;
use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw( package method args ));

1;
