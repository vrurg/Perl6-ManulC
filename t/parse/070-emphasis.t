use v6;
#`(
no precompilation;
use Grammar::Tracer;
)

use Test;
use ManulC::Parser::MD;

my $text = q{a text _with_ **emp_has_is** and *nested _emph_*

sdlkfjhsd_f;l};

my $res = MDParse( $text );
say $res;

# vim: ft=perl6
