use v6;
use Test;

use ManulC::Context;

plan 1;

subtest "Basics" => {
    plan 12;

    my $ctx = Context.new;

    $ctx.enter( 'ctx1' );
    ok $ctx.active( 'ctx1' ), "ctx1 activated";
    nok $ctx.active( 'ctx2' ), "ctx2 never been activated";
    $ctx.exit( 'ctx1' );
    nok $ctx.active( 'ctx1' ), "ctx1 deactivated";

    $ctx.wrap: 'ctx3' => {
        ok $ctx.active( 'ctx3' ), "ctx3 activated for a block";
    };
    nok $ctx.active( 'ctx3' ), "ctx3 deactivated after the block finished";

    $ctx.enter( 'ctx4' );
    is $ctx.activations( 'ctx4' ), 1, "ctx4 activated once";
    $ctx.enter( 'ctx4' );
    $ctx.enter( 'ctx4' );
    is $ctx.activations( 'ctx4' ), 3, "ctx4 activated 3 times";
    $ctx.exit( 'ctx4' );
    is $ctx.activations( 'ctx4' ), 2, "ctx4 deactivated once, still 2 activations remain";
    $ctx.reset( 'ctx4' );
    nok $ctx.active( 'ctx4' ), "ctx4 reset";

    $ctx += "operator";
    ok $ctx.active("operator"), "operator +";
    ok ($ctx has "operator"), "operator has";
    $ctx -= "operator";
    nok $ctx.active("operator"), "operator -";
}

done-testing;

# vim: ft=perl6
