package Business::IBAN;

require 5.005_62;
use Math::BigInt;
use strict;
use vars qw(@ISA @EXPORT_OK @EXPORT $VERSION @errors);

require Exporter;

@ISA = qw(Exporter);

@EXPORT_OK = ( );

@EXPORT = qw();
$VERSION = '0.03';
use constant IBAN_CTR => 0;
use constant IBAN_BBAN => 1;
use constant IBAN_ISO => 2;
use constant IBAN_FORMAT => 3;
use constant IBAN_INVALID => 4;

sub new {
  my $type = shift;
  my $self  = {};
  bless($self, $type);
  return $self;

}
# --------------------------------------
sub getIBAN {
	my $self = shift;
	my $args = shift;
	my $iso = uc $args->{ISO};
	my $bban = $args->{BBAN};
	my $bic = $args->{BIC};
	my $ac = $args->{AC};
	delete $self->{ERRORS};
	push @{$self->{ERRORS}}, IBAN_CTR unless $iso ;
	push @{$self->{ERRORS}}, IBAN_BBAN unless $bban || ($bic && $ac);
	return if $self->{ERRORS};
	$iso =~ tr/A-Za-z//cd if $iso;
	$bban =~ tr/A-Za-z09//cd if $bban;
	$ac =~ tr/A-Za-z09//cd if $ac;

	return unless $iso;
	$iso = uc $iso;
	$args->{CV} = $iso;
	$args->{CV} =~ s/([A-Z])/(ord $1)-55/eg;
	my $no;
	$args->{ISO} = $iso;
	for ($iso) {
		m/^DE$/ and $no = $self->iban_de($args), last;
		$no = $self->iban_unspec($args);
	}
	return $no;
}
# --------------------------------------
sub iban_de {
	my $self = shift;
	my $args = shift;
	$args->{BBAN} ||= sprintf "%08s%010s", $args->{BIC},$args->{AC};
	my $no = sprintf "%018s%4s00", $args->{BBAN}, $args->{CV};
	my $tmp = $no % 97;
	my $bigint = Math::BigInt->new($no);
	my $mod = sprintf "%2d", 98 - ($bigint % 97);
	substr($no,-6,6) = "";
	$no = 'IBAN '.$args->{ISO}.$mod.$no;
	return $no;
}
# --------------------------------------
sub iban_unspec {
	my $self = shift;
	my $args = shift;
	push @{$self->{ERRORS}}, IBAN_BBAN unless $args->{BBAN};
	return if $self->{ERRORS};
	my $no = sprintf "%s%4s00", $args->{BBAN}, $args->{CV};
	my $bigint = Math::BigInt->new($no);
	my $mod = 98 - ($bigint % 97);
	substr($no,-6,6) = "";
	$no = 'IBAN '.$args->{ISO}.$mod.$no;
	return $no;
}
# --------------------------------------
sub getError {
	my $self = shift;
	return unless $self->{ERRORS};
	return @{$self->{ERRORS}};
}
# --------------------------------------
sub printError {
	my $self = shift;
	return unless $self->{ERRORS};
	print "$errors[$_]\n" for @{$self->{ERRORS}};
}
# --------------------------------------
sub country {
	my $self = shift;
	return $self->{COUNTRY};
}
# --------------------------------------
sub valid {
	my $self = shift;
	my $ib = shift;
	delete $self->{ERRORS};
	$ib =~ tr/A-Za-z0-9//cd;
	$ib =~ s/^IBAN//i;
	push @{$self->{ERRORS}}, IBAN_FORMAT unless $ib =~ m/^[A-Z][A-Z]/i;
	return if $self->{ERRORS};
	my $iso = substr($ib,0,2,"");
	$iso =~ s/([A-Z])/(ord $1)-55/eg;
	my $check = substr($ib,0,2,"");
	$ib .= "$iso$check";
	$ib = Math::BigInt->new($ib);
	push @{$self->{ERRORS}}, IBAN_INVALID and return unless ($ib % 97)==1;
	return 1;
}
# --------------------------------------

@errors = (
	"No Country or Iso-Code",
	"No BBAN (Bank-Number) or Bank Identifier and Accountnumber",
	"Could not find country",
	"IBAN must containt two-letter ISO-Code at the begining",
	"IBAN is invalid",
);

1;
__END__

=head1 NAME

Business::IBAN - Validate and generate IBANs

=head1 SYNOPSIS

  use Business::IBAN;
  use Locale::Country;
  my $cc = country2code('Germany');
  my $iban = Business::IBAN->new();
  my $ib = $iban->getIBAN(
  {
    ISO => $cc, # or "DE", etc.
    BIC => 12345678, # Bank Identifier Code, meaning the BLZ
                     # in Germany
    AC => "1234567890",
  });
  # or
  my $ib = $iban->getIBAN(
  {
    ISO => "DE",
    BBAN => 123456781234567890,
  });
  if ($ib) {
    print "IBAN is $ib\n";
  }
  else {
    $iban->printError();
    # or
    my @errors = $iban->getError();
    # print your own error messages (for description of error-
    # codes see section ERROR-CODES
  }
  if ($iban->valid($ib)) {
    print "$iban is valid\n";
  }
  else {
    $iban->printError();
  }

=head1 DESCRIPTION

With this module you can validate IBANs (International Bank
Account Number) like "IBAN DE97123456781234567890".
Note that this dos not (and cannot) assure that the bank
account exists or that the bank account number for the
bank itself is valid.
You can also create an IBAN if you supply

=item

- your BBAN (Basic Bank Account Number),
  (or for germany your BLZ and account
  number are sufficient),

=item

- and either your country code (ISO3166)
  or the english name for your country.

=head2 REQUIRES

It requires the module Locale::Country, which you can get
from www.cpan.org. It's a standard module since perl-version
5.7.2.

=head2 EXPORT

None by default. All methods are accessed over the object.


=head2 ERROR-CODES

You can print your own error-messages. The array you get from
  my @errors = $iban->getError();
are numbers which stand for the following errors:

	0: No Country or Iso-Code
	1: No BBAN (Bank-Number) or Bank Identifier and Accountnumber
	2: Could not find country
	3: IBAN must containt two-letter ISO-Code at the begining

=head2 CAVEATS

Please note that this program is intended to validate IBANs and generate
them for you if you have your BBAN. It's not for generating valid
numbers for illegal purposes. The algorithm is simple and publicly
available for everyone. You can find informations about the IBAN at

=item http://www.ecbs.org

=item http://www.iban.ch

=head1 AUTHOR

Tina Mueller. tinita@cpan.org

=head1 SEE ALSO

perl(1).

=cut
