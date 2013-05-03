library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.custom_func.all;
 
entity selector is
	Generic (N: Natural := 4);
    Port ( mcu : in  STD_LOGIC_VECTOR(N-1 downto 0);
			  tagged : in  STD_LOGIC_VECTOR(N-1 downto 0);
           y : out  STD_LOGIC
);

end selector;

architecture Behavioral of selector is

signal cd: std_logic;
signal ab: std_logic;
signal use_ab: std_logic;

signal t: std_logic;

signal t1,t2,t3,t4,t5: std_logic_vector(3 downto 0);

begin

-- If MCU 0 and 1 is both untagged and they agree on output,
-- we can use MCU 0 as output
--use_ab <= not (tagged(1) or tagged(0) or (mcu(1) xor mcu(0)));
t1 <= tagged(1)& tagged(0) & mcu(1) & mcu(0);
--with tagged(1) & tagged(0) & mcu(1) & mcu(0) 

with t1 select
use_ab <= '1' when "0000" | "0011",
			 '0' when others;
					
--use_cd <= not (tagged(3) or tagged(2) or (mcu(3) xor mcu(2)));

--ab <= (mcu(0) and not tagged(0)) or (mcu(1) and not tagged(1));
--ab <= mcu(1) and mcu(0) when (tagged(0) or tagged(1)) = '0' else
--		mcu(1) when tagged(1) = '0' else
--		mcu(0) and not tagged(0);

with t1 select
ab <= '1' when "0011" | "1001" | "0110",
	    '0' when others;

-- else we must choose one of the other signals
-- cd <= (mcu(3) and not tagged(3)) or (mcu(2) and not tagged(2));
--cd <= mcu(3) and mcu(2) when (tagged(3) or tagged(2)) = '0' else
--		mcu(3) when tagged(3) = '0' else
--		mcu(2) and not tagged(2);
t2 <= tagged(3) & tagged(2) & mcu(3) & mcu(2);
with t2 select
cd <= '1' when "0011" | "1001" | "0110",
	   '0' when others;


--
--y <= ab when (mcu(2) xor mcu(3)) = '1' else
--	  cd when (tagged(3) or tagged(2)) = '0' else
--	  cd or ab;

t <= mcu(3) xor mcu(2);


--y <= ab when use_ab = '1' else
--	  cd when t = '0' else --use_cd = '1' else
--	  cd or ab;

t3 <= use_ab & ab & cd & t;

with t3 select
y <= '0' when "1000" | "1001" | "1010" | "1011" | "0001" | "0101" | "1101" | "0000" ,
	   '1' when others;
--y <= '0' when "1000" | "1001" | "1101" | "1111" | "0001" | "0011" | "1001" | "1011" | "

--y <= ab when (ab xor cd) = '0' else
--	  cd when (mcu(1) xor mcu(0)) = '1' else
--	  ab when (mcu(3) xor mcu(2)) = '1' else
--	  cd or ab;

--y <= ab when (mcu(3) xor mcu(2)) = '1' or (tagged(3) and tagged(2)) else
--	  cd;

end Behavioral;
