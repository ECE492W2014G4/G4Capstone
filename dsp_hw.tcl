# TCL File Generated by Component Editor 12.1sp1
# Sat Feb 27 17:05:41 MST 2016
# DO NOT MODIFY


# 
# dsp "dsp" v1.0
# null 2016.02.27.17:05:41
# 
# 

# 
# request TCL package from ACDS 12.1
# 
package require -exact qsys 12.1


# 
# module dsp
# 
set_module_property NAME dsp
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME dsp
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL dsp
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file dsp.vhd VHDL PATH output_files/dsp.vhd
add_fileset_file distortion_component.vhd VHDL PATH distortion_component.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1


# 
# connection point audio_in
# 
add_interface audio_in avalon_streaming end
set_interface_property audio_in associatedClock clock
set_interface_property audio_in associatedReset reset_n
set_interface_property audio_in dataBitsPerSymbol 8
set_interface_property audio_in errorDescriptor ""
set_interface_property audio_in firstSymbolInHighOrderBits true
set_interface_property audio_in maxChannel 0
set_interface_property audio_in readyLatency 0
set_interface_property audio_in ENABLED true

add_interface_port audio_in incoming_data data Input 16
add_interface_port audio_in incoming_valid valid Input 1


# 
# connection point audio_out
# 
add_interface audio_out avalon_streaming start
set_interface_property audio_out associatedClock clock
set_interface_property audio_out associatedReset reset_n
set_interface_property audio_out dataBitsPerSymbol 8
set_interface_property audio_out errorDescriptor ""
set_interface_property audio_out firstSymbolInHighOrderBits true
set_interface_property audio_out maxChannel 0
set_interface_property audio_out readyLatency 0
set_interface_property audio_out ENABLED true

add_interface_port audio_out outgoing_data data Output 16
add_interface_port audio_out outgoing_valid valid Output 1


# 
# connection point reset_n
# 
add_interface reset_n reset end
set_interface_property reset_n associatedClock clock
set_interface_property reset_n synchronousEdges DEASSERT
set_interface_property reset_n ENABLED true

add_interface_port reset_n reset_n reset_n Input 1


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset ""
set_interface_property conduit_end ENABLED true

add_interface_port conduit_end dist_en export Input 1
