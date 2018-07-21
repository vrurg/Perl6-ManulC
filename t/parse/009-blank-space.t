use v6;
#no precompilation;
#use Grammar::Tracer;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

subtest sub bList {
    plan 2;

    my $text = q:to/BLIST/;

    BLIST

    my $*md-line = 1;
    my $mdres = Markdown.parse( $text, rule => 'md-blank-space', actions => MDGActions.new );

    bail-out "Parse failed" unless so $mdres;

    is-deeply 
        $mdres, 
        Match.new(list => (), hash => Map.new((:md-blank-line([Match.new(list => (), hash => Map.new((:md-nl(Match.new(list => (), hash => Map.new(()), pos => 1, made => Any, from => 0, orig => "\n")))), pos => 1, made => Any, from => 0, orig => "\n")]))), pos => 1, made => ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), from => 0, orig => "\n"),
        "complex blockquote";

    is-deeply
        $mdres.made,
        ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"),
        "complex blockquote parsed structure";
    done-testing;
}, "Bullet list";

done-testing;

