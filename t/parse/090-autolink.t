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

plan 1;

subtest "Valid" => {
    my @tests =
        {
            text => q{Inline <http://some.addr> autolink},
            name => 'simple inline URL autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdAutolink.new(value => ManulC::Parser::MD::MdAddrUrl.new(value => "http://some.addr", type => "AddrUrl"), type => "Autolink"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc")
        },
        {
            text => q{Inline <my@email.local> autolink},
            name => 'simple inline email autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdAutolink.new(value => ManulC::Parser::MD::MdAddrEmail.new(value => "my\@email.local", type => "AddrEmail"), type => "Autolink"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline <invalid> autolink},
            name => 'invalid autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<invalid>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
