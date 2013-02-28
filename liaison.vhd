library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity liaison is	
	generic (
	M: integer := 3
	);
	port (
	clk			: in std_logic;
	mp_data		: in std_logic_vector(3 downto 0);
	reset		: in std_logic;
	di_ready	: in std_logic;
	do_ready	: out std_logic;
	voted_data	: out std_logic);
end entity;

architecture liaison of liaison is	 

signal y_t: std_logic;
signal status_t: std_logic_vector(2 downto 0);

signal do_ready_t: std_logic;
signal voted_data_t: std_logic;

-- Possible solution with state to keep track of what to send
--signal bit_send_stage: std_logic_vector(3 downto 0);
signal bit_send_stage: natural range 0 to 11; -- Need to add M when the error correction is used.

--Or could we store the data in a register, and somehow use less state calculation?
-- Do we have to store the data in a register?

-- Error correction signal - not used yet
--signal ecc: std_logic_vector (M-1 downto 0);

begin			 			  
	
voter : entity work.oving3(oving3) port map (
		a => mp_data(0), b => mp_data(1), c => mp_data(2), d => mp_data(3), 
		clk => clk, rst => reset, y => y_t, status => status_t);
		
with bit_send_stage select 
	voted_data_t <= y_t when 0 to 8,
	status_t(2) when 9,
	status_t(1) when 10,
	status_t(0) when 11;
	
do_ready_t <= di_ready;	   

-- Just route it directly?
voted_data <= voted_data_t;

-- By making this output clocked, we introduce an extra delay from one-bit voter output...
-- We need the clock to update the bit-sending state here, but we can just route the voted data 
-- directly to the output without the clock, right? 
-- Hmm, but the reset has to be synchronous...
-- But this is handled by the one-bit voter?
process (clk, reset) is
begin		
	if clk'event and clk = '1' then
		if reset = '1' then -- or is this handled by 1-bit voters?
			do_ready <= '0';  
			bit_send_stage <= 0;
		else
			do_ready <= do_ready_t;	   
			if bit_send_stage = 11 then
				bit_send_stage <= 0;
			elsif bit_send_stage /= 0 or di_ready='1' then
				bit_send_stage <= bit_send_stage + 1;
			end if;				
		end if;
	end if;
end process;
	
end architecture;