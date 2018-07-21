no precompilation;
use Grammar::Tracer;

module ManulC::Parser::MD {
    use ManulC::Parser::HTML;

    grammar Markdown is export {
        also does HTML-Tag;

        my $indent-width = 4;

        rule TOP {
            :my Int $*md-line = 1;
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
            [ <md-line> <md-nl> ]+
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
                        <md-nl> <?before
                                    <.md-eol>
                                    || ['>' [ ' ' || <.md-eol>]]
                               >
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
            <md-li-item-start> ' ' <md-li-para-body>
            [
                [ <md-nl> <md-blank-space>? ] <!before <md-li-item-start>>
                    [
                        <md-sublist>
                        || <md-li-paragraph>
                    ]
            ]*
        }

        token md-sublist {
            :my Str $*md-sublist-starter;
            [^^ && <?before <md-indent> <md-li-first-start($*md-sublist-starter)>> ]
            <md-sublist-paragraph>+ % [ <md-nl> <md-blank-space> ]

             {
                say "Parsing SUBLIST:", $/, "\n=============";
                #my $m = $/;
                #my $sublist = $m<md-sublist-para>.join("\n");
                #self.WHAT.parse( $sublist, actions => self.actions.clone );
                #say "PARSED SUBLIST:", $/, "\n-----------";
                #$m.make( $/ ) if $/;
                so $/;
             }
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

        token md-li-paragraph {
            <md-li-indent> <md-li-para-body>
        }

        token md-li-para-body {
            <md-line>+? % <md-nl> <?before
                                    $
                                    || <.md-eol> [
                                        <md-blank-space>
                                        || <.md-li-item-start>
                                    ]
                                >
        }

        token md-li-item-start {
            ^^ <md-li-indent> $<md-li-item-starter>=<$*md-li-starter>
        }

        token md-li-indent {
            ' ' ** {^$indent-width}
        }

        token md-li-delimiter {
            <md-nl> <md-blank-space>? <?before <md-li-item-start>>
        }

        token md-indent {
            ' ' ** {$indent-width}
        }

        token md-eol {
            [ \n || $ ]
        }
        token md-nl {
            <.md-eol> { ++$*md-line }
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

    class MdItem is MdContainer is export {
    }

    class MdSublist is MdContainer is export {
    }

    class MdLine is MdContainer is export {
    }

    class MdSpecialChr is MdPlainData is export {
    }

# Grammar actions
    class MDGActions is export {
        has $.nodePrefix = 'Md';

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

        #method md-sublist ($m) {
        #    my $sublist = self.makeNode( "Sublist" );
        #    $sublist.push( $m.ast.ast );
        #    $m.make( $sublist );
        #}

        method md-li-item ($m) {
        }

        method ws ($m) {
            $*md-line++ if ~$m ~~ m/\n/;
        }

        # Simple nodes where it is enough to use string part of the match
        multi method addNode(Str $name, $/ ) {
            my $node = self.makeNode( $name );
            unless ($!containerClass) {
                $!containerClass = ::( self.type2class( "Container" ) );
                $!plainDataClass = ::( self.type2class( "PlainData" ) );
            }
            given ($node) {
                when $!containerClass {
                    #say "Creating container {$node.type}";
                    for $/.chunks -> $m {
                        #say "CONTAINER \{$name\} MATCH: {$m.key}::{$m.value} ", $m.value.perl;
                        #say "!!!! ", $m.key unless $m.value.isa('Match');
                        next unless $m.value.isa('Match');
                        $node.push( $m.value.made // self.makeNode( "PlainData", value => ~$m.value ) );
                    }
                }
                when $!plainDataClass {
                    #say "Creating simple { $node.type } node: $node";
                    $node.value = ~$/;
                }
            }
            $/.make( $node ) if $node.defined;
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

    multi MDParse (Str:D $mdText) is export {
        my $rc = Markdown.new.parse( $mdText, :actions( MDGActions.new ) );
        return $rc;
    }

    multi MDParse ( IO::Handle:D $fh ) is export {
        return MDParse( $fh.slurp );
    }

}
