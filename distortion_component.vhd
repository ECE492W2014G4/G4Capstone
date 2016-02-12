library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity distort is
	port( 
	clk : in std_logic;
	reset : in std_logic;
	dist_en : in std_logic; -- 1-bit distortion enable signal
	ready : in std_logic;
	done : out std_logic;
	data_in : in std_logic_vector(15 downto 0); -- 16-bit data stream input
	clipping_value: in std_logic_vector(15 downto 0); -- 16-bit input clipping threshold
	data_out: out std_logic_vector(15 downto 0) -- 16-bit data stream output (either clipped or not)
	);
end entity distort;

architecture behavior of distort is
constant clipping_default : std_logic_vector(15 downto 0) := "0000001111101000"; -- constant value of 500 in decimal
signal clip_threshold : std_logic_vector(15 downto 0);
signal completed : std_logic;

begin
	done <= completed;
	g0:process(clk,reset,dist_en,ready)
	begin
	-- clip_threshold <= clipping_value;
	-- Default Clipping Value
	clip_threshold <= clipping_default; 
		if reset = '0' then
			data_out <= X"0000";
		--elsif (clk='1' and clk'event) then
		elsif (rising_edge(clk)) then
			if(ready = '1') then
				if dist_en = '1' then -- Check if Distortion is Enabled
					if data_in(15) = '1' then -- Check sign of sample (If negative...)
						if (not data_in(14 downto 0)) >= clip_threshold(14 downto 0) then -- compare data to clip_threshold (without sign bits)
							data_out <= '1' & (not clip_threshold(14 downto 0)); -- if data is greater than threshold, data_out = clip_threshold, concatenate '1' to complement
						else 
							data_out <= data_in;
						end if;
					elsif data_in(15) = '0' then -- Check sign of sample (If positive...)
						if data_in(14 downto 0) >= clip_threshold(14 downto 0) then
							data_out <= '0' & clip_threshold(14 downto 0);
						else
							data_out <= data_in;
						end if;
					end if;
				else
					data_out <= data_in;
				end if;
				completed <= '0';
			else
				completed <= '0';
			end if;
		else
			completed <= '0';
		end if;
	end process;
end architecture;
		
