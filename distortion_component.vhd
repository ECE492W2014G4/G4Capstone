library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

-- Distortion Settings
-- 1) Gain at 3 ("11") - Clipping at 1000 "0000001111101000"
-- 2) Gain at 3 ("10") - Clipping at 3000 "0000101110111000" - Default
-- 3) Gain at 3 ("01") - Clipping at 5000 "0001001110001000"

constant clipping_default : std_logic_vector(15 downto 0) := "0000101110111000"; -- constant value of 3000 in decimal
constant clipping_low : std_logic_vector(15 downto 0) := "0001001110001000"; -- constant value of 1000 in decimal
constant clipping_high : std_logic_vector(15 downto 0) := "0000001111101000"; -- constant value of 5000 in decimal
constant gain_constant : std_logic_vector(1 downto 0) := "10"; -- constant gain
signal clip_threshold : std_logic_vector(15 downto 0);
signal completed : std_logic :='0';


begin

	
	done <= completed;
	g0:process(clk,reset,dist_en,ready)
	variable mult_result : std_logic_vector(17 downto 0);
	begin

	-- Default Clipping Value
	clip_threshold <= clipping_default; 
		if reset = '0' then
			data_out <= X"0000";
		--elsif (clk='1' and clk'event) then
		elsif (rising_edge(clk)) then
			if(ready = '1') then
				-- Clipping Configurations --
				--if(clipping_value = "0001001110001000") then
				--	clip_threshold <= "0001001110001000";
				--elsif(clipping_value = "0000001111101000") then
				--	clip_threshold <= "0000001111101000";
				--else
				--	clip_threshold <= "0000101110111000";
				--end if;
				-- End Clipping Configurations
				if dist_en = '1' then -- Check if Distortion is Enabled
					if data_in(15) = '1' then -- Check sign of sample (If negative...)
						if (not data_in(14 downto 0)) >= clip_threshold(14 downto 0) then -- compare data to clip_threshold (without sign bits)
							mult_result := gain_constant * clip_threshold;
							data_out <= '1' & (not mult_result(14 downto 0));
							--data_out <= '1' & (not clip_threshold(14 downto 0)); -- if data is greater than threshold, data_out = clip_threshold, concatenate '1' to complement
						else 
							mult_result := gain_constant * data_in;
							data_out <= mult_result(15 downto 0);
							--data_out <= data_in;
						end if;
					elsif data_in(15) = '0' then -- Check sign of sample (If positive...)
						if data_in(14 downto 0) >= clip_threshold(14 downto 0) then
							mult_result := gain_constant * clip_threshold;
							data_out <= '0' & mult_result(14 downto 0);
							--data_out <= '0' & clip_threshold(14 downto 0);
						else
							mult_result := gain_constant * data_in;
							data_out <= mult_result(15 downto 0);
							--data_out <= data_in;
						end if;
					end if;
				else
					data_out <= data_in;
				end if;
				completed <= '1';
			else
				completed <= '0';
			end if;
		end if;
	end process;
end architecture;
		
