library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity liaison is	
	generic (
	M: integer := 5
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


-- We define a lot of constants to help readability and understandability of
-- the rest of the code
constant bits_in_word: natural := 8;
constant bits_in_status: natural := 3;

constant bits_in_data: natural := bits_in_word + bits_in_status;

constant bits_in_packet_out: natural := bits_in_data + M; -- Need to add M when ECC implemented?

constant cycle_delay : integer := 0;


-- This constant tells what cycle after di is the last where real data is sendt
constant final_data_send_stage : natural := bits_in_word + cycle_delay - 1;

-- Error correction signal - not used yet
--signal ecc: std_logic_vector (M-1 downto 0);

-- Enable input?
signal input_active: std_logic;

-- The total number of states for sending data
constant number_of_states : natural := bits_in_packet_out + cycle_delay;

-- Keeps track of which state is active
signal state_active: std_logic_vector(number_of_states - 1 downto 0);

-- Temp.signal to hold current status bit, if in appropriate state
signal status_bit: std_logic;

-- Microprocessor data register, in order to keep values stable
-- during the entire clock cycle
signal mp_data_reg: std_logic_vector(3 downto 0);

signal par_enable: std_logic_vector(M-2 downto 0);
signal par: std_logic_vector(M-1 downto 0);
signal voted_data_t: std_logic;
signal out_data: std_logic;

signal should_output_parity_bits: std_logic;
signal par_bit: std_logic;

signal sa_03610, sa_78910: std_logic;

begin			 			  

voter : entity work.oving3(oving3) port map (
		a => mp_data_reg(0), b => mp_data_reg(1),
                c => mp_data_reg(2), d => mp_data_reg(3),
                active => input_active, clk => clk, rst => reset,
                y => y_t, status => status_t);

-- Temporary result to calculate current status bit,
-- given we are sending one of the three status bits 
status_bit <=    status_t(1) when state_active(final_data_send_stage + 2) = '1'
              else
		 status_t(0) when state_active(final_data_send_stage + 3) = '1'
              else
		 '0';
			
-- If status_t(2) = '1', then the other status bits are also 1
-- or-ing is therefore safe
voted_data_t <= y_t when input_active = '1' else
					 status_bit or status_t(2);
					
-- Are we supposed to output par(4) first? (Yes)
par_bit <= 	par(4) xor par(3) xor par(2) xor par(1) xor par(0) when state_active(bits_in_data) = '1' else
				par(3) when state_active(bits_in_data + 1) = '1' else
				par(2) when state_active(bits_in_data + 2) = '1' else
				par(1) when state_active(bits_in_data + 3) = '1' else
				par(0);
					
voted_data <= voted_data_t when should_output_parity_bits = '0' else
				  par_bit;
out_data <= voted_data_t;

sa_03610 <= state_active(0) or state_active(3) or state_active(6) or state_active(10);
sa_78910 <= state_active(7) or state_active(8) or state_active(9) or state_active(10);

--par_enable(0) <= sa_03610 or state_active(8);
--par_enable(1) <= sa_03610 or state_active(9);
par_enable(0) <= state_active(1) or state_active(4) or state_active(8) or sa_03610;
par_enable(1) <= state_active(2) or state_active(5) or state_active(9) or sa_03610;
par_enable(2) <= state_active(1) or state_active(2) or state_active(3) or sa_78910;
par_enable(3) <= state_active(4) or state_active(5) or state_active(6) or sa_78910;

--par_enable(0) <= state_active(0) or state_active(1) or state_active(3) or state_active(4) or state_active(6) or state_active(8) or state_active(10);
--par_enable(1) <= state_active(0) or state_active(2) or state_active(3) or state_active(5) or state_active(6) or state_active(9) or state_active(10);
--par_enable(2) <= state_active(1) or state_active(2) or state_active(3) or state_active(7) or state_active(8) or state_active(9) or state_active(10);
--par_enable(3) <= state_active(4) or state_active(5) or state_active(6) or state_active(7) or state_active(8) or state_active(9) or state_active(10);


-- Update registers on rising edge
process (clk, reset) is
begin		
	if clk'event and clk = '1' then
		if reset = '1' then 
			do_ready <= '0';  
			state_active <= (others => '0');
			input_active <= '0';
			mp_data_reg <= (others => '0');
			par <= (others => '0');
			should_output_parity_bits <= '0';
		else
                        -- since we transmit data immediatly,
                        -- we have data output ready as soon as
                        -- data input is ready
			do_ready <= di_ready;

                        -- state_active
			state_active(0) <= di_ready;
			for i in 1 to number_of_states - 1 loop
				state_active(i) <= state_active(i-1);
			end loop;

                        -- input_active
			if di_ready = '1'
                        then
				input_active <= '1';
			elsif state_active(final_data_send_stage - cycle_delay) = '1'
                        then
				input_active <= '0';
			end if;
			
--			for i in 0 to M-2 loop
--				if state_active(bits_in_data+4) = '1' then
--					par(i) <= '0';
--				else
--					if par_enable(i) = '1' then
--						par(i) <= (par(i) xor voted_data_t);
--					end if;
--				end if;
--			end loop;
			
			
		---	if state_active(bits_in_data+4) = '1' then
		--		should_output_parity_bits <= '0';
				--par(4) <= '0';
		--		par <= (others => '0');
		--	else
				if state_active(bits_in_data-1) = '1' then
					should_output_parity_bits <= '1';
				elsif state_active(bits_in_data+4) = '1' then
					should_output_parity_bits <= '0';
				end if;
				--should_output_parity_bits <= state_active(bits_in_data-1) or should_output_parity_bits;
				
				--if par_enable(0) = '1' then
					par(0) <= (par(0) xor (out_data and par_enable(0))) and not state_active(bits_in_data+4);
				--end if;
				--if par_enable(1) = '1' then
					par(1) <= (par(1) xor (out_data and par_enable(1))) and not state_active(bits_in_data+4);
				--end if;
				--if par_enable(2) = '1' then
					par(2) <= (par(2) xor (out_data and par_enable(2))) and not state_active(bits_in_data+4);
				--end if;
				--if par_enable(3) = '1' then
					par(3) <= (par(3) xor (out_data and par_enable(3))) and not state_active(bits_in_data+4);
				--end if;
				par(4) <= (par(4) xor out_data) and not state_active(bits_in_data+4);
				
			--end if;
			
--			elsif state_active(bits_in_data-1) = '1' then
--				should_output_parity_bits <= '1';
--				par(4) <= par(4) xor out_data;
--			else
--				should_output_parity_bits <= should_output_parity_bits;
--				par(4) <= par(4) xor out_data;
--			end if;
			
			mp_data_reg <= mp_data;
      end if;
	end if;
end process;
	
end architecture;

