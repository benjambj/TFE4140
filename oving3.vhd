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
signal fails: std_logic_vector(3 downto 0) := "0000";
signal t_fails : std_logic_vector(3 downto 0) := "0000";
signal y_t: std_logic := '0';
signal status_t: std_logic_vector(2 downto 0) := "000";

begin
	
with fails select
	y_t <= 	(a and b) or (c and d) when "0000",
			(b and c) or (b and d) or (c and d) when "0001",
			(a and c) or (a and d) or (c and d) when "0010",
			(a and b) or (a and d) or (b and d) when "0100",
			(a and b) or (a and c) or (b and c) when "1000",
			(c and d) when "0011",
			(b and d) when "0101",
			(b and c) when "1001",
			(a and d) when "0110",
			(a and c) when "1010",
			(a and b) when "1100",
	 		'0' when others;

			 
t_fails <= fails or ((d xor y_t) & (c xor y_t) & (b xor y_t) & (a xor y_t));

																										
with t_fails select
	status_t <= "000" when "0000",
				"001" when "0001" | "0010" | "0100" | "1000",
	    		"010" when "0011" | "0101" | "1001" | "0110" | "1010" | "1100",
				"111" when others;

state_update: process(clk) is
begin
	if clk'event and clk = '1' then
		if rst = '1' then
			fails <= "0000";
			y <= '0';  
			status <= "000";
		else
			fails <= fails or t_fails;
			y <= y_t;		   
			status <= status_t;
		end if;	
    end if;
end process state_update;

end oving3;
