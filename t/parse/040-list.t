use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

subtest "Basic elements", {
    plan 5;

    my Int $*indent-width = 4;
    my ($text, $res);

    for 0..^$*indent-width -> $iwidth {
        $text = " " x $iwidth;
        $res = MDParse( $text, rule => "md-li-indent" );
        ok so $res, "{$iwidth}-space indent";
    }

    nok so MDParse( "    ", rule => "md-li-indent" ), "4-space indent is too long";
}

subtest "Bullet list", {
    plan 10;
    my ( $text, $res );
    my Int $*indent-width = 4;

    $text = qq{- Item 1
- Item 2
- Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "simplest";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "simplest structure";
 
    $text = qq{- Item 1
* Item 2
+ Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "mixed starters";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "mixed starters structure";
 
    $text = qq{- Item 1
   * Item 2
+ Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "indented items";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "indented items structure";
 
    $text = qq{- Item 1
with second line
* Item 2
+ Item 3
 and line 3.2};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "multi-line items";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "with second line", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => " and line 3.2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "multi-line items structure";
 
    $text = qq{- Item 1
with second line

 And one more
 paragraph
* Item 2

 Has a second
paragraph

+ Item 3
 and line 3.2

 And a paragraph at the end};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "multi-line items";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "-", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "with second line", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And one more", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => " paragraph", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Has a second", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "paragraph", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => " and line 3.2", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "And a paragraph at the end", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "multi-line items structure";
};

subtest "Numbered list", {
    my ( $text, $res );
    my Int $*indent-width = 4;

    $text = qq{1. Item 1
1. Item 2
1. Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "simplest";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "simplest structure";

    $text = qq{1. Item 1
3. Item 2
2. Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "order of numbers is irrelevant";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "3.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "2.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "mixed order structure";

    $text = qq{1.1 Item 1
1.2 Item 2
1.3 Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "dotted notation";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "1.1", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "1.2", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "1.3", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "dotted notation structure";

    #say MDDumpAST( $res.ast );
    #say $res.ast.perl;
};

subtest "Mixed", {
    plan 4;
    my ( $text, $res );
    my Int $*indent-width = 4;

    $text = qq{* Item 1
+ Item 2
1. Item 3};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "seemingly numbered item is a second item line";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "1. Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "second item line structure";

    $text = qq{1. Item 1

2. Item <b>2</b>

   Links to <a hre="http://foo.bar/baz">somewhere &amp; nowhere</a>...};

    $res = MDParse( $text, :rule('md-list') );
    ok so $res, "with HTML elements";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "2.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "2", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Links to ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<a hre=\"http://foo.bar/baz\">", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "somewhere ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "\&amp;", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " nowhere", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</a>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "...", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "HTML elements structure";

        #diag MDDumpAST( $res.ast );
        #diag $res.ast.perl;
}

subtest "Sublists", {
    my ( $text, $res );
    my Int $*indent-width = 4;

    $text = qq{1. Item1
Item 1a
  Item 1b

    * Subitem 1.1
Subitem 1.1a
    * Subitem 1.2

      SubPara <b>1.2.1</b>

  Para 1.1a
Para 1.1a line 2
  2. Item 2
Item2.1

  Para 2a

1. Item 3
Item 3a

 Para 3.1a
Para 3.1a line 2

  Para 3.2a};

    $res = MDParse( $text, :rule('md-list') );

    ok so $res, "sublist";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1a", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "  Item 1b", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdSublist.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.1a", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Subitem 1.2", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "SubPara ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "1.2.1", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "Sublist"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 1.1a", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 1.1a line 2", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "2.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item2.1", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 2a", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "1.", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3a", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 3.1a", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 3.1a line 2", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Para 3.2a", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "sublist structure";
    
        #diag MDDumpAST( $res.ast );
        #diag $res.ast.perl;
};

subtest "Badly formatted", {
    plan 1;
    my ( $text, $res );
    my Int $*indent-width = 4;

    $text = qq{* Item 1
+ Item 2

1. Item 3};

    $res = MDParse( $text, :rule('md-list') );
    nok so $res, "mix of ordered/unordered";
}

#`[
subtest sub bList {
    plan 2;

    my $text;

#`(
    my $text = qq{1. Item1
  Item 1a
  Item 1b

    * Subitem 1.1
      Subitem 1.1a
    * Subitem 1.2

      SubPara 1.2.1

  Para 1.1a
  Para 1.1b
  2. Item 2
  Item2.1

  Para 2a <a href="123"> &amp;

1. Item 3
Item 3a

Para 3.1a
Para 3.1b

  Para 3.2a};
)

    $text = qq{1. Item1

    Item1 Paragraph
    over <em>few</em>
    lines
    * Subitem 1.1
subline 1.1
      Subitem 1.1a
    * Subitem 1.2


      SubPara 1.2.1
1. Item last};

    say "«", $text, "»";
    my $*md-line = 1;
    #my $mdres = Markdown.parse( $li-body, rule => 'mdLItemBody', actions => MDGActions.new );
    my $mdres = Markdown.parse( $text, rule => 'md-list', actions => MDGActions.new );

    bail-out "Parse failed" unless so $mdres;

    say $mdres;
    say "MADE:",MDDumpAST( $mdres.made );

    #is-deeply
    #    $mdres,
    #    Match.new(pos => 93, from => 0, hash => Map.new((:mdBQLine([Match.new(pos => 16, from => 0, hash => Map.new((:mdBQLineBody(Match.new(pos => 16, from => 2, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 16, from => 15, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 25, from => 16, hash => Map.new((:mdBQLineBody(Match.new(pos => 25, from => 18, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 25, from => 24, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 27, from => 25, hash => Map.new((:mdBQLineBody(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 43, from => 27, hash => Map.new((:mdBQLineBody(Match.new(pos => 43, from => 29, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 43, from => 42, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 45, from => 43, hash => Map.new((:mdBQLineBody(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 64, from => 45, hash => Map.new((:mdBQLineBody(Match.new(pos => 64, from => 47, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 64, from => 63, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 68, from => 64, hash => Map.new((:mdBQLineBody(Match.new(pos => 68, from => 66, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 68, from => 67, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 82, from => 68, hash => Map.new((:mdBQLineBody(Match.new(pos => 82, from => 70, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 82, from => 81, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 84, from => 82, hash => Map.new((:mdBQLineBody(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 93, from => 84, hash => Map.new((:mdBQLineBody(Match.new(pos => 93, from => 86, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 93, from => 92, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)]))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDHeading.new(level => 1, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDHeading.new(level => 2, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote")),
    #    "complex blockquote";

    #is-deeply
    #    $mdres.made,
    #    ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDHeading.new(level => 1, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDHeading.new(level => 2, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"),
    #    "complex blockquote parsed structure";
}, "Bullet list";

subtest "Inlined list", {
    my $text=q:to/TEXT/;
Paragraph consisting
of a couple
of lines

With another paragraph
following

* Item 1
- Item 2
+ Item 3

Finish
TEXT

    my $mdres = MDParse( $text );
    say "Inlined:",$mdres;
    ok True, "Just";
};

subtest {
    ok "Simply fine";
}, "Ordered list";
]

done-testing;

# vim: ft=perl6
