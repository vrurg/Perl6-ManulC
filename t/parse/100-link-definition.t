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
            text => q{[id1]: http://any.com
             (Title in brackets)
[id2]: https://somewhere.org},
            name => "title on the next line",
            struct => ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "id1", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://any.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Title in brackets", type => "PlainStr")], type => "LinkdefTitle"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id2", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "https://somewhere.org", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "LinkdefParagraph"),
            rule => 'md-linkdef-paragraph',
        },
        {
            text => q<[id1]: http://google.com
[id2]: http://google.com "Double-quoted title"
[id3]: http://google.com 'Single-quoted title'
[id4]: http://google.com (Bracketed title)
   [id1a]: http://google.com
   [id2a]: http://google.com "Double-quoted title"
   [id3a]: http://google.com 'Single-quoted title'
   [id4a]: http://google.com (Bracketed title)

   [ids4]: http://google.com
    (Bracketed title on a new line)
>,
                #
                #                    [idp1]: http://google.com
                #                    [idp2]: http://google.com "Double-quoted title"
                #                    [idp3]: http://google.com 'Single-quoted title'
                #                    [idp4]: http://google.com (Bracketed title)
            name => 'link definition blocks',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "id1", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id2", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Double-quoted title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id3", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single-quoted title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id1a", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id2a", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Double-quoted title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id3a", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single-quoted title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id4a", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "LinkdefTitle"), indent => Str, type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "LinkdefParagraph"), ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "ids4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLinkdefTitle.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title on a new line", type => "PlainStr")], type => "LinkdefTitle"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "LinkdefParagraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
