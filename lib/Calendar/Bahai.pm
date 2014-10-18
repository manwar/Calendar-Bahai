package Calendar::Bahai;

$Calendar::Bahai::VERSION = '0.09';

use strict; use warnings;

=head1 NAME

Calendar::Bahai - Interface to the calendar used by Bahai faith.

=head1 VERSION

Version 0.09

=cut

use 5.006;
use Data::Dumper;
use POSIX qw/floor/;
use Time::localtime;
use List::Util qw/min/;
use Date::Calc qw/Delta_Days Day_of_Week Add_Delta_Days/;

my $BAHAI_EPOCH     = 2394646.5;
my $GREGORIAN_EPOCH = 1721425.5;

my $MONTHS = [
    '',
    'Baha',    'Jalal', 'Jamal',  'Azamat', 'Nur',       'Rahmat',
    'Kalimat', 'Kamal', 'Asma',   'Izzat',  'Mashiyyat', 'Ilm',
    'Qudrat',  'Qawl',  'Masail', 'Sharaf', 'Sultan',    'Mulk',
    'Ala' ];

my $CYCLES = [
    '',
    'Alif', 'Ba',     'Ab',    'Dal',  'Bab',    'Vav',
    'Abad', 'Jad',    'Baha',  'Hubb', 'Bahhaj', 'Javab',
    'Ahad', 'Vahhab', 'Vidad', 'Badi', 'Bahi',   'Abha',
    'Vahid' ];

my $DAYS = [
    'Jamal',    'Kamal',    'Fidal', 'Idal',
    'Istijlal', 'Istiqlal', 'Jalal' ];

sub new {
    my ($class, $yyyy, $mm, $dd) = @_;

    my ($major, $cycle);
    my $self = {};
    bless $self, $class;

    if (defined($yyyy) && defined($mm) && defined($dd)) {
        _validate_date($yyyy, $mm, $dd);
        ($major, $cycle, $yyyy) = _get_major_cycle_year($yyyy-1);
    }
    else {
        my $today = localtime;
        $yyyy = ($today->year+1900) unless defined $yyyy;
        $mm   = ($today->mon+1) unless defined $mm;
        $dd   = $today->mday unless defined $dd;
        ($major, $cycle, $yyyy, $mm, $dd) = $self->from_gregorian($yyyy, $mm, $dd);
    }

    $self->{major} = $major;
    $self->{cycle} = $cycle;
    $self->{yyyy}  = $yyyy;
    $self->{mm}    = $mm;
    $self->{dd}    = $dd;

    return $self;
}

=head1 NOTICE

