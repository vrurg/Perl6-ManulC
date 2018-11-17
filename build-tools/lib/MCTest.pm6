use v6;
unit module MCTest;
use ManulC::Parser::MD;
use Test;

sub md-test-structure ( @tests, :$rule?, :$diag-match?, :$diag-ast? ) is export {

    my Int $*md-indent-width;
    my Regex $*md-quotable;
    my Regex $*md-line-end;
    my Bool %*md-line-elems;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text>, :$rule );
        diag $res.gist if $diag-match;
        diag $res.ast.dump if $diag-ast;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}
