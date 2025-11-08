library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProgramCounter is
    port
    (
        CLK        : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        NewPC      : IN STD_LOGIC_VECTOR(31 downto 0);
        PC         : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity ProgramCounter;

architecture RTL of ProgramCounter is
    constant instructionsMaxCount : integer := 64;
begin
process(CLK, RESET)
begin
    if RESET = '1' then
        PC <= (others => '0');
    elsif rising_edge(CLK) then
        if to_integer(unsigned(newPC)) < instructionsMaxCount then
            PC <= NewPC;
        end if;
    end if;
end process;

end architecture;