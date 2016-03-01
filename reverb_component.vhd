library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_misc.all;
--USE IEEE.std_logic_arith.all;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


----------------------------------
-- Debug Approaches for Division Problem
-- 1) Try using std_logic_arith
-- 2) Try using a variable instead of a signal
-- 3) Remember to preserve the sign bit by perfrom mult_result(7)&mult_result(9 downto 2) 
-- 4) Check signal size during addition (issue is being thrown that 
-- "The warning is an assertion thrown by the deprecated std_logic_unsigned library's overloaded + operator." )
-- UPDATE: Found out that the addition is the problem, do something about it, Check the size issues

entity reverb_component is
	Generic (
		constant data_width  : positive := 16;
		constant fifo_depth	: positive := 11025
	);
	Port ( 
		clk			: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		write_en	: in  STD_LOGIC;
		data_in		: in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
		reverb_en	: in  STD_LOGIC;
		data_out	: out STD_LOGIC_VECTOR (data_width - 1 downto 0)
	);
end reverb_component;

architecture Behavioral of reverb_component is

-- Signal Assignment
constant mult_const : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
signal mult_result : STD_LOGIC_VECTOR(23 downto 0);
signal full : STD_LOGIC := '0';
signal buffer_out : STD_LOGIC_VECTOR(data_width - 1 downto 0);
signal read_en : STD_LOGIC;

begin
	
	read_en <= reverb_en;
	
	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type fifo_memory is array (0 to fifo_depth - 1) of STD_LOGIC_VECTOR (data_width - 1 downto 0);
		variable Memory : fifo_memory;
		
		variable write_pointer : natural range 0 to fifo_depth - 1;
		variable read_pointer : natural range 0 to fifo_depth - 1;
		variable var_out: std_logic_vector(data_width - 1 downto 0);
		variable mult_out_var : std_logic_vector(data_width - 1 downto 0);
		variable div_out_var : std_logic_vector(data_width - 1 downto 0);
		
	begin
	if reset = '1' then
			write_pointer := 0;
			read_pointer := 0;
			data_out <= "0000000000000000";
			full <= '0';
			buffer_out <= "0000000000000000";
			mult_result <= "000000000000000000000000";
			mult_out_var := "0000000000000000";
			div_out_var := "0000000000000000";
			var_out := "0000000000000000";
	elsif (rising_edge(clk)) then
		
		if read_en = '1' then
			-- check if the buffer is full (if not, do not read)
			if full = '1' then
				buffer_out <=  Memory(read_pointer);
				
				-----------------------------------------------------
				-- Design for Echo --
				-- data_out <= signed(buffer_out) + signed(data_in);
				-----------------------------------------------------

				-- Check if read_pointer pointer is at the end of the buffer
				if (read_pointer = fifo_depth - 1) then
					read_pointer := 0;
					--full <= '0';
				else
					read_pointer := read_pointer + 1;
				end if;
			end if;
			
			-----------------------------------------------------
			-- Design for Reverberation --
			mult_result <= std_logic_vector(signed(buffer_out) * signed(mult_const)); -- 24-bit result
			-- The input data (data_in) is added to the multiplication result divided by 2^1 which
			-- is performed by performing a right shift by 1 bit
			mult_out_var := mult_result(15 downto 0); -- first 16 bits
			div_out_var := mult_result(15) & mult_out_var(15 downto 1);
			var_out := std_logic_vector(signed(data_in) +  signed(div_out_var));
			data_out <= var_out; -- data_out is the output signal
			-----------------------------------------------------
			
		end if;
		
		
		-- write_pointer Process
		if write_en = '1' then
			Memory(write_pointer) := var_out;
			-- Check if write_pointer pointer is at the end of the buffer
			if (write_pointer = fifo_depth - 1) then
				full <= '1';
				write_pointer := 0;
			else
				write_pointer := write_pointer + 1;
			end if;
		end if;
		
			
		
	end if;
	end process;
end Behavioral;
					

