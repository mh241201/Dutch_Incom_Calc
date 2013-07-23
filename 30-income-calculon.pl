# To check if this is up-to-date with the tax rates go to
# http://www.expatax.nl/tax_rates_2013.php and see if there's anything
# newer there.
use strict;
use warnings;
use Text::TabularDisplay;
use List::Util qw(sum);

my $start = 30_000  || $ARGV[0];
my $end   = 100_000 || $ARGV[1];
my $step  = 1_000   || $ARGV[2];

my @data;
for ( my $salary = $start ; $salary <= $end ; $salary += $step ) {

    push @data => [
        # Your Gross income
        eurofy($salary),

        # Without 30% ruling
        eurofy( $salary - taxes_for($salary) ),

        percentify( taxes_for($salary), $salary ),

        # With 30% ruling
        eurofy( $salary - taxes_for( $salary * .7 ) ),

        percentify( taxes_for( $salary * .7 ), $salary ),
    ];
}

my $table = Text::TabularDisplay->new(
    "Gross income\n(before taxes)",
    "Net income\n(after taxes)",
    "Tax rate",
    "Net income\n(after taxes,\nwith 30% ruling)",
    "Tax rate",
);
$table->add(@$_) for @data;
print $table->render, "\n";
exit;

sub taxes_for {
    my $income       = shift;
    my @tax_brackets = (

        # difference         tax rate
        [ 19_645          => .37 ],
        [ 33_363 - 19_645 => .2 ],
        [ 55_991 - 33_363 => .42 ],
        [ 0               => .52 ],
    );

    my $money_left = $income;
    my $taxes      = 0;
    foreach my $bracket (@tax_brackets) {
        my ( $progressive_amount, $taxes_for ) = @$bracket;
        my $taxable_amount = $money_left;
        if ( $taxable_amount > $progressive_amount ) {
            $taxable_amount = $progressive_amount if $progressive_amount;
        }
        $money_left -= $taxable_amount;
        $taxes += $taxable_amount * $taxes_for;
        last unless $money_left;
    }
    return $taxes;
}

# From perlfaq5
sub commify {
    local $_ = shift;
    1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
    return $_;
}

sub percentify {
    my ( $amount, $total ) = @_;
    return sprintf "%.1f%%" => ( ( 100 * $amount ) / $total );
}

sub eurofy {
    my ($number) = @_;

    # Round it
    $number = int $number;

    return sprintf( "%s EUR", commify($number) );
}

