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

sub list_gpios {
    my $self = shift;

    my $num_lines = gpiod_num_lines($self->{gpiod_chip});
    return map {"line$_"} (0..$num_lines-1);
}

sub read_gpios {
    my $self = shift;
    my $lines = shift;

    my @lines = map {/line(\d+)/ && $1} @$lines;
    my @values = gpiod_read_lines($self->{gpiod_chip}, @lines);

    if (@values == @lines)
    {
        my %return;
        for (my $i=0; $i<=$#lines; $i++)
        {
            $return{$lines->[$i]} = $values[$i];
        }

        Future->done(\%return);
    } else
    {
        Future->done(undef);
    }
}

1;
