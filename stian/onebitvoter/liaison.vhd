----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:20:03 02/04/2013 
-- Design Name: 
-- Module Name:    liaison - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY liaison IS
	PORT( clk			: IN std_logic;
			mp_data		: IN std_logic_vector(3 downto 0);
			reset			: IN std_logic;
			di_ready		: IN std_logic;
			do_ready		: OUT std_logic;
			voted_data	: OUT std_logic
);

architecture Behavioral of liaison is

signal flag : Std_logic;

begin

flag <= clk;

end Behavioral;

