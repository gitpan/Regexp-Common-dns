use Module::Build;
use strict;

Module::Build->new( 
	module_name        => 'Regexp::Common::dns',
	license            => 'perl',
	create_makefile_pl => 'passthrough',
	requires           => {
		'Regexp::Common' => 0,
	},
	build_requires     => {
		'Test::More'     => 0,
	},
)->create_build_script;
