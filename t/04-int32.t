# $Id: 04-int32.t,v 1.3 2003/11/17 22:36:42 ctriv Exp $

use Test::More tests => 4004;
use Regexp::Common qw/dns/;
use strict;

my $int = (2 ** 32) - 1;

my $re = "/^$RE{'dns'}{'int32'}\$/";

for (0 .. 1000) {
	like($_, $re, "$_ matches");
}

for (my $i = $int - 500; $i<= $int; $i++) {
	like($i, $re, "$i matches");
}
	
for (my $i = $int + 1; $i <= $int + 500; $i++) {
	unlike($i, $re, "$i does not match");
}

like(int(rand $int),              $re) for 0 .. 1000;
unlike(int(rand $int) + $int + 1, $re) for 0 .. 1000;
