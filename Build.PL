use Module::Build;
my $build = Module::Build->new (
	module_name => 'Business::IBAN',
	license => 'perl',
	recommends => {
		#'perl'           => '5.6.1',
		'Locale::Country'   => '2.03',
	},
);
$build->create_build_script;

