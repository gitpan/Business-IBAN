use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Business::IBAN',
    'VERSION_FROM'	=> 'IBAN.pm', # finds $VERSION
    'PREREQ_PM'		=> {Locale::Country => 2.03}, # e.g., Module::Name => 1.1
);
