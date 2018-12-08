use v6;
use lib q<./build-tools/lib>;
use MCTest;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

my Int $*md-indent-width;
my Str $*md-line-prefix;
my Regex $*md-quotable;
my $*md-line-end;
my Bool %*md-line-elems;

plan 9;

subtest "Basics", {
    my @tests = {
        text => qq{
A paragraph
with a * \\* couple
of lines&dot;.

Then another one

And a final one.
With more than <a
href="123">one</a> line too.},
        name => "simple document",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A paragraph\nwith a ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "*", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "*", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => " couple\nof lines", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "\&dot;", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => ".", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Then another one", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And a final one.\nWith more than ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<a\nhref=\"123\">", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "one", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</a>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " line too.", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    {
        text => q{1\.2\e\\\\f},
        name => 'escaped chars',
        struct => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "1", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => ".", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "2\\e", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\\", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "f", type => "PlainStr")], type => "Line"),
        rule => 'md-line',
    },
    ;

    md-test-structure( @tests );
}

subtest "Blank space", {
    my @tests =
    {
        text => q{
},
        name => "single newline",
        struct => ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"),
    },
    {
        text => qq{\n  },
        name => "single newline and spaces",
        struct => ManulC::Parser::MD::MdBlankSpace.new(value => "\n  ", type => "BlankSpace"),
    },
    {
        text => qq{\n  \n},
        name => "nl, spaces, nl",
        struct => ManulC::Parser::MD::MdBlankSpace.new(value => "\n  \n", type => "BlankSpace"),
    },
    ;

    md-test-structure( @tests, rule => 'md-blank-space' );
}

subtest "Paragraphs" => {
    my @tests =
    {
        text => q{Single line},
        name => "single line",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    {
        text => q{First line
Second line
Third line},
        name => "multi-line",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    {
        text => q{
First line
Second line
Third line
},
        name => "multi-line, nl-surrounded",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    {
        text => q{
First line
Second line
Third line

Second paragraph
ends here

And fourth starts here...
},
        name => "multi-paragraph, nl-surrounded",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second paragraph\nends here", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And fourth starts here...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    {
        text => q{
First line
Second line
Third line

Second paragraph
ends here

And fourth starts here...

},
        name => "multi-paragraph, nl-surrounded, blank space ended",
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "First line\nSecond line\nThird line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second paragraph\nends here", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And fourth starts here...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph")], type => "Doc"),
    },
    ;

    md-test-structure( @tests );
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

    md-test-structure( @tests );
}

subtest "Invalid Headings" => {
    my @tests =
        {
            text => q{
Second Level
-------=----
            },
            name => 'mixed underline chars',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Second Level\n-------=----", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "            ", type => "BlankSpace")], type => "Paragraph")], type => "Doc"),
        },
        ;

        md-test-structure( @tests );
}

subtest "Quoting" => {
    my @tests =
        {
            text => q{A line with \a quoted\. Symbols \&...},
            name => 'basic quoting',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A line with \\a quoted", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => ".", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => " Symbols ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\&", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "...", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{With a newline\
quoting
and without},
            name => 'newline quoting',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "With a newline", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\n", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "quoting\nand without", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

subtest "Verbatim" => {
    my @tests =
        {
            text => q:to/MD/,
                    Paragraph `with verbatim` text
                    MD
            name => 'basic verbatim',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "`", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdPlainStr.new(value => "with verbatim", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Paragraph ````with verbatim```` text
                    MD
            name => 'verbatim in multiple backticks',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "````", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdPlainStr.new(value => "with verbatim", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Paragraph ` with verbatim ` text
                    MD
            name => 'verbatim with delimiting spaces',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "`", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdPlainStr.new(value => "with verbatim", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Paragraph ```` with verbatim ```` text
                    MD
            name => 'verbatim with delimiting spaces and multiple backticks',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "````", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdPlainStr.new(value => "with verbatim", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Verbatim with backtick: ` ` ` - and text
                    MD
            name => 'verbatim with backtick inside',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Verbatim with backtick: ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "`", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " - and text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Verbatim with backticks: ``` ` `` ``` - and text
                    MD
            name => 'verbatim with backticks inside',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Verbatim with backticks: ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "```", space => Str, attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial"), ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " - and text", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

subtest "Horizontal rule" => {
    my @tests =
        {
            text => q:to/MD/,
                    Paragraph 1

                    ----

                    Paragraph 2
                    MD
            name => 'basic hrule',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdHrule.new(value => "----\n", type => "Hrule"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph 2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q:to/MD/,
                    Paragraph 1

                    ***********

                    Paragraph 2
                    MD
            name => 'basic hrule',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdHrule.new(value => "***********\n", type => "Hrule"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph 2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

subtest "Horizontal rules: variations", {
    if False {
        skip "NO HORIZONTAL RULES TESTING", 1;
    }
    else {
        plan 5186;
        my $para1 = qq{A paragraph\n\n};
        my $para2 = qq{\n\nFinal paragraph};

        my $c = Channel.new;

        sub gen {
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
                                $c.send( $hrule )
                            }
                        }
                    }
                }
            }
        }

        my $l = Lock.new;

        sub test-hrule ( $hrule ) {

            my Int $*md-indent-width;
            my Str $*md-line-prefix;
            my Regex $*md-quotable;
            my $*md-line-end;
            my Bool %*md-line-elems;
            my ( $text, $res );

            Markdown::prepare-globals;

            $res = MDParse( $hrule, rule => "md-hrule" );
            $l.protect({ # Some output could be lost without locking.
                ok so $res, "\"{$hrule}\": parsed";
            });
            for 0..1 -> $para1-cnt {
                for 0..1 -> $para2-cnt {
                    Markdown::prepare-globals;
                    $text = ($para1 x $para1-cnt) ~
                            $hrule
                            ~ ( $para2 x $para2-cnt )
                            ;
                    $res = MDParse( $text );
                    $l.protect( { # Some output could be lost without locking.
                        ok so $res, "\"{$hrule}\": parsed with {$para1-cnt} pre-paragraph and {$para2-cnt} post-paragraph";
                        ok so $res<md-doc><md-hrule>, "\"{$hrule}\": <md-hrule> is present";
                    die $res.gist unless so $res<md-doc><md-hrule>;
                    } );
                }
            }
        }

        my @w;

        @w.push: start {
            gen;
            $c.close;
        };

        my $workers = Int( $*KERNEL.cpu-cores / 2 ) || 1;
        for 1..$workers {
            @w.push: start {
                react {
                    whenever $c -> $hr {
                        test-hrule( $hr );
                    }
                }
            }
        }

        await @w;

        my ( $text, $res );
        $text = qq{* _ - _ *};
        $res = MDParse( $text, rule => "md-hrule" );
        nok so $res, "no mixed syms allowed";

        $text = qq{- - - -  - -};
        $res = MDParse( $text, rule => "md-hrule" );
        nok so $res, "only same number of delimiting spaces allowed";
    }
}

done-testing;
# vim: ft=perl6
