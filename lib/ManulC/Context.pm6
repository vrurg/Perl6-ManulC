unit class Context;
use WhereList;

# Simple context object. Implements entering/exiting contexts.

has BagHash $!active-now .= new;

proto method enter (|) {*}
multi method enter ( Str:D $name ) {
    $!active-now{ $name }++;
}
multi method enter ( @names ) {
    $!active-now{ $_ }++ for @names;
}

proto method exit (|) {*}
multi method exit ( Str:D $name ) {
    $!active-now{ $name }--;
}
multi method exit ( @names where all-items Str:D ) {
    $!active-now{ $_ }-- for @names;
}
multi method exit ( *@names where all-items Str:D ) {
    $!active-now{ $_ }-- for @names;
}

method reset ( Str:D $name ) {
    $!active-now{ $name }:delete;
}

method active ( Str:D $name ) {
    ? $!active-now{ $name };
}

method has ( Str:D $name ) {
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

multi infix:<+=> ( Context:D $ctx, Str:D $name ) is export {
    $ctx.enter( $name );
}

multi infix:<-=> ( Context:D $ctx, Str:D $name ) is export {
    $ctx.exit( $name )
}
