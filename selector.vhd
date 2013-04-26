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
--signal use_ab: std_logic;
--signal use_cd: std_logic;
signal ab: std_logic;

begin

-- If MCU 0 and 1 is both untagged and they agree on output,
-- we can use MCU 0 as output
--use_ab <= not (tagged(1) or tagged(0) or (mcu(1) xor mcu(0)));
--use_cd <= not (tagged(3) or tagged(2) or (mcu(3) xor mcu(2)));

--ab <= (mcu(0) and not tagged(0)) or (mcu(1) and not tagged(1));
-- Previous functioning, 5 LUTs
--ab <= mcu(1) when tagged(1) = '0' else
--		mcu(0) when tagged(0) = '0' else '0';

ab <= (mcu(0) or mcu(1)) when (tagged(1) or tagged(0)) = '0' else
	mcu(1) when tagged(1) = '0' else
		mcu(0) when tagged(0) = '0' else '0';

-- else we must choose one of the other signals
--Previous functioning, 5 LUTs
--cd <= (mcu(3) and not tagged(3)) or (mcu(2) and not tagged(2));
--


cd <= (mcu(3) and mcu(2)) when (tagged(3) or tagged(2)) = '0' else
	mcu(3) when tagged(3) = '0' else
		mcu(2) when tagged(2) = '0' else '0';

y <=
	-- Hvis cd = '1'
	-- 1) cd er enige om 1
	-- 2) cd har gitt en gyldig stemme for 1
	-- Eneste grunn til å ikke gi ut 1, er om grunn 2 er tilfellet og
	-- ab har begge stemt 0
	-- For å gi ut 1, må altså enten 1) holde (not (tagged(3) or tagged(2))),
	-- eller så må vi ha støtte fra ab
	-- Støtte fra ab enten hvis ab stemmer 1, eller hvis ab er uenige
	-- Hvis ab er uenige, må resultatet være 1 vel...
	-- Hvis ab gir 1 om noen stemmer 1, kan vi her gi ut ab vel.. nei, ab kan være ugyldige og gi 0.
   not (tagged(3) or tagged(2)) or ab when cd = '1' else
	-- Vi vet at cd = 0
	-- 1) cd er uenige, men fungerer: Vi kan bruke ab
	-- 2) cd er enige om 0: Resultatet kan være 0
	-- 3) cd har en stemme 0: Vi kan bruke ab
	-- 4) cd er ugyldige: Vi kan bruke ab
	-- Så når er cd enige om 0? c = d og ingen tagged
	-- Vi kan finne ut at ingen er tagged
	-- Hvis ingen er tagged, gjelder 1) eller 2)
	-- Enten må vi bruke ab, eller så er svaret 0
	-- Dette strider hvis ab = 1, som her, så vi kan ikke bare kjøre ut ab
	-- 
	
	
	-- Hvis ab-semantikk er "ab = '1' <=> minst en gyldig stemme på 1"
	-- Da kan vi gi ut 1 så lenge vi ikke har to gyldige stemmer på 0 fra cd... eller?
	-- Vi har minst 1 gyldig 1-er
	-- 1) Hvis det er 2 gyldige 1-ere, kan vi gi ut 1
	-- 2) Hvis det er bare 1 gyldig 1-er, er det maks 3 uc som fungerer. 
	-- 2.1) Hvis tre fungerer, er de to andre cd, og flertallet avgjøres av om cd ikke gir 2x 0
	-- 2.2) Hvis bare to fungerer og vi har en gyldig 1-er, kan svaret være 1
	
	-- Så når har cd ikke stemt 2x 0? Hvis de er uenige (kan umulig være 2x0), eller en er ugyldig.
	 (mcu(3) xor mcu(2)) or (tagged(3) or tagged(2))  when ab = '1' else -- kan være 1 så lenge det ikke er slik at c og d begge har stemt på 0 og er gyldige 
			
	-- Hvis ingen lokalvalg gir 1:
	-- Ikke 2x 1 eller 1 gyldig 1 fra cd
	-- Ikke minst en gyldig 1 fra ab
	-- Altså, ingen gyldig 1 fra ab
	-- Eneste som kan gi 1 flertall da, er 2x1 fra cd, men det går ikke
	-- Burde altså gå å gi ut '0'...
	  '0';

--cd and not (tagged(3) or tagged(2)) or ab and not (tagged(1) or tagged(0))

--y <= '1' when ab 

--y <= cd when (cd xor ab) = '0' else
--	  ab when (tagged(0) or tagged(1)) = '0' else
--	  cd when (mcu(3) xor mcu(2)) = '0' else
--	  ..

--
--y <= ab when (mcu(2) xor mcu(3)) = '1' else
--	  cd when (tagged(3) or tagged(2)) = '0' else
--	  cd or ab;


--Previous functioning, 5 LUTs
--y <= ab when use_ab = '1' else
--	  cd when (mcu(3) xor mcu(2)) = '0' else --use_cd = '1' else
--	  ab;

--y <= ab when (ab xor cd) = '0' else
--	  cd when (mcu(1) xor mcu(0)) = '1' else
--	  ab when (mcu(3) xor mcu(2)) = '1' else
--	  cd or ab;

--y <= ab when (mcu(3) xor mcu(2)) = '1' or (tagged(3) and tagged(2)) else
--	  cd;

end Behavioral;
