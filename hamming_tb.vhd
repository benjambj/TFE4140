--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:19:50 04/22/2013
-- Design Name:   
-- Module Name:   M:/Documents/prosjekt/TFE4140/hamming_tb.vhd
-- Project Name:  TFE4140
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: liaison
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use std.textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY hamming_tb IS
END hamming_tb;
 
ARCHITECTURE behavior OF hamming_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
	 
	 -- function for std_logic_vector to string - stolen from
	 -- http://www-ee.uta.edu/Online/Zhu/spring_2007/tutorial/how_to_print_objexts.txt
  function to_string(sv: Std_Logic_Vector) return string is
    use Std.TextIO.all;
    variable bv: bit_vector(sv'range) := to_bitvector(sv);
    variable lp: line;
  begin
    write(lp, bv);
    return lp.all;
  end;


 
    COMPONENT liaison
    PORT(
         clk : IN  std_logic;
         mp_data : IN  std_logic_vector(3 downto 0);
         reset : IN  std_logic;
         di_ready : IN  std_logic;
         do_ready : OUT  std_logic;
         voted_data : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal mp_data : std_logic_vector(3 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal di_ready : std_logic := '0';

 	--Outputs
   signal do_ready : std_logic;
   signal voted_data : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
function gen_ecc(d: std_logic_vector(7 downto 0); s: std_logic_vector(2 downto 0))
		return std_logic_vector is
		variable ecc : std_logic_vector(4 downto 0);
		
		-- What way to calculate Hamming code? (which bits are most significant
		--variable w : std_logic_vector(10 downto 0);
		variable w : std_logic_vector(0 to 10);
	begin
		w := d & s;
		ecc(0) := w(0) xor w(1) xor w(3) xor w(4) xor w(6) xor w(8) xor w(10);
		ecc(1) := w(0) xor w(2) xor w(3) xor w(5) xor w(6) xor w(9) xor w(10);
		ecc(2) := w(1) xor w(2) xor w(3) xor w(7) xor w(8) xor w(9) xor w(10);
		ecc(3) := w(4) xor w(5) xor w(6) xor w(7) xor w(8) xor w(9) xor w(10);
		ecc(4) := w(0) xor w(1) xor w(2) xor w(3) xor w(4) xor w(5) xor w(6) xor w(7)
							xor w(8) xor w(9) xor w(10)
							xor ecc(0) xor ecc(1) xor ecc(2) xor ecc(3);
		assert false report "(11,15)-Hamming for " & to_string(w) & " is " & to_string(ecc) severity note;
		return ecc;
	end function;
 
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: liaison PORT MAP (
          clk => clk,
          mp_data => mp_data,
          reset => reset,
          di_ready => di_ready,
          do_ready => do_ready,
          voted_data => voted_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
	is
		variable sev: severity_level := error;
		variable testnr : integer := 0;
		procedure test_ecc (
			d0: std_logic_vector(7 downto 0);
			d1: std_logic_vector(7 downto 0);
			d2: std_logic_vector(7 downto 0);
			d3: std_logic_vector(7 downto 0);
			voted: std_logic_vector(7 downto 0);
			status : std_logic_vector(2 downto 0);
			ecc: std_logic_vector(4 downto 0))
		is
			variable j : integer := 7;
			variable output_pulse : boolean := false;
		begin
		assert false report "Test " & integer'image(testnr) & " started!" severity note;
			di_ready <= '1';
			
			-- send data and wait for do_ready
			for i in 7 downto 0 loop
				mp_data <= (d0(i), d1(i), d2(i), d3(i));
				wait for clk_period;
				di_ready <= '0';
				if do_ready = '1' or output_pulse then
					output_pulse := true;
					di_ready <= '0'; -- only effective first itteration
					assert voted_data = voted(j) report "Erroneous vote @test " & integer'image(testnr) & " @input-step " & integer'image(i) & " @output-step " & integer'image(j) & ". Value was " & std_logic'image(voted_data) & ", expected " & std_logic'image(voted(j)) & "." severity sev;
					j := j-1;
				end if;
			end loop;
			
			assert false report "Sendt " & integer'image(j+1) & " data bits before output was ready." severity note;
			
			-- check rest of voted data
			if j > -1 then -- '-1' means all data bits has been received
				for i in j downto 0 loop
						wait for clk_period;
						assert voted_data = voted(i) report "Erroneous vote @test " & integer'image(testnr) & " @output-step " & integer'image(i) & ". Value was " & std_logic'image(voted_data) & ", expected " & std_logic'image(voted(i)) & "."  severity sev;
				end loop;
			end if;
			
			-- check status
			for i in 2 downto 0 loop
				wait for clk_period;
				assert voted_data = status(i) report "Erroneous status @test " & integer'image(testnr) & " @output-step " & integer'image(i)  & ". Value was " & std_logic'image(voted_data) & ", expected " & std_logic'image(status(i)) & "." severity sev;
			end loop;
			
			-- check ecc
			for i in 4 downto 0 loop
				wait for clk_period;
				assert voted_data = ecc(i) report "Erroneous ecc @test " & integer'image(testnr) & " @output-step " & integer'image(i)  & ". Value was " & std_logic'image(voted_data) & ", expected " & std_logic'image(ecc(i)) & "." severity sev;
			end loop;
			
			assert false report "Test " & integer'image(testnr) & " completed successfully" severity note;
			testnr := testnr + 1;
		end procedure;
		
		procedure test_ecc (
			data: std_logic_vector(7 downto 0); status : std_logic_vector(2 downto 0)) is
		begin
			test_ecc(data,data,data,data,data,status,gen_ecc(data, status));
		end procedure;
		
		procedure test_ecc (
			d1: std_logic_vector(7 downto 0);
			d2: std_logic_vector(7 downto 0);
			d3: std_logic_vector(7 downto 0);
			d4: std_logic_vector(7 downto 0);
			expected: std_logic_vector(7 downto 0);
			status : std_logic_vector(2 downto 0)) is
		begin
			test_ecc(d1,d2,d3,d4,expected,status,gen_ecc(expected, status));
		end procedure;
		
		procedure test_ecc (
			data: std_logic_vector(7 downto 0); status : std_logic_vector(2 downto 0); ecc: std_logic_vector(4 downto 0)) is
		begin
			test_ecc(data,data,data,data,data,status,ecc);
		end procedure;
		
		procedure reset_liaison is
		begin
			reset <= '1';
			wait for clk_period;
			reset <= '0';
		end procedure;
		
		-- begin stim_proc
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		wait for clk_period;
		
		test_ecc("11111111", "000"); -- test 0
		--wait for clk_period*2;
		test_ecc("00000000", "000"); -- test 1
		wait for clk_period*2;
		test_ecc("10101010", "000"); -- test 2
		wait for clk_period*2;
		test_ecc("10011010", "000"); -- test 3
		wait for clk_period*2;
		test_ecc("10010011", "000"); -- test 4
		
		--TODO: Assert that waiting does not destroy anything
		--wait for clk_period * 1000;
		--TODO: Assert that nothing is broken by random input.
		
		reset_liaison;
		
		-- Old comment -- When system is broken, output from the second MCU is chosen as voted data
		test_ecc("01111111", "10111111", "11011111", "11101111", "11011111", "111"); -- test 5
		
		reset_liaison;
		 ---       D3 |  D2  |   D1  |  D0|Expected|Status
		test_ecc(X"80", X"00", X"00", X"00", X"00", "001"); -- test 6
		test_ecc(X"00", X"80", X"00", X"00", X"00", "010"); -- test 7
		
		reset_liaison;
		
		
		-- Test a series of functioning, error, functioning, error, functioning and then broken.
		test_ecc(X"55", X"55", X"55", X"55", X"55", "000"); -- test 8
		test_ecc(X"55", X"55", X"55", X"55", X"55", "000"); -- test 9
		test_ecc(X"AA", X"AA", X"AA", X"AA", X"AA", "000"); -- test 10
		test_ecc(X"0F", X"0F", X"0F", X"0F", X"0F", "000"); -- test 11
		--first failure
		test_ecc(X"0F", X"0F", X"cc", X"0F", X"0F", "001"); -- test 12
		test_ecc(X"55", X"55", X"55", X"55", X"55", "001"); -- test 13
		test_ecc(X"55", X"55", X"CA", X"55", X"55", "001"); -- test 14
		test_ecc(X"55", X"55", X"FE", X"55", X"55", "001"); -- test 15
		test_ecc(X"AA", X"AA", X"D0", X"AA", X"AA", "001"); -- test 16
		test_ecc(X"0F", X"0F", X"0D", X"0F", X"0F", "001"); -- test 17
		--second failure
		test_ecc(X"4B", X"99", X"99", X"99", X"99", "010"); -- test 18
		
		reset_liaison;
		
		--------------------------------------------------------------
		-- Regression tests
		test_ecc(X"00", X"00", X"40", X"80", X"00", "010"); -- test 19
		reset_liaison;
		
		test_ecc(X"00", X"00", X"40", X"C0", X"00", "010"); -- test 20
		reset_liaison;
		
		test_ecc(X"80", X"40", X"20", X"20", X"20", "010"); -- test 21
		reset_liaison;
		
		test_ecc(X"C0", X"40", X"00", X"00", X"00", "010"); -- test 22
		reset_liaison;
		
		assert false report "test complete yay" severity failure;
      wait;
   end process;

END;