__DATA__
$ perl 30-income-calculon.pl
+----------------+---------------+----------+------------------+----------+
| Gross income   | Net income    | Tax rate | Net income       | Tax rate |
| (before taxes) | (after taxes) |          | (after taxes,    |          |
|                |               |          | with 30% ruling) |          |
+----------------+---------------+----------+------------------+----------+
| 30,000 EUR     | 20,660 EUR    | 31.1%    | 22,460 EUR       | 25.1%    |
| 31,000 EUR     | 21,460 EUR    | 30.8%    | 23,320 EUR       | 24.8%    |
| 32,000 EUR     | 22,260 EUR    | 30.4%    | 24,180 EUR       | 24.4%    |
| 33,000 EUR     | 23,060 EUR    | 30.1%    | 25,040 EUR       | 24.1%    |
| 34,000 EUR     | 23,720 EUR    | 30.2%    | 25,900 EUR       | 23.8%    |
| 35,000 EUR     | 24,300 EUR    | 30.6%    | 26,760 EUR       | 23.5%    |
| 36,000 EUR     | 24,880 EUR    | 30.9%    | 27,620 EUR       | 23.3%    |
| 37,000 EUR     | 25,460 EUR    | 31.2%    | 28,480 EUR       | 23.0%    |
| 38,000 EUR     | 26,040 EUR    | 31.5%    | 29,340 EUR       | 22.8%    |
| 39,000 EUR     | 26,620 EUR    | 31.7%    | 30,200 EUR       | 22.6%    |
| 40,000 EUR     | 27,200 EUR    | 32.0%    | 31,060 EUR       | 22.3%    |
| 41,000 EUR     | 27,780 EUR    | 32.2%    | 31,920 EUR       | 22.1%    |
| 42,000 EUR     | 28,360 EUR    | 32.5%    | 32,780 EUR       | 22.0%    |
| 43,000 EUR     | 28,940 EUR    | 32.7%    | 33,640 EUR       | 21.8%    |
| 44,000 EUR     | 29,520 EUR    | 32.9%    | 34,500 EUR       | 21.6%    |
| 45,000 EUR     | 30,100 EUR    | 33.1%    | 35,360 EUR       | 21.4%    |
| 46,000 EUR     | 30,680 EUR    | 33.3%    | 36,220 EUR       | 21.3%    |
| 47,000 EUR     | 31,260 EUR    | 33.5%    | 37,080 EUR       | 21.1%    |
| 48,000 EUR     | 31,840 EUR    | 33.7%    | 37,888 EUR       | 21.1%    |
| 49,000 EUR     | 32,420 EUR    | 33.8%    | 38,594 EUR       | 21.2%    |
| 50,000 EUR     | 33,000 EUR    | 34.0%    | 39,300 EUR       | 21.4%    |
| 51,000 EUR     | 33,580 EUR    | 34.2%    | 40,006 EUR       | 21.6%    |
| 52,000 EUR     | 34,160 EUR    | 34.3%    | 40,712 EUR       | 21.7%    |
| 53,000 EUR     | 34,740 EUR    | 34.5%    | 41,418 EUR       | 21.9%    |
| 54,000 EUR     | 35,320 EUR    | 34.6%    | 42,124 EUR       | 22.0%    |
| 55,000 EUR     | 35,900 EUR    | 34.7%    | 42,830 EUR       | 22.1%    |
| 56,000 EUR     | 36,479 EUR    | 34.9%    | 43,536 EUR       | 22.3%    |
| 57,000 EUR     | 36,959 EUR    | 35.2%    | 44,242 EUR       | 22.4%    |
| 58,000 EUR     | 37,439 EUR    | 35.4%    | 44,948 EUR       | 22.5%    |
| 59,000 EUR     | 37,919 EUR    | 35.7%    | 45,654 EUR       | 22.6%    |
| 60,000 EUR     | 38,399 EUR    | 36.0%    | 46,360 EUR       | 22.7%    |
| 61,000 EUR     | 38,879 EUR    | 36.3%    | 47,066 EUR       | 22.8%    |
| 62,000 EUR     | 39,359 EUR    | 36.5%    | 47,772 EUR       | 22.9%    |
| 63,000 EUR     | 39,839 EUR    | 36.8%    | 48,478 EUR       | 23.1%    |
| 64,000 EUR     | 40,319 EUR    | 37.0%    | 49,184 EUR       | 23.1%    |
| 65,000 EUR     | 40,799 EUR    | 37.2%    | 49,890 EUR       | 23.2%    |
| 66,000 EUR     | 41,279 EUR    | 37.5%    | 50,596 EUR       | 23.3%    |
| 67,000 EUR     | 41,759 EUR    | 37.7%    | 51,302 EUR       | 23.4%    |
| 68,000 EUR     | 42,239 EUR    | 37.9%    | 52,008 EUR       | 23.5%    |
| 69,000 EUR     | 42,719 EUR    | 38.1%    | 52,714 EUR       | 23.6%    |
| 70,000 EUR     | 43,199 EUR    | 38.3%    | 53,420 EUR       | 23.7%    |
| 71,000 EUR     | 43,679 EUR    | 38.5%    | 54,126 EUR       | 23.8%    |
| 72,000 EUR     | 44,159 EUR    | 38.7%    | 54,832 EUR       | 23.8%    |
| 73,000 EUR     | 44,639 EUR    | 38.9%    | 55,538 EUR       | 23.9%    |
| 74,000 EUR     | 45,119 EUR    | 39.0%    | 56,244 EUR       | 24.0%    |
| 75,000 EUR     | 45,599 EUR    | 39.2%    | 56,950 EUR       | 24.1%    |
| 76,000 EUR     | 46,079 EUR    | 39.4%    | 57,656 EUR       | 24.1%    |
| 77,000 EUR     | 46,559 EUR    | 39.5%    | 58,362 EUR       | 24.2%    |
| 78,000 EUR     | 47,039 EUR    | 39.7%    | 59,068 EUR       | 24.3%    |
| 79,000 EUR     | 47,519 EUR    | 39.8%    | 59,774 EUR       | 24.3%    |
| 80,000 EUR     | 47,999 EUR    | 40.0%    | 60,479 EUR       | 24.4%    |
| 81,000 EUR     | 48,479 EUR    | 40.1%    | 61,115 EUR       | 24.5%    |
| 82,000 EUR     | 48,959 EUR    | 40.3%    | 61,751 EUR       | 24.7%    |
| 83,000 EUR     | 49,439 EUR    | 40.4%    | 62,387 EUR       | 24.8%    |
| 84,000 EUR     | 49,919 EUR    | 40.6%    | 63,023 EUR       | 25.0%    |
| 85,000 EUR     | 50,399 EUR    | 40.7%    | 63,659 EUR       | 25.1%    |
| 86,000 EUR     | 50,879 EUR    | 40.8%    | 64,295 EUR       | 25.2%    |
| 87,000 EUR     | 51,359 EUR    | 41.0%    | 64,931 EUR       | 25.4%    |
| 88,000 EUR     | 51,839 EUR    | 41.1%    | 65,567 EUR       | 25.5%    |
| 89,000 EUR     | 52,319 EUR    | 41.2%    | 66,203 EUR       | 25.6%    |
| 90,000 EUR     | 52,799 EUR    | 41.3%    | 66,839 EUR       | 25.7%    |
| 91,000 EUR     | 53,279 EUR    | 41.5%    | 67,475 EUR       | 25.9%    |
| 92,000 EUR     | 53,759 EUR    | 41.6%    | 68,111 EUR       | 26.0%    |
| 93,000 EUR     | 54,239 EUR    | 41.7%    | 68,747 EUR       | 26.1%    |
| 94,000 EUR     | 54,719 EUR    | 41.8%    | 69,383 EUR       | 26.2%    |
| 95,000 EUR     | 55,199 EUR    | 41.9%    | 70,019 EUR       | 26.3%    |
| 96,000 EUR     | 55,679 EUR    | 42.0%    | 70,655 EUR       | 26.4%    |
| 97,000 EUR     | 56,159 EUR    | 42.1%    | 71,291 EUR       | 26.5%    |
| 98,000 EUR     | 56,639 EUR    | 42.2%    | 71,927 EUR       | 26.6%    |
| 99,000 EUR     | 57,119 EUR    | 42.3%    | 72,563 EUR       | 26.7%    |
| 100,000 EUR    | 57,599 EUR    | 42.4%    | 73,199 EUR       | 26.8%    |
+----------------+---------------+----------+------------------+----------+
