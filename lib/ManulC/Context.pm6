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

multi method wrap ( Str $name, &code ) {
    self.enter( $name );
    LEAVE self.exit( $name );

    code
}

multi method wrap ( Pair $ctx-block where { .value ~~ Callable } ) {
    samewith( $ctx-block.key, $ctx-block.value )
}
