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
        [ 18_628          => .33 ],
        [ 33_436 - 18_628 => .4195 ],
        [ 55_694 - 33_436 => .42 ],
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
| 30,000 EUR     | 19,082 EUR    | 36.4%    | 22,857 EUR       | 23.8%    |
| 31,000 EUR     | 19,662 EUR    | 36.6%    | 23,564 EUR       | 24.0%    |
| 32,000 EUR     | 20,243 EUR    | 36.7%    | 24,270 EUR       | 24.2%    |
| 33,000 EUR     | 20,823 EUR    | 36.9%    | 24,976 EUR       | 24.3%    |
| 34,000 EUR     | 21,403 EUR    | 37.0%    | 25,683 EUR       | 24.5%    |
| 35,000 EUR     | 21,983 EUR    | 37.2%    | 26,389 EUR       | 24.6%    |
| 36,000 EUR     | 22,563 EUR    | 37.3%    | 27,095 EUR       | 24.7%    |
| 37,000 EUR     | 23,143 EUR    | 37.4%    | 27,802 EUR       | 24.9%    |
| 38,000 EUR     | 23,723 EUR    | 37.6%    | 28,508 EUR       | 25.0%    |
| 39,000 EUR     | 24,303 EUR    | 37.7%    | 29,214 EUR       | 25.1%    |
| 40,000 EUR     | 24,883 EUR    | 37.8%    | 29,921 EUR       | 25.2%    |
| 41,000 EUR     | 25,463 EUR    | 37.9%    | 30,627 EUR       | 25.3%    |
| 42,000 EUR     | 26,043 EUR    | 38.0%    | 31,333 EUR       | 25.4%    |
| 43,000 EUR     | 26,623 EUR    | 38.1%    | 32,040 EUR       | 25.5%    |
| 44,000 EUR     | 27,203 EUR    | 38.2%    | 32,746 EUR       | 25.6%    |
| 45,000 EUR     | 27,783 EUR    | 38.3%    | 33,452 EUR       | 25.7%    |
| 46,000 EUR     | 28,363 EUR    | 38.3%    | 34,159 EUR       | 25.7%    |
| 47,000 EUR     | 28,943 EUR    | 38.4%    | 34,865 EUR       | 25.8%    |
| 48,000 EUR     | 29,523 EUR    | 38.5%    | 35,571 EUR       | 25.9%    |
| 49,000 EUR     | 30,103 EUR    | 38.6%    | 36,277 EUR       | 26.0%    |
| 50,000 EUR     | 30,683 EUR    | 38.6%    | 36,983 EUR       | 26.0%    |
| 51,000 EUR     | 31,263 EUR    | 38.7%    | 37,689 EUR       | 26.1%    |
| 52,000 EUR     | 31,843 EUR    | 38.8%    | 38,395 EUR       | 26.2%    |
| 53,000 EUR     | 32,423 EUR    | 38.8%    | 39,101 EUR       | 26.2%    |
| 54,000 EUR     | 33,003 EUR    | 38.9%    | 39,807 EUR       | 26.3%    |
| 55,000 EUR     | 33,583 EUR    | 38.9%    | 40,513 EUR       | 26.3%    |
| 56,000 EUR     | 34,133 EUR    | 39.0%    | 41,219 EUR       | 26.4%    |
| 57,000 EUR     | 34,613 EUR    | 39.3%    | 41,925 EUR       | 26.4%    |
| 58,000 EUR     | 35,093 EUR    | 39.5%    | 42,631 EUR       | 26.5%    |
| 59,000 EUR     | 35,573 EUR    | 39.7%    | 43,337 EUR       | 26.5%    |
| 60,000 EUR     | 36,053 EUR    | 39.9%    | 44,043 EUR       | 26.6%    |
| 61,000 EUR     | 36,533 EUR    | 40.1%    | 44,749 EUR       | 26.6%    |
| 62,000 EUR     | 37,013 EUR    | 40.3%    | 45,455 EUR       | 26.7%    |
| 63,000 EUR     | 37,493 EUR    | 40.5%    | 46,161 EUR       | 26.7%    |
| 64,000 EUR     | 37,973 EUR    | 40.7%    | 46,867 EUR       | 26.8%    |
| 65,000 EUR     | 38,453 EUR    | 40.8%    | 47,573 EUR       | 26.8%    |
| 66,000 EUR     | 38,933 EUR    | 41.0%    | 48,279 EUR       | 26.8%    |
| 67,000 EUR     | 39,413 EUR    | 41.2%    | 48,985 EUR       | 26.9%    |
| 68,000 EUR     | 39,893 EUR    | 41.3%    | 49,691 EUR       | 26.9%    |
| 69,000 EUR     | 40,373 EUR    | 41.5%    | 50,397 EUR       | 27.0%    |
| 70,000 EUR     | 40,853 EUR    | 41.6%    | 51,103 EUR       | 27.0%    |
| 71,000 EUR     | 41,333 EUR    | 41.8%    | 51,809 EUR       | 27.0%    |
| 72,000 EUR     | 41,813 EUR    | 41.9%    | 52,515 EUR       | 27.1%    |
| 73,000 EUR     | 42,293 EUR    | 42.1%    | 53,221 EUR       | 27.1%    |
| 74,000 EUR     | 42,773 EUR    | 42.2%    | 53,927 EUR       | 27.1%    |
| 75,000 EUR     | 43,253 EUR    | 42.3%    | 54,633 EUR       | 27.2%    |
| 76,000 EUR     | 43,733 EUR    | 42.5%    | 55,339 EUR       | 27.2%    |
| 77,000 EUR     | 44,213 EUR    | 42.6%    | 56,045 EUR       | 27.2%    |
| 78,000 EUR     | 44,693 EUR    | 42.7%    | 56,751 EUR       | 27.2%    |
| 79,000 EUR     | 45,173 EUR    | 42.8%    | 57,457 EUR       | 27.3%    |
| 80,000 EUR     | 45,653 EUR    | 42.9%    | 58,133 EUR       | 27.3%    |
| 81,000 EUR     | 46,133 EUR    | 43.0%    | 58,769 EUR       | 27.4%    |
| 82,000 EUR     | 46,613 EUR    | 43.2%    | 59,405 EUR       | 27.6%    |
| 83,000 EUR     | 47,093 EUR    | 43.3%    | 60,041 EUR       | 27.7%    |
| 84,000 EUR     | 47,573 EUR    | 43.4%    | 60,677 EUR       | 27.8%    |
| 85,000 EUR     | 48,053 EUR    | 43.5%    | 61,313 EUR       | 27.9%    |
| 86,000 EUR     | 48,533 EUR    | 43.6%    | 61,949 EUR       | 28.0%    |
| 87,000 EUR     | 49,013 EUR    | 43.7%    | 62,585 EUR       | 28.1%    |
| 88,000 EUR     | 49,493 EUR    | 43.8%    | 63,221 EUR       | 28.2%    |
| 89,000 EUR     | 49,973 EUR    | 43.9%    | 63,857 EUR       | 28.3%    |
| 90,000 EUR     | 50,453 EUR    | 43.9%    | 64,493 EUR       | 28.3%    |
| 91,000 EUR     | 50,933 EUR    | 44.0%    | 65,129 EUR       | 28.4%    |
| 92,000 EUR     | 51,413 EUR    | 44.1%    | 65,765 EUR       | 28.5%    |
| 93,000 EUR     | 51,893 EUR    | 44.2%    | 66,401 EUR       | 28.6%    |
| 94,000 EUR     | 52,373 EUR    | 44.3%    | 67,037 EUR       | 28.7%    |
| 95,000 EUR     | 52,853 EUR    | 44.4%    | 67,673 EUR       | 28.8%    |
| 96,000 EUR     | 53,333 EUR    | 44.4%    | 68,309 EUR       | 28.8%    |
| 97,000 EUR     | 53,813 EUR    | 44.5%    | 68,945 EUR       | 28.9%    |
| 98,000 EUR     | 54,293 EUR    | 44.6%    | 69,581 EUR       | 29.0%    |
| 99,000 EUR     | 54,773 EUR    | 44.7%    | 70,217 EUR       | 29.1%    |
| 100,000 EUR    | 55,253 EUR    | 44.7%    | 70,853 EUR       | 29.1%    |
+----------------+---------------+----------+------------------+----------+
