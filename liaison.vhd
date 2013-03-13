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

--signal do_ready_t: std_logic;
signal voted_data_t: std_logic;

-- Possible solution with state to keep track of what to send
--signal bit_send_stage: std_logic_vector(3 downto 0);

constant bits_in_word: natural := 8;
constant bits_in_status: natural := 3;

constant bits_in_packet_out: natural := bits_in_word + bits_in_status; -- Need to add M when ECC implemented?

--signal bit_send_stage: natural range 0 to (bits_in_packet_out); -- Need to add M when the error correction is used.
signal input_active: std_logic;
--signal a,b,c,d: std_logic;

constant final_data_send_stage : natural := bits_in_word - 1;

constant cycle_delay : integer := 0;

--Or could we store the data in a register, and somehow use less state calculation?
-- Do we have to store the data in a register?

-- Error correction signal - not used yet
--signal ecc: std_logic_vector (M-1 downto 0);

-- Keeps track of which state is active
signal state_active: std_logic_vector(bits_in_packet_out - 1 downto 0);

--signal data_stage: std_logic;

signal status_bit: std_logic;

signal mp_data_reg: std_logic_vector(3 downto 0);

signal input_active_reg: std_logic;

begin			 			  
	
--input_active <= '1' when di_ready = '1' or (bit_send_stage > 0 and bit_send_stage < 8)
--else '0';

--latch
--input_active <= '1' when di_ready = '1' else
--					 '0' when state_active(final_data_send_stage) = '1';
--					 else unaffected;

--a <= mp_data(0) when di_internal = '1' else '0';
--b <= mp_data(1) when di_internal = '1' else '0';
--c <= mp_data(2) when di_internal = '1' else '0';
--d <= mp_data(3) when di_internal = '1' else '0';
	
voter : entity work.oving3(oving3) port map (
		a => mp_data_reg(0), b => mp_data_reg(1), c => mp_data_reg(2), d => mp_data_reg(3), active => input_active,
		clk => clk, rst => reset, y => y_t, status => status_t);
		
--with bit_send_stage select 
--	voted_data_t <= y_t when 0 to final_data_send_stage,
--					status_t(2) when final_data_send_stage + 1,
--					status_t(1) when final_data_send_stage + 2,
--					status_t(0) when final_data_send_stage + 3;
			
status_bit <= status_t(1) when state_active(final_data_send_stage + 2) = '1' else
				  status_t(0) when state_active(final_data_send_stage + 3) = '1' else
				 '0';
			
-- If status_t(2) = '1', then the other status bits are also 1
-- or-ing is therefore safe
voted_data_t <= y_t when input_active_reg = '1' else
					 status_bit or status_t(2);

--do_ready_t <= di_ready;	   

-- Just route it directly?
voted_data <= voted_data_t;

input_active_reg <= input_active;

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
--			bit_send_stage <= 0;
			state_active <= (others => '0');
			input_active <= '0';
--			input_active_reg <= '0';
			mp_data_reg <= (others => '0');
		else
			mp_data_reg <= mp_data;
			
--			input_active_reg <= input_active;
			state_active(0) <= di_ready;
			for i in 1 to bits_in_packet_out - 1 loop
				state_active(i) <= state_active(i-1);
			end loop;
			
			--do_ready <= state_active(0);
			do_ready <= di_ready;
			
			if di_ready = '1' then
				input_active <= '1';
			elsif state_active(final_data_send_stage - cycle_delay) = '1' then
				input_active <= '0';
			end if;
			
--			do_ready <= do_ready_t;
--			if di_ready='1' then
--				bit_send_stage <= 1;
--			elsif bit_send_stage = (bits_in_packet_out) then
--				bit_send_stage <= 0;
--			elsif bit_send_stage /= 0 then
--				bit_send_stage <= bit_send_stage + 1;
--			end if;				
		end if;
	end if;
end process;
	
end architecture;