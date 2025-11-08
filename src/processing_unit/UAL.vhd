LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity UAL is
    port
    (
        OP         : IN STD_LOGIC_VECTOR(2 downto 0);
        A, B       : IN STD_LOGIC_VECTOR(31 downto 0);
        S          : OUT STD_LOGIC_VECTOR(31 downto 0);
        N, Z, C, V : OUT STD_LOGIC
    );
end entity UAL;

architecture RTL of UAL is
    
begin

process(OP, A, B)
    variable A_SIGNED, B_SIGNED       : SIGNED(31 downto 0);
    variable A_UNSIGNED, B_UNSIGNED   : UNSIGNED(31 downto 0);
    variable RES_SIGNED               : SIGNED(32 downto 0);
    variable RES_UNSIGNED             : UNSIGNED(32 downto 0);
    variable S_VAR                    : STD_LOGIC_VECTOR(31 downto 0);
begin
    C <= '0';
    V <= '0';
    Z <= '0';

    A_SIGNED := SIGNED(A);
    B_SIGNED := SIGNED(B);

    A_UNSIGNED := UNSIGNED(A);
    B_UNSIGNED := UNSIGNED(B);

    case OP is
    when "000" =>
        RES_SIGNED := ('0' & A_SIGNED) + ('0' & B_SIGNED);
        RES_UNSIGNED := ('0' & A_UNSIGNED) + ('0' & B_UNSIGNED); 
        S_VAR := STD_LOGIC_VECTOR(RES_SIGNED(31 downto 0));
        C <= RES_UNSIGNED(32);
    when "001" =>
        S_VAR := B;
    when "010" =>
        RES_SIGNED := ('0' & A_SIGNED) - ('0' & B_SIGNED);
        RES_UNSIGNED := ('0' & A_UNSIGNED) - ('0' & B_UNSIGNED); 
        S_VAR := STD_LOGIC_VECTOR(RES_SIGNED(31 downto 0));
        C <= RES_UNSIGNED(32);
    when "011" =>
        S_VAR := A;
    when "100" =>
        S_VAR := A or B;
    when "101" =>
        S_VAR := A and B;
    when "110" =>
        S_VAR := A xor B;
    when "111" =>
        S_VAR := not A;
    when others => 
        S_VAR := (others => '0');
    end case;

    S <= S_VAR;
    N <= S_VAR(31);
    if S_VAR = (31 downto 0 => '0') then
        Z <= '1';
    end if;

    if OP = "000" then
        if (A_SIGNED(31) = B_SIGNED(31)) and (RES_SIGNED(31) /= A_SIGNED(31)) then
        V <= '1';
        end if;
    elsif OP = "010" then
        if (A_SIGNED(31) /= B_SIGNED(31)) and (RES_SIGNED(31) /= A_SIGNED(31)) then
        V <= '1';
        end if;
    end if;
end process;

end architecture;