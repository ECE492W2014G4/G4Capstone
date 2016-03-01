--Adapted from audio_fft app note from Andrew Ovens, and Torrin Swanson (Group 10 - 2013W:https://www.ualberta.ca/~delliott/local/ece492/appnotes/2013w/g10_audio_fft/)
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
--use IEEE.NUMERIC_STD.ALL;

entity audio_fft is 
	 port (
			clk	:	in std_logic;
			tuner_en: in std_logic;
			incoming_valid	:	in	std_logic;
			incoming_data	:	in	std_logic_vector(15 downto 0);
			outgoing_valid	:   out std_logic;
			outgoing_data	:	out signed(31 downto 0);
			reset_n: in std_logic
		);
end audio_fft;


-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture structure of audio_fft is
	
component fft_v10_1 is
    port (
      clk          : in  std_logic;
      reset_n      : in  std_logic;
      inverse      : in  std_logic;
      sink_valid   : in  std_logic;
      sink_sop     : in  std_logic;
      sink_eop     : in  std_logic;
      sink_real    : in  std_logic_vector (24 - 1 downto 0);
      sink_imag    : in  std_logic_vector (24 - 1 downto 0);
      source_ready : in  std_logic;
      sink_ready   : out std_logic;
      sink_error   : in  std_logic_vector(1 downto 0);
      source_error : out std_logic_vector(1 downto 0);
      source_sop   : out std_logic;
      source_eop   : out std_logic;
      source_valid : out std_logic;
      source_exp   : out std_logic_vector (5 downto 0);
      source_real  : out std_logic_vector (24 - 1 downto 0);
      source_imag  : out std_logic_vector (24 - 1 downto 0)
      ); 
		
  end component fft_v10_1;
		  
	signal  inverse,sink_valid,sink_sop,sink_eop,source_ready,sink_ready,source_sop,source_eop,source_valid:std_logic;
	signal sink_real,sink_imag,source_real,source_imag : std_logic_vector(23 downto 0);
	signal sink_error,source_error : std_logic_vector(1 downto 0);
	signal source_exp   : std_logic_vector (5 downto 0);
	signal sum	: signed(31 downto 0);
	signal cnt,out_cnt	: natural range 0 to 1000000000;	
	signal result48,sq_real,sq_imag,max	: signed(47 downto 0);
	signal temp_real24,temp_imag24,exp_24  : signed(23 downto 0);
	signal temp_exp : integer;
			
begin		  
		--we want a forward fft
		inverse <= '0';
		--running at our generated clock frequency, new data will always be available
		source_ready <= '1';
		sink_valid <= incoming_valid and tuner_en;
		--there is no imaginary part to our input data
		sink_imag <= "000000000000000000000000";
		--no errors on the input
		sink_error <= "00";
		--input data is left channel of audio input
		sink_real <= (others => incoming_data(15) );
		sink_real(15 downto 0) <= incoming_data(15 downto 0); 
		outgoing_data <= sum;
		FFT : fft_v10_1
    		port map (
      			clk          => clk,
      			reset_n      => reset_n,
      			inverse      => inverse,
      			sink_valid   => sink_valid,
      			sink_sop     => sink_sop,
      			sink_eop     => sink_eop,
      			sink_real    => sink_real,
      			sink_imag    => sink_imag,
      			sink_error   => sink_error,
      			source_error => source_error,
      			source_ready => source_ready,
      			sink_ready   => sink_ready,
      			source_sop   => source_sop,
      			source_eop   => source_eop,
      			source_valid => source_valid,
      			source_exp   => source_exp,
      			source_real  => source_real,
      			source_imag  => source_imag);
		fft_in_process: process(clk)
		  
		begin
		  
		if (rising_edge(clk) and sink_ready = '1') then
			
				--indicates the start of packet
				if(cnt = 0) then
					sink_sop <= '1';
				else
					sink_sop <= '0';
				end if;
				
				--counts input packets
				cnt <= cnt + 1;
				
				--indicates end of packet
				if(cnt = 1024) then
					sink_eop <= '1';
					cnt <= 0;
				else
					sink_eop <= '0';
				end if;
				
			end if;
		end process;
		
		fft_out_process: process(clk)
		  
		begin
				if (rising_edge(clk) and source_valid = '1') then
				
				--counts the current bin number of the fft output
				out_cnt <= out_cnt + 1;
			
				--resets bin counter on start of packet
				if(source_sop = '1') then
					out_cnt <= 0;
					--max is used for auto gain control, 
					--this resets it at the start of each output cycle
					max <= signed(conv_std_logic_vector(0,48));
				end if;	
				
				--source_exp is given as a negative number, 
				--this subtracts the exp value from the max value (15)
				temp_exp <= 15 + conv_integer(signed(source_exp));
					
				--shifts the output data to the right by the exp (larger exponents are shifted less)
				temp_real24 <= signed(to_stdlogicvector(to_bitvector(source_real) sra temp_exp));
				--squares the real portion
				sq_real <= temp_real24 * temp_real24;
					
				temp_imag24 <= signed(to_stdlogicvector(to_bitvector(source_imag) sra temp_exp));
				--squares the imaginary portion
				sq_imag <= temp_imag24 * temp_imag24;
					
				--finds the vector magnitude (squared) of the fft output
				result48 <= sq_real + sq_imag;

					--finds max value of all bins
				if(result48 > max) then
					max <= result48;
				end if;

				--Get the frequency (assuming fft size is 1024). 
				--Idea from http://stackoverflow.com/questions/4364823/how-do-i-obtain-the-frequencies-of-each-value-in-a-fft
				if(out_cnt < 512) then
					sum <= sum + temp_real24;
					if(out_cnt = 511) then
						outgoing_valid <= '1';				
					end if;
				elsif (out_cnt > 511) then
						outgoing_valid <= '0';
				end if;
			end if;
		  end process;
end structure;