#!/usr/bin/perl

use 5.006;
use Test::More tests => 9;
use strict; use warnings;
use Calendar::Bahai::Date;

is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->as_string, '1, Baha 172 BE');
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->to_julian, 2457102.5);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->get_year, 172);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->year, 1);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->month, 1);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->major, 1);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->cycle, 10);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->day_of_week, 6);
is(Calendar::Bahai::Date->new({major => 1, cycle => 10, year => 1, month => 1, day => 1})->to_gregorian, '2015-03-21');
