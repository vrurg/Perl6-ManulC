use v6;
use lib q<./build-tools/lib>;
use Test;
use MCTest;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

my Int $*md-indent-width;
my Str $*md-line-prefix;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

my @tests = {
        text => q:to/TEXT/,
        > quote1
        quote2
        > quote3
        >
        > # H1 in quote
        >
        > > ## H2 in quote
        > >
        > >    quote4
        >
        > quote5
        TEXT
        name => 'blockquote',
        rule => 'md-blockquote',
        struct => ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote1\nquote2\nquote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace")], type => "Paragraph"), ManulC::Parser::MD::MdHead.new(level => 1, attributes => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdHead.new(level => 2, attributes => ManulC::Parser::MD::MdAttributes, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc")], type => "Blockquote"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc")], type => "Blockquote"),
    },
    {
        text => q:to/TEXT/,
        a paragraph
        > quote1
        quote2
        > quote3
        >
        > # H1 in quote
        >
        > > ## H2 in quote
        > >
        > >    quote4
        >
        > quote5
        TEXT
        name => 'paragraph eats up unseparated blockquote',
        struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "a paragraph\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " quote1\nquote2\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " quote3\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " # H1 in quote\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ## H2 in quote\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "    quote4\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "\n", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => ">", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => " quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
    },
    ;

md-test-structure( @tests );

done-testing;

# vim: ft=perl6
