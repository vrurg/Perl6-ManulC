use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

my $mdres = MDParse(q:to/MD/);

# Head 1

Paragraph 1

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

>
> 

Paragraph 2

MD

say "TEST PARSED:", $mdres;

my $translator = MD2HTML.new(elem => $mdres.ast);
say $translator.translate;

ok True, "Fine";
done-testing;
