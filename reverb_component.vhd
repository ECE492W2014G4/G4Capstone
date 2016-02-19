library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_misc.all;
-- use IEEE.std_logic_arith.all;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity reverb_component is
	Generic (
		constant data_width  : positive := 4;
		constant fifo_depth	: positive := 4
	);
	Port ( 
		clk			: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		write_en	: in  STD_LOGIC;
		data_in		: in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
		read_en		: in  STD_LOGIC;
		data_out	: out STD_LOGIC_VECTOR (data_width - 1 downto 0)
	);
end reverb_component;

architecture Behavioral of reverb_component is
signal full : STD_LOGIC := '0';
signal old_output : STD_LOGIC_VECTOR(data_width - 1 downto 0);
signal new_output : STD_LOGIC_VECTOR(data_width - 1 downto 0);
signal buffer_out : STD_LOGIC_VECTOR(data_width - 1 downto 0);
signal data_in_int : INTEGER;
signal buffer_out_int : INTEGER;
begin

	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type fifo_memory is array (0 to fifo_depth - 1) of STD_LOGIC_VECTOR (data_width - 1 downto 0);
		variable Memory : fifo_memory;
		
		variable write_pointer : natural range 0 to fifo_depth - 1;
		variable read_pointer : natural range 0 to fifo_depth - 1;
		
	begin
	if reset = '1' then
			write_pointer := 0;
			read_pointer := 0;
			data_out <= X"00";
			full <= '0';
			buffer_out <= X"00";
			old_output <= X"00";
			new_output <= X"00";
	elsif (rising_edge(clk)) then
		
		if read_en = '1' then
			-- check if the buffer is full (if not, do not read)
			if full = '1' then
				buffer_out <=  Memory(read_pointer);
				
				-----------------------------------------------------
				-- Design for Echo --
				-- data_out <= signed(buffer_out) + signed(data_in);
				-----------------------------------------------------
				--data_out <= buffer_out;
				-- Check if read_pointer pointer is at the end of the buffer
				if (read_pointer = fifo_depth - 1) then
					read_pointer := 0;
					--full <= '0';
				else
					read_pointer := read_pointer + 1;
				end if;
			end if;
			
			-----------------------------------------------------
			-- Design for Reverb --
			data_in_int <= to_integer(signed(data_in)); -- convert to integer
			buffer_out_int <= 1*(to_integer(signed(buffer_out)))/2; -- convert to integer
			-- result is converted to std_logic_vector
			new_output <= std_logic_vector(to_signed(data_in_int,data_width) + to_signed(buffer_out_int,data_width)); 
			old_output <= new_output; -- old_output goes into the buffer
			data_out <= new_output; -- data_out is the output signal
			-----------------------------------------------------
			
		end if;
		
		
		-- write_pointer Process
		if write_en = '1' then
			--Memory(write_pointer) := data_in;
			Memory(write_pointer) := old_output;
			-- Check if write_pointer pointer is at the end of the buffer
			if (write_pointer = fifo_depth - 1) then
				full <= '1';
				write_pointer := 0;
			else
				write_pointer := write_pointer + 1;
				--full <= '0';
			end if;
		end if;
		
			
		
	end if;
	end process;
end Behavioral;
					

