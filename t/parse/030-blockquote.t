use v6;
no precompilation;
use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

my $*md-line = 1;
my $mdres = Markdown.parse( q:to/MD/, rule => 'md-blockquote', actions => MDGActions.new );
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
MD

bail-out "Complex blockquote parse failed" unless so $mdres;

is-deeply 
    $mdres, 
    Match.new(pos => 93, from => 0, hash => Map.new((:md-bq-line([Match.new(pos => 16, from => 0, hash => Map.new((:md-bq-line-body(Match.new(pos => 16, from => 2, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 16, from => 15, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 25, from => 16, hash => Map.new((:md-bq-line-body(Match.new(pos => 25, from => 18, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 25, from => 24, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 27, from => 25, hash => Map.new((:md-bq-line-body(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 27, from => 26, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 43, from => 27, hash => Map.new((:md-bq-line-body(Match.new(pos => 43, from => 29, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 43, from => 42, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 45, from => 43, hash => Map.new((:md-bq-line-body(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 45, from => 44, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 64, from => 45, hash => Map.new((:md-bq-line-body(Match.new(pos => 64, from => 47, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 64, from => 63, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 68, from => 64, hash => Map.new((:md-bq-line-body(Match.new(pos => 68, from => 66, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 68, from => 67, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 82, from => 68, hash => Map.new((:md-bq-line-body(Match.new(pos => 82, from => 70, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 82, from => 81, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 84, from => 82, hash => Map.new((:md-bq-line-body(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 84, from => 83, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any), Match.new(pos => 93, from => 84, hash => Map.new((:md-bq-line-body(Match.new(pos => 93, from => 86, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)),:md-nl(Match.new(pos => 93, from => 92, hash => Map.new(()), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => Any)]))), list => (), orig => "> quote1\nquote2\n> quote3\n>\n> # H1 in quote\n>\n> > ## H2 in quote\n> >\n> >    quote4\n>\n> quote5\n", made => ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 1, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote")),
    "complex blockquote";

is-deeply
    $mdres.made,
    ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote1", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote2", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote3", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdHead.new(level => 1, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H1 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdBlockquote.new(content => [ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdHead.new(level => 2, content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "H2 in quote", type => "PlainStr")], type => "Line")], type => "Head"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "   quote4", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "quote5", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph")], type => "Doc")], type => "Blockquote"),
    "complex blockquote parsed structure";

done-testing;
