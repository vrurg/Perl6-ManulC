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
            text => q{a text _with_ **emp_has_is** and *nested _emph_*.},
            name => 'simple and nested emphasis',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "a text ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "with", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "**", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "emp", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "has", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => "is", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => " and ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "*", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "nested ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "emph", type => "PlainStr")], type => "Line"), type => "Emphasis")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => ".", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
