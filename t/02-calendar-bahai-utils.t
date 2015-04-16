#!/usr/bin/perl

use 5.006;
use Test::More tests => 9;
use strict; use warnings;
use Calendar::Bahai::Utils qw(
    validate_year
    validate_month
    validate_day
    jwday
    gregorian_to_bahai
    julian_to_bahai
    gregorian_to_julian
    julian_to_gregorian
    get_major_cycle_year
    is_gregorian_leap_year
);

eval { validate_year(-168); };
like($@, qr/ERROR: Invalid year \[\-168\]./);

eval { validate_day(20); };
like($@, qr/ERROR: Invalid day \[20\]./);

my @g_bahai = gregorian_to_bahai(2015, 4, 16);
is(join(", ", @g_bahai), '1, 10, 1, 2, 8');

my @j_bahai = julian_to_bahai(2457102.5);
is(join(", ", @j_bahai), '1, 10, 1, 1, 1');

is(gregorian_to_julian(2015, 4, 16), 2457128.5);

my @gregorian = julian_to_gregorian(2457128.5);
is(join(", ", @gregorian), '2015, 4, 16');

# Compare year 172 BE
my @bahai = get_major_cycle_year(171);
is(join(", ", @bahai), '1, 10, 1');

ok(!!is_gregorian_leap_year(2015) == 0);

is(jwday(2457102.5), 6);
