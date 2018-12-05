use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

plan 1;

subtest "Header" => {
    my @tests =
        {
            text => q:to/MD/,
                    Head 1
                    ======

                    Pre-face

                    Head 2
                    ------

                    Paragraph
                    MD
            name => "basic setext heading",
            html => '<h1 class="mcEntity mcContainer mcHead mcHead1">Head 1</h1>
<p class="mcEntity mcContainer mcParagraph">Pre-face</p>
<h2 class="mcEntity mcContainer mcHead mcHead2">Head 2</h2>
<p class="mcEntity mcContainer mcParagraph">Paragraph</p>
',
        },
        {
            text => q:to/MD/,
                    Head *1*
                    ======

                    Pre-face

                    Head ``2``
                    ------

                    Paragraph
                    MD
            name => "setext heading with formatting",
            html => q:to/TXT/,
                    <h1 class="mcEntity mcContainer mcHead mcHead1">Head <em class="mcEntity">1</em></h1>
                    <p class="mcEntity mcContainer mcParagraph">Pre-face</p>
                    <h2 class="mcEntity mcContainer mcHead mcHead2">Head <code class="mcEntity mcContainer mcVerbatim">2</code></h2>
                    <p class="mcEntity mcContainer mcParagraph">Paragraph</p>
                    TXT
        },
        {
            text => q:to/MD/,
                    Head 1 {.myClass}
                    ======

                    Pre-face
                    MD
            name => "setext heading with attributes",
            html => q:to/MD/,
                    <h1 class="mcEntity mcContainer mcHead mcHead1 myClass">Head 1</h1>
                    <p class="mcEntity mcContainer mcParagraph">Pre-face</p>
                    MD
        },
        {
            text => q:to/MD/,
                    # Head 1

                    Pre-face

                    ## Head 2 ##

                    Body
                    MD
            name => "basic ATX heading",
            html => q:to/MD/,
                    <h1 class="mcEntity mcContainer mcHead mcHead1">Head 1</h1>
                    <p class="mcEntity mcContainer mcParagraph">Pre-face</p>
                    <h2 class="mcEntity mcContainer mcHead mcHead2">Head 2</h2>
                    <p class="mcEntity mcContainer mcParagraph">Body</p>
                    MD
        },
        {
            text => q:to/MD/,
                    # Head __1__ ##

                    Pre-face

                    ## Head `2` ##

                    Body
                    MD
            name => "ATX heading with formatting",
            html => q:to/MD/,
                    <h1 class="mcEntity mcContainer mcHead mcHead1">Head <strong class="mcEntity">1</strong></h1>
                    <p class="mcEntity mcContainer mcParagraph">Pre-face</p>
                    <h2 class="mcEntity mcContainer mcHead mcHead2">Head <code class="mcEntity mcContainer mcVerbatim">2</code></h2>
                    <p class="mcEntity mcContainer mcParagraph">Body</p>
                    MD
        },
        {
            text => q:to/MD/,
                    # Head 1   {.myClass #head1}

                    Pre-face
                    MD
            name => "ATX heading with attributes",
            html => q:to/MD/,
                    <h1 class="mcEntity mcContainer mcHead mcHead1 myClass" id="head1">Head 1</h1>
                    <p class="mcEntity mcContainer mcParagraph">Pre-face</p>
                    MD
        },
        {
            text => q:to/MD/,
                    Paragraph 1

                    * * *

                    Paragraph 2
                    MD
            name => "horizontal rule",
            html => q:to/MD/,
                    <p class="mcEntity mcContainer mcParagraph">Paragraph 1</p>
                    <hr  class="mcEntity mcHrule" />
                    <p class="mcEntity mcContainer mcParagraph">Paragraph 2</p>
                    MD
        },
    ;

    md-test-MD2HTML( @tests );
}

done-testing;
# vim: ft=perl6
