use strict;
use warnings;
package Device::Chip::Adapter::Gpiod;
use base qw(Device::Chip::Adapter);
use Carp;

our $VERSION = 'v0.1';

require XSLoader;
XSLoader::load();

# ABSTRACT: Use libgpiod with Device::Chip

sub new {
    my $class = shift;
    my %args = @_;

    die "No device specified" unless $args{device};

    my $gpiod_chip = gpiod_open($args{device});

    if ($gpiod_chip)
    {
        return bless { gpiod_chip => $gpiod_chip }, $class;
    } else
    {
        return undef;
    }
}

sub DESTROY {
    my $self = shift;
    gpiod_close($self->{gpiod_chip});
}

sub make_protocol {
    my ($self, $pname) = @_;

    if ($pname eq 'GPIO')
    {
        Future->done($self);
    } else
    {
        croak "Protocol $pname not supported";
    }
}

1;
