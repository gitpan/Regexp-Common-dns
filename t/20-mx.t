# $Id: 20-mx.t,v 1.2 2003/11/18 08:27:29 ctriv Exp $

use strict;
use Regexp::Common qw/dns/;

use Test::More tests => 27;


test_good_mxes($RE{'dns'}{'data'}{'mx'},
	{
		data     => '10 mail.example.com',
		exchange => 'mail.example.com',
		pref     => '10'
	},
	{
		data     => '1000 mail',
		exchange => 'mail',
		pref     => '1000'
	},
);

my $overflow = 2**16;

test_bad_mxes($RE{'dns'}{'data'}{'mx'},
	'',
	'1234567',
	'mail.example.com',
	'1 0 mail.example.com',
	"$overflow mail.example.com",
	'256 rfc_2181/hostname.com',
);


# test the the flags all work
test_good_mxes($RE{'dns'}{'data'}{'mx'}{-minlables => 2},
	{
		data     => '10 mail.example.com',
		exchange => 'mail.example.com',
		pref     => '10'
	},
);

test_bad_mxes($RE{'dns'}{'data'}{'mx'}{-minlables => 2},
	'10 com',
);


test_good_mxes($RE{'dns'}{'data'}{'mx'}{-rfc => 2181},
	{
		data     => '10 rfc_2181/hostname.com',
		exchange => 'rfc_2181/hostname.com',
		pref     => '10'
	},
);


sub test_good_mxes {
	my ($re, @good) = @_;
	
	my $keep = $re->{'-keep'};
	
	
	for (@good) {
		like($_->{'data'}, "/^$re\$/",   "$_->{'data'} matches");
		ok($_->{'data'} =~ m/^$keep$/, "$_->{'data'} matches with keep");
		
		is($1, $_->{'data'},     '$1 is data');
		is($2, $_->{'pref'},     '$2 is pref');
		is($3, $_->{'exchange'}, '$3 is exchange');
	}
}


sub test_bad_mxes {
	my ($re, @bad) = @_;
	
	unlike($_, "/^$re\$/", "$_ does not match") for @bad;
}
