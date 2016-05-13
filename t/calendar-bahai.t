#!/usr/bin/perl

use 5.006;
use Test::More tests => 1;
use strict; use warnings;
use Calendar::Bahai;

eval { Calendar::Bahai->new({ year => -168, month => 1 }); };
like($@, qr/ERROR: Invalid year \[\-168\]./);
