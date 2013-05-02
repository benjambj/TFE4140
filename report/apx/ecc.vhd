function gen_ecc
( d: std_logic_vector(7 downto 0);
  s: std_logic_vector(2 downto 0)
)
return std_logic_vector
is
  variable ecc : std_logic_vector(4 downto 0);
  variable w : std_logic_vector(0 to 10);
begin
  w := d & s;
  ecc(0) := w(0) xor w(1) xor w(3) xor w(4) xor w(6) xor w(8) xor w(10);
  ecc(1) := w(0) xor w(2) xor w(3) xor w(5) xor w(6) xor w(9) xor w(10);
  ecc(2) := w(1) xor w(2) xor w(3) xor w(7) xor w(8) xor w(9) xor w(10);
  ecc(3) := w(4) xor w(5) xor w(6) xor w(7) xor w(8) xor w(9) xor w(10);
  ecc(4) := w(0) xor w(1) xor w(2) xor w(3) xor w(4) xor w(5) xor
            w(6) xor w(7) xor w(8) xor w(9) xor w(10) xor
            ecc(0) xor ecc(1) xor ecc(2) xor ecc(3);
  assert false
    report "(11,15)-Hamming for " & to_string(w) & " is " & to_string(ecc)
    severity note;
  return ecc;
end function;

