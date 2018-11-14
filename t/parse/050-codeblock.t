use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;

plan 1;

my Int $*md-indent-width;
my Str @*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

subtest "Valid" => {
    my @tests = 
        {
            text => q:to/CODE/,
                    Start with a 
                    paragraph

                            Continue with
                            a code
                            block

                    Finish with another
                    paragraph...
                    CODE
            name => 'simple code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeBlock.new(indent => "        ", value => "Continue with\na code\nblock\n", type => "CodeBlock"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Finish with another\nparagraph...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    Start with a 
                    paragraph

                            Continue with
                            a code
                            block
                    Finish with another
                    paragraph...
                    CODE
            name => 'no blank line',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeBlock.new(indent => "        ", value => "Continue with\na code\nblock\n", type => "CodeBlock"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Finish with another\nparagraph...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{
Start with a 
paragraph

        Continue with
        a code
        block},
            name => 'code block at the end',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeBlock.new(indent => "        ", value => "Continue with\na code\nblock", type => "CodeBlock")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                        Multi-indent
                          code
                            block
                              span
                                over several
                                  lines
                    CODE
            name => 'multi-indented code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeBlock.new(indent => "    ", value => "Multi-indent\n  code\n    block\n      span\n        over several\n          lines\n", type => "CodeBlock")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #diag $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
