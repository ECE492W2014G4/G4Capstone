library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tuner is
	port(
		clk: in std_logic;
		reset: in std_logic;
		tuner_en: in std_logic;
		tuner_in: in std_logic;
		tuner_data: in std_logic_vector(15 downto 0);
		tuner_data_available: in std_logic;
		tuner_out: out std_logic_vector(31 downto 0)			
	);
end entity tuner;

architecture behavior of tuner is

constant magTol,slopeTol: signed(31 downto 0) := X"00000014";
constant maxCount: unsigned(31 downto 0) := X"000093F7";
signal previous, max:	std_logic_vector(15 downto 0) := X"0000";
signal counter, final_count	: unsigned(31 downto 0) :=X"00000000";
signal max_slope : signed(15 downto 0);

begin
	tuner_out <= std_logic_vector(counter);
	t0:process(reset,tuner_in,tuner_en)
		begin
			if reset = '0' then
				counter <=X"00000000";
			elsif falling_edge(tuner_in) then
				if tuner_en = '1' then
					counter <= counter +1;
				else
					counter <=X"00000000";
				end if;
			end if;
		end process;
	--zcrd:process(clk, reset, tuner_en)
		--begin
			--if reset = '0' then
				--tuner_out <=X"00000000";
			--elsif rising_edge(clk) then
				--previous <= tuner_data;
				--if tuner_data(15 downto 0) > max(15 downto 0) then
				--	max <= tuner_data;
					--max_slope <= signed(tuner_data) - signed(previous);
					--counter <= X"00000000";
				--elsif (abs(signed(max) - signed(tuner_data)) < magTol) and (abs(max_slope + signed(previous) - signed(tuner_data)) < slopeTol) then
					--tuner_out <= std_logic_vector(counter);
					--counter <= X"00000000";
				--elsif counter > maxCount or tuner_en = '0' then
					--max <= X"0000";
					--counter <= X"00000000";	
				--else
					--if tuner_data_available = '1' then
						--counter <= counter +1;
					--end if;
				--end if;
			--end if;
		--end process;
end architecture;
		
