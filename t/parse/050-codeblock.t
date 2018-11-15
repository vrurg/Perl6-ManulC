use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;

plan 2;

my Int $*md-indent-width;
my Regex $*md-quotable;
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
            name => 'basic fenced code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ~~~
                    the code goes
                      here
                    ~~~
                    CODE
            name => 'basic code block with tilde-fence',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    `````
                    the code goes
                      here
                    `````
                    CODE
            name => 'basic fenced code block with longer fence',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    `````
                    ```
                    the code goes
                      here
                    ```
                    `````
                    CODE
            name => 'backticks inside backtick-fenced codeblock',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "```\nthe code goes\n  here\n```\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    `````
                    the code goes
                      here
                    ```````
                    CODE
            name => 'basic fenced code block with closing fence longer than the opening one',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```text
                    the code goes
                      here
                    ```
                    CODE
            name => 'fenced code block with language name',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => "text", comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ``` garbage text
                    the code goes
                      here
                    ```
                    CODE
            name => 'fenced code block with "comment"',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => "garbage text", value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```text garbage text
                    the code goes
                      here
                    ```
                    CODE
            name => 'fenced code block with language and "comment"',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => "text", comment => "garbage text", value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                      ```
                      the code goes
                        here
                      ```
                    CODE
            name => 'basic indented fenced code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "the code goes\n  here\n", type => "CodeblockFenced")], type => "Doc"),
        },
        {
            text => q:to/CODE/,
                    ```
                    ```
                    CODE
            name => 'empty fenced code block',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, value => "", type => "CodeblockFenced")], type => "Doc"),
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

subtest "Invalid" => {
    my @tests = 
        {
            text => q:to/CODE/,
                    ````
                    the code goes
                      here
                    ```
                    CODE
            name => 'fenced fencing, length mismatch',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainData.new(value => "````\nthe code goes\n  here\n``", type => "PlainData"), ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
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
