# TCL File Generated by Component Editor 12.1sp1
# Thu Mar 03 19:07:48 MST 2016
# DO NOT MODIFY


# 
# dsp "dsp" v1.0
# null 2016.03.03.19:07:48
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
add_fileset_file distortion_component.vhd VHDL PATH distortion_component.vhd
add_fileset_file dsp.vhd VHDL PATH dsp.vhd
add_fileset_file MUX3x1.vhd VHDL PATH MUX3x1.vhd
add_fileset_file reverb_component.vhd VHDL PATH reverb_component.vhd


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
# connection point reset_n
# 
add_interface reset_n reset end
set_interface_property reset_n associatedClock clock
set_interface_property reset_n synchronousEdges DEASSERT
set_interface_property reset_n ENABLED true

add_interface_port reset_n reset_n reset_n Input 1


# 
# connection point audio_left_in
# 
add_interface audio_left_in avalon_streaming end
set_interface_property audio_left_in associatedClock clock
set_interface_property audio_left_in associatedReset reset_n
set_interface_property audio_left_in dataBitsPerSymbol 8
set_interface_property audio_left_in errorDescriptor ""
set_interface_property audio_left_in firstSymbolInHighOrderBits true
set_interface_property audio_left_in maxChannel 0
set_interface_property audio_left_in readyLatency 0
set_interface_property audio_left_in ENABLED true

add_interface_port audio_left_in incoming_data_left data Input 16
add_interface_port audio_left_in incoming_valid_left valid Input 1


# 
# connection point audio_right_in
# 
add_interface audio_right_in avalon_streaming end
set_interface_property audio_right_in associatedClock clock
set_interface_property audio_right_in associatedReset reset_n
set_interface_property audio_right_in dataBitsPerSymbol 8
set_interface_property audio_right_in errorDescriptor ""
set_interface_property audio_right_in firstSymbolInHighOrderBits true
set_interface_property audio_right_in maxChannel 0
set_interface_property audio_right_in readyLatency 0
set_interface_property audio_right_in ENABLED true

add_interface_port audio_right_in incoming_data_right data Input 16
add_interface_port audio_right_in incoming_valid_right valid Input 1


# 
# connection point audio_left_out
# 
add_interface audio_left_out avalon_streaming start
set_interface_property audio_left_out associatedClock clock
set_interface_property audio_left_out associatedReset reset_n
set_interface_property audio_left_out dataBitsPerSymbol 8
set_interface_property audio_left_out errorDescriptor ""
set_interface_property audio_left_out firstSymbolInHighOrderBits true
set_interface_property audio_left_out maxChannel 0
set_interface_property audio_left_out readyLatency 0
set_interface_property audio_left_out ENABLED true

add_interface_port audio_left_out outgoing_data_left data Output 16
add_interface_port audio_left_out outgoing_valid_left valid Output 1


# 
# connection point audio_right_out
# 
add_interface audio_right_out avalon_streaming start
set_interface_property audio_right_out associatedClock clock
set_interface_property audio_right_out associatedReset reset_n
set_interface_property audio_right_out dataBitsPerSymbol 8
set_interface_property audio_right_out errorDescriptor ""
set_interface_property audio_right_out firstSymbolInHighOrderBits true
set_interface_property audio_right_out maxChannel 0
set_interface_property audio_right_out readyLatency 0
set_interface_property audio_right_out ENABLED true

add_interface_port audio_right_out outgoing_data_right data Output 16
add_interface_port audio_right_out outgoing_valid_right valid Output 1


# 
# connection point conduit_end_3
# 
add_interface conduit_end_3 conduit end
set_interface_property conduit_end_3 associatedClock ""
set_interface_property conduit_end_3 associatedReset ""
set_interface_property conduit_end_3 ENABLED true

add_interface_port conduit_end_3 enable export Input 3

