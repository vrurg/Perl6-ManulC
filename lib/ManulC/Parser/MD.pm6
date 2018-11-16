use v6.c;
#`«
no precompilation;
use Grammar::Tracer;
»

module ManulC::Parser::MD {
    use ManulC::Parser::HTML;

    grammar Markdown is export {
        also does HTML-Tag;

        enum LineElements <html code attributes autolink link emphasis chr-escaped chr-special link-definition>;

        my sub set-line-elements ( *%elems ) {
            %*md-line-elems{$_} = so %elems{$_} for %elems.keys;
        }

        my multi sub only-line-elements ( *@elems ) {
            samewith( @elems );
        }
        my multi sub only-line-elements ( @elems ) {
            my %values = @elems.map: { $_ => True };
            %*md-line-elems = LineElements::.keys.map: { $_ => %values{ $_ } // False };
        }

        my sub all-line-elements {
            %*md-line-elems = LineElements::.keys.map: { $_ => True };
        }

        our sub prepare-globals {
            $*md-indent-width = 4;
            $*md-quotable = rx/\W/;
            $*md-line-end = rx/<.md-eol>/;
            all-line-elements;
        }

        rule TOP {
            #:my Int $*md-line = 1;
            :my Int $*md-indent-width;
            :my Regex $*md-quotable;
            :my $*md-line-end;
            :my Bool %*md-line-elems;
            { prepare-globals }
            <md-doc>
        }

        token md-doc {
            ^$
            || [
                <md-blank-space>
                || [
                    <md-header>
                    || <md-hrule>
                    || <md-linkdef-paragraph>
                    || <md-list>
                    || <md-codeblock>
                    || <md-blockquote>
                    || <md-paragraph>
                ]+ %% <md-blank-space>
            ]+
        }

        token md-blank-space {
            <md-blank-line>+
        }

        token md-blank-line {
            ^^ \h* <md-nl>
        }

        token md-html-elem {
            <mdHTMLTag> || <mdHTMLEntity>
        }

        token md-line {
            [ 
                   [ <md-chr-escaped>     <?{ %*md-line-elems<chr-escaped> }> ]
                || [ <md-attributes>      <?{ %*md-line-elems<attributes> }>  ]
                || [ <md-autolink>        <?{ %*md-line-elems<autolink> }>    ]
                || [ <md-html-elem>       <?{ %*md-line-elems<html> }>        ]
                || [ <md-code-inline>     <?{ %*md-line-elems<code> }>        ]
                || [ <md-link>            <?{ %*md-line-elems<link> }>        ]
                || [ <md-link-definition> <?{ %*md-line-elems<link-definition> }> ]
                || [ <md-emphasis>        <?{ %*md-line-elems<emphasis> }>    ]
                || [ <md-chr-special>     <?{ %*md-line-elems<chr-special> }> ]
                || <md-plain-str(rx/   
                                    [ <md-chr-escaped> <?{ %*md-line-elems<chr-escaped> }> ]
                                    || [ <md-chr-special> <?{ %*md-line-elems<chr-special> }> ]
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
        token md-chr-special { <[&<>_*`(){}[\]]> }
        token md-plain-str ($str-end) { [ <!before $($str-end)> . ]+ }

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
        }

        token md-link:sym<reference> {
            [ '[' ~ ']' <md-linkdef-id> \h* '[]' ]
            ||
            [ '[' ~ ']' <md-link-text> \h* '[' ~ ']' <md-linkdef-id> ]
        }

        # Link text is similar to md-line except that:
        # - nested links are not allowed
        # - ']' is serving as EOL
        # - empty line is not allowed
        token md-link-text { 
            :temp %*md-line-elems;
            { set-line-elements( :!link, :!autolink, :!link-definition ) }
            :temp $*md-line-end = rx/ ']' /;
            <md-line>
        }

        token md-link-dest {
            <md-link-addr> [ \h+ <md-link-addr-title> ]?
        }

        token md-linkdef-id {
            \N+? <?before ']'>
        }

        token md-linkdef-addr {
            <md-autolink>
            || <md-addr>
            || $<md-linkdef-addr-value>=\S+ 
        }

        token md-linkdef-title {
            :my $ttl-closing;
            :temp $*md-line-end;
            :temp %*md-line-elems;
            <["'(]> {
                $ttl-closing = ~$/ eq '(' ?? ')' !! ~$/; 
                $*md-line-end = $ttl-closing;
                only-line-elements( <chr-escaped chr-special> );
            }
            <md-line>
            $($ttl-closing)
        }

        token md-link-definition {
            ^^ $<md-ld-indent>=[\h ** {^$*md-indent-width}]
            [ '[' ~ ']' <md-linkdef-id> ] ':'
            \h+
            <md-linkdef-addr>
            [ [\h* <.md-nl> $<md-ld-indent>]? \h+ <md-linkdef-title> ]?
            \h* $$
        }

        token md-linkdef-paragraph {
            <md-link-definition>+ % <md-nl> <md-nl>
        }

        token md-image {
            '!' <md-link>
        }

        token md-emph-mark {
            <[_*]> ** 1..2 <?before \S> 
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

        token md-code-marker {
            $<md-code-quote>='`' ** 1..2 $<md-code-space>=\s?
        }

        token md-code-inline {
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

        token md-link-addr {
            <md-plain-str( rx/ \h || \) / )>
        }

        # - only escaped or special chars are allowed
        # - no HTML, no anything else
        # - " enclosed
        # - could be empty (is it a good idea?)
        token md-link-addr-title {
            :temp $*md-quotable = rx/<[\"]>/;
            \" ~ \" [
                <md-chr-escaped>
                || <md-chr-special>
                || <md-plain-str(rx/ <md-chr-special> || <md-chr-escaped> || \" /)>
            ]*
        }

        token md-header {
            :temp %*md-line-elems;
            { only-line-elements( <html attributes code link emphasis chr-escaped chr-special> ) }
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
            <md-nl>
        }

        token md-head:sym<setext> {
            :temp $*md-line-end;
            ^^
            # Do a fast check-up first because otherwise this rule is tested against every other entity in the document
            # and md-line is parsed repeatedly for each invocation. This is why I hated setext-styled headings since the
            # beginning...
            [ \N+ <md-nl> [ '='+ || '-'+ ] <md-nl> ] 
            &&
            [
                { $*md-line-end = rx{ <.md-attributes>? <.md-eol> }; }
                <md-line> \h* <md-attributes>? \h* <md-nl>
                [ 
                    $<md-hlevel-first>=[ '='+ ]
                    || $<md-hlevel=second>=[ '-'+ ]
                ]
                <md-nl>
            ]
        }

        token md-hrule {
            ^^ \h* $<md-hr-sym>=<[*_-]> $<md-hr-delim>=[ \h* ] {} $<md-hr-sym> ** 2..* % $<md-hr-delim> \h* <md-nl>
        }

        token md-paragraph {
            #<md-para-body( rx/<.md-eol> [ <.md-blank-space> || $ ]/ )> <md-nl> 
            :temp $*md-line-end = rx/<.md-eol> [ <.md-blank-space> || $ ]/;
             <md-line> <md-nl> 
        }

        token md-para-body ( $paraEnd ) {
            <md-line>+? % <md-nl> <?before $($paraEnd) || $>
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
            ^^ '>' [
                $<md-bq-line-body>=<md-nl>
                || ' ' $<md-bq-line-body>=[
                    .*? [
                        <md-nl> <?before <.md-eol> || ['>' [ ' ' || <.md-eol>]]>
                    ]
                ]
            ]
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
            ^^ ' '* { $*md-cb-prefix = ~$/ } <md-cb-fence> 
               [ $<md-cb-language>=\S+ ]? 
               [ <md-nl> || \s $<md-cb-comment>=\N*? <md-nl> ]
            <md-cb-line>*?
            ^^ $($*md-cb-prefix) $($*md-cb-fence-char) ** {$*md-cb-fence-length..Inf} <md-nl>
        }

        token md-cb-first-line {
            $<md-first-pfx>=[ <md-indent>+ ] <md-cb-line-body> { $*md-cb-prefix = ~$<md-first-pfx> }
        }

        token md-cb-line {
            $($*md-cb-prefix) <md-cb-line-body>
        }

        token md-cb-line-body {
            \N+ <md-nl>
        }

        # Fenced code block defined with ` or ~ and language name support
        token md-cb-fence {
            [ '`' ** 3..* || '~' ** 3..* ] {
                $*md-cb-fence-char =  $/.substr( 0, 1 );
                $*md-cb-fence-length = $/.chars;
            }
        }

        my $li-bullet-start = q{<[*+-]>};
        my $li-num-start = q{\d+ '.' [ [\d+]* % '.' ]};
        token md-list {
            :my Str $*md-li-starter;
            <md-li-first-start($*md-li-starter)> <md-li-item>+ % <md-li-delimiter> <md-nl>
        }

        token md-li-first-start (Str $li-starter is rw) {
            [
                && <?before
                    <md-li-indent>
                        [
                            <$li-bullet-start> { $li-starter = $li-bullet-start }
                            || <$li-num-start> { $li-starter = $li-num-start }
                        ]
                   >
            ]
        }

        token md-li-item {
            <md-li-item-start> \h+? <md-li-paragraph>
            [
                $<md-li-item-spacer>=[ <md-nl> <md-blank-space>? ] <!before <.md-li-item-start>>
                    [
                        <md-sublist>
                        || <md-codeblock>
                        || \h <md-li-paragraph>
                    ]
            ]*
        }

        token md-li-paragraph {
            <md-li-indent> <md-para-body( rx/<.md-li-para-end>/ )>
        }

        token md-li-para-end {
            :my Str $li-starter; # Stub for md-li-first-start token
            <.md-eol> [ <.md-blank-space> || <.md-li-item-start> || $ ]
        }

        token md-li-item-start {
            ^^ <md-li-indent> $<md-li-item-starter>=<$*md-li-starter>
        }

        token md-li-indent {
            ' ' ** {^$*md-indent-width}
        }

        token md-li-delimiter {
            <md-nl> <md-blank-space>? <?before <.md-li-item-start>>
        }

        token md-sublist {
            :my Str $*md-sublist-starter;
            [
                [^^ && <?before <md-indent> <md-li-first-start($*md-sublist-starter)>> ]
                <md-sublist-paragraph>+ % [ <md-nl> <md-blank-space> ]
            ]
            <?{ # Use boolean to fail sublist parsing if sublist is malformed.
                my $m = $/;
                my $sublist = [~] $m.caps.map( { 
                    .key eq 'md-sublist-paragraph' ??
                    [~] .value.caps.map( { .key ~~ /^ 'md-sublist-line' || 'md-nl' $/ ?? ~.value !! "" } )
                    !!
                    ~.value
                });
                self.WHAT.parse( $sublist, rule => "md-list", actions => self.actions.clone );
                $m.make( $/ ) if $/;
                so $/;
            }>
        }

        token md-sublist-paragraph {
          [ ^^ <md-indent> <md-sublist-line> ]+ % <md-nl>
        }

        token md-sublist-line {
            <md-sublist-line-noblank>+? % <md-nl> <?before <.md-eol> [ <.md-indent> || <.md-blank-space> || <.md-li-item-start> ]>
        }

        token md-sublist-line-noblank {
            \s* \S \N*
        }

        token md-indent {
            ' ' ** {$*md-indent-width}
        }

        token md-eol {
            \n || $
        }
        token md-nl {
            <.md-eol> # { ++$*md-line }
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
    }

    class MdPlainData is MdEntity is export {
        has $.value is rw;

        method ast-dump ( Int $level --> Str ) {
            my $ent = callsame;
            return $ent ~ "\n" ~ $!value.ast-dump( $level + 1 ) if $!value ~~ MdEntity;
            $ent ~ ": «" ~ $!value ~ "»";
        }
    }

    class MdContainer is MdEntity is export {
        has @.content is rw;

        method push( MdEntity $entity ) {
            @.content.push( $entity );
        }

        method ast-dump ( Int $level --> Str ) {
            callsame() ~ "\n" ~ @.content.map( { .ast-dump( $level + 1 ) } ).join( "\n" )
        }
    }

    class MdBlankSpace      is MdPlainData  is export { }
    class MdChar            is MdPlainData  is export { }
    class MdDoc             is MdContainer  is export { }
    class MdPlainStr        is MdPlainData  is export { }

    class MdBlockquote      is MdDoc        is export { }
    class MdChrEscaped      is MdChar       is export { }
    class MdChrSpecial      is MdChar       is export { }
    class MdHtmlElem        is MdPlainData  is export { }
    class MdParagraph       is MdContainer  is export { }
    class MdList            is MdContainer  is export { }
    class MdCodeBlock       is MdPlainData  is export { }

    class MdCodeblockStd is MdCodeBlock is export {
        has Str $.indent;
    }

    class MdCodeblockFenced is MdCodeBlock is export {
        has Str $.language;
        has Str $.comment;
    }

    class MdLiItem is MdContainer is export {
        has Str $.starter;

        method info-str {
            return "starter({ $.starter })";
        }
    }

    class MdLiParagraph is MdParagraph is export {
        has Str $.indent;
    }

    class MdLinkAddr        is MdPlainData  is export { }
    class MdLinkText        is MdContainer  is export { }

    class MdLink is MdEntity is export {
        has MdLinkText $.text is required;
        has MdLinkAddr $.addr is required;

        method ast-dump ( Int $level --> Str ) {
            callsame() ~ $.addr.ast-dump( $level + 1 ) ~ "\n" ~ $.text.ast-dump( $level + 1 )
        }
    }

    class MdAddrEmail           is MdPlainStr       is export { }
    class MdAddrUrl             is MdPlainStr       is export { }
    class MdAttributes          is MdContainer      is export { }
    class MdAttributeClass      is MdPlainStr       is export { }
    class MdAttributeId         is MdPlainStr       is export { }
    class MdAutolink            is MdPlainData      is export { }
    class MdLine                is MdContainer      is export { }
    class MdLinkAddrTitle       is MdContainer      is export { }
    class MdLinkReference       is MdLink           is export { }
    class MdLinkdefId           is MdPlainStr       is export { }
    class MdLinkdefParagraph    is MdContainer      is export { } 
    class MdSpecialChr          is MdPlainData      is export { }
    class MdSublist             is MdList           is export { }
    class MdLiItemSpacer        is MdPlainStr       is export { }
    class MdLinkdefAddr         is MdPlainData      is export { }

    class MdHead is MdContainer is export {
        has $.level is required;
        has MdAttributes $.attributes;

        method name {
            my $name = callsame;
            $name ~ " #$!level";
        }
    }

    class MdAttributeKeyval is MdPlainData is export {
        has Str $.key;
        has Str $.quote;

        method info-str {
            my $qinf = "";
            $qinf = ";quote:" ~ $_ with $.quote;
            "key:$.key$qinf"
        }
    }

    class MdLinkAdhoc is MdLink is export {
        has MdLinkAddrTitle $.title;

        method ast-dump ( Int $level --> Str ) {
            my $title-dump = $.title.defined ??  "\n" ~ $.title.ast-dump( $level + 1 ) !! "";
                    
            callsame() ~ $title-dump;
        }
    }

    class MdImage is MdEntity is export {
        has MdLink $.link is required;
    }

    class MdLinkDefinition is MdEntity is export {
        has Str $.id is required;
        has MdLinkdefAddr $.addr is required;
        has MdLine $.title;
        has Str $.indent;

        method ast-dump ( Int $level --> Str ) {
            callsame()
                ~ "[$.id]\n" 
                ~ $.addr.ast-dump( $level + 1 )
                ~ ( $.title ?? "\n" ~ $.title.ast-dump( $level + 1 ) !! "" );
        }
    }

    class MdEmphasis is MdPlainStr is export {
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
            return Nil unless $class;
            return ::($class).new( :$type, |objParams );
        }

        method TOP ($/) {
            $/.make( $/<md-doc>.made );
        }

        method makeHead ( $m, Int $level ) {
            my $node = self.makeNode( "Head", :$level );
            $node.push( $m<md-line>.made );
            $node.push: .ast with $m<md-attributes>;
            $m.make( $node );
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
            $bq.push( $m.ast.ast );
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

        method md-sublist ($m) {
            # copy items from parsed sublist body.
            my $sublist = self.makeNode( "Sublist", content => $m.ast.ast.content );
            #$sublist.push( $m.ast.ast );
            $m.make( $sublist );
        }

        method md-list ($m) {
            my $list = self.makeNode("List");
            $m<md-li-item>.map: { $list.push( .ast ) };
            $m.make( $list );
        }

        method md-li-item ($m) {
            my $starter = ~$m<md-li-item-start><md-li-item-starter>;
            my $li-item = self.makeNode( "LiItem", :$starter );

            for $m.caps -> $mcap {
                given $mcap.key {
                    when 'md-li-paragraph' | 'md-sublist' | 'md-codeblock' {
                        $li-item.push($mcap.value.ast);
                    }
                    when 'md-li-item-spacer' {
                        $li-item.push(
                            self.makeNode( 'LiItemSpacer', value => ~$mcap.value )
                        )
                    }
                }
            }

            $m.make( $li-item );
        }

        method m2paragraph ($m, Str $type) {
            my $node = self.makeNode( $type );
            for $m<md-para-body>.caps -> $mcap {
                $node.push( $mcap.value.ast // self.makeNode( "PlainData", value => ~$mcap.value ) );   
            }
            $node.push( self.makeNode( "PlainData", value => ~$m<md-nl> ) )
                if $m<md-nl>;
            $m.make( $node );
        }

        method md-li-paragraph ( $m ) {
            self.m2paragraph($m, "LiParagraph" );
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

        method md-link:sym<adhoc> ( $m ) {
            my %link-attrs;

            %link-attrs<text> = $m<md-link-text>.ast;
            %link-attrs<addr> = $m<md-link-dest><md-link-addr>.ast;
            with $m<md-link-dest><md-link-addr-title> {
                %link-attrs<title> = .ast;
            }
            my $link = self.makeNode("LinkAdhoc", |%link-attrs);
            $m.make( $link );
        }

        method md-link:sym<reference> ( $m ) {
            my %link-attrs;

            %link-attrs<text> = self.makeNode( "LinkText", content => [ ~( $m<md-link-text> // $m<md-linkdef-id> ) ] );
            %link-attrs<addr> = self.makeNode(
                                    'LinkAddr', 
                                    value => ~( $m<md-linkdef-id> // $m<md-link-text> ) );

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

            $m.make( self.makeNode( 'LinkdefAddr', :value( $addr ) ) );
        }

        method md-linkdef-title ( $m ) {
            $m.make( $m<md-line>.ast );
        }

        method md-link-definition ( $m ) {
            my %linkdef-attrs = 
                                id   => ~$m<md-linkdef-id>,
                                addr => $m<md-linkdef-addr>.ast;

            %linkdef-attrs<title> = .ast with $m<md-linkdef-title>;
            %linkdef-attrs<indent> = ~$_ with $m<md-ld-indent>;

            $m.make( self.makeNode( 'LinkDefinition', |%linkdef-attrs ) );
        }

        method md-image ( $m ) {
            $m.make( self.makeNode( 'Image', link => $m<md-link>.ast ) );
        }

        method md-attributes ( $m ) {
            my $attrs = self.makeNode( 'Attributes' );
            $attrs.push: .ast for $m<md-attribute>;
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
        multi method addNode(Str $name, $m ) {
            #note "ADDNODE<$name>:", $m;
            my $node = self.makeNode( $name );
            unless ($!containerClass) {
                $!containerClass = ::( self.type2class( "Container" ) );
                $!plainDataClass = ::( self.type2class( "PlainData" ) );
            }
            given ($node) {
                when $!containerClass {
                    #say "Creating container {$node.type}";
                    for $m.chunks -> $m {
                        #note "CONTAINER \{$name\} MATCH: {$m.key}::{$m.value} ", $m.value.perl;
                        #say "!!!! ", $m.key unless $m.value.isa('Match');
                        next unless $m.value.isa('Match');
                        #note "Pushing onto container: ", $m.value.ast if $m.value.ast;
                        $node.push( $m.value.ast // self.makeNode( "PlainData", value => ~$m.value ) );
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
            #note "FALLBACK($name) on ", $?CLASS.^name;
            $?CLASS.^add_method(
                $name,
                method ( |cap ) { self.addNode( $name, |cap ) }
            );
            self."$name"( |c );
        }

        multi method FALLBACK ($name, |c) { callsame }
    }

    role MDTranslator is export {
        has MdEntity $.elem is required;

        multi method translate () {
            #say "[default]";
            self.translate( $.elem );
        }

        multi method translate(MdContainer $elem) {
            #say "[container {$elem.name}]";
            return [~] $elem.content.map: { self.translate( $_ ) };
        }

        multi method translate(MdPlainData $elem) { ... }
    }

    multi MDParse ( Str:D $mdText, |parserArgs ) is export {
        my $rc = Markdown.new.parse( $mdText, :actions( MDGActions.new ), |parserArgs );
        return $rc;
    }

    multi MDParse ( IO::Handle:D $fh, |parserArgs ) is export {
        return MDParse( $fh.slurp, |parserArgs );
    }
}
