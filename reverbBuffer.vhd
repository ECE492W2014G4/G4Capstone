-- reverbBuffer.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reverbBuffer is
	generic (
		AUTO_CLOCK_CLOCK_RATE : string := "-1";
		base_addr			  : std_logic_vector(31 downto 0) := X"00000000";
		buffersize            : std_logic_vector(31 downto 0) := X"000014A4"--X"00000A52" 
	);
	port (
		avm_m0_address       : out std_logic_vector(31 downto 0);                    --    m0.address
		avm_m0_read          : out std_logic;                                        --      .read
		avm_m0_waitrequest   : in  std_logic                     := '0';             --      .waitrequest
		avm_m0_readdata      : in  std_logic_vector(15 downto 0) := (others => '0'); --      .readdata
		avm_m0_write         : out std_logic;                                        --      .write
		avm_m0_writedata     : out std_logic_vector(15 downto 0);                    --      .writedata
		avm_m0_readdatavalid : in  std_logic                     := '0';             --      .readdatavalid
		dsp_ready			 : in  std_logic;
		dsp_in				 : in  std_logic_vector(15 downto 0);
		dsp_done			 : out std_logic;
		dsp_out				 : out std_logic_vector(15 downto 0);
		clk                  : in  std_logic                     := '0';
		reset                : in  std_logic                     := '0'              -- reset.reset_n
	);
end entity reverbBuffer;

architecture rtl of reverbBuffer is
type state is (idle, reading, writing);
signal current_state: state;
signal original,delayed: std_logic_vector(15 downto 0);

signal read_addr, read_delayed,write_addr: std_logic_vector(31 downto 0) := base_addr;
signal read_flag : std_logic := '0';
constant offset : std_logic_vector(31 downto 0) := std_logic_vector(signed(base_addr)+ 16 );
 
begin
	fsm: process(clk,reset)
			begin
				if reset = '0' then
					write_addr <= base_addr;
					read_addr <= offset;
					current_state <= idle;
					read_flag <= '0';
				elsif rising_edge(clk) then
					case current_state is 
						when idle => 
							if dsp_ready = '1' then -- I have data avail.
								avm_m0_write <= '1'; -- Telling the SDRAM we're writing to it.
								current_state <= writing;
							else
								avm_m0_write <= '0';
							end if;							
						when reading => -- Reading the SDRAM
							if avm_m0_waitrequest = '0' then
								avm_m0_address <= read_addr;
								dsp_out <= avm_m0_readdata;
								if read_addr = std_logic_vector(signed(buffersize) - 1) then
									read_addr <= offset; -- To the beginning
									avm_m0_read <= '0';							
								else
									read_addr <= std_logic_vector(signed(read_addr) + 2);						
								end if;
								current_state <= idle;
								dsp_done <= '1';
							else
								dsp_done <= '0';
							end if;
						when writing =>
							if avm_m0_waitrequest = '0' then
								avm_m0_address <= write_addr;	-- can only write when waitrequest = 0
								avm_m0_writedata <= dsp_in; 	-- Writes to SDRAM
								if write_addr = std_logic_vector(signed(buffersize)-1) then
									write_addr <= base_addr; -- Reset the write addr
									avm_m0_write <= '0'; -- Telling SDRAM we've stopped writing
									avm_m0_read <= '1';	 -- Read once SDRAM is full
									read_flag <= '1';					
								else
									write_addr <= std_logic_vector(signed(write_addr) + 2);						
								end if;
								if read_flag = '1' then
									current_state <= reading;								
								end if;								
							end if;
						when others =>
							current_state <= idle;
					end case;
				end if;
			end	process;
end architecture rtl; -- of reverbBuffer
