
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY reverb_component_tb IS
END reverb_component_tb;

ARCHITECTURE behavior OF reverb_component_tb IS 
	
	-- Component Declaration for the Unit Under Test (UUT)
	component reverb_component
		port (
			clk		: in std_logic;
			reset		: in std_logic;
			data_in	: in std_logic_vector(15 downto 0);
			ready : in std_logic;
			done : out std_logic;
--			write_en	: in std_logic;
			reverb_en	: in std_logic;
			data_out	: out std_logic_vector(15 downto 0)
		);
	end component;
	
	--Inputs
	signal clk		: std_logic := '0';
	signal reset		: std_logic := '0';
	signal data_in	: std_logic_vector(15 downto 0) := (others => '0');
	signal reverb_en	: std_logic := '0';
	signal ready		: std_logic := '1';
	signal done			: std_logic := '0';
--	signal write_en	: std_logic := '0';
	
	--Outputs
	signal data_out	: std_logic_vector(15 downto 0);


	
	-- Clock period definitions
	constant clk_period : time := 100 ms;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: reverb_component
		PORT MAP (
			clk		=> clk,
			reset		=> reset,
			data_in	=> data_in,
			ready => ready,
			done => done,
--			write_en	=> write_en,
			reverb_en	=> reverb_en,
			data_out	=> data_out
		);
	
	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	-- Reset process
	reset_proc : process
	begin
	wait for clk_period * 1;
		reset <= '0';
		wait for clk_period;
		
		reset <= '1';
		wait;
	end process;
	
	-- Write process
	wr_proc : process
		variable counter : unsigned (7 downto 0) := (others => '0');
	begin		
		wait for clk_period * 2;
--		write_en <= '1';
		reverb_en <= '1';
		for i in 1 to 32 loop
			counter := counter + 1;
			
			data_in <= "00000000"&std_logic_vector(counter);
			
			wait for clk_period * 1;
			
			
		end loop;	
		wait for clk_period * 10;
		
		wait;
	end process;


END;