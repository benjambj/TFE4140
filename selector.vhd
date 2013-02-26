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
--signal amcu : std_logic_vector(N-1 downto 0);
--signal anmcu : std_logic_vector(N-1 downto 0);

--
--signal ab: std_logic_vector(3 downto 0);
--signal ab_active: std_logic_vector(1 downto 0);
--signal ab_sum: std_logic_vector(1 downto 0);
--signal cd: std_logic_vector(3 downto 0);
--signal cd_active: std_logic_vector(1 downto 0);
--signal cd_sum: std_logic_vector(1 downto 0);

signal cd: std_logic;
signal use_ab: std_logic;

begin

--ab <= mcu(1) and mcu(0) when active(0) = '0' and active(1) = '0' else
--      mcu(0) when active(0) = '0' else
--		'0';

use_ab <= not (active(1) or active(0) or (mcu(1) xor mcu(0)));

cd <= mcu(3) and mcu(2) when active(3) = '0' and active(2) = '0' else
      mcu(3) when active(3) = '0' else
		'0';

y <= mcu(0) when use_ab = '1' else
	  cd;

--y <= ab when active(1) = '0' and active(0) = '0' else
--	  cd;

--ab <= b & a & active(1) & active(0);
--
--with ab select
--	ab_active <= "00" when "0000"
--					 "01" when "--01" | "10"
--
--cd <= d & c & active(3) & active(2);


-- Idea : Sum(activeOnes) > (Sum(actives) >> 1) instead of Sum(activeOnes) - Sum(activeZeroes) > 0
-- Any benefit? Maybe, remove anmcu...

--amcu <= mcu and active;
--anmcu <= not mcu and active;
--
--do_selection : process(amcu, anmcu) is
--	variable count : integer range 0 to N;
--	variable activeC: integer range 0 to 4;
--begin
--		count := 0;
--		for i in N-1 downto 0 loop
--				if amcu(i) = '1' then
--					count := count + 1;
----				end if;
--				elsif anmcu(i) = '1' then
--					count := count - 1;
--				end if;
----				if (active(i) = '1') then
----					activeC := activeC + 1;
----				end if;
--		end loop;
----		y <= bool_to_stdlogic(count > (activeC rsl 1));
--		y <= bool_to_stdlogic(count > 0);
--end process;

end Behavioral;