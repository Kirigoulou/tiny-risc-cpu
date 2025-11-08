library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegisterBoard is
    port
    (
        CLK        : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        W          : IN STD_LOGIC_VECTOR(31 downto 0);
        RA, RB, RW : IN STD_LOGIC_VECTOR(3 downto 0);
        WE         : IN STD_LOGIC;
        A, B       : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity RegisterBoard;

architecture RTL of RegisterBoard is 
    type table is array(15 downto 0) of std_logic_vector(31 downto 0);

    function init_banc return table is
    variable result : table;
    begin
        for i in 14 downto 0 loop
            result(i) := (others=>'0');
        end loop;
        result(15):=X"00000030";
        return result;
    end init_banc;

    signal Banc: table := init_banc;
begin

process(RA, RB, Banc)
begin
    A <= Banc(TO_INTEGER(UNSIGNED(RA)));
    B <= Banc(TO_INTEGER(UNSIGNED(RB)));
end process;

process(CLK, RESET)
begin
    if RESET = '1' then
        Banc <= init_banc; -- pas sur du tout de ca
    elsif rising_edge(CLK) then
        if WE = '1' then
            Banc(TO_INTEGER(UNSIGNED(RW))) <= W;
        end if;
    end if;
end process;

end architecture;