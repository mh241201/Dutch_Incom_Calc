use strict;
use warnings;
use Text::TabularDisplay;
use List::Util qw(sum);

my $start = 1_000    || $ARGV[0];
my $end   = 100_000  || $ARGV[1];
my $step  = 1_000    || $ARGV[2];

my @data;
for (my $salary = $start; $salary <= $end; $salary += $step) {

    push @data => [
        # Your Gross income
        eurofy($salary),

        # Without 30% ruling
        eurofy(
            tax_each_bucket(
                divide_income_into_tax_buckets($salary),
            )
        ),

        # With a 30% ruling you only pay taxes on 70% of your income
        eurofy(
            sum(
                tax_each_bucket(
                    divide_income_into_tax_buckets($salary * 0.70),
                ),
                $salary * 0.30
            ),
        ),
    ];
}

my $table = Text::TabularDisplay->new(
    "Gross income\n(before taxes)",
    "Net income\n(after taxes)",
    "Net income\n(after taxes,\nwith 30% ruling)",
);
$table->add(@$_) for @data;
print $table->render, "\n";
exit;

sub divide_income_into_tax_buckets {
    my ($income) = @_;

    # The tax rate According to Abigail:
    ## 33%     for income up to EUR 18.628
    ## 41.95%  for income between EUR 18.628 and EUR 33.436
    ## 42%     for income between EUR 33.436 and EUR 55.694
    ## 52%     for income above EUR 55.694
    my %bucket_checks = (
        33      => sub { $_[0] < 18_628 },
        '41.95' => sub { $_[0] >= 18_628 and $_[0] < 33_436 },
        42      => sub { $_[0] >= 33_436 and $_[0] < 55_694 },
        52      => sub { $_[0] >= 55_694 }
    );

    my %bucket;
    for my $amount (1..$income) {
        my $in_bucket = 0;
        for my $bucket (keys %bucket_checks) {
            # Brute-force to keep your house warm during winter in
            # Amsterdam.
            if ($bucket_checks{$bucket}->($amount)) {
                die "panic: We already have amount <$amount> in a bucket" if $in_bucket;
                $bucket{$bucket}++;
                $in_bucket = 1;
            }
        }
    }

    return %bucket;
}

sub tax_each_bucket {
    my (%bucket) = @_;

    return sum(
        map {
            apply_tax_rate(
                $bucket{$_},
                $_,
            );
        } keys %bucket
    );
}

sub apply_tax_rate {
    my ($number, $tax_rate) = @_;

    return ($number * ((100 - $tax_rate) / 100));
}

# From perlfaq5
sub commify {
    local $_  = shift;
    1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
    return $_;
}

sub eurofy {
    my ($number) = @_;

    # Round it
    $number = int $number;

    return sprintf("%s EUR", commify($number));
}

sub percentify {
    my ($number) = @_;

    return sprintf "%.02f%%", $number;
}

