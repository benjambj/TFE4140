library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity liaison_tb is
end liaison_tb;

architecture TB_ARCHITECTURE of liaison_tb is
	-- Component declaration of the tested unit
	component liaison
	port(
		clk : in STD_LOGIC;
		mp_data : in STD_LOGIC_VECTOR(3 downto 0);
		reset : in STD_LOGIC;
		di_ready : in STD_LOGIC;
		do_ready : out STD_LOGIC;
		voted_data : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal mp_data : STD_LOGIC_VECTOR(3 downto 0);
	signal reset : STD_LOGIC;
	signal di_ready : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal do_ready : STD_LOGIC;
	signal voted_data : STD_LOGIC;

	-- Add your code here ...
    constant clk_period : time := 10 ns; 
	
	
begin

	-- Unit Under Test port map
	UUT : liaison
		port map (
			clk => clk,
			mp_data => mp_data,
			reset => reset,
			di_ready => di_ready,
			do_ready => do_ready,
			voted_data => voted_data
		);
		
	clk_process :process
    begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
    end process;	

		
	-- Add your stimulus here ...
	stim: process is
	type word_t is array(0 to 3) of std_logic_vector(7 downto 0);
	variable word: word_t;
	begin 					
		-- First, reset the circuit
		reset <= '1';
		wait for 2*clk_period;
		reset <= '0';
		
		-- Case 1: all bytes are the same.
			word := ("01010101", "01010101", "01010101", "01010101"); 
			di_ready <= '1';
			for j in 0 to 3 loop
				mp_data(j) <= word(j)(7);
			end loop;
			wait for clk_period;	 
			assert voted_data = word(0)(7) report "Erroneous vote" severity failure;
			di_ready <= '0';
			for i in 6 downto 0 loop
				for j in 0 to 3 loop
					mp_data(j) <= word(j)(i);
				end loop;
				wait for clk_period;
				assert voted_data = word(0)(i) report "Erroneous vote" severity failure;
			end loop;
			
			-- Allow status to be sent
			wait for clk_period; 
			assert voted_data = '0' report "Should not have status all fail" severity failure;
			wait for clk_period; 
			assert voted_data = '0' report "Should not have status two fail" severity failure;
			wait for clk_period; 
			assert voted_data = '0' report "Should not have status one fail" severity failure;
			
		-- Case 2: one byte differs in final bit
			word := ("01010101", "01010101", "01010101", "01010100"); 
			di_ready <= '1';
			for j in 0 to 3 loop
				mp_data(j) <= word(j)(7);
			end loop;
			wait for clk_period; 
			assert voted_data = word(0)(7) report "Erroneous vote" severity failure;
			di_ready <= '0';
			for i in 6 downto 0 loop
				for j in 0 to 3 loop
					mp_data(j) <= word(j)(i);
				end loop;
				wait for clk_period; 
				assert voted_data = word(0)(i) report "Erroneous vote" severity failure;
			end loop;
			
			-- Allow status to be sent
			
			wait for clk_period; 
			assert voted_data = '0' report "Should not have status all fail" severity failure;
			wait for clk_period; 
			assert voted_data = '0' report "Should not have status two fail" severity failure;
			wait for clk_period; 
			assert voted_data = '1'report "Should have status one fail" severity failure;
				
			
		wait;
	end process;													 
		
	
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_liaison of liaison_tb is
	for TB_ARCHITECTURE
		for UUT : liaison
			use entity work.liaison(liaison);
		end for;
	end for;
end TESTBENCH_FOR_liaison;

