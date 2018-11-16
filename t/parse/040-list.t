use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;

my Int $*md-indent-width;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

subtest "Basic elements", {
    plan 5;

    my ($text, $res);

    Markdown::prepare-globals;

    for 0..^$*md-indent-width -> $iwidth {
        $text = " " x $iwidth;
        $res = MDParse( $text, rule => "md-li-indent" );
        ok so $res, "{$iwidth}-space indent";
    }

    nok so MDParse( "    ", rule => "md-li-indent" ), "4-space indent is too long";
}

subtest "Bullet list", {
    plan 10;
    my ( $text, $res );

    Markdown::prepare-globals;

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

    Markdown::prepare-globals;

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

    Markdown::prepare-globals;

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

    Markdown::prepare-globals;

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
};

subtest "With code block", {
    plan 2;
    my ( $text, $res );

    Markdown::prepare-globals;

    $text = qq{* Item 1
+ Item 2

    Included code block
    on two lines

+ Item 3};

    $res = MDParse( $text, :rule('md-list') );
    #diag $res.gist;
    ok so $res, "list with code block";
    is-deeply
        $res.ast,
        ManulC::Parser::MD::MdList.new(content => [ManulC::Parser::MD::MdLiItem.new(starter => "*", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 1", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 2", type => "PlainStr")], type => "Line")], type => "LiParagraph"), ManulC::Parser::MD::MdLiItemSpacer.new(value => "\n\n", type => "LiItemSpacer"), ManulC::Parser::MD::MdCodeblockStd.new(indent => "    ", value => "Included code block\non two lines\n", type => "CodeblockStd")], type => "LiItem"), ManulC::Parser::MD::MdLiItem.new(starter => "+", content => [ManulC::Parser::MD::MdLiParagraph.new(indent => Str, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Item 3", type => "PlainStr")], type => "Line")], type => "LiParagraph")], type => "LiItem")], type => "List"),
        "list with code block structure";
    
        #diag MDDumpAST( $res.ast );
        #diag $res.ast.perl;

}

subtest "Badly formatted", {
    plan 1;
    my ( $text, $res );

    Markdown::prepare-globals;

    $text = qq{* Item 1
+ Item 2

1. Item 3};

    $res = MDParse( $text, :rule('md-list') );
    nok so $res, "mix of ordered/unordered";
}

done-testing;

# vim: ft=perl6
