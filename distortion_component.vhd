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
	clipping_write : in std_logic;
	clipping_read : in std_logic;
	clipping_value: in std_logic_vector(15 downto 0); -- 16-bit input clipping threshold
	clipping_readdata: out std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(15 downto 0) -- 16-bit data stream output (either clipped or not)
	);
end entity distort;

architecture behavior of distort is

-- Distortion Settings
-- 1) Gain at 3 ("11") - Clipping at 1000 "0000001111101000"
-- 2) Gain at 3 ("10") - Clipping at 3000 "0000101110111000" - Default
-- 3) Gain at 3 ("01") - Clipping at 5000 "0001001110001000"

constant clipping_default : std_logic_vector(15 downto 0) := "0000101110111000"; -- constant value of 3000 in decimal
constant clipping_high : std_logic_vector(15 downto 0) := "0000000001100100"; -- constant value of 1000 in decimal
constant clipping_low : std_logic_vector(15 downto 0) := "0000001111101000"; -- constant value of 5000 in decimal
constant clipping_inc : std_logic_vector(15 downto 0) := X"01F4";

signal gain_constant : std_logic_vector(2 downto 0) := "001"; -- constant gain: default at 1

signal clip_threshold,clip_sample : std_logic_vector(15 downto 0);
signal completed : std_logic :='0';
signal counter: unsigned(15 downto 0);


begin
	clipping_readdata <= clip_threshold;
	done <= completed;
--	c0: process(clk)
--		begin
--			if rising_edge(clk) then
--				if clipping_read = '0' then
--					clipping_readdata <= clip_threshold;				
--				end if;		
--			end if;
--		end process;
	c1: process(clk,clipping_write)
			begin
				if rising_edge(clk) then
					if dist_en = '1' then
						if clipping_write = '0' then -- Active Low
							clip_sample <= clipping_value;
						else
							case clip_sample is
 								when X"0001" =>  
									clip_threshold <= X"0BB8"; -- Level: 1 - 3000
									gain_constant <= "001";   -- Gain: 1
								when X"0002" => 
									clip_threshold <= X"076C"; -- Level: 2 - 1900
									gain_constant <= "010";   -- Gain: 2
								when X"0003" => 
									clip_threshold <= X"0514"; -- Level: 3 - 1300
									gain_constant <= "010";   -- Gain: 2
								when X"0004" => 
									clip_threshold <= X"02BC"; -- Level: 4 - 700
									gain_constant <= "011";   -- Gain: 3
								when X"0005" => 
									clip_threshold <= X"012C"; -- Level: 5 - 300
									gain_constant <= "111";   -- Gain: 5
  								when others =>
									clip_threshold <= X"012C"; -- Level: X - 300
									gain_constant <= "111"; 
							end case;
						end if;
					end if;
				end if;
			end process;
	
	g0:process(clk,reset,dist_en,ready)
	variable mult_result : std_logic_vector(18 downto 0);
	begin
		if reset = '0' then
			data_out <= X"0000";
		elsif (rising_edge(clk)) then
			if(ready = '1') then
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
		
