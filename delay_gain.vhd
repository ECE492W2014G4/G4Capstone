LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity delay_gain is

	port (
		clk : in std_logic;
		reset : in std_logic;
		ready : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		done : out std_logic;
		data_out : out std_logic_vector (15 downto 0)
		);
end delay_gain;

architecture Behavioral of delay_gain is

-- Signal Assignment
constant mult_const : STD_LOGIC_VECTOR(3 downto 0) := "0001";
signal delay_signal : std_logic_vector(15 downto 0);
signal div_result :	STD_LOGIC_VECTOR(15 downto 0);
signal completed : std_logic :='0';

begin
	done <= completed;
	process (clk,reset,ready)
		variable div_out_var : std_logic_vector(15 downto 0);
		variable mult_out_var : std_logic_vector(19 downto 0);
		begin
			if reset = '0' then
				data_out <= X"0000";
				delay_signal <= X"0000";
				div_result <= X"0000";
				mult_out_var := X"00000";
				div_out_var := X"0000";
			elsif (rising_edge(clk)) then
				if ready = '1' then
					mult_out_var := std_logic_vector(unsigned(mult_const) * unsigned(data_in));
					-- Right Shift 2^1 (divided by 2)
					div_out_var := data_in(15) & mult_out_var(15 downto 1);
					data_out <= div_out_var after 100 ms;
					completed <= '1';
				else
					completed <= '0';
				end if;
			end if;
			
	end process;
end Behavioral;
					
			
