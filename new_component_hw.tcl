# TCL File Generated by Component Editor 12.1sp1
# Thu Apr 07 01:18:49 MDT 2016
# DO NOT MODIFY


# 
# reverbBuffer "reverbBuffer" v1.0
# null 2016.04.07.01:18:49
# 
# 

# 
# request TCL package from ACDS 12.1
# 
package require -exact qsys 12.1


# 
# module reverbBuffer
# 
set_module_property NAME reverbBuffer
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME reverbBuffer
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL reverbBuffer
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file reverbBuffer.vhd VHDL PATH reverbBuffer.vhd


# 
# parameters
# 
add_parameter base_addr STD_LOGIC_VECTOR 0
set_parameter_property base_addr DEFAULT_VALUE 0
set_parameter_property base_addr DISPLAY_NAME base_addr
set_parameter_property base_addr TYPE STD_LOGIC_VECTOR
set_parameter_property base_addr UNITS None
set_parameter_property base_addr ALLOWED_RANGES 0:4294967295
set_parameter_property base_addr HDL_PARAMETER true
add_parameter buffersize STD_LOGIC_VECTOR 1321
set_parameter_property buffersize DEFAULT_VALUE 1321
set_parameter_property buffersize DISPLAY_NAME buffersize
set_parameter_property buffersize TYPE STD_LOGIC_VECTOR
set_parameter_property buffersize UNITS None
set_parameter_property buffersize ALLOWED_RANGES 0:4294967295
set_parameter_property buffersize HDL_PARAMETER true


# 
# display items
# 


# 
# connection point m0
# 
add_interface m0 avalon start
set_interface_property m0 addressUnits SYMBOLS
set_interface_property m0 associatedClock clock
set_interface_property m0 associatedReset reset
set_interface_property m0 bitsPerSymbol 8
set_interface_property m0 burstOnBurstBoundariesOnly false
set_interface_property m0 burstcountUnits WORDS
set_interface_property m0 doStreamReads false
set_interface_property m0 doStreamWrites false
set_interface_property m0 holdTime 0
set_interface_property m0 linewrapBursts false
set_interface_property m0 maximumPendingReadTransactions 0
set_interface_property m0 readLatency 0
set_interface_property m0 readWaitTime 2
set_interface_property m0 setupTime 0
set_interface_property m0 timingUnits Cycles
set_interface_property m0 writeWaitTime 0
set_interface_property m0 ENABLED true

add_interface_port m0 avm_m0_address address Output 32
add_interface_port m0 avm_m0_read read Output 1
add_interface_port m0 avm_m0_waitrequest waitrequest Input 1
add_interface_port m0 avm_m0_readdata readdata Input 16
add_interface_port m0 avm_m0_write write Output 1
add_interface_port m0 avm_m0_writedata writedata Output 16
add_interface_port m0 avm_m0_readdatavalid readdatavalid Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true

add_interface_port reset reset reset_n Input 1


# 
# connection point dsp_in
# 
add_interface dsp_in avalon_streaming start
set_interface_property dsp_in associatedClock clock
set_interface_property dsp_in associatedReset reset
set_interface_property dsp_in dataBitsPerSymbol 8
set_interface_property dsp_in errorDescriptor ""
set_interface_property dsp_in firstSymbolInHighOrderBits true
set_interface_property dsp_in maxChannel 0
set_interface_property dsp_in readyLatency 0
set_interface_property dsp_in ENABLED true

add_interface_port dsp_in dsp_done valid Output 1
add_interface_port dsp_in dsp_out data Output 16


# 
# connection point dsp_out
# 
add_interface dsp_out avalon_streaming end
set_interface_property dsp_out associatedClock clock
set_interface_property dsp_out associatedReset reset
set_interface_property dsp_out dataBitsPerSymbol 8
set_interface_property dsp_out errorDescriptor ""
set_interface_property dsp_out firstSymbolInHighOrderBits true
set_interface_property dsp_out maxChannel 0
set_interface_property dsp_out readyLatency 0
set_interface_property dsp_out ENABLED true

add_interface_port dsp_out dsp_ready valid Input 1
add_interface_port dsp_out dsp_in data Input 16


# 
# connection point dsp_delayed
# 
add_interface dsp_delayed avalon_streaming start
set_interface_property dsp_delayed associatedClock clock
set_interface_property dsp_delayed dataBitsPerSymbol 8
set_interface_property dsp_delayed errorDescriptor ""
set_interface_property dsp_delayed firstSymbolInHighOrderBits true
set_interface_property dsp_delayed maxChannel 0
set_interface_property dsp_delayed readyLatency 0
set_interface_property dsp_delayed ENABLED true

add_interface_port dsp_delayed dsp_delayed_valid valid Output 1
add_interface_port dsp_delayed dsp_delayed data Output 16

