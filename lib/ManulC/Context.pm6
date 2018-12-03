unit class Context;

# Simple context object. Implements entering/exiting contexts.

has BagHash $!active-now .= new;

proto method enter (|) {*}
multi method enter ( Str $name ) {
    $!active-now{ $name }++;
}
multi method enter ( @names ) {
    $!active-now{ $_ }++ for @names;
}

proto method exit (|) {*}
multi method exit ( Str $name ) {
    $!active-now{ $name }--;
}
multi method exit ( @names ) {
    $!active-now{ $_ }-- for @names;
}

method reset ( Str $name ) {
    $!active-now{ $name }:delete;
}

method active ( Str $name ) {
    ? $!active-now{ $name };
}

method activations ( Str $name ) { $!active-now{ $name } }

proto method wrap (|) {*}

multi method wrap ( @names is copy, &code, |args ) {
    # XXX LEAVE would be more reasonable here. But, unfortunately, it's broken when a loop is used inside it.
    CATCH { self.exit: @names; $_.rethrow };

    self.enter( @names );

    my $rc = code( |args );
    self.exit( @names );
    $rc;
}

multi method wrap ( Str $name, &code, |args ) {
    samewith( [$name], &code, |args )
}

multi method wrap ( Pair $ctx-block where { .value ~~ Callable } ) {
    samewith( [ $ctx-block.key ], $ctx-block.value )
}

multi infix:<+> ( Context $ctx, Str $name ) is export {
    $ctx.enter( $name )
}

multi infix:<-> ( Context $ctx, Str $name ) is export {
    $ctx.exit( $name )
}

multi infix:<has> ( Context $ctx, Str $name ) is export {
    $ctx.active( $name )
}