On July 10, 2014, the  Universal  House  of  Justice  announced  three  decisions
regarding the Badi` (Bahai) calendar,  which  will affect the dates of Feasts and
Holy Days. Naw Ruz will usually fall on March 20th,which means that all the Feast
days will be one day earlier,and the births of the Bab and of Baha'u'llah will be
celebrated on two consecutive days in the Autumn.The changes take effect from the
next Bahai New Year, from sunset on March 20, 2015. The definitive tables showing
the new dates have not yet been released (as of September 24, 2014), but there is
a preliminary discussion L<here|http://senmcglinn.wordpress.com/2014/09/22/changes-in-bahai-calendar-what-how-why>.

=head1 SYNOPSIS

The  Bahai  calendar started from the original Badi calendar, created by the Bab.
The  Bahai  calendar  is  composed  of 19 months, each with 19 days. Years in the
Bahai  calendar  are  counted  from Thursday, 21 March 1844, the beginning of the
Bahai  Era  or Badi Era (abbreviated BE or B.E.). Year 1 BE thus began at sundown
20  March  1844.  Using the Bahai names for the weekday and month, day one of the
Bahai Era was Istijlal (Majesty), 1 Baha (Splendour) 1 BE.

=head2 Bahai Calendar for the month of Baha year 168 BE.

            Baha [168 BE]

    Sun  Mon  Tue  Wed  Thu  Fri  Sat
           1    2    3    4    5    6
      7    8    9   10   11   12   13
     14   15   16   17   18   19

=head2 Months Names

    Month     Arabic Name     English Translation     Gregorian Dates
    1         Baha            Splendour               21 Mar - 08 Apr
    2         Jalal           Glory                   09 Apr - 27 Apr
    3         Jamal           Beauty                  28 Apr - 16 May
    4         Azamat          Grandeur                17 May - 04 Jun
    5         Nur             Light                   05 Jun - 23 Jun
    6         Rahmat          Mercy                   24 Jun - 12 Jul
    7         Kalimat         Words                   13 Jul - 31 Jul
    8         Kamal           Perfection              01 Aug - 19 Aug
    9         Asma            Names                   20 Aug - 07 Sep
    10        Izzat           Might                   08 Sep - 26 Sep
    11        Mashiyyat       Will                    27 Sep - 15 Oct
    12        Ilm             Knowledge               16 Oct - 03 Nov
    13        Qudrat          Power                   04 Nov - 22 Nov
    14        Qawl            Speech                  23 Nov - 11 Dec
    15        Masail          Questions               12 Dec - 30 Dec
    16        Sharaf          Honour                  31 Dec - 18 Jan
    17        Sultan          Sovereignty             19 Jan - 06 Feb
    18        Mulk            Dominion                07 Feb - 25 Feb
              Ayyam-i-Ha      The Days of Ha          26 Feb - 01 Mar
    19        Ala             Loftiness               02 Mar - 20 Mar (Month of fasting)

=head2 Weekdays

    Arabic Name     English Translation     Day of the Week
    Jalal           Glory                   Saturday
    Jamal           Beauty                  Sunday
    Kamal           Perfection              Monday
    Fidal           Grace                   Tuesday
    Idal            Justice                 Wednesday
    Istijlal        Majesty                 Thursday
    Istiqlal        Independence            Friday

=head2 Kull-i-Shay and Vahid

Also  existing in the Bahai calendar system is a 19-year cycle called Vahid and a
361-year (19x19) supercycle called Kull-i-Shay (literally, "All Things"). Each of
the 19 years in a Vahid has been given a name as shown in the table below.The 9th
Vahid of the 1st Kull-i-Shay  started  on 21 March 1996,  and the 10th Vahid will
begin in 2015. The current Bahai year,year 168 BE (21 March 2011 - 20 March 2012)
,  is year Badi of the 9th Vahid of the 1st Kull-i-Shay. The 2nd Kull-i-Shay will
begin in 2205.

=head2 1st Kull-i-Shay

    No.  Name     Meaning         1        2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19
    1    Alif     A               1844     1863     1882     1901     1920     1939     1958     1977     1996     2015     2034     2053     2072     2091     2110     2129     2148     2167     2186
    2    Ba       B               1845     1864     1883     1902     1921     1940     1959     1978     1997     2016     2035     2054     2073     2092     2111     2130     2149     2168     2187
    3    Ab       Father          1846     1865     1884     1903     1922     1941     1960     1979     1998     2017     2036     2055     2074     2093     2112     2131     2150     2169     2188
    4    Dal      D               1847     1866     1885     1904     1923     1942     1961     1980     1999     2018     2037     2056     2075     2094     2113     2132     2151     2170     2189
    5    Bab      Gate            1848     1867     1886     1905     1924     1943     1962     1981     2000     2019     2038     2057     2076     2095     2114     2133     2152     2171     2190
    6    Vav      V               1849     1868     1887     1906     1925     1944     1963     1982     2001     2020     2039     2058     2077     2096     2115     2134     2153     2172     2191
    7    Abad     Eternity        1850     1869     1888     1907     1926     1945     1964     1983     2002     2021     2040     2059     2078     2097     2116     2135     2154     2173     2192
    8    Jad      Generosity      1851     1870     1889     1908     1927     1946     1965     1984     2003     2022     2041     2060     2079     2098     2117     2136     2155     2174     2193
    9    Baha     Splendour       1852     1871     1890     1909     1928     1947     1966     1985     2004     2023     2042     2061     2080     2099     2118     2137     2156     2175     2194
    10   Hubb     Love            1853     1872     1891     1910     1929     1948     1967     1986     2005     2024     2043     2062     2081     2100     2119     2138     2157     2176     2195
    11   Bahhaj   Delightful      1854     1873     1892     1911     1930     1949     1968     1987     2006     2025     2044     2063     2082     2101     2120     2139     2158     2177     2196
    12   Javab    Answer          1855     1874     1893     1912     1931     1950     1969     1988     2007     2026     2045     2064     2083     2102     2121     2140     2159     2178     2197
    13   Ahad     Single          1856     1875     1894     1913     1932     1951     1970     1989     2008     2027     2046     2065     2084     2103     2122     2141     2160     2179     2198
    14   Vahhab   Bountiful       1857     1876     1895     1914     1933     1952     1971     1990     2009     2028     2047     2066     2085     2104     2123     2142     2161     2180     2199
    15   Vidad    Affection       1858     1877     1896     1915     1934     1953     1972     1991     2010     2029     2048     2067     2086     2105     2124     2143     2162     2181     2200
    16   Badi     Beginning       1859     1878     1897     1916     1935     1954     1973     1992     2011     2030     2049     2068     2087     2106     2125     2144     2163     2182     2201
    17   Bahi     Luminous        1860     1879     1898     1917     1936     1955     1974     1993     2012     2031     2050     2069     2088     2107     2126     2145     2164     2183     2202
    18   Abha     Most Luminous   1861     1880     1899     1918     1937     1956     1975     1994     2013     2032     2051     2070     2089     2108     2127     2146     2165     2184     2203
    19   Vahid    Unity           1862     1881     1900     1919     1938     1957     1976     1995     2014     2033     2052     2071     2090     2109     2128     2147     2166     2185     2204

=head1 METHODS

=head2 as_string()

Return Bahai date in human readable format.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    print "Bahai date is " . $calendar->as_string() . "\n";

=cut

sub as_string {
    my ($self) = @_;

    my $yyyy = $self->{major} * (19 * ($self->{cycle} - 1) + $self->{yyyy});
    return sprintf("%02d, %s %d BE", $self->{dd}, $MONTHS->[$self->{mm}], $yyyy);
}

=head2 today()

Return today's date in Bahai  calendar  as list in the format major, cycle, yyyy,
mm and dd.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    my ($major, $cycle, $yyyy, $mm, $dd) = $bahai->today();
    print "Major [$major] Cycle [$cycle] Year [$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub today {
    my ($self) = @_;

    my $today = localtime;
    return $self->from_gregorian($today->year+1900, $today->mon+1, $today->mday);
}

=head2 dow(yyyy, mm, dd)

Get day of the week of the given Bahai date, starting with sunday (0).

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    print "Day of the week; [" . $calendar->dow() . "]\n";

=cut

sub dow {
    my ($self, $yyyy, $mm, $dd) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    _validate_date($yyyy, $mm, $dd);

    my ($major, $cycle);
    ($major, $cycle, undef) = _get_major_cycle_year($yyyy);
    my @gregorian = $self->to_gregorian($major, $cycle, $yyyy, $mm, $dd);
    return Day_of_Week(@gregorian);
}

=head2 get_calendar(yyyy, mm)

Return calendar for given year and month in Bahai calendar.It return current month
of Bahai calendar if no argument is passed in.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    print $saka->get_calendar();

    # Print calendar for year 168 and month 1.
    print $saka->get_calendar(168, 1);

=cut

sub get_calendar {
    my ($self, $yyyy, $mm) = @_;

    my ($major, $cycle, $year);
    my ($calendar, $start_index, $days);

    if (defined($yyyy) && defined($mm)) {
        _validate_date($yyyy, $mm, 1);
        $calendar = sprintf("\n\t%s [%d BE]\n", $MONTHS->[$mm], $yyyy);
    }
    else {
        $yyyy = $self->{major} * (19 * ($self->{cycle} - 1) + $self->{yyyy});
        $calendar = sprintf("\n\t%s [%d BE]\n", $MONTHS->[$self->{mm}], $yyyy);
        $mm   = $self->{mm};
    }

    $calendar .= "\nSun  Mon  Tue  Wed  Thu  Fri  Sat\n";
    $start_index = $self->dow($yyyy, $mm, 1);
    map { $calendar .= "     " } (1..($start_index%=7));
    foreach (1 .. 19) {
        $calendar .= sprintf("%3d  ", $_);
        $calendar .= "\n" unless (($start_index+$_)%7);
    }

    return sprintf("%s\n\n", $calendar);
}

=head2 from_gregorian(yyyy, mm, dd)

Convert Gregorian date to Bahai date.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    my ($major, $cycle, $yyyy, $mm, $dd) = $calendar->from_gregorian(2011, 3, 25);

=cut

sub from_gregorian {
    my ($self, $yyyy, $mm, $dd) = @_;

    return $self->from_julian(_gregorian_to_julian($yyyy, $mm, $dd));
}

=head2 to_gregorian()

Convert Bahai date to Gregorian date.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    my ($yyyy, $mm, $dd) = $calendar->to_gregorian();

=cut

sub to_gregorian {
    my ($self, $major, $cycle, $yyyy, $mm, $dd) = @_;

    $major = $self->{major} unless defined $major;
    $cycle = $self->{cycle} unless defined $cycle;
    $yyyy  = $self->{yyyy}  unless defined $yyyy;
    $mm    = $self->{mm}    unless defined $mm;
    $dd    = $self->{dd}    unless defined $dd;

    return _julian_to_gregorian($self->to_julian($major, $cycle, $yyyy, $mm, $dd));
}

=head2 from_julian()

Convert Julian date to Bahai date.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    my ($major, $cycle, $yyyy, $mm, $dd) = $calendar->from_julian(2400124.5);

=cut

sub from_julian {
    my ($self, $julian) = @_;

    my ($major, $cycle, $yyyy, $mm, $dd);
    my ($gy, $bstarty, $j1, $j2, $bys, $bld);

    $julian    = floor($julian) + 0.5;
    ($gy)      = _julian_to_gregorian($julian);
    ($bstarty) = _julian_to_gregorian($BAHAI_EPOCH);
    $j1        = _gregorian_to_julian($gy, 1, 1);
    $j2        = _gregorian_to_julian($gy, 3, 20);

    $bys = $gy - ($bstarty + ((($j1 <= $julian) && ($julian <= $j2)) ? 1 : 0));
    ($major, $cycle, $yyyy) = _get_major_cycle_year($bys);

    $dd    = $julian - $self->to_julian($major, $cycle, $yyyy, 1, 1);
    $bld   = $self->to_julian($major, $cycle, $yyyy, 20, 1);
    $mm    = ($julian >= $bld) ? 20 : (floor($dd / 19) + 1);
    $dd    = ($julian + 1) - $self->to_julian($major, $cycle, $yyyy, $mm, 1);

    return ($major, $cycle, $yyyy, $mm, $dd);
}

=head2 to_julian(major, cycle, yyyy, mm, dd)

Convert Bahai date to Julian date.

    use strict; use warnings;
    use Calendar::Bahai;

    my $calendar = Calendar::Bahai->new();
    my $julian   = $calendar->to_julian();

=cut

sub to_julian {
    my ($self, $major, $julian, $cycle, $yyyy, $mm, $dd) = @_;

    $major = $self->{major} unless defined $major;
    $cycle = $self->{cycle} unless defined $cycle;
    $yyyy  = $self->{yyyy}  unless defined $yyyy;
    $mm    = $self->{mm}    unless defined $mm;
    $dd    = $self->{dd}    unless defined $dd;

    my ($y) = _julian_to_gregorian($BAHAI_EPOCH);
    my $gy  = (361 * ($major - 1)) + (19 * ($cycle - 1)) + ($yyyy - 1) + $y;

    return _gregorian_to_julian($gy, 3, 20)
           +
           (19 * ($mm - 1))
           +
           (($mm != 20) ? 0 : (_is_gregorian_leap($gy + 1) ? -14 : -15))
           +
           $dd;
}

sub _gregorian_to_julian {
    my ($yyyy, $mm, $dd) = @_;

    return ($GREGORIAN_EPOCH - 1) +
           (365 * ($yyyy - 1)) +
           floor(($yyyy - 1) / 4) +
           (-floor(($yyyy - 1) / 100)) +
           floor(($yyyy - 1) / 400) +
           floor((((367 * $mm) - 362) / 12) +
           (($mm <= 2) ? 0 : (_is_gregorian_leap($yyyy) ? -1 : -2)) +
           $dd);
}

sub _julian_to_gregorian {
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

    my $yearday = $wjd - _gregorian_to_julian($year, 1, 1);
    my $leapadj = (($wjd < _gregorian_to_julian($year, 3, 1)) ? 0 : ((_is_gregorian_leap($year) ? 1 : 2)));
    my $month   = floor(((($yearday + $leapadj) * 12) + 373) / 367);
    my $day     = ($wjd - _gregorian_to_julian($year, $month, 1)) + 1;

    return ($year, $month, $day);
}

sub _get_major_cycle_year {
    my ($bys) = @_;

    my $major = floor($bys / 361) + 1;
    my $cycle = floor(($bys % 361) / 19) + 1;
    my $yyyy  = ($bys % 19) + 1;

    return ($major, $cycle, $yyyy);
}

sub _is_gregorian_leap {
    my ($yyyy) = @_;

    return (($yyyy % 4) == 0) &&
            (!((($yyyy % 100) == 0) && (($yyyy % 400) != 0)));
}

sub _validate_date {
    my ($yyyy, $mm, $dd) = @_;

    die("ERROR: Invalid year [$yyyy].\n")
        unless (defined($yyyy) && ($yyyy =~ /^\d+$/) && ($yyyy > 0));
    die("ERROR: Invalid month [$mm].\n")
        unless (defined($mm) && ($mm =~ /^\d{1,2}$/) && ($mm >= 1) && ($mm <= 19));
    die("ERROR: Invalid day [$dd].\n")
        unless (defined($dd) && ($dd =~ /^\d{1,2}$/) && ($dd >= 1) && ($dd <= 19));
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

    perldoc Calendar::Bahai

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

Copyright 2011 - 2014 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
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

1; # End of Calendar::Bahai
