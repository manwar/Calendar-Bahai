use Test::More tests => 3;

use strict; use warnings;
use Calendar::Bahai;

my ($calendar);

eval { $calendar = Calendar::Bahai->new(-168, 1, 1); };
like($@, qr/ERROR: Invalid year \[\-168\]./);

eval { $calendar = Calendar::Bahai->new(168, 20, 1); };
like($@, qr/ERROR: Invalid month \[20\]./);

eval { $calendar = Calendar::Bahai->new(2011, 12, 20); };
like($@, qr/ERROR: Invalid day \[20\]./);