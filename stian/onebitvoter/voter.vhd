----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:48 02/04/2013 
-- Design Name: 
-- Module Name:    voter - Behavioral 
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
use work.custom_func.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity voter is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           c : in  STD_LOGIC;
           d : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           y : out  STD_LOGIC;
           status : out  STD_LOGIC_VECTOR (2 downto 0)
);
end voter;

architecture Behavioral of voter is

signal working : std_logic_vector(3 downto 0);
signal next_working : std_logic_vector(3 downto 0);
signal tmp_working : std_logic_vector(3 downto 0);

signal num_working : integer range 0 to 4;

signal internal_voted : std_logic;

component selector is
    Port ( mcu : in  STD_LOGIC_VECTOR(3 downto 0);
			  active : in  STD_LOGIC_VECTOR(3 downto 0);
           y : out  STD_LOGIC
);
end component;

begin

sel: component selector
	port map (
		mcu(0)=> a,
		mcu(1)=> b,
		mcu(2)=> c,
		mcu(3)=> d,
		active=> working,
		y=> internal_voted
	);



vote : process(clk, internal_voted)
begin
	if rising_edge(clk) then
		if reset = '1' then
			y <= '0';
		else
			y <= internal_voted;
		end if;
	end if;
end process;

work: process(reset, working, a, b, c, d, internal_voted) is
begin
	if reset = '1' then
		next_working <= (others => '1');
	else
		next_working(0) <= working(0) and bool_to_stdlogic(a = internal_voted);
		next_working(1) <= working(1) and bool_to_stdlogic(b = internal_voted);
		next_working(2) <= working(2) and bool_to_stdlogic(c = internal_voted);
		next_working(3) <= working(3) and bool_to_stdlogic(d = internal_voted);
	end if;
end process;

process(clk, working, next_working) begin
	tmp_working <= next_working and working;
end process;

process(next_working) is
	VARIABLE count : integer range 0 to 4;
begin
			count := 0;
			for i in 3 downto 0 loop
				if next_working(i) = '1' then
					count := count + 1;
				end if;
			end loop;
			num_working <= count;
end process;

calc_status : process(clk, reset, tmp_working)
begin
	if rising_edge(clk) then
		if (reset = '1') then
			status <= "000";
			working <= (others => '1');
		else
			working <= tmp_working;
			case num_working is
				when 4 => 		status <= "000";
				when 3 => 		status <= "001";
				when 2 => 		status <= "010";
				when others => status <= "111";
			end case;
		end if;
	end if;
end process;

end Behavioral;

