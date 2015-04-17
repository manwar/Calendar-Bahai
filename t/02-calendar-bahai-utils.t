#!/usr/bin/perl

use 5.006;
use Test::More tests => 12;
use strict; use warnings;
use Calendar::Bahai::Utils qw(
    validate_bahai_year
    validate_bahai_month
    validate_bahai_day
    jwday
    gregorian_to_bahai
    bahai_to_gregorian
    julian_to_bahai
    bahai_to_julian
    gregorian_to_julian
    julian_to_gregorian
    get_major_cycle_year
    is_gregorian_leap_year
);

eval { validate_bahai_year(-168); };
like($@, qr/ERROR: Invalid year \[\-168\]./);

eval { validate_bahai_month(20); };
like($@, qr/ERROR: Invalid month \[20\]./);

eval { validate_bahai_day(20); };
like($@, qr/ERROR: Invalid day \[20\]./);

my @g_bahai = gregorian_to_bahai(2015, 4, 16);
is(join(", ", @g_bahai), '1, 10, 1, 2, 8');

my @b_gregorian = bahai_to_gregorian(1, 10, 1, 2, 8);
is(join(", ", @b_gregorian), '2015, 4, 16');

my @j_bahai = julian_to_bahai(2457102.5);
is(join(", ", @j_bahai), '1, 10, 1, 1, 1');

is(bahai_to_julian(1, 10, 1, 1, 1), 2457102.5);

is(gregorian_to_julian(2015, 4, 16), 2457128.5);

my @gregorian = julian_to_gregorian(2457128.5);
is(join(", ", @gregorian), '2015, 4, 16');

# Compare year 172 BE
my @bahai = get_major_cycle_year(171);
is(join(", ", @bahai), '1, 10, 1');

ok(!!is_gregorian_leap_year(2015) == 0);

is(jwday(2457102.5), 6);
