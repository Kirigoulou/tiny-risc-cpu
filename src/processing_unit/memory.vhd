library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity MemoryBoard is
    port
    (
        CLK        : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        DATAIN     : IN STD_LOGIC_VECTOR(31 downto 0);
        ADDR       : IN STD_LOGIC_VECTOR(5 downto 0);
        WE         : IN STD_LOGIC;
        DATAOUT    : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity MemoryBoard;

architecture RTL of MemoryBoard is 
    type table is array(63 downto 0) of std_logic_vector(31 downto 0);

    function init_banc return table is
    variable result : table;
    begin
        for i in 63 downto 0 loop
            result(i) := (others=>'0');
        end loop;

        for i in 32 to 42 loop
            result(i) := std_logic_vector(to_unsigned(i - 32, 32));
        end loop;
        -- result(15):=X"00000030";
        return result;
    end init_banc;

    signal Banc: table := init_banc;
begin

process(ADDR, Banc)
begin
    DATAOUT <= Banc(TO_INTEGER(UNSIGNED(ADDR)));
end process;

process(CLK, RESET)
begin
    if RESET = '1' then
        Banc <= init_banc; -- pas sur du tout de ca
    elsif rising_edge(CLK) then
        if WE = '1' then
            Banc(TO_INTEGER(UNSIGNED(ADDR))) <= DATAIN;
        end if;
    end if;
end process;

end architecture;