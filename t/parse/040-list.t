use v6;
use lib q<./build-tools/lib>;
use Test;
use MCTest;
use ManulC::Parser::MD;

my Int $*md-indent-width;
my Str $*md-line-prefix;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;
my %*md-link-definitions;

subtest "Bullet list", {
    my @tests =
                {
                    text => q:to/TST/,
                            - Item 1
                            - Item 2
                            - Item 3
                            TST
                    name => "simplest",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            + Item 1
                               * Item 2
                            + Item 3
                            TST
                    name => "indented items",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            * Item 1
                            with second line
                            * Item 2
                            * Item 3
                                and line 3.2
                            TST
                    name => "multi-line items",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1\nwith second line", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3\n    and line 3.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1
                            with second line

                              And some more
                              text
                            - Item 2

                              Has a second
                            paragraph

                            - Item 3
                                and line 3.2

                              And some text at the end
                            TST
                    name => "multi-line items with paragraphs",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1\nwith second line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And some more\n  text", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Has a second\nparagraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3\n    and line 3.2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And some text at the end", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                ;

    md-test-structure( @tests );
}

subtest "Starters" => {
    my $*md-li-starter;

    my @tests = {
            text => q{1) },
            name => 'bracketed number',
            struct => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "1", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"),
            rule => 'md-li-item-start',
    },
    {
            text => q{(1) },
            name => 'bracket-enclosed number',
            struct => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumEmbraceStart.new(number => "1", value => "(", type => "LiNumEmbraceStart"), type => "LiItemStart"),
            rule => 'md-li-item-start',
    },
    ;

    md-test-structure( @tests, init => { $*md-li-starter = Nil } );
}

