
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/test.t'
use lib "lib";
#use Locale::Country;
#my $cc = country2code('Germany');
my $cc = "DE";
BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Business::IBAN;
$loaded = 1;
print "ok 1\n";
my $iban = Business::IBAN->new();
my $ib = $iban->getIBAN(
	{
		ISO => $cc,
		BIC => "36020041",
		AC => "12345678",
	});
if ($ib) {
	print "ok 2\n";
}
else {
	print "not ok 2\n";
}
#print "testing $ib\n";
if ($iban->valid($ib)) {
	print "ok 3\n";
}
else {
	print "not ok 3\n";
	#print $iban->printError();
}
$ib = "IBAN DE54360200410012345678"; # wrong
if ($iban->valid($ib)) {
	print "not ok 4\n";
	#print $iban->printError();
}
else {
	print "ok 4\n";
}

