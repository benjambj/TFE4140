signal amcu : std_logic_vector(N-1 downto 0);
signal anmcu : std_logic_vector(N-1 downto 0);

amcu <= mcu and active;
anmcu <= not mcu and active;

do_selection : process(amcu, anmcu) is
  variable count : integer range 0 to N;
begin
  count := 0;
  for i in N-1 downto 0 loop
    if amcu(i) = '1' then
      count := count + 1;
    elsif anmcu(i) = '1' then
      count := count - 1;
    end if;
  end loop;
  y <= bool_to_stdlogic(count > 0);
end process;
