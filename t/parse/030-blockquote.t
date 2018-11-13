use v6;
no precompilation;
use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

plan 2;

my $*md-line = 1;
my $text = q:to/TEXT/;
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

my $res = Markdown.parse( $text, rule => 'md-blockquote', actions => MDGActions.new );

ok so $res, "Complex blockquote parse failed";

is-deeply
    $res.ast,
    ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote1\nquote2\nquote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 1, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote"),
    "complex blockquote parsed structure";

    #diag $res.gist;
    #diag MDDumpAST( $res.ast );
    #diag $res.ast.perl;

done-testing;

# vim: ft=perl6
