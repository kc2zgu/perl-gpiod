#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <gpiod.h>

MODULE = Device::Chip::Adapter::Gpiod	PACKAGE = Device::Chip::Adapter::Gpiod

void*
gpiod_open(device)
    char *device
  CODE:
    struct gpiod_chip *chip = gpiod_chip_open(device);
    RETVAL = chip;
  OUTPUT:
    RETVAL

void
gpiod_close(chip_ptr)
    void *chip_ptr
  CODE:
    struct gpiod_chip *chip = (struct gpiod_chip*)chip_ptr;
    gpiod_chip_close(chip);
