library ieee;
use ieee.std_logic_1164.all;

entity MUX3X1 is
	port(
		clk: in std_logic;
		distortion: in std_logic_vector(15 downto 0);
		reverb: in std_logic_vector(15 downto 0);
		AUDIO_IN: in std_logic_vector(15 downto 0);
		OUTPUT: out std_logic_vector(15 downto 0);
		SEL: in std_logic_vector(2 downto 0)
	);
end entity MUX3X1;

architecture arch of MUX3X1 is
begin
	MUX: process(clk,SEL)
			begin
				if(rising_edge(clk)) then
					case SEL is
 						when "001" =>  
							OUTPUT <= distortion;
						when "010" => 
							OUTPUT <= reverb;
  						when others =>
							--no effect to be applied
							--distortion component has a passthrough functionality (it simply passes through the audio when an effect is not applied)
							OUTPUT <= AUDIO_IN;
						end case;
				end if;
			end process;
end arch; 
 
