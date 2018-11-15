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
            text => q{Inline <http://some.addr> autolink},
            name => 'simple inline URL autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdAutolink.new(value => ManulC::Parser::MD::MdAddrUrl.new(value => "http://some.addr", type => "AddrUrl"), type => "Autolink"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline <my@email.local> autolink},
            name => 'simple inline email autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdAutolink.new(value => ManulC::Parser::MD::MdAddrEmail.new(value => "my\@email.local", type => "AddrEmail"), type => "Autolink"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline <invalid> autolink},
            name => 'invalid autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdHtmlElem.new(value => "<invalid>", type => "HtmlElem"), ManulC::Parser::MD::MdPlainStr.new(value => " autolink", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        Markdown::prepare-globals;
        my $res = MDParse( $test<text> );
        #diag $res.gist;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
