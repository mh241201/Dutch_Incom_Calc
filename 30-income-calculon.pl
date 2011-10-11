use strict;
use warnings;
use Text::Table;

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
            salary_at_tax_rate(
                $salary,
                tax_rate($salary, 0),
            ),
        ),
        percentify(tax_rate($salary, 0)),

        # With 30% ruling
        eurofy(
            # You only pay taxes on 70% of your income
            salary_at_tax_rate(
                $salary * 0.70,
                tax_rate($salary, 1),
            )
            +
            # You get the other 30% for free
            $salary * 0.30,
        ),
        percentify(tax_rate($salary, 1)),
    ];
}

my $table = Text::Table->new(
    "Gross income\n(before taxes)",
    "Net income\n(after taxes)",
    "tax rate",
    "Net income\n(after taxes,\nwith 30% ruling)",
    "tax rate\nwith 30% ruling",
);
$table->load(@data);
print $table;
exit;

sub tax_rate {
    my ($income, $has_30_percent_ruling) = @_;

    # If you have a 1000 Euros per month you get 300 EUR tax free and
    # pay income tax is if you'd have made 700 EUR.
    $income *= 0.70 if $has_30_percent_ruling;

    # The tax rate According to Abigail:
    ## 33%     for income up to EUR 18.628
    ## 41.95%  for income between EUR 18.628 and EUR 33.436
    ## 42%     for income between EUR 33.436 and EUR 55.694
    ## 52%     for income above EUR 55.694
    my $tax_rate;
    if ($income < 18_628) {
        $tax_rate = 33;
    } elsif ($income >= 18_628 and $income < 33_436) {
        $tax_rate = 41.95;
    } elsif ($income >= 33_436 and $income < 55.694) {
        $tax_rate = 42;
    } elsif ($income >= 55.694) {
        $tax_rate = 52;
    } else {
        die "zomg error";
    }

    return $tax_rate;
}

