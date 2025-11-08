library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity tb_registers is
end;

architecture test of tb_registers is

  signal CLK      :  std_logic := '0';
  signal RST      :  std_logic;

  constant Period : time := 1 us; -- 1 MHz
  signal DONE : boolean;
  signal test_phase: integer := 0;

  signal RegWr : STD_LOGIC;
  signal busA, busB, busW : std_logic_vector(31 downto 0);
  signal Rw, Ra, Rb : STD_LOGIC_VECTOR(3 downto 0);
begin

  CLK <= '0' when DONE else not CLK after Period / 2;
  RST <= '1', '0' after Period;
  DONE <= true after 1.5 sec;

  Registers : entity work.RegisterBoard port map ( 
    CLK => CLK,
    RESET => RST,
    W => busW,
    RA => Ra,
    RB => Rb,
    RW => Rw,
    WE => RegWr,
    A => busA,
    B => busB
  );

  Stim: process
  begin
    RegWr <= '0';
    Ra <= "0000";
    Rb <= "0000";
    Rw <= "0000";
    wait for 5 ns;

    -- Read first and last cells
    test_phase <= 1;
    Rb <= "1111";
    Ra <= "0000";
    wait for 10 ns;

    -- Write last cell into first cell
    test_phase <= 2;
    busW <= busB;
    RegWr <= '1';
    Rw <= "0000";
    wait for 10 ns;

    -- Read first and last cells again
    test_phase <= 3;
    Rb <= "1111";
    Ra <= "0000";
    wait for 10 ns;

    wait;
  end process;

end architecture;