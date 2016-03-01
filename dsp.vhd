-- Design unit: DSP
-- Structural implementation 
-- Included components: distortion_component, Serializer, reverb 
-- Authors : Aaron Arnason, Byron Maroney, Edrick De Guzman

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity dsp is
	port(
	clk: in std_logic;
	fft_clk: in std_logic;
	reset_n: in std_logic;
	dist_en : in std_logic;
	tuner_en : in std_logic;
	incoming_data_left: in std_logic_vector(15 downto 0);
	incoming_valid_left: in std_logic;
	incoming_data_right: in std_logic_vector(15 downto 0);
	incoming_valid_right: in std_logic;
	outgoing_data_left: out std_logic_vector(15 downto 0);
	outgoing_valid_left: out std_logic;
	outgoing_data_right: out std_logic_vector(15 downto 0);
	outgoing_valid_right: out std_logic;
	tuner_readdata: out std_logic_vector(31 downto 0)
	);
end entity dsp;

architecture arch of dsp is
	signal dist_completed, fft_done: std_logic;
	signal outgoing:std_logic_vector(15 downto 0);
	signal temp: signed(31 downto 0);
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
	component audio_fft is 
	 port (
			clk	:	in std_logic;
			tuner_en: in std_logic;
			incoming_valid	:	in std_logic;
			incoming_data	:	in	std_logic_vector(15 downto 0);
			outgoing_valid	:   out std_logic;
			outgoing_data	:	out signed(31 downto 0);
			reset_n: in std_logic
		);
	end component;	
begin
		outgoing_valid_left <= dist_completed;
		outgoing_valid_right <= dist_completed;
		outgoing_data_left <= outgoing;
		outgoing_data_right <= outgoing;

		tuner_readdata <= std_logic_vector(temp);
		d1:distort port map (	clk =>clk,reset=>reset_n,
									 	dist_en => dist_en,
										ready => incoming_valid_left,
										done => dist_completed, 
										data_in => incoming_data_left(15 downto 0),
										data_out => outgoing(15 downto 0));
		tuner:audio_fft port map (
									clk	=> fft_clk,
									tuner_en =>tuner_en,
									incoming_valid => incoming_valid_left,
									incoming_data => incoming_data_left(15 downto 0),
									outgoing_valid => fft_done,
									outgoing_data  => temp,
									reset_n => reset_n
						);
end architecture;
