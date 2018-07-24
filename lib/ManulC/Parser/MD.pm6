#no precompilation;
#use Grammar::Tracer;

module ManulC::Parser::MD {
    use ManulC::Parser::HTML;

    grammar Markdown is export {
        also does HTML-Tag;

        rule TOP {
            #:my Int $*md-line = 1;
            :my Int $*indent-width = 4;
            <md-doc>
        }

        token md-doc {
            ^$
            || [
                <md-blank-space>
                || [
                    <md-head>
                    || <md-list>
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
                <md-html-elem>
                || <md-special-chr>
                || <md-plain-str>
            ]+
        }

        token md-special-chr { <[&<>]> }
        token md-plain-str { \N+? <?before [ <md-special-chr> || $$ ]> }

        token md-head {
            ^^ $<md-hlevel>=[ '#' ** 1..6 ] \h+ <md-line> <md-nl>
        }

        token md-paragraph {
             <md-para-body([rx/<.md-blank-space>/])> <md-nl> 
            #[ <md-line> <md-nl> ]+
        }

        token md-para-body ( @paraEnd ) {
            <md-line>+? % <md-nl> <?before @paraEnd || $>
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
                        || \h <md-li-paragraph>
                    ]
            ]*
        }

        token md-li-paragraph {
            <md-li-indent> <md-para-body([rx/<.md-li-para-end>/])>
        }

        token md-li-para-end {
            :my Str $li-starter; # Stub for md-li-first-start token
            #<.md-eol> [ <.md-blank-space> || \h* <.md-li-first-start($li-starter)> ]
            <.md-eol> [ <.md-blank-space> || <.md-li-item-start> ]
        }

        token md-li-item-start {
            ^^ <md-li-indent> $<md-li-item-starter>=<$*md-li-starter>
        }

        token md-li-indent {
            ' ' ** {^$*indent-width}
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
                    $_.key eq 'md-sublist-paragraph' ??
                    [~] $_.value.caps.map( { $_.key ~~ /^ 'md-sublist-line' || 'md-nl' $/ ?? ~$_.value !! "" } )
                    !!
                    ~$_.value
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
            ' ' ** {$*indent-width}
        }

        token md-eol {
            [ \n || $ ]
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
    }

    class MdPlainData is MdEntity is export {
        has $.value is rw;
    }

    class MdContainer is MdEntity is export {
        has @.content is rw;

        method push( MdEntity $entity ) {
            @.content.push( $entity );
        }
    }

    class MdDoc is MdContainer is export {
    }

    class MdHead is MdContainer is export {
        has $.level is required;

        method name {
            my $name = callsame;
            $name ~ " #$!level";
        }
    }

    class MdBlankSpace is MdPlainData is export {
    }

    class MdPlainStr is MdPlainData is export {
    }

    class MdHtmlElem is MdPlainData is export {
    }

    class MdParagraph is MdContainer is export {
    }

    class MdBlockquote is MdDoc is export {
    }

    class MdList is MdContainer is export {
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

    class MdLiItemSpacer is MdPlainStr is export {
    }

    class MdSublist is MdList is export {
    }

    class MdLine is MdContainer is export {
    }

    class MdSpecialChr is MdPlainData is export {
    }

# Grammar actions
    class MDGActions is export {
        has $.nodePrefix = 'Md';
        has $.curLine = 1;

        has $!containerClass;
        has $!plainDataClass;

        # Takes a rule name in form md-word1-woRd2, returns MdWord1WoRd2
        method rule2type ( Str $ruleName ) {
            return $ruleName unless $ruleName ~~ /^ "md-" /;
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

        method md-head ($/) {
            my $level = (~$/<md-hlevel>).chars;
            #say "HEADING:", $/<md-line>;
            my $node = self.makeNode( "Head", :$level );
            $node.push( $/<md-line>.made );
            $/.make( $node );
        }

        method md-blockquote ($m) {
            my $bq = self.makeNode( "Blockquote" );
            $bq.push( $m.ast.ast );
            $m.make( $bq );
        }

        method md-sublist ($m) {
            # copy items from parsed sublist body.
            my $sublist = self.makeNode( "Sublist", content => $m.ast.ast.content );
            #say "SUBLIST AST:", MDDumpAST( $m.ast.ast );
            #$sublist.push( $m.ast.ast );
            $m.make( $sublist );
        }

        method md-list ($m) {
            my $list = self.makeNode("List");
            $m<md-li-item>.map: { $list.push( $_.ast ) };
            $m.make( $list );
        }

        method md-li-item ($m) {
            my $starter = ~$m<md-li-item-start><md-li-item-starter>;
            my $li-item = self.makeNode( "LiItem", :$starter );

            for $m.caps -> $mcap {
                given $mcap.key {
                    when 'md-li-paragraph' | 'md-sublist' {
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

        method md-paragraph ($m) {
            self.m2paragraph($m, "Paragraph");
        }

        method md-li-paragraph ($m) {
            self.m2paragraph($m, "LiParagraph" );
        }

        #method ws ($m) {
        #    $*md-line++ if ~$m ~~ m/\n/;
        #}

        # Simple nodes where it is enough to use string part of the match
        multi method addNode(Str $name, $m ) {
            my $node = self.makeNode( $name );
            unless ($!containerClass) {
                $!containerClass = ::( self.type2class( "Container" ) );
                $!plainDataClass = ::( self.type2class( "PlainData" ) );
            }
            given ($node) {
                when $!containerClass {
                    #say "Creating container {$node.type}";
                    for $m.chunks -> $m {
                        #say "CONTAINER \{$name\} MATCH: {$m.key}::{$m.value} ", $m.value.perl;
                        #say "!!!! ", $m.key unless $m.value.isa('Match');
                        next unless $m.value.isa('Match');
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
            #say "FALLBACK($name) on ", $?CLASS.^methods;
            $?CLASS.^add_method(
                $name,
                method ( |cap ) { self.addNode( $name, |cap ) }
            );
            self."$name"( |c );
            #self.addNode($name, |c);
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

    sub MDDumpAST ( MdEntity $elem, Int :$level = 0 ) is export {
        my $line = '| ' x $level ~ $elem.type ~ ( $elem.^can('info-str') ?? ": " ~ $elem.info-str !! "" );
        
        if $elem ~~ MdPlainData {
            $line ~= ": «{ $elem.^can('to-str') ?? $elem.to-str !! $elem.value }»";
        } elsif $elem ~~ MdContainer {
            $line ~= "\n" ~ $elem.content
                                .map( { MDDumpAST( $_, level => $level + 1 ) } )
                                .join( "\n" );
        } else {
            $line ~= " !! Unknown type of element: neither PlainData nor Container";
        }
    }
}
