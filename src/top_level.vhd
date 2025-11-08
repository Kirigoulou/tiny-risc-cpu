LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity TopLevel is
    port
    (
        CLK        : IN STD_LOGIC;
        KEY		   :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		SW 		   :  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        HEX0       :  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX1       :  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX2       :  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX3       :  OUT  STD_LOGIC_VECTOR(0 TO 6)
    );
end entity TopLevel;

architecture RTL of TopLevel is
    signal POL, RESET : std_logic;
    signal DisplayOutput : std_logic_vector(31 downto 0);
begin

RESET <= not KEY(0);
POL <= SW(9);

CPU: entity work.CPU
port map(
    CLK => CLK,
    RESET => RESET,
    DisplayOutput => DisplayOutput
);

Seg0 : entity work.SEVEN_SEG port map (
    Data => DisplayOutput(3 downto 0),
    Pol => POL,
    Segout => HEX0
);

Seg1 : entity work.SEVEN_SEG port map (
    Data => DisplayOutput(7 downto 4),
    Pol => POL,
    Segout => HEX1
);

Seg2 : entity work.SEVEN_SEG port map (
    Data => DisplayOutput(11 downto 8),
    Pol => POL,
    Segout => HEX2
);

Seg3 : entity work.SEVEN_SEG port map (
    Data => DisplayOutput(15 downto 12),
    Pol => POL,
    Segout => HEX3
);

end architecture;