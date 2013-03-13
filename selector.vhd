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
signal use_ab: std_logic;

begin

-- If MCU 0 and 1 is both untagged and they agree on output, we can use MCU 0 as output
use_ab <= not (tagged(1) or tagged(0) or (mcu(1) xor mcu(0)));

-- else we must choose one of the other signals
cd <= mcu(3) and mcu(2) when tagged(3) = '0' and tagged(2) = '0' else
      mcu(3) when tagged(3) = '0' else
		mcu(2);
--		'0'; Cannot assume 0?

y <= mcu(0) when use_ab = '1' else
	  cd;

end Behavioral;
