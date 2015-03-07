package Iterator::Chain;
use 5.008001;
use strict;
use warnings;

use Carp qw/croak/;
use Iterator::GroupedRange;

our $VERSION = "0.01";


sub new {
    my ($class, $provider, $count, $cb) = @_;

    my $grouped = Iterator::GroupedRange->new($provider, $count);
    my $iter = Iterator::GroupedRange->new(sub {
        $grouped->next;
    }, 1);

    return bless +{
        iters => [ +{ iter => $iter, cb => $cb } ],
    }, $class;
}

sub chain {
    my ($self, $another) = @_;
    my $class = __PACKAGE__;
    unless (ref $another && $another->isa($class)) {
        croak "1st argument must be a $class object";
    }

    my @iters = @{$self->{iters}};
    for (@{$another->{iters}}) {
        push @iters, $_;
    }

    return bless +{
        iters => \@iters,
    }, $class;
}

sub next {
    my $self = shift;
    while (@{$self->{iters}}) {
        my $iter = $self->{iters}->[0];
        my $items = $iter->{iter}->next;

        if ($items) {
            return $items->[0];
        } else {
            shift @{$self->{iters}};
        }
    }

    return undef;
}

sub has_next {
    my $self = shift;
    while (@{$self->{iters}}) {
        my $iter = $self->{iters}->[0];
        if (my $has_next = $iter->{iter}->has_next) {
            return $has_next;
        } else {
            shift @{$self->{iters}};
        }
    }

    return undef;
}

sub cb {
    my ($self, @args) = @_;
    if (@{$self->{iters}}) {
        my $iter = $self->{iters}->[0];
        if (my $cb = $iter->{cb}) {
            $cb->(@args);
        }
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

Iterator::Chain - It's new $module

=head1 SYNOPSIS

    use Iterator::Chain;

=head1 DESCRIPTION

Iterator::Chain is ...

=head1 LICENSE

Copyright (C) Yuuki Furuyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yuuki Furuyama E<lt>addsict@gmail.comE<gt>

=cut

