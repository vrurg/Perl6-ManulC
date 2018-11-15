use v6;
#`(
no precompilation;
use Grammar::Tracer;
)
use Test;
use ManulC::Parser::MD;

plan 1;

my Int $*md-indent-width;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

subtest "Valid" => {
    my @tests = 
        {
            text => q{a text _with_ **emp_has_is** and *nested _emph_*.},
            name => 'simple and nested emphasis',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "a text ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "with", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => " ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "**", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "emp", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "has", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => "is", type => "PlainStr")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => " and ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "*", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "nested ", type => "PlainStr"), ManulC::Parser::MD::MdEmphasis.new(mark => "_", value => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "emph", type => "PlainStr")], type => "Line"), type => "Emphasis")], type => "Line"), type => "Emphasis"), ManulC::Parser::MD::MdPlainStr.new(value => ".", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        #diag $res.ast.dump;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
