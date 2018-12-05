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
            text => q{[Link text](http://google.com)},
            name => 'simple link',
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle, attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link text](http://google.com "My title")},
            name => "link with simple title in double quotes",
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My title", type => "PlainStr")], type => "LinkTitle"), attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link text](http://google.com 'My title')},
            name => "link with simple title in single quotes",
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My title", type => "PlainStr")], type => "LinkTitle"), attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link "text" > &](http://google.com "My \"title\"")},
            name => "link with special and quoted chars",
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "title", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped")], type => "LinkTitle"), attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\"", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "text", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\"", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link <b>text</b>](http://google.com)},
            name => 'simple link with text with HTML',
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkTitle, attrs => ManulC::Parser::MD::MdAttributes, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "text", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link reference][link id]},
            name => 'reference link',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link reference", type => "PlainStr")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "link id", type => "LinkAddr"), type => "LinkReference"),
        },
        {
            text => q{[Link reference] [link id spaced]},
            name => 'reference link with spaces between text and addr',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link reference", type => "PlainStr")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "link id spaced", type => "LinkAddr"), type => "LinkReference"),
        },
        {
            text => q{[Link reference][]},
            name => 'reference link with text as id',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLinkdefId.new(value => "Link reference", type => "LinkdefId")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Link reference", type => "LinkAddr"), type => "LinkReference")
        },
        {
            text => q{[Link reference, spaced] []},
            name => 'reference link with text as id',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLinkdefId.new(value => "Link reference, spaced", type => "LinkdefId")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Link reference, spaced", type => "LinkAddr"), type => "LinkReference"),
        },
        ;

    md-test-structure( @tests, :rule<md-link> );
}

subtest "Invalid" => {
    my @tests =
        {
            text => q{[Link text](http://google.com},
            name => 'no closing brace',
        },
        {
            text => q{[Link text(http://google.com)},
            name => "no closing bracket",
        },
        {
            text => q{[](http://google.com)},
            name => "empty link text",
        },
        {
            text => q{[Link text](http://google.com Title)},
            name => "unquoted title",
        },
        {
            text => q{[Linked [text](http://nomatter.local) is not ok](http://google.com Title)},
            name => "nested link",
        },
        ;

    md-test-structure( @tests, :rule<md-link>, :nok, :diag-ast );
}

done-testing;

# vim: ft=perl6
