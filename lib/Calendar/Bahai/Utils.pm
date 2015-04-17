package Calendar::Bahai::Utils;

$Calendar::Bahai::Utils::VERSION = '0.14';

=head1 NAME

Calendar::Bahai::Utils - Helper package for Calendar::Bahai.

=head1 VERSION

Version 0.14

=head1 DESCRIPTION

Helper package for L<Calendar::Bahai> and L<Calendar::Bahai::Date>.

=cut

use strict; use warnings;
use 5.006;
use Data::Dumper;
use POSIX qw/floor/;
use Term::ANSIColor::Markup;
use parent 'Exporter';

use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(
    $BAHAI_EPOCH
    $GREGORIAN_EPOCH
    $BAHAI_MONTH_NAMES
    $BAHAI_CYCLES
    $BAHAI_DAY_NAMES
    $BAHAI_YEAR
    $BAHAI_MONTH
    $BAHAI_DAY

    get_bahai_month_calendar
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

our $BAHAI_EPOCH     = 2394646.5;
our $GREGORIAN_EPOCH = 1721425.5;

our $BAHAI_MONTH_NAMES = [
    '',
    'Baha',    'Jalal', 'Jamal',  'Azamat', 'Nur',       'Rahmat',
    'Kalimat', 'Kamal', 'Asma',   'Izzat',  'Mashiyyat', 'Ilm',
    'Qudrat',  'Qawl',  'Masail', 'Sharaf', 'Sultan',    'Mulk',
    'Ala'
];

our $BAHAI_CYCLES = [
    '',
    'Alif', 'Ba',     'Ab',    'Dal',  'Bab',    'Vav',
    'Abad', 'Jad',    'Baha',  'Hubb', 'Bahhaj', 'Javab',
    'Ahad', 'Vahhab', 'Vidad', 'Badi', 'Bahi',   'Abha',
    'Vahid'
];

our $BAHAI_DAY_NAMES = [
    '<yellow><bold>    Jamal </bold></yellow>',
    '<yellow><bold>    Kamal </bold></yellow>',
    '<yellow><bold>    Fidal </bold></yellow>',
    '<yellow><bold>     Idal </bold></yellow>',
    '<yellow><bold> Istijlal </bold></yellow>',
    '<yellow><bold> Istiqlal </bold></yellow>',
    '<yellow><bold>    Jalal </bold></yellow>'
];

our $BAHAI_YEAR  = sub { validate_bahai_year(@_)  };
our $BAHAI_MONTH = sub { validate_bahai_month(@_) };
our $BAHAI_DAY   = sub { validate_bahai_day(@_)   };

=head1 METHODS

=head2 validate_bahai_year($year)

Dies if the given C<$year> is not a valid Bahai year.

=cut

sub validate_bahai_year {
    my ($year) = @_;

    die("ERROR: Invalid year [$year].\n")
        unless (defined($year) && ($year =~ /^\d+$/) && ($year > 0));
}

=head2 validate_bahai_month($month)

Dies if the given C<$month> is not a valid Bahai month.

=cut

sub validate_bahai_month {
    my ($month) = @_;

    die("ERROR: Invalid month [$month].\n")
        unless (defined($month) && ($month =~ /^\d{1,2}$/) && ($month >= 1) && ($month <= 19));
}

=head2 validate_bahai_day($day)

Dies if the given C<$day> is not a valid Bahai day.

=cut

sub validate_bahai_day {
    my ($day) = @_;

    die ("ERROR: Invalid day [$day].\n")
        unless (defined($day) && ($day =~ /^\d{1,2}$/) && ($day >= 1) && ($day <= 19));
}

=head2 jwday($julian_date)

Returns day of week for the given Julian date C<$julian_date>, with 0 for Sunday.

=cut

sub jwday {
    my ($julian_date) = @_;

    return floor($julian_date + 1.5) % 7;
}

=head2 gregorian_to_bahai($year, $month, $day)

Returns Bahai date component as list (majaor, cycle, year, month, day) equivalent
of the given gregorian date.

=cut

sub gregorian_to_bahai {
    my ($year, $month, $day) = @_;

    return julian_to_bahai(gregorian_to_julian($year, $month, $day));
}

=head2 bahai_to_gregorian($major, $cycle, $year, $month, $day)

Returns Gregorian date as list (yyyy, mm, dd) equivalent of the given bahai date.

=cut

sub bahai_to_gregorian {
    my ($major, $cycle, $year, $month, $day) = @_;

    return julian_to_gregorian(bahai_to_julian($major, $cycle, $year, $month, $day));
}

=head2 julian_to_bahai($julian_date)

Returns Bahai date component as list (majaor, cycle, year, month, day) equivalent
of the given Julian date C<$julian_date>.

=cut

sub julian_to_bahai {
    my ($julian_date) = @_;

    $julian_date = floor($julian_date) + 0.5;
    my $gregorian_year = (julian_to_gregorian($julian_date))[0];
    my $start_year     = (julian_to_gregorian($BAHAI_EPOCH))[0];

    my $j1 = gregorian_to_julian($gregorian_year, 1, 1);
    my $j2 = gregorian_to_julian($gregorian_year, 3, 20);

    my $bahai_year = $gregorian_year - ($start_year + ((($j1 <= $julian_date) && ($julian_date <= $j2)) ? 1 : 0));
    my ($major, $cycle, $year) = get_major_cycle_year($bahai_year);

    my $days  = $julian_date - bahai_to_julian($major, $cycle, $year, 1, 1);
    my $bld   = bahai_to_julian($major, $cycle, $year, 20, 1);
    my $month = ($julian_date >= $bld) ? 20 : (floor($days / 19) + 1);
    my $day   = ($julian_date + 1) - bahai_to_julian($major, $cycle, $year, $month, 1);

    return ($major, $cycle, $year, $month, $day);
}

=head2 bahai_to_julian($major, $cycle, $year, $month, $day)

Returns julian date of the given bahai date.

=cut

sub bahai_to_julian {
    my ($major, $cycle, $year, $month, $day) = @_;

    my ($g_year) = julian_to_gregorian($BAHAI_EPOCH);
    my $gy     = (361 * ($major - 1)) +
                 (19  * ($cycle - 1)) +
                 ($year - 1) + $g_year;

    return gregorian_to_julian($gy, 3, 20)
           +
           (19 * ($month - 1))
           +
           (($month != 20) ? 0 : (is_gregorian_leap_year($gy + 1) ? -14 : -15))
           +
           $day;
}

=head2 gregorian_to_julian($year, $month, $day)

Returns Julian date equivalent of the given Gregorian date.

=cut

sub gregorian_to_julian {
    my ($year, $month, $day) = @_;

    return ($GREGORIAN_EPOCH - 1) +
           (365 * ($year - 1)) +
           floor(($year - 1) / 4) +
           (-floor(($year - 1) / 100)) +
           floor(($year - 1) / 400) +
           floor((((367 * $month) - 362) / 12) +
           (($month <= 2) ? 0 : (is_gregorian_leap_year($year) ? -1 : -2)) +
           $day);
}

=head2 julian_to_gregorian($julian_date)

Returns Gregorian date as list (yyyy, mm, dd) equivalent of the given Julian date
C<$julian_date>.

=cut

sub julian_to_gregorian {
    my ($julian) = @_;

    my $wjd        = floor($julian - 0.5) + 0.5;
    my $depoch     = $wjd - $GREGORIAN_EPOCH;
    my $quadricent = floor($depoch / 146097);
    my $dqc        = $depoch % 146097;
    my $cent       = floor($dqc / 36524);
    my $dcent      = $dqc % 36524;
    my $quad       = floor($dcent / 1461);
    my $dquad      = $dcent % 1461;
    my $yindex     = floor($dquad / 365);
    my $year       = ($quadricent * 400) + ($cent * 100) + ($quad * 4) + $yindex;

    $year++ unless (($cent == 4) || ($yindex == 4));

    my $yearday = $wjd - gregorian_to_julian($year, 1, 1);
    my $leapadj = (($wjd < gregorian_to_julian($year, 3, 1)) ? 0 : ((is_gregorian_leap_year($year) ? 1 : 2)));
    my $month   = floor(((($yearday + $leapadj) * 12) + 373) / 367);
    my $day     = ($wjd - gregorian_to_julian($year, $month, 1)) + 1;

    return ($year, $month, $day);
}

=head2 get_major_cycle_year($bahai_year)

Returns the attribute as list major, cycle & year as in Kull-i-Shay) of the given
Bahai year C<$bahai_year>.

