library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity distortion is
	port(
	clk: in std_logic;
	reset_n: in std_logic;
	dist_en : in std_logic;
	incoming_data: in std_logic_vector(31 downto 0);
	incoming_valid: in std_logic;
	outgoing_data: out std_logic_vector(31 downto 0);
	outgoing_valid: out std_logic
	);
end entity distortion;

architecture arch of distortion is
	signal dist_completed: std_logic_vector(1 downto 0);
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
		outgoing_valid <= dist_completed(0) and dist_completed(1);
		g1: for i in 0 to 1 generate
				d1:distort port map (	clk =>clk,reset=>reset_n,
									 	dist_en => dist_en,
										ready => incoming_valid,
										done => dist_completed(i), 
										data_in => incoming_data((16*i + 15) downto (i*16)),
										data_out => outgoing_data((16*i + 15) downto (i*16)));
		end generate g1;
end architecture;