__DATA__
$ perl 30-income-calculon.pl
+----------------+---------------+------------------+
| Gross income   | Net income    | Net income       |
| (before taxes) | (after taxes) | (after taxes,    |
|                |               | with 30% ruling) |
+----------------+---------------+------------------+
| 1,000 EUR      | 670 EUR       | 769 EUR          |
| 2,000 EUR      | 1,340 EUR     | 1,538 EUR        |
| 3,000 EUR      | 2,010 EUR     | 2,307 EUR        |
| 4,000 EUR      | 2,680 EUR     | 3,076 EUR        |
| 5,000 EUR      | 3,350 EUR     | 3,845 EUR        |
| 6,000 EUR      | 4,020 EUR     | 4,614 EUR        |
| 7,000 EUR      | 4,690 EUR     | 5,383 EUR        |
| 8,000 EUR      | 5,360 EUR     | 6,152 EUR        |
| 9,000 EUR      | 6,030 EUR     | 6,921 EUR        |
| 10,000 EUR     | 6,700 EUR     | 7,690 EUR        |
| 11,000 EUR     | 7,370 EUR     | 8,458 EUR        |
| 12,000 EUR     | 8,040 EUR     | 9,228 EUR        |
| 13,000 EUR     | 8,710 EUR     | 9,997 EUR        |
| 14,000 EUR     | 9,380 EUR     | 10,766 EUR       |
| 15,000 EUR     | 10,050 EUR    | 11,535 EUR       |
| 16,000 EUR     | 10,720 EUR    | 12,304 EUR       |
| 17,000 EUR     | 11,390 EUR    | 13,073 EUR       |
| 18,000 EUR     | 12,060 EUR    | 13,842 EUR       |
| 19,000 EUR     | 12,696 EUR    | 14,611 EUR       |
| 20,000 EUR     | 13,277 EUR    | 15,380 EUR       |
| 21,000 EUR     | 13,857 EUR    | 16,148 EUR       |
| 22,000 EUR     | 14,438 EUR    | 16,917 EUR       |
| 23,000 EUR     | 15,018 EUR    | 17,686 EUR       |
| 24,000 EUR     | 15,599 EUR    | 18,456 EUR       |
| 25,000 EUR     | 16,179 EUR    | 19,225 EUR       |
| 26,000 EUR     | 16,760 EUR    | 19,994 EUR       |
| 27,000 EUR     | 17,340 EUR    | 20,738 EUR       |
| 28,000 EUR     | 17,921 EUR    | 21,444 EUR       |
| 29,000 EUR     | 18,501 EUR    | 22,151 EUR       |
| 30,000 EUR     | 19,082 EUR    | 22,857 EUR       |
| 31,000 EUR     | 19,662 EUR    | 23,563 EUR       |
| 32,000 EUR     | 20,243 EUR    | 24,270 EUR       |
| 33,000 EUR     | 20,823 EUR    | 24,976 EUR       |
| 34,000 EUR     | 21,403 EUR    | 25,683 EUR       |
| 35,000 EUR     | 21,983 EUR    | 26,389 EUR       |
| 36,000 EUR     | 22,563 EUR    | 27,095 EUR       |
| 37,000 EUR     | 23,143 EUR    | 27,802 EUR       |
| 38,000 EUR     | 23,723 EUR    | 28,508 EUR       |
| 39,000 EUR     | 24,303 EUR    | 29,214 EUR       |
| 40,000 EUR     | 24,883 EUR    | 29,921 EUR       |
| 41,000 EUR     | 25,463 EUR    | 30,626 EUR       |
| 42,000 EUR     | 26,043 EUR    | 31,333 EUR       |
| 43,000 EUR     | 26,623 EUR    | 32,039 EUR       |
| 44,000 EUR     | 27,203 EUR    | 32,745 EUR       |
| 45,000 EUR     | 27,783 EUR    | 33,452 EUR       |
| 46,000 EUR     | 28,363 EUR    | 34,158 EUR       |
| 47,000 EUR     | 28,943 EUR    | 34,865 EUR       |
| 48,000 EUR     | 29,523 EUR    | 35,571 EUR       |
| 49,000 EUR     | 30,103 EUR    | 36,277 EUR       |
| 50,000 EUR     | 30,683 EUR    | 36,983 EUR       |
| 51,000 EUR     | 31,263 EUR    | 37,689 EUR       |
| 52,000 EUR     | 31,843 EUR    | 38,395 EUR       |
| 53,000 EUR     | 32,423 EUR    | 39,101 EUR       |
| 54,000 EUR     | 33,003 EUR    | 39,807 EUR       |
| 55,000 EUR     | 33,583 EUR    | 40,513 EUR       |
| 56,000 EUR     | 34,133 EUR    | 41,219 EUR       |
| 57,000 EUR     | 34,613 EUR    | 41,925 EUR       |
| 58,000 EUR     | 35,093 EUR    | 42,631 EUR       |
| 59,000 EUR     | 35,573 EUR    | 43,337 EUR       |
| 60,000 EUR     | 36,053 EUR    | 44,043 EUR       |
| 61,000 EUR     | 36,533 EUR    | 44,749 EUR       |
| 62,000 EUR     | 37,013 EUR    | 45,455 EUR       |
| 63,000 EUR     | 37,493 EUR    | 46,161 EUR       |
| 64,000 EUR     | 37,973 EUR    | 46,867 EUR       |
| 65,000 EUR     | 38,453 EUR    | 47,573 EUR       |
| 66,000 EUR     | 38,933 EUR    | 48,279 EUR       |
| 67,000 EUR     | 39,413 EUR    | 48,985 EUR       |
| 68,000 EUR     | 39,893 EUR    | 49,691 EUR       |
| 69,000 EUR     | 40,373 EUR    | 50,397 EUR       |
| 70,000 EUR     | 40,853 EUR    | 51,103 EUR       |
| 71,000 EUR     | 41,333 EUR    | 51,809 EUR       |
| 72,000 EUR     | 41,813 EUR    | 52,515 EUR       |
| 73,000 EUR     | 42,293 EUR    | 53,221 EUR       |
| 74,000 EUR     | 42,773 EUR    | 53,927 EUR       |
| 75,000 EUR     | 43,253 EUR    | 54,633 EUR       |
| 76,000 EUR     | 43,733 EUR    | 55,339 EUR       |
| 77,000 EUR     | 44,213 EUR    | 56,045 EUR       |
| 78,000 EUR     | 44,693 EUR    | 56,751 EUR       |
| 79,000 EUR     | 45,173 EUR    | 57,457 EUR       |
| 80,000 EUR     | 45,653 EUR    | 58,133 EUR       |
| 81,000 EUR     | 46,133 EUR    | 58,769 EUR       |
| 82,000 EUR     | 46,613 EUR    | 59,404 EUR       |
| 83,000 EUR     | 47,093 EUR    | 60,040 EUR       |
| 84,000 EUR     | 47,573 EUR    | 60,676 EUR       |
| 85,000 EUR     | 48,053 EUR    | 61,312 EUR       |
| 86,000 EUR     | 48,533 EUR    | 61,948 EUR       |
| 87,000 EUR     | 49,013 EUR    | 62,584 EUR       |
| 88,000 EUR     | 49,493 EUR    | 63,220 EUR       |
| 89,000 EUR     | 49,973 EUR    | 63,856 EUR       |
| 90,000 EUR     | 50,453 EUR    | 64,492 EUR       |
| 91,000 EUR     | 50,933 EUR    | 65,128 EUR       |
| 92,000 EUR     | 51,413 EUR    | 65,764 EUR       |
| 93,000 EUR     | 51,893 EUR    | 66,400 EUR       |
| 94,000 EUR     | 52,373 EUR    | 67,037 EUR       |
| 95,000 EUR     | 52,853 EUR    | 67,673 EUR       |
| 96,000 EUR     | 53,333 EUR    | 68,309 EUR       |
| 97,000 EUR     | 53,813 EUR    | 68,945 EUR       |
| 98,000 EUR     | 54,293 EUR    | 69,581 EUR       |
| 99,000 EUR     | 54,773 EUR    | 70,217 EUR       |
| 100,000 EUR    | 55,253 EUR    | 70,853 EUR       |
+----------------+---------------+------------------+
