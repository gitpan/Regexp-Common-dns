# $Id: 03-int16.t,v 1.4 2003/11/17 22:36:42 ctriv Exp $

use Test::More tests => 4004;
use Regexp::Common qw/dns/;
use strict;

my $int = (2 ** 16) - 1;

my $re = "/^$RE{'dns'}{'int16'}\$/";

for (0 .. 1000) {
	like($_, $re, "$_ matches");
}

for (($int - 500) .. $int) {
	like($_, $re, "$_ matches");
}
	
for (($int + 1) .. ($int + 500)) {
	unlike($_, $re, "$_ does not match");
}


like(int(rand $int),              $re) for 0 .. 1000;
unlike(int(rand $int) + $int + 1, $re) for 0 .. 1000;
