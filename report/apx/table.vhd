with fails select
  y <=  (a and b) or (c and d) when "0000",
        (b and c) or (b and d) or (c and d) when "0001",
        (a and c) or (a and d) or (c and d) when "0010",
        (a and b) or (a and d) or (b and d) when "0100",
        (a and b) or (a and c) or (b and c) when "1000",
        (c and d) when "0011",
        (b and d) when "0101",
        (b and c) when "1001",
        (a and d) when "0110",
        (a and c) when "1010",
        (a and b) when "1100",
              '0' when others;
