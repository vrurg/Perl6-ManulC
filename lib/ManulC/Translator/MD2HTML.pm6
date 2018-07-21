module ManulC::Translator {
    use ManulC::Parser::MD;

    our %char2ent = '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    ;

    class MD2HTML does MDTranslator is export {

        multi method translate(MdSpecialChr $elem) {
            #say "[special char]";
            %char2ent{$elem.value} || '&#' ~ ord( $elem.value ) ~ ';';
        }

        multi method translate(MdHead $h) {
            #say "[heading]";
            my $tagName = 'h' ~ $h.level;
            return "<$tagName>" ~ (callsame) ~ "</$tagName>\n";

            multi method translate(MdBlockquote $elem) {
                return "<blockquote>\n" ~ (callsame) ~ "</blockquote>\n";
            }

            multi method translate(MdPlainData $elem) {
                #say "[plain {$elem.name}]";
                $elem.value;
            }
        }
    }
}
