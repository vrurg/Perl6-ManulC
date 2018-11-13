use v6;
#`(
no precompilation;
use Grammar::Tracer;
)
use Test;
use ManulC::Parser::MD;

plan 2;

subtest "Valid" => {
    my @tests = 
        {
            text => q{Inline `code` line},
            name => 'simple inline code',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdPlainData.new(value => "`code`", type => "PlainData"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code`` line},
            name => 'simple inline code, double quote',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdPlainData.new(value => "``code``", type => "PlainData"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline code `` ` `` line},
            name => 'inline code with backtick',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline code ", type => "PlainStr"), ManulC::Parser::MD::MdPlainData.new(value => "`` ` ``", type => "PlainData"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code & special`` line},
            name => 'inline code with special char',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdPlainData.new(value => "``code \& special``", type => "PlainData"), ManulC::Parser::MD::MdPlainStr.new(value => " line", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        {
            text => q{Inline ``code \& \` - no escapes``},
            name => 'inline code doesn\'t support escaped chars',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Inline ", type => "PlainStr"), ManulC::Parser::MD::MdPlainData.new(value => "``code \\\& \\` - no escapes``", type => "PlainData")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "", type => "PlainData")], type => "Paragraph")], type => "Doc"),
        },
        ;

    plan 2 * @tests.elems;

    for @tests -> $test {
        my Int $*md-indent-width;
        my Str @*md-quotable;
        my Regex $*md-line-end;
        my Bool %*md-line-elems;
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
