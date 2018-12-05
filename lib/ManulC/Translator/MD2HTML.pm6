module ManulC::Translator {
    use ManulC::Parser::MD;
    use ManulC::Context;

    our %char2ent = '&' => '&amp;',
                    '<' => '&lt;',
                    '>' => '&gt;',
    ;

    class MD2HTML does MDTranslator is export {
        has Str $.class-prefix = "mc";
        has Context $.ctx;
        has %.link-definitions;

        submethod TWEAK {
            $!ctx = Context.new;
        }

        proto method mc-class (|) {*}
        multi method mc-class ( @classes ) {
            @classes.map: $!class-prefix ~ *
        }
        multi method mc-class ( Str $base-class ) {
            samewith( [ $base-class ] )
        }
        multi method mc-class ( MdEntity $elem, Str $class ) {
            samewith( [ |$elem.classes, $class ] );
        }
        multi method mc-class ( MdEntity $elem, @classes ) {
            samewith( [ |$elem.classes, |@classes ] );
        }
        multi method mc-class ( *@classes ) {
            samewith( @classes )
        }

        method kvAttr2pair ( MdAttributeKeyval:D $elem ) {
            with $elem {
                return .key => .quote ~ .value ~ .quote
            }
        }

        proto method tag (|) {*}

        multi method tag ( Pair $tag, |args --> Str) {
                samewith( $tag.key, $tag.value, |args )
        }

        multi method tag (
            Str:D $tag!,
            Str $content?,
            MdAttributes :$md-attrs?,
            :@classes is copy,
            :@ids is copy,
            :@attrs is copy
            --> Str
        ) {

            with $md-attrs {
                for .attrs -> $attr {
                    given $attr {
                        when MdAttributeId {
                            @ids.push: .value;
                        }
                        when MdAttributeClass {
                            @classes.push: .value;
                        }
                        when MdAttributeKeyval {
                            @attrs.append: self.kvAttr2pair( $_ );
                        }
                        default {
                            fail "Unknown attribute element type: " ~ .WHO;
                        }
                    }
                }
            }

            my $att-str = "";
            my @a-str;

            @a-str.push: 'class="' ~ @classes.map( { ~$_ } ).join(" ") ~ '"' if @classes;
            @a-str.push: 'id="' ~ @ids.map( { ~$_ } ).join(" ") ~ '"' if @ids;
            @a-str.append: @attrs.map: { .key ~ '=' ~ .value } if @attrs;

            $att-str = @a-str.join(" ");

            with $content {
                return "<$tag $att-str>$content\</$tag>"
            }

            "<$tag $att-str />"
        }

        method img-tag( MdLink $elem, :@attrs is copy, Str :$class, |args ) {
            @attrs.append: ( alt => '"' ~ self.translate( $elem.text ) ~ '"' );
            my $str = self.tag(
                "img",
                :@attrs,
                :classes( self.mc-class( "Image", $class ) ),
                |args
            );
            $str
        }

        proto method img (|) {*}
        multi method img( MdLinkAdhoc $elem ) {
            $!ctx.wrap(
                "image-adhoc",
                sub {
                    my @attrs;

                    @attrs.append: ( src => self.translate( $elem.addr ) );

                    with $elem.title {
                        @attrs.append: ( title => self.translate( $_ ) );
                    }

                    self.img-tag( $elem, :@attrs, :class<ImageAdhoc>, :md-attrs( $elem.attrs ) );
                }
            )
        }

        multi method img ( MdLinkReference $elem ) {
            $!ctx.wrap(
                'image-reference',
                 sub {
                    my @attrs;
                    my $def = %!link-definitions{ $elem.addr.value.fc };
                    fail "No image definition found for ID '" ~ $elem.addr.value ~ "'" unless $def;

                    @attrs.append: ( src => self.translate( $def.addr ) );
                    with $def.title {
                        @attrs.append: ( title => self.translate( $_ ) );
                    }

                    self.img-tag( $elem, :@attrs, :class<ImageReference>, :md-attrs( $def.attrs ) );
                }
            )
        }

        method chr2ent ( Str $chr ) {
            %char2ent{ $chr } || '&#' ~ ord( $chr ) ~ ';';
        }

        method on-failure ( Failure $fail ) {
            self.tag( "span", $fail.exception.message, classes => self.mc-class(<Warning>) )
        }

        method on-exception ( Exception $ex ) {
            self.tag( "div", $ex ~ $ex.backtrace, classes => self.mc-class(<Error>) )
        }

        multi method translate ( MdDoc:D $elem ) {
            %!link-definitions = $elem.link-definitions;
            nextsame
        }

        multi method translate(MdChrSpecial:D $elem) {
            self.chr2ent( $elem.value );
        }

        multi method translate ( MdChrEscaped $elem ) {
            return "<br />" if $elem.value ~~ /\n/;
            self.chr2ent( $elem.value );
        }

        multi method translate ( MdParagraph:D $elem ) {
            my &callee = nextcallee;
            $!ctx.wrap(
                "paragraph",
                sub {
                    self.tag(
                        'p',
                        self.&callee( $elem ),
                        classes => self.mc-class( $elem, "Paragraph" )
                    )
                }
            )
        }

        multi method translate ( MdAttributes:D $elem ) {
            # Only IDs are used. For now at least.

            my @anchors;
            for $elem.attrs -> $attr {
                if $attr ~~ MdAttributeId {
                    @anchors.push: self.tag( "a", :ids([$attr.value]) );
                }
            }

            @anchors.join;
        }

        multi method translate ( MdAutolink:D $elem ) {
            my $addr = $elem.value;

            given $addr {
                when MdAddrUrl {
                    my @attrs = href => .value;
                    return self.tag( "a", .value, :@attrs );
                }
                when MdAddrEmail {
                    # Expected code:
                    # return self.obscure-email( .value );
                    # NOTE: Perhaps obsuring must be handed over to a macro/plugin
                    return self.tag( "span", "Emails are not generated yet", classes => self.mc-class("Alert") );
                }
            }
            fail "Unknown autolink address class: " ~ $addr.WHO;
        }

        multi method translate ( MdLinkDefinition:D $elem ) {
            ""
        }

        # This thing never returns a things...
        multi method translate ( MdLinkdefParagraph:D $elem ) {
            ""
        }

        multi method translate ( MdVerbatim:D $elem ) {
            my &callee = nextcallee;
            $!ctx.wrap(
                "verbatim",
                sub {
                    self.tag(
                        "code",
                        self.&callee( $elem ),
                        md-attrs => $elem.attrs,
                        classes => self.mc-class( $elem, "Verbatim" ),
                    )
                }
            )
        }

        multi method translate ( MdLink:D $elem, :@attrs, |args ) {
            $!ctx.wrap(
                "link",
                sub {
                    self.tag(
                            "a",
                            self.translate( $elem.text ),
                            :@attrs,
                            :classes( self.mc-class( $elem, $elem.type ) ),
                            |args
                    );
                }
            )
        }

        multi method translate ( MdLinkAdhoc:D $elem ) {
            my &callee = nextcallee;
            $!ctx.wrap(
                'link-adhoc',
                sub {
                    my @attrs;

                    @attrs.append: ( href => self.translate( $elem.addr ) );

                    if $elem.title {
                        @attrs.append: ( title => self.translate( $elem.title ) );
                    }

                    self.&callee( $elem, :@attrs, :md-attrs( $elem.attrs ) );
                }
            )
        }

        multi method translate ( MdLinkTitle:D $elem ) {
            return '"' ~ callsame() ~ '"'
        }

        multi method translate ( MdLinkAddr:D $elem ) {
            my $straddr = $elem.value ~~ MdEntity ?? callsame() !! ~$elem.value;
            '"' ~ $straddr ~ '"'
        }

        multi method translate ( MdLinkReference:D $elem ) {
            my &callee = nextcallee;
            $!ctx.wrap(
                'link-reference',
                 sub { # Use sub because fail within a block behaves not as I'd want it... ;)
                    my @attrs;
                    my $def = %!link-definitions{ $elem.addr.value.fc };
                    fail "No link definition found for ID '" ~ $elem.addr.value ~ "'" unless $def;

                    @attrs.append: ( href => self.translate( $def.addr ) );
                    with $def.title {
                        @attrs.append: ( title => self.translate( $def.title ) );
                    }

                    self.&callee( $elem, :@attrs, :md-attrs( $def.attrs ) );
                }
            )
        }

        multi method translate ( MdImage $elem ) {
            $!ctx.wrap(
                'image' => sub { self.img( $elem.link ) }
            )
        }

        multi method translate ( MdEmphasis $elem ) {
            $!ctx.wrap:
                'emphasis' => sub {
                    my $text = self.translate( $elem.value );
                    my Str $tag;
                    my @classes;
                    given $elem.mark {
                        when '_' | '*' {
                            $tag = 'em';
                        }
                        when '__' | '**' {
                            $tag = 'strong';
                        }
                        default {
                            $tag = 'span';
                            @classes.push: 'BadEmphasis';
                        }
                    }
                    self.tag( $tag, $text, classes => self.mc-class( $elem, @classes ) );
                }
        }

        multi method translate( MdHead:D $h ) {
            #say "[heading]";
            my $tagName = 'h' ~ $h.level;
            self.tag( $tagName, callsame(), attrs => $h.attributes );
        }

        multi method translate( MdBlockquote:D $elem ) {
            self.tag( 'blockquote', callsame() );
        }

        multi method translate ( MdBlankSpace:D $elem ) {
            return "" if $!ctx has "paragraph";
            "\n\n"
        }

        multi method translate ( MdEol:D $elem ) {
            return "" if $!ctx has "paragraph";
            "\n"
        }

        multi method translate(MdPlainData:D $elem) {
            fail "Element '" ~ self.WHO ~ "' value is not defined" without $elem.value;
            if $elem.value ~~ MdEntity {
                return self.translate( $elem.value );
            }
            ~$elem.value;
        }
    }

    sub md2html ( Str $text --> Str ) is export {
        my $struct = MDParse( $text ).ast;
        MD2HTML.new.translate( $struct )
    }
}
