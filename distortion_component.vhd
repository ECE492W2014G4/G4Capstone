library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity distort is
	port( 
	clk : in std_logic;
	reset : in std_logic;
	dist_en : in std_logic; -- 1-bit distortion enable signal
	data_in : in std_logic_vector(15 downto 0); -- 16-bit data stream input
	clipping_value: in std_logic_vector(15 downto 0); -- 16-bit input clipping threshold
	data_out: out std_logic_vector(15 downto 0) -- 16-bit data stream output (either clipped or not)
	);
end entity distort;

architecture behavior of distort is
constant clipping_default : std_logic_vector(15 downto 0) := "0000001111101000"; -- constant value of 500 in decimal
signal clip_threshold : std_logic_vector(15 downto 0);

begin
	process(clk,reset,dist_en)
	begin
	-- clip_threshold <= clipping_value;
	-- Default Clipping Value
	clip_threshold <= clipping_default;
		if reset = '0' then
			data_out <= X"0000";
		elsif (rising_edge(clk)) then
			-- Check if Distortion is Enabled
			if dist_en = '1' then 
				-- Check sign of sample (If negative...)
				if data_in(15) = '1' then 
					-- compare data to clip_threshold (without sign bits)
					if (not data_in(14 downto 0)) >= clip_threshold(14 downto 0) then 
						-- if data is greater than threshold, data_out = clip_threshold, concatenate '1' to complement
						data_out <= '1' & (not clip_threshold(14 downto 0)); 
					else 
						data_out <= data_in;
					end if;
				-- Check sign of sample (If positive...)
				elsif data_in(15) = '0' then 
					if data_in(14 downto 0) >= clip_threshold(14 downto 0) then
						data_out <= '0' & clip_threshold(14 downto 0);
					else
						data_out <= data_in;
					end if;
				end if;
			else
				data_out <= data_in;
			end if;
		end if;
	end process;
end architecture;
		
