# $Id: 20-a.t,v 1.1 2003/11/18 08:27:29 ctriv Exp $

use Test::More tests => 7503;
use Regexp::Common qw/dns/;
use strict;

#
# This is already tested by Regexp::Common, but I'm putting a few extra tests in...
#
my $re = $RE{'dns'}{'data'}{'a'};

for (0..2500) {
	my $ip = random_ip();
	like($ip, "/^$re\$/", "$ip matches");
		
	$ip =~ m/^$re->{'-keep'}$/;
	
	is($1, $ip, "\$1 is $ip");
}


for (0..2500) {
	my $ip = random_bad_ip();
	
	unlike($ip, "/^$re\$/", "$ip does not match");
}


sub random_ip {
	return join('.',
		int rand(255),
		int rand(255),
		int rand(255), 
		int rand(255),
	);
}

sub random_bad_ip {
	my @ip = (
		int rand(255),
		int rand(255) ,
		int rand(255), 
		int rand(255),
	);
	
	for (0..rand(4)) {
		$ip[rand @ip] += 256;
	}
	
	return join('.', @ip[0..rand @ip]);
}

