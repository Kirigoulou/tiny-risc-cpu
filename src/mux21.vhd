LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity MUX21 is generic(N : positive := 32);
    port (
        A, B : IN STD_LOGIC_VECTOR(N - 1 downto 0);
        COM  : IN STD_LOGIC;
        S    : OUT STD_LOGIC_VECTOR(N - 1 downto 0)
    );
end entity;

architecture dataflow of MUX21 is
begin
    S <= A when COM = '0' else B;
end architecture;