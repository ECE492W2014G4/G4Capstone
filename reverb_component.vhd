library IEEE;

USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity reverb_component is

	Port ( 
		clk			: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		ready 		: in std_logic;
		done 		: out std_logic;
		data_in		: in  STD_LOGIC_VECTOR (15 downto 0);
		reverb_en	: in  STD_LOGIC;
		data_out	: out STD_LOGIC_VECTOR (15 downto 0)
	);
end reverb_component;

architecture Behavioral of reverb_component is
	
	signal out_signals : std_logic_vector(63 downto 0);
	signal completed : std_logic_vector(2 downto 0);
	component delay_gain
		port (
			clk : in std_logic;
			reset : in std_logic;
			ready : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			done : out std_logic;
			data_out : out std_logic_vector (15 downto 0)
			);
	end component;
	
begin
data_out <= std_logic_vector(signed(data_in) + signed(out_signals(15 downto 0)) + signed(out_signals(31 downto 16)) + signed(out_signals(47 downto 32)) + signed(out_signals(63 downto 48)));
	
	delay_gain_stages: 
	for i in 0 to 3 generate
		if1: if (i = 3) generate
			G0: delay_gain port map (
				clk => clk,
				reset => reset,
				ready => completed(i-1),
				data_in => out_signals(16*(i)-1 downto 16*(i-1)),
				done => done,
				data_out => out_signals(16*(i + 1)-1 downto 16*i)
			);
		end generate;	
		if2: if (i = 0) generate
			G1: delay_gain port map (
					clk => clk,
					reset => reset,
					ready => ready,
					data_in => data_in,
					done => completed(i),
					data_out => out_signals(16*(i + 1)-1 downto 16*i)
				);
		end generate;
		if3: if (i > 0 and i < 3) generate
			G2: delay_gain port map (
					clk => clk,
					reset => reset,
					ready => completed(i-1),
					data_in => out_signals(16*(i)-1 downto 16*(i-1)),
					done => completed(i),
					data_out => out_signals(16*(i + 1)-1 downto 16*i)
				);
		end generate;
   end generate delay_gain_stages;
end Behavioral;













