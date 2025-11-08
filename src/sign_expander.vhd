library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExpander is generic (N : positive := 8);
    port
    (
        E : in std_logic_vector(N - 1 downto 0);
        S : out std_logic_vector(31 downto 0)
    );
end entity SignExpander;

architecture RTL of SignExpander is
begin
    S <= std_logic_vector(resize(signed(E), 32));
end architecture;