use v6;
use lib q<./build-tools/lib>;
use MCTest;
use Test;
use ManulC::Parser::MD;
use ManulC::Translator::MD2HTML;

plan 1;

subtest "Basic" => {
    my @tests =
        {
            text => q:to/MD/,
                    First paragraph

                    Second paragraph
                    MD
            name => "simplest text",
            html => '<p class="mcEntity mcContainer mcParagraph">First paragraph</p><p class="mcEntity mcContainer mcParagraph">Second paragraph</p>',
        },
        {
            text => q:to/MD/,
                    First paragraph with &, and >, and <, and ', and )

                    Second paragraph
                    MD
            name => "special chars",
            html => '<p class="mcEntity mcContainer mcParagraph">First paragraph with &amp;, and &gt;, and &lt;, and &#39;, and &#41;</p><p class="mcEntity mcContainer mcParagraph">Second paragraph</p>',
        },
        {
            text => q:to/MD/,
                    First paragraph with <em id="mine">HTML</em>

                    Second paragraph
                    MD
            name => "HTML elements",
            html => '<p class="mcEntity mcContainer mcParagraph">First paragraph with <em id="mine">HTML</em></p><p class="mcEntity mcContainer mcParagraph">Second paragraph</p>',
        },
        {
            text => q:to/MD/,
                    First line \
                    Second line
                    MD
            name => "quoted newline",
            html => '<p class="mcEntity mcContainer mcParagraph">First line <br />Second line</p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with {#anch1 #anch2} anchors
                    MD
            name => "anchors",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with <a id="anch1" /><a id="anch2" /> anchors</p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with verbatim: `code & code`
                    MD
            name => "verbatim",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with verbatim: <code class="mcEntity mcContainer mcVerbatim">code &amp; code</code></p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with ad-hoc link: [Link with href & title](http://anywhere.org "Title <\"text\">")
                    MD
            name => "ad-hoc link",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with ad-hoc link: <a class="mcEntity mcLink mcLinkAdhoc" href="http://anywhere.org" title="Title &lt;&#34;text&#34;&gt;">Link with href &amp; title</a></p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with ad-hoc link: [Link with href & title](http://anywhere.org "Title <\"text\">"){.Mine key=value attr="text"}
                    MD
            name => "ad-hoc link with attributes",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with ad-hoc link: <a class="mcEntity mcLink mcLinkAdhoc Mine" href="http://anywhere.org" title="Title &lt;&#34;text&#34;&gt;" key=value attr="text">Link with href &amp; title</a></p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link: [see at][link id]

                    [Link ID]: http://nah.dont.go "Title is mine!"
                    MD
            name => "reference link",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with reference link: <a class="mcEntity mcLink mcLinkReference" href="http://nah.dont.go" title="Title is mine&#33;">see at</a></p>',
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link to a missing definition: [see at][no id]
                    MD
            name => "reference link without link definition",
            html => q{<p class="mcEntity mcContainer mcParagraph">Paragraph with reference link to a missing definition: <span class="mcWarning">No link definition found for ID 'no id'</span></p>}
        },
        {
            text => q:to/MD/,
                    Paragraph with reference link: [see at][посилання]

                    [Посилання]: <http://nah.dont.go> "Загловок із \" квотуванням"
                    MD
            name => "reference link with autolinked definition",
            html => '<p class="mcEntity mcContainer mcParagraph">Paragraph with reference link: <a class="mcEntity mcLink mcLinkReference" href="<a href=http://nah.dont.go>http://nah.dont.go</a>" title="Загловок із &#34; квотуванням">see at</a></p>',
        },
        {
            text => q:to/MD/,
                    See if escaped chars work: \&, \", \., \*
                    MD
            name => "escaped chars",
            html => '<p class="mcEntity mcContainer mcParagraph">See if escaped chars work: &amp;, &#34;, &#46;, &#42;</p>',
        },
        {
            text => q:to/MD/,
                    If looking for The Holy Graail – try <http://google.com>
                    MD
            name => "autolinking",
            html => '<p class="mcEntity mcContainer mcParagraph">If looking for The Holy Graail – try <a href=http://google.com>http://google.com</a></p>',
        },
        {
            text => q:to/MD/,
                    ![Isn't this artwork just gorgeous?](/img/arts/top1.png "Is it for real?")
                    MD
            name => "ad-hoc image",
            html => '<p class="mcEntity mcContainer mcParagraph"><img class="mcImage mcImageAdhoc" src="/img/arts/top1.png" title="Is it for real?" alt="Isn&#39;t this artwork just gorgeous?" /></p>',
        },
        {
            text => q:to/MD/,
                    ![top artwork][]

                    [Top Artwork]: /img/arts/top1.jpg "Just look at it!"
                    MD
            name => "ad-hoc image",
            html => '<p class="mcEntity mcContainer mcParagraph"><img class="mcImage mcImageReference" src="/img/arts/top1.jpg" title="Just look at it&#33;" alt="top artwork" /></p>',
        },
        {
            text => q:to/MD/,
                    Emphasis variants: _underscore_, *asterisk*, __double under__, **double aster**, _*heh*_, _under and *aster* and __strong under__ same time_
                    MD
            name => "emphasis",
            html => '<p class="mcEntity mcContainer mcParagraph">Emphasis variants: <em class="mcEntity">underscore</em>, <em class="mcEntity">asterisk</em>, <strong class="mcEntity">double under</strong>, <strong class="mcEntity">double aster</strong>, <em class="mcEntity"><em class="mcEntity">heh</em></em>, <em class="mcEntity">under and <em class="mcEntity">aster</em> and <strong class="mcEntity">strong under</strong> same time</em></p>',
        },
    ;

    md-test-MD2HTML( @tests );
}

done-testing;
# vim: ft=perl6
