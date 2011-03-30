use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'Calendar::Bahai',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/Calendar/Bahai.pm',
    add_to_cleanup    => [ 'Calendar-Bahai-*' ],
    build_requires    => {
        'Test::More'      => 0,
        'Readonly'        => 0,
        'Time::localtime' => 1.02,
        'List::Util'      => 1.21,
        'Date::Calc'      => 5.7,
    },
);

$builder->create_build_script();