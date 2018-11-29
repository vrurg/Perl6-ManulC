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
            text => q{Inline `code` line},
            name => 'simple inline code',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "`", space => Str, content => [ManulC::Parser::MD::MdPlainStr.new(value => "code", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code`` line},
            name => 'simple inline code, double quote',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "``", space => Str, content => [ManulC::Parser::MD::MdPlainStr.new(value => "code", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline code `` ` `` line},
            name => 'inline code with backtick',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline code ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "``", space => Str, content => [ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code & special`` line},
            name => 'inline code with special char',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "``", space => Str, content => [ManulC::Parser::MD::MdPlainStr.new(value => "code ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " special", type => "PlainStr")], type => "Verbatim"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code \& \` - no escapes``},
            name => 'inline code doesn\'t support escaped chars',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdVerbatim.new(marker => "``", space => Str, content => [ManulC::Parser::MD::MdPlainStr.new(value => "code \\", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "\&", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " \\", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "`", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " - no escapes", type => "PlainStr")], type => "Verbatim")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
