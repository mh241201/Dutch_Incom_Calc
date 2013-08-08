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
        [ 33_363 - 19_645 => .42 ],
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
| 30,000 EUR     | 18,382 EUR    | 38.7%    | 22,162 EUR       | 26.1%    |
| 31,000 EUR     | 18,962 EUR    | 38.8%    | 22,868 EUR       | 26.2%    |
| 32,000 EUR     | 19,542 EUR    | 38.9%    | 23,574 EUR       | 26.3%    |
| 33,000 EUR     | 20,122 EUR    | 39.0%    | 24,280 EUR       | 26.4%    |
| 34,000 EUR     | 20,702 EUR    | 39.1%    | 24,986 EUR       | 26.5%    |
| 35,000 EUR     | 21,282 EUR    | 39.2%    | 25,692 EUR       | 26.6%    |
| 36,000 EUR     | 21,862 EUR    | 39.3%    | 26,398 EUR       | 26.7%    |
| 37,000 EUR     | 22,442 EUR    | 39.3%    | 27,104 EUR       | 26.7%    |
| 38,000 EUR     | 23,022 EUR    | 39.4%    | 27,810 EUR       | 26.8%    |
| 39,000 EUR     | 23,602 EUR    | 39.5%    | 28,516 EUR       | 26.9%    |
| 40,000 EUR     | 24,182 EUR    | 39.5%    | 29,222 EUR       | 26.9%    |
| 41,000 EUR     | 24,762 EUR    | 39.6%    | 29,928 EUR       | 27.0%    |
| 42,000 EUR     | 25,342 EUR    | 39.7%    | 30,634 EUR       | 27.1%    |
| 43,000 EUR     | 25,922 EUR    | 39.7%    | 31,340 EUR       | 27.1%    |
| 44,000 EUR     | 26,502 EUR    | 39.8%    | 32,046 EUR       | 27.2%    |
| 45,000 EUR     | 27,082 EUR    | 39.8%    | 32,752 EUR       | 27.2%    |
| 46,000 EUR     | 27,662 EUR    | 39.9%    | 33,458 EUR       | 27.3%    |
| 47,000 EUR     | 28,242 EUR    | 39.9%    | 34,164 EUR       | 27.3%    |
| 48,000 EUR     | 28,822 EUR    | 40.0%    | 34,870 EUR       | 27.4%    |
| 49,000 EUR     | 29,402 EUR    | 40.0%    | 35,576 EUR       | 27.4%    |
| 50,000 EUR     | 29,982 EUR    | 40.0%    | 36,282 EUR       | 27.4%    |
| 51,000 EUR     | 30,562 EUR    | 40.1%    | 36,988 EUR       | 27.5%    |
| 52,000 EUR     | 31,142 EUR    | 40.1%    | 37,694 EUR       | 27.5%    |
| 53,000 EUR     | 31,722 EUR    | 40.1%    | 38,400 EUR       | 27.5%    |
| 54,000 EUR     | 32,302 EUR    | 40.2%    | 39,106 EUR       | 27.6%    |
| 55,000 EUR     | 32,882 EUR    | 40.2%    | 39,812 EUR       | 27.6%    |
| 56,000 EUR     | 33,461 EUR    | 40.2%    | 40,518 EUR       | 27.6%    |
| 57,000 EUR     | 33,941 EUR    | 40.5%    | 41,224 EUR       | 27.7%    |
| 58,000 EUR     | 34,421 EUR    | 40.7%    | 41,930 EUR       | 27.7%    |
| 59,000 EUR     | 34,901 EUR    | 40.8%    | 42,636 EUR       | 27.7%    |
| 60,000 EUR     | 35,381 EUR    | 41.0%    | 43,342 EUR       | 27.8%    |
| 61,000 EUR     | 35,861 EUR    | 41.2%    | 44,048 EUR       | 27.8%    |
| 62,000 EUR     | 36,341 EUR    | 41.4%    | 44,754 EUR       | 27.8%    |
| 63,000 EUR     | 36,821 EUR    | 41.6%    | 45,460 EUR       | 27.8%    |
| 64,000 EUR     | 37,301 EUR    | 41.7%    | 46,166 EUR       | 27.9%    |
| 65,000 EUR     | 37,781 EUR    | 41.9%    | 46,872 EUR       | 27.9%    |
| 66,000 EUR     | 38,261 EUR    | 42.0%    | 47,578 EUR       | 27.9%    |
| 67,000 EUR     | 38,741 EUR    | 42.2%    | 48,284 EUR       | 27.9%    |
| 68,000 EUR     | 39,221 EUR    | 42.3%    | 48,990 EUR       | 28.0%    |
| 69,000 EUR     | 39,701 EUR    | 42.5%    | 49,696 EUR       | 28.0%    |
| 70,000 EUR     | 40,181 EUR    | 42.6%    | 50,402 EUR       | 28.0%    |
| 71,000 EUR     | 40,661 EUR    | 42.7%    | 51,108 EUR       | 28.0%    |
| 72,000 EUR     | 41,141 EUR    | 42.9%    | 51,814 EUR       | 28.0%    |
| 73,000 EUR     | 41,621 EUR    | 43.0%    | 52,520 EUR       | 28.1%    |
| 74,000 EUR     | 42,101 EUR    | 43.1%    | 53,226 EUR       | 28.1%    |
| 75,000 EUR     | 42,581 EUR    | 43.2%    | 53,932 EUR       | 28.1%    |
| 76,000 EUR     | 43,061 EUR    | 43.3%    | 54,638 EUR       | 28.1%    |
| 77,000 EUR     | 43,541 EUR    | 43.5%    | 55,344 EUR       | 28.1%    |
| 78,000 EUR     | 44,021 EUR    | 43.6%    | 56,050 EUR       | 28.1%    |
| 79,000 EUR     | 44,501 EUR    | 43.7%    | 56,756 EUR       | 28.2%    |
| 80,000 EUR     | 44,981 EUR    | 43.8%    | 57,461 EUR       | 28.2%    |
| 81,000 EUR     | 45,461 EUR    | 43.9%    | 58,097 EUR       | 28.3%    |
| 82,000 EUR     | 45,941 EUR    | 44.0%    | 58,733 EUR       | 28.4%    |
| 83,000 EUR     | 46,421 EUR    | 44.1%    | 59,369 EUR       | 28.5%    |
| 84,000 EUR     | 46,901 EUR    | 44.2%    | 60,005 EUR       | 28.6%    |
| 85,000 EUR     | 47,381 EUR    | 44.3%    | 60,641 EUR       | 28.7%    |
| 86,000 EUR     | 47,861 EUR    | 44.3%    | 61,277 EUR       | 28.7%    |
| 87,000 EUR     | 48,341 EUR    | 44.4%    | 61,913 EUR       | 28.8%    |
| 88,000 EUR     | 48,821 EUR    | 44.5%    | 62,549 EUR       | 28.9%    |
| 89,000 EUR     | 49,301 EUR    | 44.6%    | 63,185 EUR       | 29.0%    |
| 90,000 EUR     | 49,781 EUR    | 44.7%    | 63,821 EUR       | 29.1%    |
| 91,000 EUR     | 50,261 EUR    | 44.8%    | 64,457 EUR       | 29.2%    |
| 92,000 EUR     | 50,741 EUR    | 44.8%    | 65,093 EUR       | 29.2%    |
| 93,000 EUR     | 51,221 EUR    | 44.9%    | 65,729 EUR       | 29.3%    |
| 94,000 EUR     | 51,701 EUR    | 45.0%    | 66,365 EUR       | 29.4%    |
| 95,000 EUR     | 52,181 EUR    | 45.1%    | 67,001 EUR       | 29.5%    |
| 96,000 EUR     | 52,661 EUR    | 45.1%    | 67,637 EUR       | 29.5%    |
| 97,000 EUR     | 53,141 EUR    | 45.2%    | 68,273 EUR       | 29.6%    |
| 98,000 EUR     | 53,621 EUR    | 45.3%    | 68,909 EUR       | 29.7%    |
| 99,000 EUR     | 54,101 EUR    | 45.4%    | 69,545 EUR       | 29.8%    |
| 100,000 EUR    | 54,581 EUR    | 45.4%    | 70,181 EUR       | 29.8%    |
+----------------+---------------+----------+------------------+----------+
