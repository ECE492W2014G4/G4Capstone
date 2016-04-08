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

entity sdramBuffer is
	generic (
		AUTO_CLOCK_CLOCK_RATE : string := "-1";
		base_addr			  : std_logic_vector(31 downto 0) := X"00000000";
		buffersize            : std_logic_vector(31 downto 0) := X"00002948"-- X"000014A4" X"00000A52" 
	);
	port (
		avm_m0_address       : out std_logic_vector(31 downto 0);                    --    m0.address
		avm_m0_read          : out std_logic;                                        --      .read
		avm_m0_waitrequest   : in  std_logic                     := '0';             --      .waitrequest
		avm_m0_readdata      : in  std_logic_vector(15 downto 0) := (others => '0'); --      .readdata
		avm_m0_write         : out std_logic;                                        --      .write
		avm_m0_writedata     : out std_logic_vector(15 downto 0);                    --      .writedata
		avm_m0_readdatavalid : in  std_logic                     := '0';             --      .readdatavalid
		buffer_in_valid			 : in  std_logic;
		buffer_in				 : in  std_logic_vector(15 downto 0);
		buffer_out_valid			 : out std_logic;
		buffer_out				 : out std_logic_vector(15 downto 0);
		clk                  : in  std_logic                     := '0';
		reset                : in  std_logic                     := '0'              -- reset.reset_n
	);
end entity sdramBuffer;

architecture rtl of sdramBuffer is
type state is (idle, reading, writing);
signal current_state: state;
signal read_addr, write_addr: std_logic_vector(31 downto 0) := base_addr;
 
begin
	fsm: process(clk,reset)
			begin
				if reset = '0' then
					write_addr <= base_addr;
					read_addr <= base_addr;
					current_state <= idle;
				elsif rising_edge(clk) then
					case current_state is 
						when idle => 
							if buffer_in_valid = '1' then -- I have data avail.
								avm_m0_write <= '1'; -- Telling the SDRAM we're writing to it.
								current_state <= writing;
							else
								avm_m0_write <= '0';
							end if;							
						when reading => -- Reading the SDRAM
							if avm_m0_waitrequest = '0' then
								avm_m0_address <= read_addr;
								buffer_out <= avm_m0_readdata;
								if read_addr = std_logic_vector(signed(buffersize) - 1) then
									read_addr <= base_addr; -- To the beginning
								elsif read_addr > write_addr then
									read_addr <= std_logic_vector(signed(read_addr)+2); 							
								else
									read_addr <= std_logic_vector(signed(write_addr) - 2);						
								end if;
								current_state <= idle;
								buffer_out_valid <= '1';
							else
								buffer_out_valid <= '0';
							end if;
						when writing =>
							if avm_m0_waitrequest = '0' then
								avm_m0_address <= write_addr;	-- can only write when waitrequest = 0
								avm_m0_writedata <= buffer_in; 	-- Writes to SDRAM
								if write_addr = std_logic_vector(signed(buffersize)-1) then
									write_addr <= base_addr; -- Reset the write addr
								else
									write_addr <= std_logic_vector(signed(write_addr) + 2);						
								end if;
								avm_m0_write <= '0'; -- Telling SDRAM we've stopped writing
								avm_m0_read <= '1';	 -- Read SDRAM (next cycle)
								current_state <= reading;																
							end if;
						when others =>
							current_state <= idle;
					end case;
				end if;
			end	process;
end architecture rtl; -- of reverbBuffer
