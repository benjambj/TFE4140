-------------------------------------------------------------------------------
--
-- Title       : oving3
-- Design      : oving4
-- Author      : Ole Brumm
-- Company     : Hundremeterskogen Dataservice
--
-------------------------------------------------------------------------------
--
-- File        : oving3.vhd
-- Generated   : Fri Feb 15 09:08:16 2013
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity oving3 is
	 port(
		 a : in STD_LOGIC;
		 b : in STD_LOGIC;
		 c : in STD_LOGIC;
		 d : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 y : out STD_LOGIC;
		 status : out STD_LOGIC_VECTOR(2 downto 0)
	     );
end oving3;								  

architecture oving3 of oving3 is  

-- fails(3) == d_failed, fails(2) == c_failed, fails(1) == b_failed, fails(0) == a_failed
-- changed semantics to working instead of fails hahaha
signal working: std_logic_vector(3 downto 0);
signal t_working : std_logic_vector(3 downto 0);
signal y_t: std_logic;
signal status_t: std_logic_vector(2 downto 0);

component selector is
	port ( mcu : in std_logic_vector(3 downto 0);
			 active : in std_logic_vector(3 downto 0);
			 y : out std_logic);
end component;

begin
	
--with working select
--	y_t <= 	(a and b) or (c and d) when "1111",
--				(b and c) or (b and d) or (c and d) when "1110",
--				(a and c) or (a and d) or (c and d) when "1101",
--				(a and b) or (a and d) or (b and d) when "1011",
--				(a and b) or (a and c) or (b and c) when "0111",
--				(c and d) when "1100",
--				(b and d) when "1010",
--				(b and c) when "0110",
--				(a and d) when "1001",
--				(a and c) when "0101",
--				(a and b) when "0011",
--				'0' when others;
sel : component selector
	port map (mcu(0) => a, mcu(1) => b, mcu(2) => c, mcu(3) => d, active => working, y => y_t);

			 
t_working <= working or (((d xor y_t)) & ((c xor y_t)) & ((b xor y_t)) & ((a xor y_t)));

with t_working select				
status_t(0) <= '0' when "0000" | "1100" | "1010" | "0110" | "1001" | "0101" | "0011",
					'1' when others;
					
with t_working select
status_t(1) <= '0' when "0000" | "0001" | "0010" | "0100" | "1000",
					'1' when others;
		
status_t(2) <= status_t(1) and status_t(0);
				
--with t_working select
--	status_t <= "000" when "0000",
--				"001" when "0001" | "0010" | "0100" | "1000",
--	    		"010" when "1100" | "1010" | "0110" | "1001" | "0101" | "0011",
--				"111" when others;

state_update: process(clk) is
begin
	if clk'event and clk = '1' then
		if rst = '1' then
			working <= "0000";
			y <= '0';  
			status <= "000";
		else
			working <= t_working;
			y <= y_t;		   
			status <= status_t;
		end if;	
    end if;
end process state_update;

end oving3;
