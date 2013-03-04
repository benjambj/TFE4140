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

constant bits_in_word: natural := 8;
constant bits_in_status: natural := 3;

constant bits_in_packet_out: natural := bits_in_word + bits_in_status; -- Need to add M when ECC implemented?

signal bit_send_stage: natural range 0 to (bits_in_packet_out); -- Need to add M when the error correction is used.
signal di_internal: std_logic;
signal a,b,c,d: std_logic;

constant final_data_send_stage : natural := bits_in_word;

--Or could we store the data in a register, and somehow use less state calculation?
-- Do we have to store the data in a register?

-- Error correction signal - not used yet
--signal ecc: std_logic_vector (M-1 downto 0);

begin			 			  
	
di_internal <= '1' when di_ready = '1' or (bit_send_stage > 0 and bit_send_stage < 8)
else '0';

a <= mp_data(0) when di_internal = '1' else '0';
b <= mp_data(1) when di_internal = '1' else '0';
c <= mp_data(2) when di_internal = '1' else '0';
d <= mp_data(3) when di_internal = '1' else '0';
	
voter : entity work.oving3(oving3) port map (
		a => a, b => b, c => c, d => d,
		clk => clk, rst => reset, y => y_t, status => status_t);
		
with bit_send_stage select 
	voted_data_t <= y_t when 0 to final_data_send_stage,
					status_t(2) when final_data_send_stage + 1,
					status_t(1) when final_data_send_stage + 2,
					status_t(0) when final_data_send_stage + 3;
				
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
			if di_ready='1' then
				bit_send_stage <= 1;
			elsif bit_send_stage = (bits_in_packet_out) then
				bit_send_stage <= 0;
			elsif bit_send_stage /= 0 then
				bit_send_stage <= bit_send_stage + 1;
			end if;				
		end if;
	end if;
end process;
	
end architecture;