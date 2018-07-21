use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

subtest sub bList {
    plan 2;

    my $text;

#`(
    my $text = qq{1. Item1
  Item 1a
  Item 1b

    * Subitem 1.1
      Subitem 1.1a
    * Subitem 1.2

      SubPara 1.2.1

  Para 1.1a
  Para 1.1b
  2. Item 2
  Item2.1

  Para 2a <a href="123"> &amp;

1. Item 3
Item 3a

Para 3.1a
Para 3.1b

  Para 3.2a};
)

    $text = qq{1. Item1

    * Subitem 1.1
subline 1.1
      Subitem 1.1
    * Subitem 1.2


      SubPara 1.2.1
1. Item last};

    say "«", $text, "»";
    my $*md-line = 1;
    #my $mdres = Markdown.parse( $li-body, rule => 'mdLItemBody', actions => MDGActions.new );
    my $mdres = Markdown.parse( $text, rule => 'md-list', actions => MDGActions.new );

    bail-out "Parse failed" unless so $mdres;

    say $mdres;
    say "MADE:",$mdres.made.perl;

    is-deeply
        $mdres,
        Match.new(pos => 93, from => 0, hash => Map.new((:mdBQLine([Match.new(pos => 16, from => 0, hash => Map.new((:mdBQLineBody(Match.new(pos => 16, from => 2, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 16, from => 15, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 25, from => 16, hash => Map.new((:mdBQLineBody(Match.new(pos => 25, from => 18, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 25, from => 24, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 27, from => 25, hash => Map.new((:mdBQLineBody(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 43, from => 27, hash => Map.new((:mdBQLineBody(Match.new(pos => 43, from => 29, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 43, from => 42, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 45, from => 43, hash => Map.new((:mdBQLineBody(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 64, from => 45, hash => Map.new((:mdBQLineBody(Match.new(pos => 64, from => 47, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 64, from => 63, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 68, from => 64, hash => Map.new((:mdBQLineBody(Match.new(pos => 68, from => 66, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 68, from => 67, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 82, from => 68, hash => Map.new((:mdBQLineBody(Match.new(pos => 82, from => 70, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 82, from => 81, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 84, from => 82, hash => Map.new((:mdBQLineBody(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 93, from => 84, hash => Map.new((:mdBQLineBody(Match.new(pos => 93, from => 86, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:mdNL(Match.new(pos => 93, from => 92, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)]))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDHeading.new(level => 1, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDHeading.new(level => 2, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote")),
        "complex blockquote";

    is-deeply
        $mdres.made,
        ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDHeading.new(level => 1, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDBlockquote.new(content => [ManulC::Parser::MD::MDDocument.new(content => [ManulC::Parser::MD::MDHeading.new(level => 2, content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Heading"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"), ManulC::Parser::MD::MDBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MDParagraph.new(content => [ManulC::Parser::MD::MDLine.new(content => [ManulC::Parser::MD::MDPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MDPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Document")], type => "Blockquote"),
        "complex blockquote parsed structure";
}, "Bullet list";

subtest "Inlined list", {
    my $text=q:to/TEXT/;
Paragraph

* Item 1
- Item 2
+ Item 3

Finish
TEXT

    my $mdres = MDParse( $text );
    say "Inlined:",$mdres;
    ok True, "Just";
};

subtest {
    ok "Simply fine";
}, "Ordered list";

done-testing;

# vim: ft=perl6
