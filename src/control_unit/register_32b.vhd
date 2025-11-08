library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity Register32b is
    port
    (
        CLK         : IN STD_LOGIC;
        RESET       : IN STD_LOGIC;
        DATAIN      : IN STD_LOGIC_VECTOR(31 downto 0);
        WE          : IN STD_LOGIC;
        DATAOUT     : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity Register32b;

architecture RTL of Register32b is
begin

process(CLK, RESET)
begin
    if RESET = '1' then
        DATAOUT <= (others => '0');
    elsif rising_edge(CLK) then
        if WE = '1' then
            DATAOUT <= DATAIN;
        end if;
    end if;
end process;

end architecture;