use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;

my Int $*md-indent-width;
my Str $*md-line-prefix;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

plan 2;

subtest "Valid" => {
    my @tests =
        {
            text => q{Paragraph with image ![Image text](/img/foo.jpg)},
            name => 'simple image',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle, attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Paragraph with image ![Image text](/img/foo.jpg "My title")},
            name => "image with simple title",
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My title", type => "PlainStr")], type => "LinkTitle"), attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{![Image "text" > &](/img/foo.jpg "My \"title\"")},
            name => "image with special and quoted chars",
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "title", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped")], type => "LinkTitle"), attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image \"text\" ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{![Image <b>text</b>](/img/foo.jpg)},
            name => 'simple image with text with HTML',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle, attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "text", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "/img/foo.jpg", type => "LinkAddr"), type => "LinkAdhoc"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Paragraph with image ![Image reference][img id]},
            name => 'reference image',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image reference", type => "PlainStr")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "img id", type => "LinkAddr"), type => "LinkReference"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Paragraph with image ![Image reference] [img id spaced]},
            name => 'reference image with spaces',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Image reference", type => "PlainStr")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "img id spaced", type => "LinkAddr"), type => "LinkReference"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Paragraph with image ![Image reference][]},
            name => 'reference image with text as id',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLinkdefId.new(value => "Image reference", type => "LinkdefId")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Image reference", type => "LinkAddr"), type => "LinkReference"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Paragraph with image ![Image reference, spaced] []},
            name => 'reference image with text as id, spaced',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Paragraph with image ", type => "PlainStr"), ManulC::Parser::MD::MdImage.new(link => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLinkdefId.new(value => "Image reference, spaced", type => "LinkdefId")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Image reference, spaced", type => "LinkAddr"), type => "LinkReference"), type => "Image")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
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

    md-test-structure( @tests, :nok, rule => "md-image" );
}

done-testing;

# vim: ft=perl6