subtest "Numbered list", {
    my @tests =
                {
                    text => q:to/TST/,
                            1. Item 1
                            1. Item 2
                            1. Item 3
                            TST
                    name => "simplest",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1. Item 1
                            3. Item 2
                            2. Item 3
                            TST
                    name => "irrelevant order of numbers",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "3", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "2", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            #. Item 1
                            #. Item 2
                            #. Item 3
                            TST
                    name => "with hashes",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1) Item 1
                            2) Item 2
                            1) Item 3
                            TST
                    name => "bracketed notation",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "1", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "2", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "1", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            #) Item 1
                            #) Item 2
                            #) Item 3
                            TST
                    name => "hashed bracketed notation",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "#", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "#", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "#", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            (1) Item 1
                            (2) Item 2
                            (1) Item 3
                            TST
                    name => "bracket-embraced notation",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumEmbraceStart.new(number => "1", value => "(", type => "LiNumEmbraceStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumEmbraceStart.new(number => "2", value => "(", type => "LiNumEmbraceStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumEmbraceStart.new(number => "1", value => "(", type => "LiNumEmbraceStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                ;
    md-test-structure( @tests );
}

subtest "Compact/Loose" => {
    my @tests =
        {
            text => q:to/TXT/,
                    * Item1

                    * Item2

                    * Item3


                    TXT
            name => 'loose list',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n\n", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q:to/TXT/,
                    * Item1
                    * Item2
                    * Item3

                    TXT
            name => 'compact list',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Doc"),
        },
        {
            text => q:to/TXT/,
                    * Item1
                      1. Subitem 1.1
                      1. Subitem 1.2

                      Additional text
                    * Item2
                    * Item3

                    TXT
            name => 'compact list with sublist and paragraph',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item1", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Additional text", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Doc"),
        },
        ;

        md-test-structure( @tests );
}

subtest "Items with bodies" => {
    my @tests =
                {
                    text => q:to/TST/,
                            1. Item 1

                               2. Subtitem 1.1

                                  With paragraphs

                                  and text element

                            3. Item 2
                            TST
                    name => 'sublist with paragraph and text elements',
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "2", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subtitem 1.1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "With paragraphs", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "and text element", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "3", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1
                              1. Subitem 1.1
                              1. Subitem 1.2
                            -  Item 2
                             +. second line
                            -     Item 3
                               +. Subitem 3.1
                               +. Subitem 3.2 (no, just two more lines of this item)
                            - Item 4
                               + Subitem 4.1
                               + Subitem 4.2

                            - Item 5
                              is a loose item

                               + Subitem 5.1
                               + Subitem 5.2

                            + Item 6
                              #. Subitem 6.1
                                 1. Subitem 6.1.1
                                 1. Subitem 6.1.2

                              #. Subitem 6.2
                              with second line
                                 1. Subitem 6.2.1
                                 1. Subitem 6.2.2
                            +

                             Item 7
                            TST
                    name => "a few variations",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => "  ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2\n +. second line", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdCodeblockStd.new(indent => "    ", value => "Item 3\n", type => "CodeblockStd"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "+. Subitem 3.1\n   +. Subitem 3.2 ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "(", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "no, just two more lines of this item", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ")", type => "ChrSpecial")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 4", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 4.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 4.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 5\n  is a loose item", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 5.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "   ", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 5.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 6", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.1", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "     ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.1.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "     ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.1.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "  ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.2\n  with second line", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "     ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.2.1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "     ", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 6.2.2\n+", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "LiItem")], type => "List")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => " Item 7", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1
                                  1. too deep 1.1
                                  1. too deep 1.2
                            TST
                    name => "too deep indentation",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1\n      1. too deep 1.1\n      1. too deep 1.2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1

                                  1. just a code block
                                  1. of Item 1
                            TST
                    name => "code block included",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "      ", value => "1. just a code block\n1. of Item 1\n", type => "CodeblockStd")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1. Item 1
                               ```
                               1. just a code block
                               1. of Item 1
                               ```
                            TST
                    name => "fenced code block included",
                    struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph"), ManulC::Parser::MD::MdCodeblockFenced.new(language => Str, comment => Str, attrs => ManulC::Parser::MD::MdAttributes, value => "1. just a code block\n1. of Item 1\n", type => "CodeblockFenced")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1. Item 1
                                       ```
                                       1. just a code block
                                       1. of Item 1
                                       ```
                            TST
                    name => "fenced code block -- too indented",
                    struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1\n           ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "```", attrs => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdPlainStr.new(value => "\n           1. just a code block\n           1. of Item 1\n", type => "PlainStr")], type => "Verbatim")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1

                                > 1. Quoted Item 1
                                > 1. Quoted Item 2
                            TST
                    name => "blockquote included",
                    struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Quoted Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Quoted Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Blockquote")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1

                              With a
                              paragraph

                              And one
                            more

                                And yet
                                another text
                            TST
                    name => "multi-paragraph",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "With a\n  paragraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And one\nmore", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And yet\n    another text", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            - Item 1

                                [link 1]: http://foo.foo
                                [link 2]: http://goo.gle

                                [link 3]: http://google.com
                            TST
                    name => "link definitions included",
                    struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {"link 1" => ManulC::Parser::MD::MdLinkDefinition.new(id => "link 1", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://foo.foo", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition"), "link 2" => ManulC::Parser::MD::MdLinkDefinition.new(id => "link 2", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://goo.gle", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition"), "link 3" => ManulC::Parser::MD::MdLinkDefinition.new(id => "link 3", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition")}, content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "link 1", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://foo.foo", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "link 2", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://goo.gle", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LinkdefParagraph"), ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "link 3", addr => ManulC::Parser::MD::MdLinkAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, attrs => ManulC::Parser::MD::MdAttributes, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "LinkdefParagraph")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                ;
    md-test-structure( @tests );
}

subtest "Mixed", {
    my @tests =
                {
                    text => q:to/TST/,
                            - Item 1
                            * Item 2
                            + Item 3
                            TST
                    name => "mixed starters",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "-", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            * Item 1
                            * Item 2
                            1. Item 3
                            TST
                    name => "bulleted with numbered-looking paragraph",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1. Item 1.
                            #. Item 2.
                            1) Item 1)
                            1) Item 2)
                            TST
                    name => "numbered, different styles",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1.", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "#", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2.", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "1", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ")", type => "ChrSpecial")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumBracketStart.new(number => "1", value => ")", type => "LiNumBracketStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ")", type => "ChrSpecial")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            * Item 1
                            + Item 2

                            1. Item 3
                            TST
                    name => "bulleted list followed by numbered",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            + Item 1
                            * Item 2
                            * Item 3

                            Paragraph

                                A code
                                block
                            TST
                    name => 'list, paragraph, code block',
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "+", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "LiItemText")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiBulletStart.new(value => "*", type => "LiBulletStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "    ", value => "A code\nblock\n", type => "CodeblockStd")], type => "Doc"),
                },
                {
                    text => q:to/TST/,
                            1. Item 1

                            2. Item <b>2</b>

                               Links to <a hre="http://foo.bar/baz">somewhere &amp; nowhere</a>...
                            TST
                    name => "with HTML elements",
                    struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "1", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => ManulC::Parser::MD::MdLiItemStart.new(align => "", spacing => " ", value => ManulC::Parser::MD::MdLiNumDotStart.new(number => "2", value => ".", type => "LiNumDotStart"), type => "LiItemStart"), content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "2", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdLiItemText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Links to ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<a hre=\"http://foo.bar/baz\">", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "somewhere ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "\&amp;", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " nowhere", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</a>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "...", type => "PlainStr")], type => "LiItemText")], type => "LiItem")], type => "List")], type => "Doc"),
                },
                ;
    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
