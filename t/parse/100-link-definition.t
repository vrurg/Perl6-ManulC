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
            text => q<[id1]: http://google.com 
[id2]: http://google.com "Double-quoted title"
[id3]: http://google.com 'Single-quoted title'
[id4]: http://google.com (Bracketed title)
   [id1]: http://google.com 
   [id2]: http://google.com "Double-quoted title"
   [id3]: http://google.com 'Single-quoted title'
   [id4]: http://google.com (Bracketed title)

   [ids4]: http://google.com 
    (Bracketed title)
>,
                #
                #                    [idp1]: http://google.com 
                #                    [idp2]: http://google.com "Double-quoted title"
                #                    [idp3]: http://google.com 'Single-quoted title'
                #                    [idp4]: http://google.com (Bracketed title)
            name => 'link definition blocks',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "id1", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id2", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Double-quoted title", type => "PlainStr")], type => "Line"), indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id3", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single-quoted title", type => "PlainStr")], type => "Line"), indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "Line"), indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id1", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id2", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Double-quoted title", type => "PlainStr")], type => "Line"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id3", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Single-quoted title", type => "PlainStr")], type => "Line"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "Line"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "LinkdefParagraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "ids4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "Line"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "LinkdefParagraph")], type => "Doc"),
        },
        {
            text => q<A paragraph with link definitions. [id_]: http://google.com 
[id1]: http://google.com 
[ids2]: http://google.com 
 (Bracketed title)
It ends here.

   [ids4]: http://google.com 
    (Bracketed title)
>,
                #
                #                    [idp1]: http://google.com 
                #                    [idp2]: http://google.com "Double-quoted title"
                #                    [idp3]: http://google.com 'Single-quoted title'
                #                    [idp4]: http://google.com (Bracketed title)
            name => 'simple inline URL autolink',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A paragraph with link definitions. ", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "[", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => "id", type => "PlainStr"), ManulC::Parser::MD::MdChrSpecial.new(value => "_", type => "ChrSpecial"), ManulC::Parser::MD::MdChrSpecial.new(value => "]", type => "ChrSpecial"), ManulC::Parser::MD::MdPlainStr.new(value => ": http://google.com \n", type => "PlainStr"), ManulC::Parser::MD::MdLinkDefinition.new(id => "id1", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine, indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainStr.new(value => "\n", type => "PlainStr"), ManulC::Parser::MD::MdLinkDefinition.new(id => "ids2", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "Line"), indent => "", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainStr.new(value => "\nIt ends here.", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "Paragraph"), ManulC::Parser::MD::MdBlankSpace.new(value => "\n", type => "BlankSpace"), ManulC::Parser::MD::MdLinkdefParagraph.new(content => [ManulC::Parser::MD::MdLinkDefinition.new(id => "ids4", addr => ManulC::Parser::MD::MdLinkdefAddr.new(value => ManulC::Parser::MD::MdPlainStr.new(value => "http://google.com", type => "PlainStr"), type => "LinkdefAddr"), title => ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Bracketed title", type => "PlainStr")], type => "Line"), indent => "   ", type => "LinkDefinition"), ManulC::Parser::MD::MdPlainData.new(value => "\n", type => "PlainData")], type => "LinkdefParagraph")], type => "Doc"),
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
        #diag $res.ast.dump;
        ok so $res, $test<name>;
        is-deeply $res.ast, $test<struct>, $test<name> ~ ": structure";
        #note $res.ast.perl;
    }
}

done-testing;

# vim: ft=perl6
