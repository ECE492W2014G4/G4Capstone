LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

ENTITY distortion_component_tb IS 
END distortion_component_tb;
--1111110010011001
--1111101110100100
--1111101110000100
--1111110000111111
--1111110110111000
--1111111110110000
--0000000111001111
--0000001110111000
--0000010100010001
--0000010110010101
--0000010100100000 

ARCHITECTURE behavior OF distortion_component_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT distort  --'distortion_component' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such. 
    PORT( 
		data_in : in std_logic_vector(15 downto 0); -- 16-bit data stream input
		dist_en : in std_logic; -- 1-bit distortion enable signal
		clipping_value: in std_logic_vector(15 downto 0); -- 16-bit input clipping threshold
		clk : in std_logic;
		reset : in std_logic;
		data_out: out std_logic_vector(15 downto 0) -- 16-bit data stream output (either clipped or not)
    );
    END COMPONENT;
   --declare inputs and initialize them
   signal data_in : std_logic_vector(15 downto 0) := "0000000000000000";
   signal dist_en : std_logic := '1';
   signal clipping_value : std_logic_vector(15 downto 0) := "0000001111101000"; -- Clipped at 1000
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   --declare outputs and initialize them
   signal data_out: std_logic_vector(15 downto 0);
   -- Clock period definitions
   constant clk_period : time := 1 ns;
   
   BEGIN
   
	uut: distort PORT MAP (
		clk => clk,
		reset => reset,
		data_in => data_in,
		dist_en => dist_en,
		clipping_value => clipping_value,
		data_out => data_out
		);
		
	clk_process :process
	begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
	end process;
	
	stim_proc: process
	begin         
        wait for 10 ns;
        data_in <="1111110010011001";
        wait for 10 ns;
        data_in <="1111101110100100";
        wait for 10 ns;
        data_in <="1111101110000100";
        wait for 10 ns;
        data_in <="0111110000111111";
		wait for 10 ns;
		data_in <="1111110110111000";
		wait for 10 ns;
		data_in <="1111111110110000";
		wait for 10 ns;
		data_in <="1111110000111111";
		wait for 10 ns;
		data_in <="0000000111001111";
		wait for 10 ns;
		data_in <="0000001110111000";
		wait for 10 ns;
		data_in <="0000010100010001";
		wait for 10 ns;
		data_in <="0000010110010101";
		wait for 10 ns;
		data_in <="0000010100100000";
		wait for 10 ns;
        report "Test bench Complete";
        wait;
    end process stim_proc;

END behavior;