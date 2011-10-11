use strict;
use warnings;
use Text::Table;
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

my $table = Text::Table->new(
    "Gross income\n(before taxes)",
    "Net income\n(after taxes)",
    "Net income\n(after taxes,\nwith 30% ruling)",
);
$table->load(@data);
print $table;
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
        '44.95' => sub { $_[0] >= 18_628 and $_[0] < 33_436 },
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
Gross income   Net income    Net income
(before taxes) (after taxes) (after taxes,
                             with 30% ruling)
1,000 EUR      670 EUR       769 EUR
2,000 EUR      1,340 EUR     1,538 EUR
3,000 EUR      2,010 EUR     2,307 EUR
4,000 EUR      2,680 EUR     3,076 EUR
5,000 EUR      3,350 EUR     3,845 EUR
6,000 EUR      4,020 EUR     4,614 EUR
7,000 EUR      4,690 EUR     5,383 EUR
8,000 EUR      5,360 EUR     6,152 EUR
9,000 EUR      6,030 EUR     6,921 EUR
10,000 EUR     6,700 EUR     7,690 EUR
11,000 EUR     7,370 EUR     8,458 EUR
12,000 EUR     8,040 EUR     9,228 EUR
13,000 EUR     8,710 EUR     9,997 EUR
14,000 EUR     9,380 EUR     10,766 EUR
15,000 EUR     10,050 EUR    11,535 EUR
16,000 EUR     10,720 EUR    12,304 EUR
17,000 EUR     11,390 EUR    13,073 EUR
18,000 EUR     12,060 EUR    13,842 EUR
19,000 EUR     12,685 EUR    14,611 EUR
20,000 EUR     13,235 EUR    15,380 EUR
21,000 EUR     13,786 EUR    16,148 EUR
22,000 EUR     14,336 EUR    16,917 EUR
23,000 EUR     14,887 EUR    17,686 EUR
24,000 EUR     15,437 EUR    18,456 EUR
25,000 EUR     15,988 EUR    19,225 EUR
26,000 EUR     16,538 EUR    19,994 EUR
27,000 EUR     17,089 EUR    20,730 EUR
28,000 EUR     17,639 EUR    21,415 EUR
29,000 EUR     18,190 EUR    22,101 EUR
30,000 EUR     18,740 EUR    22,786 EUR
31,000 EUR     19,291 EUR    23,471 EUR
32,000 EUR     19,841 EUR    24,157 EUR
33,000 EUR     20,392 EUR    24,842 EUR
34,000 EUR     20,959 EUR    25,527 EUR
35,000 EUR     21,539 EUR    26,213 EUR
36,000 EUR     22,119 EUR    26,898 EUR
37,000 EUR     22,699 EUR    27,583 EUR
38,000 EUR     23,279 EUR    28,269 EUR
39,000 EUR     23,859 EUR    28,954 EUR
40,000 EUR     24,439 EUR    29,639 EUR
41,000 EUR     25,019 EUR    30,324 EUR
42,000 EUR     25,599 EUR    31,010 EUR
43,000 EUR     26,179 EUR    31,695 EUR
44,000 EUR     26,759 EUR    32,380 EUR
45,000 EUR     27,339 EUR    33,066 EUR
46,000 EUR     27,919 EUR    33,751 EUR
47,000 EUR     28,499 EUR    34,437 EUR
48,000 EUR     29,079 EUR    35,127 EUR
49,000 EUR     29,659 EUR    35,833 EUR
50,000 EUR     30,239 EUR    36,539 EUR
51,000 EUR     30,819 EUR    37,245 EUR
52,000 EUR     31,399 EUR    37,951 EUR
53,000 EUR     31,979 EUR    38,657 EUR
54,000 EUR     32,559 EUR    39,363 EUR
55,000 EUR     33,139 EUR    40,069 EUR
56,000 EUR     33,688 EUR    40,775 EUR
57,000 EUR     34,168 EUR    41,481 EUR
58,000 EUR     34,648 EUR    42,187 EUR
59,000 EUR     35,128 EUR    42,893 EUR
60,000 EUR     35,608 EUR    43,599 EUR
61,000 EUR     36,088 EUR    44,305 EUR
62,000 EUR     36,568 EUR    45,011 EUR
63,000 EUR     37,048 EUR    45,717 EUR
64,000 EUR     37,528 EUR    46,423 EUR
65,000 EUR     38,008 EUR    47,129 EUR
66,000 EUR     38,488 EUR    47,835 EUR
67,000 EUR     38,968 EUR    48,541 EUR
68,000 EUR     39,448 EUR    49,247 EUR
69,000 EUR     39,928 EUR    49,953 EUR
70,000 EUR     40,408 EUR    50,659 EUR
71,000 EUR     40,888 EUR    51,365 EUR
72,000 EUR     41,368 EUR    52,071 EUR
73,000 EUR     41,848 EUR    52,777 EUR
74,000 EUR     42,328 EUR    53,483 EUR
75,000 EUR     42,808 EUR    54,189 EUR
76,000 EUR     43,288 EUR    54,895 EUR
77,000 EUR     43,768 EUR    55,601 EUR
78,000 EUR     44,248 EUR    56,307 EUR
79,000 EUR     44,728 EUR    57,013 EUR
80,000 EUR     45,208 EUR    57,688 EUR
81,000 EUR     45,688 EUR    58,324 EUR
82,000 EUR     46,168 EUR    58,960 EUR
83,000 EUR     46,648 EUR    59,596 EUR
84,000 EUR     47,128 EUR    60,232 EUR
85,000 EUR     47,608 EUR    60,868 EUR
86,000 EUR     48,088 EUR    61,504 EUR
87,000 EUR     48,568 EUR    62,140 EUR
88,000 EUR     49,048 EUR    62,776 EUR
89,000 EUR     49,528 EUR    63,412 EUR
90,000 EUR     50,008 EUR    64,048 EUR
91,000 EUR     50,488 EUR    64,684 EUR
92,000 EUR     50,968 EUR    65,320 EUR
93,000 EUR     51,448 EUR    65,956 EUR
94,000 EUR     51,928 EUR    66,592 EUR
95,000 EUR     52,408 EUR    67,228 EUR
96,000 EUR     52,888 EUR    67,864 EUR
97,000 EUR     53,368 EUR    68,500 EUR
98,000 EUR     53,848 EUR    69,136 EUR
99,000 EUR     54,328 EUR    69,772 EUR
100,000 EUR    54,808 EUR    70,408 EUR
