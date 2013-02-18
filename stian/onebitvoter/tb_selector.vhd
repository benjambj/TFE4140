--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:45:24 02/08/2013
-- Design Name:   
-- Module Name:   /home/hvatum/Skole/TFE4140/a3/onebitvoter/tb_selector.vhd
-- Project Name:  onebitvoter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: selector
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
 
ENTITY tb_selector IS
	Generic (N: natural := 4);
END tb_selector;
 
ARCHITECTURE behavior OF tb_selector IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT selector
    PORT(
         mcu : IN  std_logic_vector(3 downto 0);
         active : IN  std_logic_vector(3 downto 0);
         y : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal mcu : std_logic_vector(3 downto 0) := (others => '0');
   signal active : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal y : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
  
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: selector PORT MAP (
          mcu => mcu,
          active => active,
          y => y
        );
		  
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      for i in 0 to 15 loop
			active <= std_logic_vector(to_unsigned(i,N));			
			for j in 0 to 15 loop
					mcu <= std_logic_vector(to_unsigned(j,N));
					wait for 10 ns;
			end loop;
		end loop;

      wait;
   end process;

END;
