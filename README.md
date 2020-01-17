[![Build Status](https://travis-ci.org/holli-holzer/raku-JSON-Pretty-Sorted.svg?branch=master)](https://travis-ci.org/holli-holzer/raku-JSON-Pretty-Sorted)

NAME
====

JSON::Pretty::Sorted - JSON::Pretty, but with the ability to sort keys and data

SYNOPSIS
========

```perl6
    use JSON::Pretty::Sorted;

    # For brevity
    sub no-ws( $v ) { $v.subst( /\s/, '', :g ) }

    my %data = :c(1), :a(3), :b(2);

    # sort by key, '{"a":3,"b":2,"c":1}'
    say no-ws to-json %data, sorter => { $^a.key cmp $^b.key };

    # sort by value, '{"a":3,"b":2,"c":1}'
    say no-ws to-json %data, sorter => { $^b.value cmp $^a.value }

    my %data = foo => [ 1, 2, 3 ], bar => [5, 6, 4], baz => [ 3.1, 8.1, 1.1 ];

    # '{"bar":[6,5,4],"baz":[3.1,8.1,1.1],"foo":[3,2,1]}'
    say no-ws to-json %data,
        sorter => {
                $^a.isa( Pair ) ?? $^a.key cmp $^b.key !!
                $^a.isa( Int )  ?? $^b <=> $^a         !!
                Same;
        };

    # Same as above
    multi sub sorter( Pair $a, Pair $b ) { $a.key cmp $b.key }
    multi sub sorter( Int $a, Int $b )   { $b <=> $a }
    multi sub sorter( $a, $b )           { Same }

    say no-ws to-json( %data, :&sorter );
```

DESCRIPTION
===========

JSON::Pretty::Sorted is the same as [JSON::Pretty](https://github.com/FROGGS/p6-JSON-Pretty), but with the ability to sort the JSON output.

AUTHOR
======

holli-holzer (holli.holzer@gmail.com)

COPYRIGHT AND LICENSE
=====================

This library is free software; you can redistribute it and/or modify it under the GPL-3 License.

