entity liaison
is
generic (
         M: integer := 5
        );
port (
         clk        : in std_logic;
         mp_data    : in std_logic_vector(3 downto 0);
         reset      : in std_logic;
         di_ready   : in std_logic;
         do_ready   : out std_logic;
         voted_data : out std_logic
     );
end entity;
