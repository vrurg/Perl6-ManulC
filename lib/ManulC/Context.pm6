unit class Context;

# Simple context object. Implements entering/exiting contexts.

has BagHash $!active-now .= new;

method enter ( Str $name ) {
    $!active-now{ $name }++;
}

method exit ( Str $name ) {
    $!active-now{ $name }--;
}


method reset ( Str $name ) {
    $!active-now{ $name }:delete;
}

method active ( Str $name ) {
    ? $!active-now{ $name };
}

method activations ( Str $name ) { $!active-now{ $name } }

proto method wrap (|) { * }

multi method wrap ( @names, &code, |args ) {
    @names.map: { self.enter( $_ ) };
    LEAVE @names.map: { self.exit( $_ ) };

    code( |args );
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
