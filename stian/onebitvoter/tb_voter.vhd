--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:55:52 02/08/2013
-- Design Name:   
-- Module Name:   /home/hvatum/Skole/TFE4140/a3/onebitvoter/tb_voter.vhd
-- Project Name:  onebitvoter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: voter
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
USE ieee.numeric_std.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_voter IS
END tb_voter;
 
ARCHITECTURE behavior OF tb_voter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT voter
    PORT(
         a : IN  std_logic;
         b : IN  std_logic;
         c : IN  std_logic;
         d : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         y : OUT  std_logic;
         status : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal mcu : std_logic_vector(3 downto 0);
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal y : std_logic;
   signal status : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: voter PORT MAP (
          a => mcu(0),
          b => mcu(1),
          c => mcu(2),
          d => mcu(3),
          clk => clk,
          reset => reset,
          y => y,
          status => status
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
   begin		
      -- easy initialization
      wait for 100 ns;	
			reset <= '1';
      wait for clk_period*2;
			mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period*2;
			reset <= '0';
		wait for clk_period;
		-- check that reset works
		assert(status<="000" and y='0') report "Error at 0: reset";

		-- testing normal transistions to 1
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "000" and y='1') report "Error at 1";
		
		-- testing normal transistions to 0
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		assert(status = "000" and y='0') report "Error at 2";
		
		-- testing one failed at transistions to 1
		mcu <= std_logic_vector(to_unsigned(14,4));
		wait for clk_period;
		assert(status = "001" and y='1') report "Error at 3";

		-- testing all back transistions to 1
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		-- status should still be one failed
		assert(status = "001" and y='1') report "Error at 4";
		
		-- testing all back transistions to 0
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		assert(status = "001" and y='0') report "Error at 5";
		
		-- testing two back transistions to 1, one marked as failed
		mcu <= std_logic_vector(to_unsigned(3,4));
		wait for clk_period;
		assert(status = "010" and y='0') report "Error at 6";
		
		-- testing working ones transistions to 1, defect ones is 0
		mcu <= std_logic_vector(to_unsigned(12,4));
		wait for clk_period;
		assert(status = "010" and y='1') report "Error at 7";
		
		-- kill one more
		mcu <= std_logic_vector(to_unsigned(8,4));
		wait for clk_period;
		-- we cant know, defaulting result to 0
		assert(status = "111" and y='0') report "Error at 8";
		
		
		-- reset
		reset <= '1';
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		reset <= '0';
		-- back on track
		assert(status = "000" and y='0') report "Error at 9";
		
		wait for clk_period;
		-- two fails at the same time
		mcu <= std_logic_vector(to_unsigned(6,4));
		wait for clk_period;
		assert(status = "010" and y='0') report "Error at 10";
		
		-- two old still working
		mcu <= std_logic_vector(to_unsigned(6,4));
		wait for clk_period;
		assert(status = "010" and y='0') report "Error at 11";
		
		-- two old still working
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "010" and y='1') report "Error at 12";
		
		-- two old still working
		mcu <= std_logic_vector(to_unsigned(9,4));
		wait for clk_period;
		assert(status = "010" and y='1') report "Error at 13";
		
		-- two old still working
		mcu <= std_logic_vector(to_unsigned(6,4));
		wait for clk_period;
		assert(status = "010" and y='0') report "Error at 14";
		
		-- now all hope is lost
		mcu <= std_logic_vector(to_unsigned(1,4));
		wait for clk_period;
		assert(status = "111" and y='0') report "Error at 15";
		
		-- now all hope is lost
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "111" and y='1') report "Error at 16";
		
		-- and we cant recover, even if signals are back OK
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		assert(status = "111" and y='0') report "Error at 17";
		
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "111" and y='1') report "Error at 18";
		
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		assert(status = "111" and y='0') report "Error at 19";
		
		-- try normal operation for a while
		reset <= '1';
		mcu <= std_logic_vector(to_unsigned(0,4));
		wait for clk_period;
		reset <= '0';
		assert(status = "000" and y='0') report "Error at 20";
		
		mcu <= std_logic_vector(to_unsigned(0,4));	
		wait for clk_period;
		assert(status = "000" and y='0') report "Error at 20";
		
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "000" and y='1') report "Error at 21";
		
		mcu <= std_logic_vector(to_unsigned(0,4));	
		wait for clk_period;
		assert(status = "000" and y='0') report "Error at 22";
		
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "000" and y='1') report "Error at 23";
		
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "000" and y='1') report "Error at 24";
		
		mcu <= std_logic_vector(to_unsigned(15,4));
		wait for clk_period;
		assert(status = "000" and y='1') report "Error at 25";
		
		mcu <= std_logic_vector(to_unsigned(0,4));	
		wait for clk_period;
		assert(status = "000" and y='0') report "Error at 26";
		
		-- and crash
		mcu <= std_logic_vector(to_unsigned(7,4));
		wait for clk_period;
		assert(status = "001" and y='1') report "Error at 27";
		
		-- done
      wait;
   end process;

END;
