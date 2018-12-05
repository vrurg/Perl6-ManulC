use v6;
unit module MCTest;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;
use Test;

sub md-test-structure ( @tests, :$rule?, :$nok?, :$diag-match?, :$diag-ast?, :$init? ) is export {

    my Int $*md-indent-width;
    my Regex $*md-quotable;
    my Regex $*md-line-end;
    my Bool %*md-line-elems;

    my $planned = 0;
    for @tests -> $tst {
        $planned++;
        $planned++ with $tst<struct>;
        $planned++ with $tst<subtest>;
    }

    plan $planned;

    for @tests -> $test {
        Markdown::prepare-globals;
        with $test<init> // $init {
            $_();
        }
        my $res = MDParse( $test<text>, :rule( $test<rule> // $rule ) );
        diag $res.gist if $diag-match || $test<diag-match>;
        if ( $diag-ast || $test<diag-ast>) && $res {
            with $res.ast {
                diag .dump;
            }
            else {
                diag "NO AST";
            }
        }
        my &tester = &ok;
        if $nok || $test<nok> {
           &tester = &nok;
        }
        tester so $res, $test<name>;
        with $test<struct> {
            if $res && $res.ast {
                is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
            } else {
                skip "NO AST" ~ ( $res ?? "" !! ", PARSE FAILED" ), 1;
            }
        }
        with $test<subtest> {
            my &st-block = {
                $test<subtest>( $res )
            };
            subtest "Custom subtest of " ~ $test<name>, &st-block;
        }
        #note $res.ast.perl;
    }
}

sub md-test-MD2HTML ( @tests ) is export {
    plan @tests.elems;

    for @tests -> $test {
        my $html = md2html( $test<text> );
        # diag $html;
        is $html, $test<html>, $test<name>;
    }
}
