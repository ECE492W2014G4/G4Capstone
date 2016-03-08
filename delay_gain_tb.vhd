LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY delay_gain_tb IS
END delay_gain_tb;

ARCHITECTURE behavior OF delay_gain_tb IS 
	
	-- Component Declaration for the Unit Under Test (UUT)
	component delay_gain
		port (
		clk : in std_logic;
		reset : in std_logic;
		ready : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		done : out std_logic;
		data_out : out std_logic_vector (15 downto 0);
		next_stage_out : out std_logic_vector (15 downto 0)
		);
	end component;
	
	--Inputs
	signal clk		: std_logic := '0';
	signal reset		: std_logic := '0';
	signal data_in	: std_logic_vector(15 downto 0) := (others => '0');
	signal ready		: std_logic := '1';
	signal done			: std_logic := '0';
	
	--Outputs
	signal data_out	: std_logic_vector(15 downto 0);
	signal next_stage_out : std_logic_vector(15 downto 0);
	
	-- Clock period definitions
	constant clk_period : time := 50 ms;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: delay_gain
		PORT MAP (
		clk => clk,
		reset => reset,
		ready => ready,
		data_in => data_in,
		done => done,
		data_out => data_out,
		next_stage_out => next_stage_out
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
	wait for clk_period * 2;
		reset <= '0';
		wait for clk_period;
		
		reset <= '1';
		wait;
	end process;
	
	-- Write process
	delay_proc : process
		variable counter : unsigned (7 downto 0) := (others => '0');
	begin		
		wait for clk_period * 3;
--		reverb_en <= '1';
		for i in 1 to 32 loop
			counter := counter + 1;
			
			data_in <= "00000000"&std_logic_vector(counter);
			
			wait for clk_period * 1;
			
		end loop;	
		
		wait;
	end process;
	
	-- Read process
	-- rd_proc : process
	-- begin
		-- wait for clk_period;			
		-- reverb_en <= '1';
		-- --wait for clk_period * 5;
		-- --reverb_en <= '0';
		-- --wait for clk_period * 5;
		-- --reverb_en <= '1';
		
		-- wait;
	-- end process;

END;
