use strict;
use Test::More 0.98;

use Iterator::Chain;

my $iter1 = Iterator::Chain->new([1, 2, 3, 4, 5, 6, 7], 10, sub {
    return +{
        label  => 'iter1',
        max_id => shift,
    };
});

my $iter2 = Iterator::Chain->new([8, 9, 10, 11, 12, 13, 14], 10, sub {
    return +{
        label  => 'iter2',
        max_id => shift,
    };
});

my $iter = $iter1->chain($iter2);

my @rv;
while (my $item = $iter->next) {
    push @rv, $item;
    last if scalar(@rv) >= 10;
}
note explain \@rv;

is_deeply \@rv, [(1..10)];

if (my $item = $iter->next) {
    is_deeply $iter->cb($item), +{
        label  => 'iter2',
        max_id => 11,
    };
}

done_testing;
