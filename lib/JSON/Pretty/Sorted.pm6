use v6.c;

unit module JSON::Pretty::Sorted:ver<0.0.1>:auth<holli-holzer(holli.holzer@gmail.com>;

proto to-json($, :$indent = 0, :$first = 0, :&sorter = {0} ) is export {*}

my $s = 2;
multi to-json(Real:D $d, :$indent = 0, :$first = 0, :&sorter = {0}) { (' ' x $first) ~ ~$d }
multi to-json(Bool:D $d, :$indent = 0, :$first = 0, :&sorter = {0}) { (' ' x $first) ~ ($d ?? 'true' !! 'false') }
multi to-json(Str:D $d, :$indent = 0, :$first = 0, :&sorter = {0}) {
    (' ' x $first) ~ '"'
    ~ $d.trans(['"', '\\', "\b", "\f", "\n", "\r", "\t"]
            => ['\"', '\\\\', '\b', '\f', '\n', '\r', '\t'])\
            .subst(/<-[\c32..\c126]>/, { ord(~$_).fmt('\u%04x') }, :g)
    ~ '"'
}
multi to-json(Positional:D $d, :$indent = 0, :$first = 0, :&sorter = {0}) {
    return (' ' x $first) ~ "\["
            ~ ($d ?? $d.sort(&sorter).map({ "\n" ~ to-json($_, :indent($indent + $s), :first($indent + $s), :&sorter) }).join(",") ~ "\n" ~ (' ' x $indent) !! ' ')
            ~ ']';
}
multi to-json(Associative:D $d, :$indent = 0, :$first = 0, :&sorter = {0}) {
    return (' ' x $first) ~ "\{"
            ~ ($d ?? $d.sort(&sorter).map({ "\n" ~ to-json(.key, :first($indent + $s), :&sorter) ~ ' : ' ~ to-json(.value, :indent($indent + $s), :&sorter) }).join(",") ~ "\n" ~ (' ' x $indent) !! ' ')
            ~ '}';
}

multi to-json(Mu:U $, :$indent = 0, :$first = 0, :&sorter = {0} ) { 'null' }
multi to-json(Mu:D $s, :$indent = 0, :$first = 0, :&sorter = {0} ) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

sub from-json($text) is export {
    use JSON::Tiny;
    from-json($text)
}

=begin pod

=head1 NAME

JSON::Pretty::Sorted - JSON::Pretty, but with the ability to sort keys and data

=head1 SYNOPSIS

=begin code :lang<perl6>

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

=end code

=head1 DESCRIPTION

JSON::Pretty::Sorted is the same as L<JSON::Pretty|https://github.com/FROGGS/p6-JSON-Pretty>,
but with the ability to sort the JSON output.

=head1 AUTHOR

holli-holzer (holli.holzer@gmail.com)

=head1 COPYRIGHT AND LICENSE

Copyright 2019 holli-holzer

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
