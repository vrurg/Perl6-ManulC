use v6.c;
# no precompilation;
# use Grammar::Tracer;
#use Grammar::Tracer::Compact;

module ManulC::Parser::MD {
    use ManulC::Parser::HTML;

    grammar Markdown is export {
        also does HTML-Tag;

        enum LineElements <html verbatim attributes autolink link image emphasis chr-escaped chr-special>;

        my sub set-line-elements ( *%elems ) {
            %*md-line-elems{$_} = so %elems{$_} for %elems.keys;
        }

        my multi sub only-line-elements ( *@elems ) {
            samewith( @elems );
        }

        my multi sub only-line-elements ( @elems ) {
            my %values = @elems.map: {
                die "Internal: unknown markdown line element '$_'" unless LineElements::{$_}:exists;
                $_ => True
            };
            %*md-line-elems = LineElements::.keys.map: { $_ => %values{ $_ } // False };
        }

        my sub all-line-elements {
            %*md-line-elems = LineElements::.keys.map: { $_ => True };
        }

        our sub prepare-globals {
            $*md-indent-width = 4;
            $*md-line-prefix = '';
            $*md-quotable     = rx/\W/;
            $*md-line-end     = rx/<.md-eol>/;
            all-line-elements;
        }

        rule TOP {
            :my Int $*md-indent-width;
            :my Str $*md-line-prefix;
            :my Regex $*md-quotable;
            :my $*md-line-end;
            :my Bool %*md-line-elems;
            :my %*md-link-definitions;
            { prepare-globals }
            <md-doc>
        }

        token md-doc {
            ^$
            || [
                    <md-blank-space>
                    || <md-header>
                    || <md-hrule>
                    || <md-linkdef-paragraph>
                    || <md-list>
                    || <md-codeblock>
                    || <md-blockquote>
                    || <md-paragraph>
            ]+
        }

        token md-blank-space {
            <md-blank-line>+
        }

        token md-blank-line {
            ^^ \h* <.md-eol>
        }

        token md-html-elem {
            <mdHTMLTag> || <mdHTMLEntity> || <mdHTMLComment>
        }

        token md-line {
            [

                # XXX Possible optimization: moved <?{ }> construct in front of corresponding tokens and use it with
                # <?before .>; create a benchmark test beforehand to see if this little complication really helps.

                   [ <md-chr-escaped>     <?{ %*md-line-elems<chr-escaped> }>     ]
                || [ <md-attributes>      <?{ %*md-line-elems<attributes> }>      ]
                || [ <md-autolink>        <?{ %*md-line-elems<autolink> }>        ]
                || [ <md-html-elem>       <?{ %*md-line-elems<html> }>            ]
                || [ <md-verbatim>        <?{ %*md-line-elems<verbatim> }>        ]
                || [ <md-image>           <?{ %*md-line-elems<image> }>           ]
                || [ <md-link>            <?{ %*md-line-elems<link> }>            ]
                || [ <md-emphasis>        <?{ %*md-line-elems<emphasis> }>        ]
                || [ <md-chr-special>     <?{ %*md-line-elems<chr-special> }>     ]
                || <md-plain-str(rx/
                                    [ <.md-chr-escaped> <?{ %*md-line-elems<chr-escaped> }> ]
                                    || [ <.md-chr-special> <?{ %*md-line-elems<chr-special> }> ]
                                    || $($*md-line-end)
                                /)>
            ]+? <?before $($*md-line-end)>
        }

        token md-attributes {
            '{' ~ '}' [ \s* <md-attribute>+ % \s+ \s* ]
        }

        proto token md-attribute {*}
        token md-attribute:sym<class> {
            '.' $<md-attr-class>=[ <:L + :N + [-]>+ ]
        }
        token md-attribute:sym<id> {
            '#' $<md-attr-id>=[ <:L + :N + [-]>+ ]
        }
        token md-attribute:sym<keyval> {
            :my $*html-nonval-chars = rx/ \} /;
            $<md-attr-key>=<mdHTMLAttrName> '=' $<md-attr-val>=<mdHTMLAttrVal>
        }

        token md-chr-escaped {
            \\ $<md-escaped-chr>=$($*md-quotable)
        }
        token md-chr-special { <[!&<>_*'"`(){}[\]]> }
        token md-plain-str ( $str-end ) { [ <!before $($str-end)> . ]+ }

        proto token md-addr {*}
        token md-addr:sym<url> {
            \w+ '://' \S+? <?before '>'>
        }

        token md-addr:sym<email> {
            \S+? '@' \S+? <?before '>'>
        }

        token md-autolink {
            '<' ~ '>' <md-addr>
        }

        proto token md-link {*}

        token md-link:sym<adhoc> {
            '[' ~ ']' <md-link-text>
            '(' ~ ')' <md-link-dest>
            <md-attributes>?
        }

        token md-link:sym<reference> {
            [ '[' ~ ']' <md-linkdef-id> \h* '[]' ]
            ||
            [ '[' ~ ']' <md-link-text> \h* '[' ~ ']' <md-linkdef-id> ]
            <md-attributes>?
        }

        # Link text is similar to md-line except that:
        # - nested links are not allowed
        # - ']' is serving as EOL
        # - empty line is not allowed
        token md-link-text {
            :temp %*md-line-elems;
            { set-line-elements( :!link, :!autolink, :!link-definition, :!image ) }
            :temp $*md-line-end = rx/ ']' /;
            <md-line>
        }

        token md-link-dest {
            <md-link-addr> [ \s+ <md-link-addr-title> ]?
        }

        token md-linkdef-id {
            \N+? <?before ']'>
        }

        token md-linkdef-addr {
            <md-autolink>
            || $<md-linkdef-addr-value>=\S+
        }

        token md-linkdef-title {
            :my $ttl-closing;
            :temp $*md-line-end;
            :temp %*md-line-elems;
            <["'(]> {
                my $q = ~$/;
                $ttl-closing = $q eq '(' ?? rx{ ')' } !! rx{ $($q) };
                $*md-line-end = $ttl-closing;
                only-line-elements( <chr-escaped chr-special> );
            }
            <md-line>
            $($ttl-closing)
        }

        token md-link-definition {
            ^^ <md-align>
            [ '[' ~ ']' <md-linkdef-id> ] ':'
            \h+
            <md-linkdef-addr>
            [ [$<line-end>=\h* <md-eol> $<md-ld-indent>=<md-align>]? \h+ <md-linkdef-title> ]?
            \h* $$
        }

        token md-linkdef-paragraph {
            <md-link-definition>+ % <md-eol>
            <md-eol>
            <md-blank-space>?
        }

        token md-image {
            '!' <md-link>
        }

        token md-emph-mark {
            [ <[_*]> | '**' | '__' ] <?before \S>
        }

        token md-emphasis {
            :my Str $md-emph-mark;
            <md-emph-mark> {
                $md-emph-mark = ~$/;
            }
            :temp $*md-line-end = rx/<.md-eol> || [<?after \S> $($md-emph-mark)]/;
            <md-line>
            <?after \S> $($md-emph-mark)
        }

        token md-link-addr {
            <md-plain-str( rx/ \s || \) / )>
        }

        # - only escaped or special chars are allowed
        # - no HTML, no anything else
        # - " enclosed
        # - could be empty (is it a good idea?)
        token md-link-addr-title {
            :my $ttl-closing;
            :temp $*md-quotable = rx/<[\"]>/;
            :temp $*md-line-end;
            :temp %*md-line-elems;
            <["']> {
                my $q = ~$/;
                only-line-elements( <chr-escaped chr-special> );
                $*md-line-end = $ttl-closing = rx/ $($q) /;
            }
            <md-line>
            $($ttl-closing)
        }

        token md-header {
            :temp %*md-line-elems;
            { only-line-elements( <html attributes verbatim link image emphasis chr-escaped chr-special> ) }
            <md-head>
        }

        proto token md-head {*}

        token md-head:sym<atx> {
            :temp $*md-line-end;
            ^^
            $<md-hlevel>=[ '#' ** 1..6 ] {
                $*md-line-end = rx{
                    [ \h+ '#'+ \h* ]? <md-attributes>? <.md-eol>
                } # rx end
            }
            \h+
            <md-line>
            [ \h+ '#'+ \h* ]?
            <md-attributes>?
            <md-eol>
        }

        token md-head:sym<setext> {
            :temp $*md-line-end;
            ^^
            # Do a fast check-up first because otherwise this rule is tested against every other entity in the document
            # and md-line is parsed repeatedly for each invocation. This is why I hated setext-styled headings since the
            # beginning...
            [ \N+ <md-eol> [ '='+ || '-'+ ] <md-eol> ]
            &&
            [
                { $*md-line-end = rx{ <.md-attributes>? <.md-eol> }; }
                <md-line> \h* <md-attributes>? \h* <md-eol>
                [
                    $<md-hlevel-first>=[ '='+ ]
                    || $<md-hlevel=second>=[ '-'+ ]
                ]
                <md-eol>
            ]
        }

        token md-hrule {
            ^^ \h* $<md-hr-sym>=<[*_-]> $<md-hr-delim>=[ \h* ] {} $<md-hr-sym> ** 2..* % $<md-hr-delim> \h* <md-eol>
        }

        token md-paragraph ( Regex :$line-end?, Regex :$before = rx{ <?after .> } ) {
            :temp $*md-line-end = $line-end // rx/<.md-eol> [ <.md-blank-space> || <md-cb-fence-start> || $ ]/;
             <md-line>
             <md-eol>
             [ <md-blank-space> || $ ]
             <?before $($before)>
        }

        token md-blockquote {
            <md-bq-line>+ {
                my $m = $/;
                my $bq-body =  [~] $m<md-bq-line>.map( { $_<md-bq-line-body> } );
                $m.make(
                    my $res = self.WHAT.parse(
                        $bq-body,
                        actions => self.actions.clone,
                    )
                );
            }
        }

        token md-bq-line {
            <md-bq-starter>
            $<md-bq-line-body>=[
                .*? <md-eol> <?before <.md-eol> || <.md-bq-starter>>
            ]
        }

        token md-bq-starter {
            ^^ <md-align> '>' ' '?
        }

        proto token md-codeblock {*}

        # Stadndard markdown code block defined by indentation.
        token md-codeblock:sym<std> {
            :my $*md-cb-prefix;
            <md-cb-first-line>
            <md-cb-line>*
        }

        token md-codeblock:sym<fenced> {
            :my $*md-cb-prefix;
            :my ( $*md-cb-fence-length, $*md-cb-fence-char );

            ^^ <md-cb-fence> { $*md-cb-prefix = ~($/<md-cb-fence><md-cb-fence-start><md-align>) }
                [ $<md-cb-language>=\S+ ]?
                [ <md-eol> || \s $<md-cb-comment>=\N*? <md-eol> ]
            <md-cb-line>*?
            ^^ $($*md-cb-prefix) $($*md-cb-fence-char) ** {$*md-cb-fence-length..Inf} <md-eol>
        }

        token md-cb-first-line {
            $<md-first-pfx>=[ <md-indent>+ ] <md-cb-line-body> { $*md-cb-prefix = ~$<md-first-pfx> }
        }

        token md-cb-line {
            $($*md-cb-prefix) <md-cb-line-body>
        }

        token md-cb-line-body {
            \N+ <md-eol>
        }

        # Fenced code block defined with ` or ~ and language name support
        token md-cb-fence-start {
            <md-align> $<md-cb-fence-line>=[ '`' ** 3..* || '~' ** 3..* ]
        }

        token md-cb-fence {
            <md-cb-fence-start>
            {
                with $/<md-cb-fence-start><md-cb-fence-line> {
                    $*md-cb-fence-char =   .substr( 0, 1 );
                    $*md-cb-fence-length = .chars;
                }
            }
        }

        token md-code-marker {
            $<md-code-quote>='`' ** 1..2 $<md-code-space>=' '?
        }

        # For code inlined into other elements (md-line primarily)
        token md-verbatim {
            :my $md-end-marker;
            :temp %*md-line-elems;
            :temp $*md-line-end;
            { only-line-elements( <chr-special> ) }

            <md-code-marker> {
                $md-end-marker = $/<md-code-marker><md-code-space> ~ $/<md-code-marker><md-code-quote>;
                $*md-line-end = $md-end-marker;
            }
            <md-line>
            $($md-end-marker)
        }

        my $li-num-start = q{\d+ '.' [ [\d+]* % '.' ]};
        token md-list {
            :my $*md-li-starter;
            <md-li-item>+
        }

        token md-li-item {
            :my $*md-li-item-loose;
            :my $*md-li-indent-align;
            :my $line-prefix = $*md-line-prefix;
            :my Bool $first-line = True;

            <md-li-item-start>
            {
                $*md-li-indent-align = $/<md-li-item-start>.chars;
            }

            # A paragraph within list must precede another item of the same or a nested list; or another paragraph of this very item.
            # In any other case this is not a paragraph but an item text element.
            :my $para-before = rx{
                [ $($line-prefix) ' ' ** {^$*md-indent-width} <.md-li-item-starter> ]
                || [ ' ' ** {$*md-li-indent-align} \h* \S ]
            };

            # A paragraph line must end before either a fenced code block, or any list item, or a paragraph not belonging to the current item.
            :my $para-end = rx/ <.md-eol>
                                        [
                                            [ # Before any new list item. Too indented ones are ignored and treated as continuation lines.
                                                <.md-blank-space>?
                                                ' ' ** { ^( $*md-li-indent-align + $*md-indent-width ) }
                                                <.md-li-item-starter( :any )>
                                            ]
                                            || [ # Any paragraph starting after a blank space and not too indented
                                                <.md-blank-space>
                                                ' ' ** { ^( $*md-li-indent-align + $*md-indent-width ) } \S
                                            ]
                                            || <.md-cb-fence-start>
                                        ]
                                    /;

            :temp $*md-line-prefix = "";

            #<md-li-item-body( ' ' x $*md-li-indent-align )>
            [
                [
                    <md-linkdef-paragraph>
                    || <md-list>
                    || <md-codeblock>
                    || <md-blockquote>
                    || <md-align> [
                        <md-paragraph( :line-end($para-end), :before($para-before) )>
                        || <md-li-item-text>
                    ]
                ]
                [ <md-blank-space> <?before $($para-before)>]?
                {
                    if $first-line {
                        $first-line = False;
                        $*md-line-prefix = ' ' x $*md-li-indent-align;
                    }
                }
            ]+
        }

        # Similar to paragraph but when it isn't; i.e. when not followed by a blank space.
        token md-li-item-text {
            :temp $*md-line-end = rx/ <.md-eol>
                                        [
                                            ' ' ** {^($*md-li-indent-align + $*md-indent-width)}
                                            <.md-li-item-starter( :any )> ' '
                                            || <md-cb-fence-start>
                                            || <.md-eol>
                                        ]
                                    /;
            <md-line> <md-eol>
        }

        token md-li-item-start {
            ^^ <md-align> <md-li-item-starter> $<spacing>=' '+? <?before <.md-indent>* [ \S || <.md-eol> ]>
        }

        token md-li-item-starter ( Bool :$any = False ) {
            :my $starter = (
                $*md-li-starter.defined && !$any
                ??
                  $*md-li-starter
                !!
                  rx{ [
                        <md-li-bullet-start>         { $*md-li-starter //= rx/ <md-li-bullet-start> /      }
                        || <md-li-num-dot-start>     { $*md-li-starter //= rx/ <md-li-num-dot-start> /     }
                        || <md-li-num-bracket-start> { $*md-li-starter //= rx/ <md-li-num-bracket-start> / }
                        || <md-li-num-embrace-start> { $*md-li-starter //= rx/ <md-li-num-embrace-start> / }
                      ] <?before ' '> } );

            $<starter>=$($starter) # $<starter> is necessary because otherwise subtokens in $starter will be lost in resulting Match object.
        }

        token md-li-bullet-start {
            $<symbol>=<[*+-]>
        }

        token md-li-num-number {
            \d+ || \#
        }

        token md-li-num-dot-start {
            <md-li-num-number> $<symbol>='.'
        }

        token md-li-num-bracket-start {
            <md-li-num-number> $<symbol>=')'
        }

        token md-li-num-embrace-start {
            $<symbol>='(' ~ ')' <md-li-num-number>
        }

        token md-indent {
            $($*md-line-prefix) ' ' ** {$*md-indent-width}
        }

        token md-align {
            $($*md-line-prefix) ' ' ** {^$*md-indent-width}
        }

        token md-eol {
            \n || $
        }

        token ws {
            <!ww> \s*
        }
    }

# Parsed tree classes
    class MdEntity is export {
        has Str $.type is required;

        method name { $!type }

        method dump-prefix ( Int $level --> Str ) {
            '| ' x $level
        }

        method dump ( Int $level = 0 --> Str ) {
            self.ast-dump( $level );
        }

        method ast-dump ( Int $level --> Str ) {
            self.dump-prefix( $level ) ~
            self.name ~ (
                self.^can( "info-str" ) ?? " [" ~ self.info-str ~ "]" !! ""
            )
        }

        method classes { ["Entity"] }

        method Str {
            fail "Element of type '" ~ self.WHO ~ "' doesn't support stringification";
        }
    }

    class MdPlainData is MdEntity is export {
        has $.value is rw;

        method ast-dump ( Int $level --> Str ) {
            my $ent = callsame;
            return $ent ~ "\n" ~ $!value.ast-dump( $level + 1 ) if $!value ~~ MdEntity;
            $ent ~ ": «" ~ $!value ~ "»";
        }

        method Str { ~$!value }
    }

    class MdContainer is MdEntity is export {
        has @.content;

        method push( MdEntity $entity ) {
            @.content.push( $entity );
        }

        method append( @elems ) {
            @.content.append: @elems;
        }

        method ast-dump ( Int $level --> Str ) {
            callsame() ~ "\n" ~ @.content.map( { .ast-dump( $level + 1 ) } ).join( "\n" )
        }

        method classes {
            callsame().push: "Container";
        }
    }

    class MdBlankSpace          is MdPlainData      is export { }
    class MdChar                is MdPlainData      is export { }
    class MdPlainStr            is MdPlainData      is export { }
    class MdLine                is MdContainer      is export { }

    class MdBlockquote          is MdContainer      is export { }
    class MdChrEscaped          is MdChar           is export { }
    class MdChrSpecial          is MdChar           is export { }
    class MdCodeBlock           is MdPlainData      is export { }
    class MdHtmlElem            is MdPlainData      is export { }
    class MdEol                 is MdPlainStr       is export { }
    class MdParagraph           is MdContainer      is export { }
    class MdList                is MdContainer      is export { }
    class MdLiItemText          is MdLine           is export { }
    class MdLiItemStarter       is MdPlainData      is export { }

    class MdDoc is MdContainer is export {
        has %.link-definitions;
    }

    class MdLiItemStart is MdPlainData is export {
        has Str $.align is required;
        has Str $.spacing is required;

        method info-str {
            $.value.info-str;
        }
    }

    class MdLiBulletStart   is MdLiItemStarter  is export {
        method info-str {
            $.value;
        }
    }

    class MdLiNumberStart is MdLiItemStarter is export {
        has Str $.number is required;

        method info-str {
            $.number ~ $.value;
        }
    }

    class MdLiNumDotStart     is MdLiNumberStart is export { }
    class MdLiNumBracketStart is MdLiNumberStart is export { }

    class MdLiNumEmbraceStart is MdLiNumberStart is export {
        method info-str {
            "({ $.number })"
        }
    }

    class MdLiItem is MdContainer is export {
        has MdLiItemStart:D $.starter is required;

        method info-str {
            return "starter«{ $.starter.info-str }»";
        }
    }


    class MdLinkAddr        is MdPlainStr   is export { }
    class MdLinkText        is MdContainer  is export { }

    class MdLink is MdEntity is export {
        has MdLinkText $.text is required;
        has MdLinkAddr $.addr is required;

        method ast-dump ( Int $level --> Str ) {
            callsame() ~ "\n" ~ $.addr.ast-dump( $level + 1 ) ~ "\n" ~ $.text.ast-dump( $level + 1 )
        }

        method classes {
            callsame.push: "Link"
        }
    }

    class MdAddrEmail           is MdPlainStr       is export { }
    class MdAddrUrl             is MdPlainStr       is export { }
    class MdAttributeClass      is MdPlainStr       is export { }
    class MdAttributeId         is MdPlainStr       is export { }
    class MdAutolink            is MdPlainData      is export { }
    class MdLiDelimiter         is MdPlainStr       is export { }
    class MdLinkTitle           is MdLine           is export { }
    class MdLinkReference       is MdLink           is export { }
    class MdLinkdefId           is MdPlainStr       is export { }
    class MdLinkdefParagraph    is MdContainer      is export { }
    class MdSpecialChr          is MdPlainData      is export { }
    class MdSublist             is MdList           is export { }

    class MdAttributes is MdEntity is export {
        has MdEntity @.attrs;
    }

    class MdVerbatim is MdContainer is export {
        has Str $.marker;
        has Str $.space;
        has MdAttributes $.attrs;

        method info-str {
            "code marker:«$.marker»" ~ ($.space ?? " with space" !! "")
        }
    }

    class MdCodeblockStd is MdCodeBlock is export {
        has Str $.indent;
    }

    class MdCodeblockFenced is MdCodeBlock is export {
        has Str $.language;
        has Str $.comment;
        has MdAttributes $.attrs;
    }

    class MdHead is MdContainer is export {
        has $.level is required;
        has MdAttributes $.attributes;

        method name {
            my $name = callsame;
            $name ~ " #$!level";
        }
    }

    class MdAttributeKeyval is MdPlainData is export {
        has Str $.key is required;
        has Str $.quote = "";

        method info-str {
            my $qinf = "";
            $qinf = ";quote:" ~ $_ with $.quote;
            "key:$.key$qinf"
        }
    }

    class MdLinkAdhoc is MdLink is export {
        has MdLinkTitle $.title;
        has MdAttributes $.attrs;

        method ast-dump ( Int $level --> Str ) {
            my $title-dump = $.title.defined ??  "\n" ~ $.title.ast-dump( $level + 1 ) !! "";

            callsame() ~ $title-dump;
        }
    }

    class MdImage is MdEntity is export {
        has MdLink $.link is required;

        method ast-dump ( Int $level --> Str ) {
            callsame() ~ "\n" ~ $.link.ast-dump( $level + 1 )
        }
    }

    class MdLinkDefinition is MdEntity is export {
        has Str $.id is required;
        has MdLinkAddr $.addr is required;
        has MdLine $.title;
        has Str $.indent;
        has MdAttributes $.attrs;

        method ast-dump ( Int $level --> Str ) {
            callsame()
                ~ "[$.id]\n"
                ~ $.addr.ast-dump( $level + 1 )
                ~ ( $.title ?? "\n" ~ $.title.ast-dump( $level + 1 ) !! "" );
        }
    }

    class MdEmphasis is MdPlainData is export {
        has Str $.mark is required;

        method info-str { $.mark }
    }

# Grammar actions
    class MDGActions is export {
        has $.nodePrefix = 'Md';
        has $.curLine = 1;

        has $!containerClass;
        has $!plainDataClass;

        # Takes a rule name in form md-word1-woRd2, returns MdWord1WoRd2
        method rule2type ( Str $ruleName is copy ) {
            return $ruleName unless $ruleName ~~ /^ "md-" /;
            $ruleName ~~ s/':' sym '<' (.+?) '>'/-$0/;
            $ruleName.split("-")[1..*].map( { .tc } ).join;
        }

        method type2class ( Str $nodeType ) {
            my $className = $!nodePrefix ~ $nodeType ;
            return Nil if ::{$className} ~~ Nil;
            return $className;
        }

        multi method makeNode( Str $rule, |objParams ) {
            state %rule2class;
            my ($class, $type);
            if %rule2class{$rule}:exists {
                ($class, $type) = %rule2class{$rule}<class type>;
            } else {
                $type = self.rule2type( $rule );
                #say "Rule $rule => $type";
                $class = self.type2class( $type );
                %rule2class{$rule} = { :$class, :$type };
                #say "No class for $type" unless $class;
            }
            fail "No class for node '$type'" unless $class;
            return ::($class).new( :$type, |objParams );
        }

        method TOP ($/) {
            $/.make( $/<md-doc>.made );
        }

        method makeHead ( $m, Int $level ) {
            my %h-params;
            %h-params<attributes> = .ast with $m<md-attributes>;
            my $node = self.makeNode( "Head", :$level, |%h-params );
            $node.push( $m<md-line>.made );
            $m.make( $node );
        }

        method md-doc ( $m ) {
            self.addNode( "Doc", $m, link-definitions => %*md-link-definitions );
        }

        method md-header ( $m ) { $m.make( $m<md-head>.ast ) }

        method md-head:sym<setext> ( $m ) {
            my $level = $m<md-hlevel-first> ?? 1 !! 2;
            self.makeHead( $m, $level )
        }

        method md-head:sym<atx> ( $m ) {
            my $level = (~$m<md-hlevel>).chars;
            self.makeHead( $m, $level )
        }

        method md-blockquote ($m) {
            my $bq = self.makeNode( "Blockquote" );
            %*md-link-definitions = %*md-link-definitions, |$m.ast.ast.link-definitions;
            $bq.append( $m.ast.ast.content );
            $m.make( $bq );
        }

        method md-codeblock:sym<std> ( $m ) {
            my $indent = ~$m<md-cb-first-line><md-first-pfx>;
            my $value = ~$m<md-cb-first-line><md-cb-line-body> ~
                        [~] $m<md-cb-line>.map: { ~ $_<md-cb-line-body> }
            $m.make( self.makeNode( "CodeblockStd", :$indent, :$value ) );
        }

        method md-codeblock:sym<fenced> ( $m ) {
            my %cb-params = value => [~] $m<md-cb-line>.map: { ~ $_<md-cb-line-body> };

            %cb-params<language> = ~$_ with $m<md-cb-language>;
            %cb-params<comment>  = ~$_ with $m<md-cb-comment>;

            $m.make(
                self.makeNode(
                    "CodeblockFenced", |%cb-params
                )
            )
        }

        method md-verbatim ( $m ) {
            $m.make(
                self.makeNode(
                        'Verbatim',
                        content => $m<md-line>.ast.content,
                        marker  => ~$m<md-code-marker><md-code-quote>,
                        spacing => ~$m<md-code-marker><md-code-space>,
                )
            );
        }

        method md-list ($m) {
            my $list = self.makeNode("List" );
            for $m.caps {
                $list.push( .value.ast )
            }
            $m.make( $list );
        }

        method md-li-item ($m) {
            my $starter = $m<md-li-item-start>.ast;
            my $li-item = self.makeNode( "LiItem", :$starter );

            for $m.caps[1..*] -> $mcap {
                next unless $mcap.value.ast;
                $li-item.push: $mcap.value.ast;
            }

            $m.make( $li-item );
        }

        method md-li-item-start ( $m ) {
            $m.make(
                self.makeNode(
                    'LiItemStart',
                    value => $m<md-li-item-starter>.ast,
                    align => ~$m<md-align>,
                    spacing => ~$m<spacing>,
                )
            );
        }

        method md-li-item-starter ( $m ) {
            $m.make( $m<starter>.caps[0].value.ast );
        }

        method md-li-bullet-start ( $m ) {
            $m.make( self.makeNode( 'LiBulletStart', value => ~$m<symbol> ) );
        }

        method makeNumStarter ( Str $rule, $m ) {
            $m.make( self.makeNode( $rule, value => ~$m<symbol>, number => ~$m<md-li-num-number> ) );
        }

        method md-li-num-dot-start ( $m ) {
            self.makeNumStarter( 'LiNumDotStart', $m );
        }

        method md-li-num-bracket-start ( $m ) {
            self.makeNumStarter( 'LiNumBracketStart', $m );
        }

        method md-li-num-embrace-start ( $m ) {
            self.makeNumStarter( 'LiNumEmbraceStart', $m );
        }

        method md-li-item-text ( $m ) {
            $m.make( self.makeNode('LiItemText', content => $m<md-line>.ast.content ) );
        }

        method md-chr-escaped ($m) {
            $m.make( self.makeNode( "ChrEscaped", value => ~$m<md-escaped-chr> ) );
        }

        method md-emphasis ( $m ) {
            $m.make(
                self.makeNode(
                    'Emphasis',
                    mark  => ~$m<md-emph-mark>,
                    value => $m<md-line>.ast,
                )
            );
        }

        method md-link-addr-title ( $m ) {
            $m.make( self.makeNode( 'LinkTitle', content => $m<md-line>.ast.content ) )
        }

        method md-link:sym<adhoc> ( $m ) {
            my %link-attrs;

            %link-attrs<text> = $m<md-link-text>.ast;
            %link-attrs<addr> = $m<md-link-dest><md-link-addr>.ast;
            with $m<md-link-dest><md-link-addr-title> {
                %link-attrs<title> = .ast;
            }
            with $m<md-attributes> {
                %link-attrs<attrs> = .ast;
            }
            my $link = self.makeNode("LinkAdhoc", |%link-attrs);
            $m.make( $link );
        }

        method md-link:sym<reference> ( $m ) {
            my %link-attrs;

            my @text-content;
            with $m<md-link-text> {
                @text-content = $_<md-line>.ast.content;
            }
            else {
                @text-content = [ $m<md-linkdef-id>.ast ];
            }

            %link-attrs<text> = self.makeNode( "LinkText", content => @text-content );
            %link-attrs<addr> = self.makeNode(
                                    'LinkAddr',
                                    value => ~( $m<md-linkdef-id> // $m<md-link-text> ) );
            with $m<md-attributes> {
                %link-attrs<attrs> = .ast;
            }

            my $link = self.makeNode( "LinkReference", |%link-attrs );
            $m.make( $link );
        }

        method md-autolink ( $m ) {
            $m.make( self.makeNode( 'Autolink', value => $m<md-addr>.ast ) );
        }

        method md-linkdef-addr ( $m ) {
            my $addr;

            with $m<md-linkdef-addr-value> {
                $addr = self.makeNode( 'PlainStr', value => ~$_ );
            }
            with $m<md-autolink> || $m<md-addr> {
                $addr = .ast;
            }

            $m.make( self.makeNode( 'LinkAddr', :value( $addr ) ) );
        }

        method md-linkdef-title ( $m ) {
            $m.make(
                self.makeNode(
                    'LinkTitle',
                    content => $m<md-line>.ast.content,
                )
            );
        }

        method md-link-definition ( $m ) {
            my %linkdef-attrs =
                                id   => ~$m<md-linkdef-id>,
                                addr => $m<md-linkdef-addr>.ast;

            %linkdef-attrs<title> = .ast with $m<md-linkdef-title>;
            %linkdef-attrs<indent> = ~$_ with $m<md-ld-indent>;
            %linkdef-attrs<attrs> = .ast with $m<md-attributes>;

            my $ldef = self.makeNode( 'LinkDefinition', |%linkdef-attrs );
            %*md-link-definitions{ %linkdef-attrs<id>.fc } = $ldef;
            $m.make( $ldef );
        }

        method md-image ( $m ) {
            $m.make( self.makeNode( 'Image', link => $m<md-link>.ast ) );
        }

        method md-attributes ( $m ) {
            my $attrs = self.makeNode( 'Attributes' );
            $attrs.attrs.push: .ast for $m<md-attribute>;
            $m.make( $attrs );
        }

        method md-attribute:sym<class> ( $m ) {
            $m.make( self.makeNode( 'AttributeClass', value => ~$m<md-attr-class> ) );
        }

        method md-attribute:sym<id> ( $m ) {
            $m.make( self.makeNode( 'AttributeId', value => ~$m<md-attr-id> ) );
        }

        method md-attribute:sym<keyval> ( $m ) {
            my %qparam;
            %qparam<quote> = ~$_ with $m<md-attr-val><mdHTMLValQuot>;
            $m.make(
                self.makeNode(
                    'AttributeKeyval',
                    key => ~$m<md-attr-key>,
                    value => ~$m<md-attr-val><mdHTMLValue>,
                    |%qparam
                )
            );
        }

        #method ws ($m) {
        #    $*md-line++ if ~$m ~~ m/\n/;
        #}

        # Simple nodes where it is enough to use string part of the match
        multi method addNode(Str $name, $m, |node-params ) {
            #note "ADDNODE<$name>:", $m;
            my $node = self.makeNode( $name, |node-params );
            unless ($!containerClass) {
                $!containerClass = ::( self.type2class( "Container" ) );
                $!plainDataClass = ::( self.type2class( "PlainData" ) );
            }
            given ($node) {
                when $!containerClass {
                    #note "Creating container {$node.type}";
                    for $m.chunks -> $elem {
                        # note "CONTAINER \{$name\} MATCH: {$elem.key}::{$elem.value}\n  -> ", $elem.value.perl;
                        # note "!!!! ", $elem.key unless $elem.value.isa('Match');
                        next unless $elem.value.isa('Match');
                        # note "Pushing onto container: ", $elem.value.ast if $elem.value.ast;

                        # Explode if there is a error. Most likely it would be a misspelled node or node class name
                        # detected by makeNode method.
                        if $elem.value.ast ~~ Failure {
                            say $elem.value.ast;
                        }

                        $node.push( $elem.value.ast // self.makeNode( "PlainData", value => ~$elem.value ) );
                    }
                }
                when $!plainDataClass {
                    #say "Creating simple { $node.type } node: $node";
                    $node.value = ~$m;
                }
            }
            $m.make( $node ) if $node.defined;
        }

        multi method FALLBACK ( $name where /^md/, |c ) {
            #note "FALLBACK($name)";
            $?CLASS.^add_method(
                $name,
                method ( |cap ) { self.addNode( $name, |cap ) }
            );
            self."$name"( |c );
        }

        multi method FALLBACK ($name, |c) { callsame }
    }

    role MDTranslator is export {
        proto method translate (|) {*}

        method !map-translate-element ( MdEntity:D $elem --> Str ) {
            my $str = self.translate( $elem );
            #note "GOT STR: ", $str, " // ", $str.WHAT, " from ", $_.WHO;
            if $str ~~ Failure {
                return self.on-failure( $str );
            }
            CATCH {
                default {
                    return self.on-exception( $_ );
                }
            }
            $str
        }

        multi method translate(MdContainer $elem) {
            [~] $elem.content.map( { self!map-translate-element($_) } )
        }

        method on-failure { ... }
        method on-exception { ... }
    }

    multi MDParse ( Str:D $mdText, |parserArgs ) is export {
        my $rc = Markdown.new.parse( $mdText, :actions( MDGActions.new ), |parserArgs );
        return $rc;
    }

    multi MDParse ( IO::Handle:D $fh, |parserArgs ) is export {
        return MDParse( $fh.slurp, |parserArgs );
    }
}
