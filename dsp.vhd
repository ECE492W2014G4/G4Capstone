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
	reset_n: in std_logic;
	enable: in std_logic_vector(2 downto 0);
	incoming_data_left: in std_logic_vector(15 downto 0);
	incoming_valid_left: in std_logic;
	incoming_data_right: in std_logic_vector(15 downto 0);
	incoming_valid_right: in std_logic;
	outgoing_data_left: out std_logic_vector(15 downto 0);
	outgoing_valid_left: out std_logic;
	outgoing_data_right: out std_logic_vector(15 downto 0);
	outgoing_valid_right: out std_logic;
	outgoing_streaming: out std_logic_vector(31 downto 0);
	outgoing_streaming_valid: out std_logic
	);
end entity dsp;

architecture arch of dsp is
	signal dist_completed: std_logic_vector(1 downto 0);
	signal dist_en : std_logic;
	signal reverb_en : std_logic;
	signal tuner_en : std_logic;
	signal out_valid: std_logic;
	signal distortion, reverb, tuner, livestream, outgoing :std_logic_vector(15 downto 0);
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

	component reverb_component is
			port(
				clk			: in  STD_LOGIC;
				reset		: in  STD_LOGIC;
				data_in		: in  STD_LOGIC_VECTOR (15 downto 0);
				reverb_en	: in  STD_LOGIC;
				ready 		: in std_logic; --
				done 		: out std_logic; --
				data_out	: out STD_LOGIC_VECTOR (15 downto 0)
			);
	end component;
	component MUX3X1 is
	port(
		clk: in std_logic;
		distortion: in std_logic_vector(15 downto 0);
		reverb: in std_logic_vector(15 downto 0);
		tuner: in std_logic_vector(15 downto 0);
		livestream: in std_logic_vector(15 downto 0);
		AUDIO_IN: in std_logic_vector(15 downto 0);
		OUTPUT: out std_logic_vector(15 downto 0);
		SEL: in std_logic_vector(2 downto 0)
	);
	end component;
begin
		out_valid	<= dist_completed(0) OR dist_completed(1);	
		outgoing_valid_left <= out_valid;
		outgoing_valid_right <= out_valid;
		outgoing_data_left <= outgoing;
		outgoing_data_right <= outgoing;
		
		MUX: MUX3X1 port map (  clk => clk,
								distortion => distortion,
								reverb => reverb, 
								tuner => tuner,
								livestream => livestream,
								AUDIO_IN => incoming_data_left(15 downto 0),
								OUTPUT => outgoing,
								SEL => enable(2 downto 0));
		d1:distort port map (	clk =>clk,reset=>reset_n,
						dist_en => enable(0),
						ready => incoming_valid_left,
						done => dist_completed(0), 
						data_in => incoming_data_left(15 downto 0),
						data_out => distortion(15 downto 0));
		r1:reverb_component port map ( clk => clk,
						reset => reset_n,
						data_in => incoming_data_left(15 downto 0),
						reverb_en => enable(1),
						ready => incoming_valid_left,
						done => dist_completed(1),
						data_out => reverb(15 downto 0));
		fifo_out: process(clk, out_valid)
		begin
			if(rising_edge(clk)) then
				if(reset_n = '0') then
					outgoing_streaming <= X"00000000";
					outgoing_streaming_valid <= '0';
				elsif(out_valid = '1') then
					outgoing_streaming(31 downto 16) <= (others => outgoing(15));
					outgoing_streaming(15 downto 0) <= outgoing(15 downto 0);
					outgoing_streaming_valid <= '1';
				else
					outgoing_streaming_valid <= '0';
				end if;			
			end if;
		end process;
		
end architecture;
