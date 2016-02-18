library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;


entity fifo_buffer is
	Generic (
		constant data_width  : positive := 4;
		constant fifo_depth	: positive := 4
	);
	Port ( 
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		write_en	: in  STD_LOGIC;
		data_in		: in  STD_LOGIC_VECTOR (data_width - 1 downto 0);
		read_en		: in  STD_LOGIC;
		data_out	: out STD_LOGIC_VECTOR (data_width - 1 downto 0)
	);
end fifo_buffer;

architecture Behavioral of fifo_buffer is

begin

	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type fifo_memory is array (0 to fifo_depth - 1) of STD_LOGIC_VECTOR (data_width - 1 downto 0);
		variable Memory : fifo_memory;
		
		variable write_pointer : natural range 0 to fifo_depth - 1;
		variable read_pointer : natural range 0 to fifo_depth - 1;
		
		--variable Looped : boolean;
		
	begin
	if reset = '1' then
			write_pointer := 0;
			read_pointer := 0;
			data_out <= X"00";
	elsif (rising_edge(clk)) then
		-- write_pointer Process
		if write_en = '1' then
			Memory(write_pointer) := data_in;
			-- Check if write_pointer pointer is at the end of the buffer
			if (write_pointer = fifo_depth - 1) then
				write_pointer := 0;
			else
				write_pointer := write_pointer + 1;
			end if;
		end if;
			
		if read_en = '1' then
			-- data_out <= x"01";
			data_out <= Memory(read_pointer);
			-- Check if read_pointer pointer is at the end of the buffer
			if (read_pointer = fifo_depth - 1) then
				read_pointer := 0;
			else
				read_pointer := read_pointer + 1;
			end if;
		end if;
	end if;
	end process;
end Behavioral;
					

