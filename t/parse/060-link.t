use v6;
#`(
no precompilation;
use Grammar::Tracer;
)
use Test;
use ManulC::Parser::MD;

my Int $*md-indent-width;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

plan 2;

subtest "Valid" => {
    my @tests = 
        {
            text => q{[Link text](http://google.com)},
            name => 'simple link',
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link text](http://google.com "My title")},
            name => "link with simple title",
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My title", type => "PlainStr")], type => "LinkAddrTitle"), text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link text", type => "PlainStr")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link "text" > &](http://google.com "My \"title\"")},
            name => "link with special and quoted chars",
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "My ", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped"), ManulC::Parser::MD::MdPlainStr.new(value => "title", type => "PlainStr"), ManulC::Parser::MD::MdChrEscaped.new(value => "\"", type => "ChrEscaped")], type => "LinkAddrTitle"), text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link \"text\" ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link <b>text</b>](http://google.com)},
            name => 'simple link with text with HTML',
            struct => ManulC::Parser::MD::MdLinkAdhoc.new(title => ManulC::Parser::MD::MdLinkAddrTitle, text => ManulC::Parser::MD::MdLinkText.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Link ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<b>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => "text", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "</b>", type => "HtmlElem")], type => "Line")], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "http://google.com", type => "LinkAddr"), type => "LinkAdhoc"),
        },
        {
            text => q{[Link reference][link id]},
            name => 'reference link',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Link reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "link id", type => "LinkAddr"), type => "LinkReference"),
        },
        {
            text => q{[Link reference] [link id spaced]},
            name => 'reference link with spaces',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Link reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "link id spaced", type => "LinkAddr"), type => "LinkReference"),
        },
        {
            text => q{[Link reference][]},
            name => 'reference link with text as id',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Link reference"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Link reference", type => "LinkAddr"), type => "LinkReference"),
        },
        {
            text => q{[Link reference, spaced] []},
            name => 'reference link with text as id',
            struct => ManulC::Parser::MD::MdLinkReference.new(text => ManulC::Parser::MD::MdLinkText.new(content => ["Link reference, spaced"], type => "LinkText"), addr => ManulC::Parser::MD::MdLinkAddr.new(value => "Link reference, spaced", type => "LinkAddr"), type => "LinkReference"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text>, rule => 'md-link' );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
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

    plan @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text>, rule => 'md-link' );
        nok so $res, $test<name>;
        #note $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
