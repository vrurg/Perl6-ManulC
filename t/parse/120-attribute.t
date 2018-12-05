use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;

my Int $*md-indent-width;
my Str $*md-line-prefix;
my Regex $*md-quotable;
my Regex $*md-line-end;
my Bool %*md-line-elems;

plan 2;

subtest "Valid" => {
    my @tests =
        {
            text => q<{#anchor}>,
            name => 'attributes with only id',
            struct => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeId.new(value => "anchor", type => "AttributeId")), type => "Attributes"),
        },
        {
            text => q<{.class}>,
            name => 'attributes with only class',
            struct => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeClass.new(value => "class", type => "AttributeClass")), type => "Attributes"),
        },
        {
            text => q<{key=value}>,
            name => 'attributes with only key/value',
            struct => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeKeyval.new(key => "key", quote => "", value => "value", type => "AttributeKeyval")), type => "Attributes"),
        },
        {
            text => q<{#id .class key1='value1' key2="val'ue2" key=value}>,
            name => 'attributes with all elements',
            struct => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeId.new(value => "id", type => "AttributeId"), ManulC::Parser::MD::MdAttributeClass.new(value => "class", type => "AttributeClass"), ManulC::Parser::MD::MdAttributeKeyval.new(key => "key1", quote => "'", value => "value1", type => "AttributeKeyval"), ManulC::Parser::MD::MdAttributeKeyval.new(key => "key2", quote => "\"", value => "val'ue2", type => "AttributeKeyval"), ManulC::Parser::MD::MdAttributeKeyval.new(key => "key", quote => "", value => "value", type => "AttributeKeyval")), type => "Attributes"),
        },
        ;

    md-test-structure( @tests, :rule('md-attributes') );
}

subtest "Embedding" => {
    my @tests =
        {
            text => q:to/HEAD/,
                        # ATX heading {#anchor .class}
                        HEAD
            name => 'ATX header',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdHead.new(level => 1, attributes => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeId.new(value => "anchor", type => "AttributeId"), ManulC::Parser::MD::MdAttributeClass.new(value => "class", type => "AttributeClass")), type => "Attributes"), content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "ATX heading ", type => "PlainStr")], type => "Line")], type => "Head")], type => "Doc"),
        },
        {
            text => q:to/HEAD/,
                        ## ATX heading2 ## {#anchor .class}
                        HEAD
            name => 'ATX header, hash terminated',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdHead.new(level => 2, attributes => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeId.new(value => "anchor", type => "AttributeId"), ManulC::Parser::MD::MdAttributeClass.new(value => "class", type => "AttributeClass")), type => "Attributes"), content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "ATX heading2", type => "PlainStr")], type => "Line")], type => "Head")], type => "Doc"),
        },
        {
            text => q:to/HEAD/,
                        Setext heading {#setext .setext-class}
                        ---
                        HEAD
            name => 'Setext header, hash terminated',
            struct => ManulC::Parser::MD::MdDoc.new(link-definitions => {}, content => [ManulC::Parser::MD::MdHead.new(level => 2, attributes => ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeId.new(value => "setext", type => "AttributeId"), ManulC::Parser::MD::MdAttributeClass.new(value => "setext-class", type => "AttributeClass")), type => "Attributes"), content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "Setext heading ", type => "PlainStr")], type => "Line")], type => "Head")], type => "Doc"),
        },
        {
            text => q:to/HEAD/,
                        A paragraph {.class #id mykey="my value"} with attributes.
                        HEAD
            name => 'paragraph',
            struct => ManulC::Parser::MD::MdDoc.new(content => [ManulC::Parser::MD::MdParagraph.new(content => [ManulC::Parser::MD::MdLine.new(content => [ManulC::Parser::MD::MdPlainStr.new(value => "A paragraph ", type => "PlainStr"), ManulC::Parser::MD::MdAttributes.new(attrs => Array[ManulC::Parser::MD::MdEntity].new(ManulC::Parser::MD::MdAttributeClass.new(value => "class", type => "AttributeClass"), ManulC::Parser::MD::MdAttributeId.new(value => "id", type => "AttributeId"), ManulC::Parser::MD::MdAttributeKeyval.new(key => "mykey", quote => "\"", value => "my value", type => "AttributeKeyval")), type => "Attributes"), ManulC::Parser::MD::MdPlainStr.new(value => " with attributes.", type => "PlainStr")], type => "Line"), ManulC::Parser::MD::MdEol.new(value => "\n", type => "Eol")], type => "Paragraph")], type => "Doc"),
        },
        ;

    md-test-structure( @tests );
}

done-testing;

# vim: ft=perl6
