use v6;
#`(
no precompilation;
use Grammar::Tracer;
)
use Test;
use ManulC::Parser::MD;

plan 2;

subtest "Valid" => {
    my @tests = 
        {
            text => q{![Image text](/img/foo.jpg)},
            name => 'simple image',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image"),
        },
        {
            text => q{![Image text](/img/foo.jpg "My title")},
            name => "image with simple title",
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My title", type => "PlainStr")], type => "LinkAddrTitle"), text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image"),
        },
        {
            text => q{![Image "text" > &](/img/foo.jpg "My \"title\"")},
            name => "image with special and quoted chars",
            struct =>  ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "title", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped")], type => "LinkAddrTitle"), text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image \"text\" ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image"),
        },
        {
            text => q{![Image <b>text</b>](/img/foo.jpg)},
            name => 'simple image with text with HTML',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "text", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image"),
        },
        {
            text => q{![Image reference][img id]},
            name => 'reference image',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Image reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "img id", type => "LinkAddr"), type => "LinkReference"), type => "Image"),
        },
        {
            text => q{![Image reference] [img id spaced]},
            name => 'reference image with spaces',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Image reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "img id spaced", type => "LinkAddr"), type => "LinkReference"), type => "Image"),
        },
        {
            text => q{![Image reference][]},
            name => 'reference image with text as id',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Image reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Image reference", type => "LinkAddr"), type => "LinkReference"), type => "Image"),
        },
        {
            text => q{![Image reference, spaced] []},
            name => 'reference image with text as id',
            struct => ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Image reference, spaced"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Image reference, spaced", type => "LinkAddr"), type => "LinkReference"), type => "Image"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        my Int $*md-indent-width;
        my Str @*md-quotable;
        my Regex $*md-line-end;
        my Bool %*md-line-elems;
        Markdown::prepare-globals;
        my $res = MDParse( $test<text>, rule => 'md-image' );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

subtest "Invalid" => {
    my @tests = 
        {
            text => q{![Img text](/img/foo.jpg},
            name => 'no closing brace',
        },
        {
            text => q{![Img text(/img/foo.jpg)},
            name => "no closing bracket",
        },
        {
            text => q{![](/img/foo.jpg)},
            name => "empty link text",
        },
        {
            text => q{![Img text](/img/foo.jpg Title)},
            name => "unquoted title",
        },
        {
            text => q{![Img ![text](/img/bar.jpg) is not ok](/img/foo.jpg)},
            name => "nested link",
        },
        ;

    plan @tests.elems;

    for @tests -> $test {
        my Int $*md-indent-width;
        my Str @*md-quotable;
        my Regex $*md-line-end;
        my Bool %*md-line-elems;
        Markdown::prepare-globals;
        my $res = MDParse( $test<text>, rule => 'md-link' );
        nok so $res, $test<name>;
        #note $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
