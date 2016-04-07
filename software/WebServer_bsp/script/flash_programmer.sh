#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting ELF File: /afs/ualberta.ca/home/b/m/bmaroney/G4Capstone/software/WebServer/WebServer.elf to: "../flash/WebServer_generic_tristate_controller_0.flash"
#
elf2flash --input="/afs/ualberta.ca/home/b/m/bmaroney/G4Capstone/software/WebServer/WebServer.elf" --output="../flash/WebServer_generic_tristate_controller_0.flash" --boot="$SOPC_KIT_NIOS2/components/altera_nios2/boot_loader_cfi.srec" --base=0x400000 --end=0x800000 --reset=0x400000 --verbose 

#
# Programming File: "../flash/WebServer_generic_tristate_controller_0.flash" To Device: generic_tristate_controller_0
#
nios2-flash-programmer "../flash/WebServer_generic_tristate_controller_0.flash" --base=0x400000 --sidp=0x9090A0 --id=0x0 --timestamp=1460017624 --device=1 --instance=0 '--cable=USB-Blaster on localhost [2-1.6]' --program --verbose --erase-all 