=cut

sub get_major_cycle_year {
    my ($bahai_year) = @_;

    my $major = floor($bahai_year / 361) + 1;
    my $cycle = floor(($bahai_year % 361) / 19) + 1;
    my $year  = ($bahai_year % 19) + 1;

    return ($major, $cycle, $year);
}

=head2 is_gregorian_leap_year($year)

Returns 0 or 1 if the given Gregorian year C<$year> is a leap year or not.

=cut

sub is_gregorian_leap_year {
    my ($year) = @_;

    return (($year % 4) == 0) &&
            (!((($year % 100) == 0) && (($year % 400) != 0)));
}

sub get_bahai_month_calendar {
    my ($year, $month, $start_index) = @_;

    my $line1 = '<blue><bold>+' . ('-')x76 . '+</bold></blue>';
    my $line2 = '<blue><bold>|</bold></blue>' .
                (' ')x29 . '<yellow><bold>' .
                sprintf("%-9s [%3d BE]", $BAHAI_MONTH_NAMES->[$month], $year) .
                '</bold></yellow>' . (' ')x29 . '<blue><bold>|</bold></blue>';
    my $line3 = '<blue><bold>+';

    for(1..7) {
        $line3 .= ('-')x(10) . '+';
    }
    $line3 .= '</bold></blue>';

    my $line4 = '<blue><bold>|</bold></blue>' .
                join("<blue><bold>|</bold></blue>", @$BAHAI_DAY_NAMES) .
                '<blue><bold>|</bold></blue>';

    my $calendar = join("\n", $line1, $line2, $line3, $line4, $line3)."\n";
    $calendar .= '<blue><bold>|</bold></blue>          ';

    map { $calendar .= "           " } (2..($start_index %= 7));
    foreach (1 .. 19) {
        $calendar .= sprintf("<blue><bold>|</bold></blue><cyan><bold>%9d </bold></cyan>", $_);
        if ($_ != 19) {
            $calendar .= "<blue><bold>|</bold></blue>\n" . $line3 . "\n"
                unless (($start_index + $_) % 7);
        }
        elsif ($_ == 19) {
            my $x = 7 - (($start_index + $_) % 7);
            if (($x >= 2) && ($x != 7)) {
                $calendar .= '<blue><bold>|</bold></blue>          ';
                map { $calendar .= ' 'x11 } (1..$x-1);
            }
        }
    }

    $calendar = sprintf("%s<blue><bold>|</bold></blue>\n%s\n", $calendar, $line3);

    return Term::ANSIColor::Markup->colorize($calendar);
}

#
#
# PRIVATE METHODS

sub _validate_bahai_date {
    my ($year, $month, $day) = @_;

    validate_bahai_day($day);
    validate_bahai_month($month);
    validate_bahai_year($year);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Calendar-Bahai>

=head1 BUGS

Please report any bugs / feature requests to C<bug-calendar-bahai at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Bahai>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Bahai::Utils

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Bahai>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Bahai>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Bahai>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Bahai/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011 - 2015 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Calendar::Bahai::Utils