sub salary_at_tax_rate {
    my ($salary, $tax_rate) = @_;

    return ($salary * ((100 - $tax_rate) / 100));
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
$ perl 30-income-calculon.pl 20000 80000 2000
Gross income   Net income    tax rate Net income       tax rate
(before taxes) (after taxes)          (after taxes,    with 30% ruling
                                      with 30% ruling)
1,000 EUR      670 EUR       33.00%   769 EUR          33.00%
2,000 EUR      1,340 EUR     33.00%   1,538 EUR        33.00%
3,000 EUR      2,010 EUR     33.00%   2,307 EUR        33.00%
4,000 EUR      2,680 EUR     33.00%   3,076 EUR        33.00%
5,000 EUR      3,350 EUR     33.00%   3,845 EUR        33.00%
6,000 EUR      4,020 EUR     33.00%   4,614 EUR        33.00%
7,000 EUR      4,690 EUR     33.00%   5,383 EUR        33.00%
8,000 EUR      5,360 EUR     33.00%   6,152 EUR        33.00%
9,000 EUR      6,030 EUR     33.00%   6,921 EUR        33.00%
10,000 EUR     6,700 EUR     33.00%   7,690 EUR        33.00%
11,000 EUR     7,370 EUR     33.00%   8,459 EUR        33.00%
12,000 EUR     8,040 EUR     33.00%   9,228 EUR        33.00%
13,000 EUR     8,710 EUR     33.00%   9,997 EUR        33.00%
14,000 EUR     9,380 EUR     33.00%   10,766 EUR       33.00%
15,000 EUR     10,050 EUR    33.00%   11,535 EUR       33.00%
16,000 EUR     10,720 EUR    33.00%   12,304 EUR       33.00%
17,000 EUR     11,390 EUR    33.00%   13,073 EUR       33.00%
18,000 EUR     12,060 EUR    33.00%   13,842 EUR       33.00%
19,000 EUR     11,029 EUR    41.95%   14,611 EUR       33.00%
20,000 EUR     11,610 EUR    41.95%   15,380 EUR       33.00%
21,000 EUR     12,190 EUR    41.95%   16,149 EUR       33.00%
22,000 EUR     12,771 EUR    41.95%   16,918 EUR       33.00%
23,000 EUR     13,351 EUR    41.95%   17,687 EUR       33.00%
24,000 EUR     13,932 EUR    41.95%   18,456 EUR       33.00%
25,000 EUR     14,512 EUR    41.95%   19,225 EUR       33.00%
26,000 EUR     15,093 EUR    41.95%   19,994 EUR       33.00%
27,000 EUR     15,673 EUR    41.95%   19,071 EUR       41.95%
28,000 EUR     16,254 EUR    41.95%   19,777 EUR       41.95%
29,000 EUR     16,834 EUR    41.95%   20,484 EUR       41.95%
30,000 EUR     17,415 EUR    41.95%   21,190 EUR       41.95%
31,000 EUR     17,995 EUR    41.95%   21,896 EUR       41.95%
32,000 EUR     18,576 EUR    41.95%   22,603 EUR       41.95%
33,000 EUR     19,156 EUR    41.95%   23,309 EUR       41.95%
34,000 EUR     16,320 EUR    52.00%   24,015 EUR       41.95%
35,000 EUR     16,800 EUR    52.00%   24,722 EUR       41.95%
36,000 EUR     17,280 EUR    52.00%   25,428 EUR       41.95%
37,000 EUR     17,760 EUR    52.00%   26,134 EUR       41.95%
38,000 EUR     18,240 EUR    52.00%   26,841 EUR       41.95%
39,000 EUR     18,720 EUR    52.00%   27,547 EUR       41.95%
40,000 EUR     19,200 EUR    52.00%   28,254 EUR       41.95%
41,000 EUR     19,680 EUR    52.00%   28,960 EUR       41.95%
42,000 EUR     20,160 EUR    52.00%   29,666 EUR       41.95%
43,000 EUR     20,640 EUR    52.00%   30,373 EUR       41.95%
44,000 EUR     21,120 EUR    52.00%   31,079 EUR       41.95%
45,000 EUR     21,600 EUR    52.00%   31,785 EUR       41.95%
46,000 EUR     22,080 EUR    52.00%   32,492 EUR       41.95%
47,000 EUR     22,560 EUR    52.00%   33,198 EUR       41.95%
48,000 EUR     23,040 EUR    52.00%   30,528 EUR       52.00%
49,000 EUR     23,520 EUR    52.00%   31,164 EUR       52.00%
50,000 EUR     24,000 EUR    52.00%   31,800 EUR       52.00%
51,000 EUR     24,480 EUR    52.00%   32,436 EUR       52.00%
52,000 EUR     24,960 EUR    52.00%   33,072 EUR       52.00%
53,000 EUR     25,440 EUR    52.00%   33,708 EUR       52.00%
54,000 EUR     25,920 EUR    52.00%   34,344 EUR       52.00%
55,000 EUR     26,400 EUR    52.00%   34,980 EUR       52.00%
56,000 EUR     26,880 EUR    52.00%   35,616 EUR       52.00%
57,000 EUR     27,360 EUR    52.00%   36,252 EUR       52.00%
58,000 EUR     27,840 EUR    52.00%   36,888 EUR       52.00%
59,000 EUR     28,320 EUR    52.00%   37,524 EUR       52.00%
60,000 EUR     28,800 EUR    52.00%   38,160 EUR       52.00%
61,000 EUR     29,280 EUR    52.00%   38,796 EUR       52.00%
62,000 EUR     29,760 EUR    52.00%   39,432 EUR       52.00%
63,000 EUR     30,240 EUR    52.00%   40,068 EUR       52.00%
64,000 EUR     30,720 EUR    52.00%   40,704 EUR       52.00%
65,000 EUR     31,200 EUR    52.00%   41,340 EUR       52.00%
66,000 EUR     31,680 EUR    52.00%   41,976 EUR       52.00%
67,000 EUR     32,160 EUR    52.00%   42,612 EUR       52.00%
68,000 EUR     32,640 EUR    52.00%   43,248 EUR       52.00%
69,000 EUR     33,120 EUR    52.00%   43,884 EUR       52.00%
70,000 EUR     33,600 EUR    52.00%   44,520 EUR       52.00%
71,000 EUR     34,080 EUR    52.00%   45,156 EUR       52.00%
72,000 EUR     34,560 EUR    52.00%   45,792 EUR       52.00%
73,000 EUR     35,040 EUR    52.00%   46,428 EUR       52.00%
74,000 EUR     35,520 EUR    52.00%   47,064 EUR       52.00%
75,000 EUR     36,000 EUR    52.00%   47,700 EUR       52.00%
76,000 EUR     36,480 EUR    52.00%   48,336 EUR       52.00%
77,000 EUR     36,960 EUR    52.00%   48,972 EUR       52.00%
78,000 EUR     37,440 EUR    52.00%   49,608 EUR       52.00%
79,000 EUR     37,920 EUR    52.00%   50,244 EUR       52.00%
80,000 EUR     38,400 EUR    52.00%   50,880 EUR       52.00%
81,000 EUR     38,880 EUR    52.00%   51,516 EUR       52.00%
82,000 EUR     39,360 EUR    52.00%   52,152 EUR       52.00%
83,000 EUR     39,840 EUR    52.00%   52,788 EUR       52.00%
84,000 EUR     40,320 EUR    52.00%   53,424 EUR       52.00%
85,000 EUR     40,800 EUR    52.00%   54,060 EUR       52.00%
86,000 EUR     41,280 EUR    52.00%   54,696 EUR       52.00%
87,000 EUR     41,760 EUR    52.00%   55,332 EUR       52.00%
88,000 EUR     42,240 EUR    52.00%   55,968 EUR       52.00%
89,000 EUR     42,720 EUR    52.00%   56,604 EUR       52.00%
90,000 EUR     43,200 EUR    52.00%   57,240 EUR       52.00%
91,000 EUR     43,680 EUR    52.00%   57,876 EUR       52.00%
92,000 EUR     44,160 EUR    52.00%   58,512 EUR       52.00%
93,000 EUR     44,640 EUR    52.00%   59,148 EUR       52.00%
94,000 EUR     45,120 EUR    52.00%   59,784 EUR       52.00%
95,000 EUR     45,600 EUR    52.00%   60,420 EUR       52.00%
96,000 EUR     46,080 EUR    52.00%   61,056 EUR       52.00%
97,000 EUR     46,560 EUR    52.00%   61,692 EUR       52.00%
98,000 EUR     47,040 EUR    52.00%   62,328 EUR       52.00%
99,000 EUR     47,520 EUR    52.00%   62,964 EUR       52.00%
100,000 EUR    48,000 EUR    52.00%   63,600 EUR       52.00%





