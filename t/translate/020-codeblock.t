use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

plan 1;

subtest "Basic" => {
    my @tests =
        {
            text => q:to/MD/,
                    First paragraph

                        use v6;
                        use ManulC::Parser::MD;

                    Second paragraph
                    MD
            name => "indented code",
            html => q:to/HTML/,
                    <p class="mcEntity mcContainer mcParagraph">First paragraph</p>
                    <pre class="mcEntity mcCode"><code class="mcEntity mcCode">use v6;
                    use ManulC::Parser::MD;</code></pre>
                    <p class="mcEntity mcContainer mcParagraph">Second paragraph</p>
                    HTML
        },
        {
            text => q:to/MD/,
                    First paragraph
                    ``` perl
                    use v6;
                    use ManulC::Parser::MD;
                    ```

                    Second paragraph
                    MD
            name => "fenced code",
            html => q:to/HTML/,
                    <p class="mcEntity mcContainer mcParagraph">First paragraph</p>
                    <pre class="mcEntity mcCode perl"><code class="mcEntity mcCode perl">use v6;
                    use ManulC::Parser::MD;</code></pre><p class="mcEntity mcContainer mcParagraph">Second paragraph</p>
                    HTML
        },
        {
            text => q:to/MD/,
                    First paragraph
                    ``` perl {#sample .aClass key="value" attr=something}
                    use v6;
                    use ManulC::Parser::MD;
                    ```

                    Second paragraph
                    MD
            name => "fenced code with attributes",
            html => q:to/HTML/,
                    <p class="mcEntity mcContainer mcParagraph">First paragraph</p>
                    <pre class="mcEntity mcCode perl aClass" id="sample" key="value" attr=something><code class="mcEntity mcCode perl">use v6;
                    use ManulC::Parser::MD;</code></pre><p class="mcEntity mcContainer mcParagraph">Second paragraph</p>
                    HTML
        },
        ;

    md-test-MD2HTML( @tests );
}

done-testing;

# vim: ft=perl6
