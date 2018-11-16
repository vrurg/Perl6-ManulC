use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

subtest "Paragraphs/lines", {
    my ($text, $res);

    $text = qq{
A paragraph 
with a * \\* couple 
of lines&dot;.

Then another one

And a final one.
With more than <a
href="123">one</a> line too.};

    $res = MDParse( $text );
    #diag $res.gist;
    ok so $res, "simple document";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A paragraph \nwith a ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "*", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "*", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => " couple \nof lines", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "\&dot;", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => ".", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Then another one", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And a final one.\nWith more than ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<a\nhref=\"123\">", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "one", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</a>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " line too.", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        "simple document structure";
}

subtest "Escaped chars", {
    my ($text, $res);

    my Int $*md-indent-width;
    my Regex $*md-quotable;
    my Regex $*md-line-end;
    my Bool %*md-line-elems;
    Markdown::prepare-globals;

    $text = q{1\.2\e\\\\f};
    $res = MDParse( $text, rule => "md-line" );
    #diag $res.gist;
    ok so $res, "escaped chars";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "1", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => ".", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "2\\e", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\\", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "f", type => "PlainStr")], type => "Line"),
        "escaped chars structure";
};

subtest "Blank space", {
    plan 6;
    my ($text, $res);

    $text = q{
};
    $res = MDParse( $text, :rule('md-blank-space') );
    ok so $res, "single newline";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"),
        "single newline structure";

    $text = q{
  };
    $res = MDParse( $text, :rule('md-blank-space') );
    ok so $res, "single newline & spaces";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdBlankSpace.new(value => "\n  ", type => "BlankSpace"),
        "single newline & spaces structure";

    $text = q{
  
};
    $res = MDParse( $text, :rule('md-blank-space') );
    ok so $res, "nl-spaces-nl";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdBlankSpace.new(value => "\n  \n", type => "BlankSpace"),
        "single newline & spaces structure";

    #diag MDDumpAST( $res.ast );
    #diag $res.ast.perl;
}

subtest "Paragraphs" => {
    my ($text, $res);

    $text = q{Single line};
    $res = MDParse( $text );
    ok so $res, "single line";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        "single line structure";

    $text = q{First line
Second line
Third line};
    $res = MDParse( $text );
    ok so $res, "multi-line";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        "multi-line structure";

    $text = q{
First line
Second line
Third line
};
    $res = MDParse( $text );
    ok so $res, "multi-line, nl-surrounded";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        "nl-surrounded structure";

    $text = q{
First line
Second line
Third line

Second paragraph
ends here

And fourth starts here...
};
    $res = MDParse( $text );
    ok so $res, "multi-paragraph";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second paragraph\nends here", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And fourth starts here...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        "multi-paragraph structure";
    #diag $res.gist;
    #diag MDDumpAST( $res.ast );
    #diag $res.ast.perl;
};

subtest "Valid Headings" => {
    my @tests = 
        {
            text => q{
First Level
===========
            },
            name => 'underlined first level',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 1, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First Level", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q{
Second Level
------------
            },
            name => 'underlined second level',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second Level", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q{
 Second Level
-------------
            },
            name => 'heading with a leading space',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => " Second Level", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q{
# First Level Hashed
            },
            name => 'ATX first level',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 1, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First Level Hashed", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q{
## Second Level Hashed ##
            },
            name => 'ATX second level, hash-terminated',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second Level Hashed", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q{
## Second Level ## Hashed
            },
            name => 'ATX second level, contains hashes',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 2, attributes => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second Level ## Hashed", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

subtest "Invalid Headings" => {
    my @tests = 
        {
            text => q{
Second Level
-------=----
            },
            name => 'mixed underline chars',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second Level\n-------=----", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

subtest "Quoting" => {
    my @tests = 
        {
            text => q{A line with \a quoted\. Symbols \&...},
            name => 'basic quoting',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A line with \\a quoted", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => ".", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => " Symbols ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\&", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{With a newline\
quoting
and without},
            name => 'newline quoting',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "With a newline", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\n", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "quoting\nand without", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

#`[ Temorarily disable a long-running test
subtest "Horizontal rules", {
    plan 5186;
    my ( $text, $res );
    my $para1 = qq{A paragraph\n\n};
    my $para2 = qq{\n\nFinal paragraph};

    Markdown::prepare-globals;

    for qw{ * - _ } -> $sym {
        for 3..6 -> $length {
            for 0..2 -> $spaces {
                for 0,1,2,4 -> $pre-space {
                    for 0,1,2,4 -> $post-space {
                        my $hrule = 
                            ( " " x $pre-space )
                            ~ ( ( $sym xx $length ).join( " " x $spaces ) )
                            ~ ( " " x $post-space )
                            ;
                        $res = MDParse( $hrule, rule => "md-hrule" );
                        ok so $res, "parsed horizontal rule: \"{$hrule}\"";
                        for 0..1 -> $para1-cnt {
                            for 0..1 -> $para2-cnt {
                                $text = ($para1 x $para1-cnt) ~
                                        $hrule
                                        ~ ( $para2 x $para2-cnt )
                                        ;
                                $res = MDParse( $text );
                                ok so $res, "parse hrule \"{$hrule}\" with {$para1-cnt} pre-paragraph and {$para2-cnt} post-paragraph";
                                ok so $res<md-doc><md-hrule>, "<md-hrule> is present";
                                diag $res.gist unless so $res<md-doc><md-hrule>;
                            }
                        }
                    }
                }
            }
        }
    }

    $text = qq{* _ - _ *};
    $res = MDParse( $text, rule => "md-hrule" );
    nok so $res, "no mixed syms allowed";

    $text = qq{- - - -  - -};
    $res = MDParse( $text, rule => "md-hrule" );
    nok so $res, "only same number of delimiting spaces allowed";
}
]

done-testing;
# vim: ft=perl6
