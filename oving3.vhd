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

                 -- Active is set if error tagging is enabled
		 active: in STD_LOGIC;
		 clk : in STD_LOGIC;
		 
                 -- rst is the reset signal
                 rst : in STD_LOGIC;
		 y : out STD_LOGIC;
		 status : out STD_LOGIC_VECTOR(2 downto 0)
	     );
end oving3;								  

architecture oving3 of oving3 is  

-- fails(3) == d_failed, fails(2) == c_failed, fails(1) == b_failed, fails(0) == a_failed
signal error_tags: std_logic_vector(3 downto 0);
signal t_error_tags : std_logic_vector(3 downto 0);
signal y_t: std_logic;
signal status_t: std_logic_vector(2 downto 0);

component selector is
	port ( mcu : in std_logic_vector(3 downto 0);
			 active : in std_logic_vector(3 downto 0);
			 y : out std_logic);
end component;

begin

    sel : component selector
	port map (mcu(0) => a, mcu(1) => b, mcu(2) => c, mcu(3) => d, tagged => error_tags, y => y_t);

			 
-- This is where the error tags are calculated by comparing mcu's output against voted output
t_error_tags <= error_tags or ((active and (d xor y_t)) & (active and (c xor y_t)) & (active and (b xor y_t)) & (active and (a xor y_t)));

-- Set current status based on what mcu's are still error_tags
with t_error_tags select
	status_t <= "000" when "0000",
				"001" when "0001" | "0010" | "0100" | "1000",
	    		"010" when "1100" | "1010" | "0110" | "1001" | "0101" | "0011",
				"111" when others;

-- Since y is output, and we need its value, we also need
-- a signal attached to it
y <= y_t;

-- On rising edge, send output
state_update: process(clk) is
begin
	if clk'event and clk = '1' then
		if rst = '1' then
			error_tags <= "0000";
			status <= "000";
		else
			error_tags <= t_error_tags;
			status <= status_t;
		end if;	
    end if;
end process state_update;

end oving3;
