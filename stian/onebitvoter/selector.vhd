----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:21:47 02/08/2013 
-- Design Name: 
-- Module Name:    selector - Behavioral 
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
USE work.custom_func.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity selector is
	Generic (N: Natural := 4);
    Port ( mcu : in  STD_LOGIC_VECTOR(N-1 downto 0);
			  active : in  STD_LOGIC_VECTOR(N-1 downto 0);
           y : out  STD_LOGIC
);

end selector;

architecture Behavioral of selector is
signal amcu : std_logic_vector(N-1 downto 0);
signal anmcu : std_logic_vector(N-1 downto 0);
begin

amcu <= mcu and active;
anmcu <= not mcu and active;

do_selection : process(amcu, anmcu) is
	variable count : integer range 0 to N;
begin
		count := 0;
		for i in N-1 downto 0 loop
				if amcu(i) = '1' then
					count := count + 1;
				elsif anmcu(i) = '1' then
					count := count - 1;
				end if;
		end loop;
		y <= bool_to_stdlogic(count > 0);
end process;

end Behavioral;