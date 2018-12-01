use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

subtest "Basic" => {
    my @tests = {
            text => q:to/MD/,
                    First paragraph

                    Second paragraph
                    MD
            name => "simplest text",
            html => '',
        },
        {
            text => q:to/MD/,
                    First paragraph with &, and >, and <, and ', and )

                    Second paragraph
                    MD
            name => "special chars",
            html => '',
        },
        {
            text => q:to/MD/,
                    First paragraph with <em id="mine">HTML</em>

                    Second paragraph
                    MD
            name => "HTML elements",
            html => '',
        },
        {
            text => q:to/MD/,
                    First line \
                    Second line
                    MD
            name => "quoted newline",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with {#anch1 #anch2} anchors
                    MD
            name => "anchors",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with verbatim: `code & code`
                    MD
            name => "verbatim",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with ad-hoc link: [Link with href & title](http://anywhere.org "Title <\"text\">")
                    MD
            name => "ad-hoc link",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with ad-hoc link: [Link with href & title](http://anywhere.org "Title <\"text\">"){.Mine key=value attr="text"}
                    MD
            name => "ad-hoc link with attributes",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link: [see at][link id]

                    [Link ID]: http://nah.dont.go "Title is mine!"
                    MD
            name => "reference link",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link to a missing definition: [see at][no id]
                    MD
            name => "reference link without link definition",
            html => '',
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link: [see at][посилання]

                    [Посилання]: <http://nah.dont.go> "Загловок із \" квотуванням"
                    MD
            name => "reference link with autolinked definition",
            html => '',
        },
    ;

    for @tests -> $test {
        my $html = md2html( $test<text> );
        diag $html;
        is $html, $test<html>, $test<name>;
    }
}
