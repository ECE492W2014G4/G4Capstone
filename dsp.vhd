-- Design unit: DSP
-- Structural implementation 
-- Included components: distortion_component, Serializer, reverb 
-- Authors : Aaron Arnason, Byron Maroney, Edrick De Guzman

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dsp is
	port(
	clk: in std_logic;
	reset_n: in std_logic;
	dist_en : in std_logic;
	incoming_data: in std_logic_vector(15 downto 0);
	incoming_valid: in std_logic;
	outgoing_data: out std_logic_vector(15 downto 0);
	outgoing_valid: out std_logic
	);
end entity dsp;

architecture arch of dsp is
	signal dist_completed: std_logic;
	component distort is
			port( 
				clk : in std_logic;
				reset : in std_logic;
				dist_en : in std_logic; -- 1-bit distortion enable signal
				ready : in std_logic;
				done : out std_logic;
				data_in : in std_logic_vector(15 downto 0); -- 16-bit data stream input
				data_out: out std_logic_vector(15 downto 0) -- 16-bit data stream output (either clipped or not)
			);
	end component;	
begin
		outgoing_valid <= dist_completed;
		d1:distort port map (	clk =>clk,reset=>reset_n,
									 	dist_en => dist_en,
										ready => incoming_valid,
										done => dist_completed, 
										data_in => incoming_data(15 downto 0),
										data_out => outgoing_data(15 downto 0));

end architecture;
