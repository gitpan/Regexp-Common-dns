# $Id: 20-cname.t,v 1.1 2003/11/18 08:27:29 ctriv Exp $

use Test::More tests => 252;
use Regexp::Common qw/dns/;
use strict;

my $hybrid_tests = sub {
	my $re = shift;
	
	my @good = qw(
		one.rr-a.test
		one.rr_a.test
		example.com.
		example.com
		_example.com
		-example.com
		example-.com
		example_.com
		org
		org.
	);
			
	like($_, "/^$re\$/", "cname $_ OK") for @good;
	
	#
	# Test that -keep works
	#
	for (@good) {
		$_ =~ m/^$re->{'-keep'}$/;
		is($1, $_, "\$1 = $_");
	} 


	my @bad = (
		'',
		'double..dots',
	);
	
	push(@bad, "bad${_}lable") for ('!', '@', '#', '$', '%', '^', '&', '*', '{', '}', '(', ')', '<', '>');
	
	unlike($_, "/^$re\$/", "domain $_ not OK") for @bad;	
	
	unlike('org',           "/^$re->{-minlables => 2}\$/"); # no match
	  like('co.org',        "/^$re->{-minlables => 2}\$/"); # match
	  like('one.rr-cname.test', "/^$re->{-minlables => 2}\$/"); # match

	unlike('*.org', "/^$re\$/");
	  like('*.org', "/^$re->{-wildcard}\$/");
};	

my $rfc1035_tests = sub {
	my $re = shift;
	
	my @good = qw(
		one.rr-a.test
		example.com.
		example.com
		org
		org.
	);
			
	like($_, "/^$re\$/", "domain $_ OK") for @good;
	
	#
	# Test that -keep works
	#
	for (@good) {
		$_ =~ m/^$re->{'-keep'}$/;
		is($1, $_, "\$1 = $_");
	} 


	my @bad = (
		'',
		'double..dots',
		'-leading-hyp.com',
		'trailed-hyp-.com',
	);
	
	push(@bad, "bad${_}lable") for ('!', '@', '#', '$', '%', '^', '&', '*', '_', '{', '}', '(', ')', '<', '>');
	
	unlike($_, "/^$re\$/", "domain $_ not OK") for @bad;	
	
	unlike('org',           "/^$re->{-minlables => 2}\$/"); # no match
	  like('co.org',        "/^$re->{-minlables => 2}\$/"); # match
	  like('one.rr-a.test', "/^$re->{-minlables => 2}\$/"); # match

	unlike('*.org', "/^$re\$/");
	  like('*.org', "/^$re->{-wildcard}\$/");
};

my $rfc2181_tests = sub {
	my $re = shift;
	
	my @good = (
		#         1         2         3         4         5         6
		'this_lable_is_maxlenth_1234567890123456789012345678901234567890.com',
	qw(
		example.com.
		example.com
		org
		org.
		*.example.com
		*.example.com.
		lable.example.com
		lable.example.com.
	));
	
	push(@good, "rfc2181_${_}_lable") for ('!', '@', '#', '$', '%', '^', '&', '*', '{', '}', '(', ')', '<', '>');
		
	like($_, "/^$re\$/", "domain $_ OK") for @good;
	
	#
	# Test that -keep works
	#
	for (@good) {
		$_ =~ m/^$re->{'-keep'}$/;
		is($1, $_, "\$1 = $_");
	} 


	my @bad = (
		'',
		'double..dots',
	);
	
	unlike($_, "/^$re\$/", "domain $_ not OK") for @bad;	
	
	unlike('org',           "/^$re->{-minlables => 2}\$/"); # no match
	  like('co.org',        "/^$re->{-minlables => 2}\$/"); # match
	  like('one.rr-a.test', "/^$re->{-minlables => 2}\$/"); # match
};


#
# run the actual tests
#
 $hybrid_tests->($RE{'dns'}{'data'}{'cname'}{-rfc => 'hybrid'});
$rfc1035_tests->($RE{'dns'}{'data'}{'cname'}{-rfc => 1035});
$rfc2181_tests->($RE{'dns'}{'data'}{'cname'}{-rfc => 2181});
  

# is hybrid the default?  
$hybrid_tests->($RE{'dns'}{'data'}{'cname'});

# test that we can set our own default
{
	local $Regexp::Common::dns::DEFAULT_RFC = 1035;
	$rfc1035_tests->($RE{'dns'}{'data'}{'cname'});
}
{
	local $Regexp::Common::dns::DEFAULT_RFC = 2181;
	$rfc2181_tests->($RE{'dns'}{'data'}{'cname'});
}
	
