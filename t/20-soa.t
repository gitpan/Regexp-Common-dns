# $Id: 20-soa.t,v 1.1 2003/11/18 08:25:51 ctriv Exp $

use strict;
use Regexp::Common qw/dns/;

use Test::More tests => 122;

my $int32_overflow = 2**32;
my $int32_max      = 2**32 - 1;

test_good_soa($RE{'dns'}{'data'}{'soa'},
	{
		data     => 'A.ROOT-SERVERS.NET. NSTLD.VERISIGN-GRS.COM. 2003111701 1800 900 604800 86400',
		mname    => 'A.ROOT-SERVERS.NET.',
		rname    => 'NSTLD.VERISIGN-GRS.COM.',
		serial   => 2003111701,
		refresh  => 1800,
		retry    => 900,
		expire   => 604800,
		minimum  => 86400,
	},
	{
		data     => 'ns1.example.com hostmaster.example.com 2160314910 600 300 604800 600',
		mname    => 'ns1.example.com',
		rname    => 'hostmaster.example.com',
		serial   => 2160314910,
		refresh  => 600,
		retry    => 300,
		expire   => 604800,
		minimum  => 600,
	},
	{
		data     => 'ns1 hostmaster.example 1 600 300 604800 600',
		mname    => 'ns1',
		rname    => 'hostmaster.example',
		serial   => 1,
		refresh  => 600,
		retry    => 300,
		expire   => 604800,
		minimum  => 600,
	},
	{
		data     => "ns_1.example.com host-master.example.com $int32_max $int32_max $int32_max $int32_max $int32_max",
		mname    => 'ns_1.example.com',
		rname    => 'host-master.example.com',
		serial   => $int32_max,
		refresh  => $int32_max,
		retry    => $int32_max,
		expire   => $int32_max,
		minimum  => $int32_max,
	},
);


test_bad_soa($RE{'dns'}{'data'}{'soa'},
	'ns1.example.com hostmaster 2160314910 600 300 604800 600',
	'ns1.example.com hostmaster.example.com 600 300 604800 600',
	'ns1.example.com hostmaster.example.com 300 604800 600',
	'ns1.example.com hostmaster.example.com 604800 600',
	'ns1.example.com hostmaster.example.com 600',
	'ns1.example.com hostmaster.example.com',
	'ns1.example.com',
	"ns1.example.com hostmaster.example.com $int32_overflow 600 300 604800 600",
	"ns1.example.com hostmaster.example.com 2160314910 $int32_overflow 300 604800 600",
	"ns1.example.com hostmaster.example.com 2160314910 600 $int32_overflow 604800 600",
	"ns1.example.com hostmaster.example.com 2160314910 600 300 $int32_overflow 600",
	"ns1.example.com hostmaster.example.com 2160314910 600 300 604800 $int32_overflow",
	map { 'exa${_}ple.com host${_}master.example.com 2160314910 600 300 604800 600' } (qw(
		! @ $ % ^ & * ( ) { } [ ] < > . / ? ' "
	), '#', ','),  # silly silly warnings I tell you!
);

test_good_soa($RE{'dns'}{'data'}{'soa'}{-rfc => 2181},
	{
		data     => 'ns:1.example.com host/master.example.com 2160314910 600 300 604800 600',
		mname    => 'ns:1.example.com',
		rname    => 'host/master.example.com',
		serial   => 2160314910,
		refresh  => 600,
		retry    => 300,
		expire   => 604800,
		minimum  => 600,
	},
);

{ 
	local $Regexp::Common::dns::DEFAULT_RFC = 2181;
	test_good_soa($RE{'dns'}{'data'}{'soa'},
		{
			data     => 'ns:1.example.com host/master.example.com 2160314910 600 300 604800 600',
			mname    => 'ns:1.example.com',
			rname    => 'host/master.example.com',
			serial   => 2160314910,
			refresh  => 600,
			retry    => 300,
			expire   => 604800,
			minimum  => 600,
		},
	);	
}

test_good_soa($RE{'dns'}{'data'}{'soa'}{-rfc => 1035},
	{
		data     => 'ns1.example.com hostmaster.example.com 2160314910 600 300 604800 600',
		mname    => 'ns1.example.com',
		rname    => 'hostmaster.example.com',
		serial   => 2160314910,
		refresh  => 600,
		retry    => 300,
		expire   => 604800,
		minimum  => 600,
	},
);

{
	local $Regexp::Common::dns::DEFAULT_RFC = 1035;
	test_good_soa($RE{'dns'}{'data'}{'soa'},
		{
			data     => 'ns1.example.com hostmaster.example.com 2160314910 600 300 604800 600',
			mname    => 'ns1.example.com',
			rname    => 'hostmaster.example.com',
			serial   => 2160314910,
			refresh  => 600,
			retry    => 300,
			expire   => 604800,
			minimum  => 600,
		},
	);
}

test_bad_soa($RE{'dns'}{'data'}{'soa'}{-rfc => 1035},
	'ns1.example.com host_master.example 2160314910 600 300 604800 600',
	'_ns1.example.com hostmaster 2160314910 600 300 604800 600',
	'ns1_.example.com hostmaster 2160314910 600 300 604800 600',
	'ns/1.example.com hostmaster 2160314910 600 300 604800 600',
);

{
	local $Regexp::Common::dns::DEFAULT_RFC = 1035;
	test_bad_soa($RE{'dns'}{'data'}{'soa'},
		'ns1.example.com host_master.example 2160314910 600 300 604800 600',
		'_ns1.example.com hostmaster 2160314910 600 300 604800 600',
		'ns1_.example.com hostmaster 2160314910 600 300 604800 600',
		'ns/1.example.com hostmaster 2160314910 600 300 604800 600',
	);
}



sub test_good_soa {
	my ($re, @good) = @_;
	
	my $keep = $re->{'-keep'};
	
	
	for (@good) {
		like($_->{'data'}, "/^$re\$/",   "$_->{'data'} matches");
		ok($_->{'data'} =~ $keep, "$_->{'data'} matches with keep");
		
		is($1, $_->{'data'},    '$1 is data');
		is($2, $_->{'mname'},   '$2 is mname');
		is($3, $_->{'rname'},   '$3 is rname');
		is($4, $_->{'serial'},  '$4 is serial');
		is($5, $_->{'refresh'}, '$5 is refresh');
		is($6, $_->{'retry'},   '$6 is retry');
		is($7, $_->{'expire'},  '$7 is expire');
		is($8, $_->{'minimum'}, '$8 is minimum');
	}
}


sub test_bad_soa {
	my ($re, @bad) = @_;
	
	unlike($_, "/^$re\$/", "$_ does not match") for @bad;
}
