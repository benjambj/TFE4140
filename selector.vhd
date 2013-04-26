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
signal ab: std_logic;

begin

-- the value of ab is 1 if we have a valid vote for 1 from either a or b
ab <= (mcu(0) or mcu(1)) when (tagged(1) or tagged(0)) = '0' else
	mcu(1) when tagged(1) = '0' else
		mcu(0) when tagged(0) = '0' else '0';

-- the value of cd is 1 if the untagged ones agree on 1
cd <= (mcu(3) and mcu(2)) when (tagged(3) or tagged(2)) = '0' else
	mcu(3) when tagged(3) = '0' else
		mcu(2) when tagged(2) = '0' else '0';

y <=
	-- Hvis cd = '1', s� gjelder enten
	-- 1) cd er enige om 1
	-- 2) cd har gitt en gyldig stemme for 1
	-- Eneste grunn til � ikke gi ut 1, er om grunn 2 er tilfellet og
	-- ab har begge stemt 0
	-- For � gi ut 1, m� alts� enten 1) holde (not (tagged(3) or tagged(2))),
	-- eller s� m� vi ha st�tte fra ab
   not (tagged(3) or tagged(2)) or ab when cd = '1' else
	
	-- Case: ab = '1' og cd = '0'
	-- Hvis ab-semantikk er "ab = '1' <=> minst en gyldig stemme p� 1"
	-- Da kan vi gi ut 1 s� lenge vi ikke har to gyldige stemmer p� 0 fra cd... eller?
	-- Vi har minst 1 gyldig 1-er
	-- 1) Hvis det er 2 gyldige 1-ere, kan vi gi ut 1
	-- 2) Hvis det er bare 1 gyldig 1-er, er det maks 3 uc som fungerer. 
	-- 2.1) Hvis tre fungerer, er de to andre cd, og flertallet avgj�res av om cd ikke gir 2x 0
	-- 2.2) Hvis bare to fungerer og vi har en gyldig 1-er, kan svaret v�re 1
	
	-- S� n�r har cd ikke stemt 2x 0? Hvis de er uenige (kan umulig v�re 2x0), eller en er ugyldig.
	 (mcu(3) xor mcu(2)) or (tagged(3) or tagged(2))  when ab = '1' else -- kan v�re 1 s� lenge det ikke er slik at c og d begge har stemt p� 0 og er gyldige 
			
	-- Hvis ingen lokalvalg gir 1:
	-- Ikke minst en gyldig 1 fra ab
	-- Alts�, ingen gyldig 1 fra ab
	-- Eneste som kan gi 1 flertall da, er 2x1 fra cd, men da hadde cd v�rt 1 og cd er 0
	-- Burde alts� g� � gi ut '0'...
	  '0';

end Behavioral;
