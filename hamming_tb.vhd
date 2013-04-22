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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

function test_ecc ( v: std_logic_vector(7 downto 0),
	ecc: std_logic_vector(4 downto 0))
	begin
		test_ecc(v,v,v,v,ecc);
	end function;
 
function test_ecc (
	v0: std_logic_vector(7 downto 0),
	v1: std_logic_vector(7 downto 0),
	v2: std_logic_vector(7 downto 0),
	v3: std_logic_vector(7 downto 0),
	ecc: std_logic_vector(4 downto 0)
	)
    return std_logic is
    begin
        if x then
            return '1';
        else
            return '0';
        end if;
end function;
 
ENTITY hamming_tb IS
END hamming_tb;
 
ARCHITECTURE behavior OF hamming_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		
		test_ecc_single();
      -- insert stimulus here 

      wait;
   end process;

END;
