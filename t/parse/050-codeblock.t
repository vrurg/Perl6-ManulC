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
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "        ", value => "Continue with\na code\nblock\n", type => "CodeblockStd"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Finish with another\nparagraph...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
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
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "        ", value => "Continue with\na code\nblock\n", type => "CodeblockStd"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Finish with another\nparagraph...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{
Start with a 
paragraph

        Continue with
        a code
        block},
            name => 'code block at the end',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Start with a \nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "        ", value => "Continue with\na code\nblock", type => "CodeblockStd")], type => "Doc"),
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
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockStd.new(indent => "    ", value => "Multi-indent\n  code\n    block\n      span\n        over several\n          lines\n", type => "CodeblockStd")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```
                    the code goes
                      here
                    ```
                    CODE
            name => 'basic GitHub-like code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockGithub")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```text
                    the code goes
                      here
                    ```
                    CODE
            name => 'GitHub-like code block with language name',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => "text", comment => Str, value => "the code goes\n  here\n", type => "CodeblockGithub")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ``` garbage text
                    the code goes
                      here
                    ```
                    CODE
            name => 'GitHub-like code block with "comment"',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => Str, comment => "garbage text", value => "the code goes\n  here\n", type => "CodeblockGithub")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```text garbage text
                    the code goes
                      here
                    ```
                    CODE
            name => 'GitHub-like code block with language and "comment"',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => "text", comment => "garbage text", value => "the code goes\n  here\n", type => "CodeblockGithub")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                      ```
                      the code goes
                        here
                      ```
                    CODE
            name => 'basic indented GitHub-like code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockGithub")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```
                    ```
                    CODE
            name => 'empty GitHub-like code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockGithub.new(language => Str, comment => Str, value => "", type => "CodeblockGithub")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        #diag $res.ast.dump;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #diag $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
