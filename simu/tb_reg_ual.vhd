library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity tb_reg_ual is
end;

architecture test of tb_reg_ual is

  signal CLK      :  std_logic := '0';
  signal RST      :  std_logic;

  constant Period : time := 1 us; -- 1 MHz
  signal DONE : boolean;
  signal test_phase: integer := 0;

  signal RegWr : STD_LOGIC;
  signal busA, busB, busW : std_logic_vector(31 downto 0);
  signal OP : STD_LOGIC_VECTOR(2 downto 0);
  signal Rw, Ra, Rb : STD_LOGIC_VECTOR(3 downto 0);
  signal N, Z, C, V : std_logic;

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

  UAL : entity work.UAL port map (
    OP => OP,
    A => busA,
    B => busB,
    S => busW,
    N => N,
    Z => Z,
    C => C,
    V => V
  );

  Stim: process
  begin
    RegWr <= '0';
    Ra <= "0000";
    Rb <= "0000";
    Rw <= "0000";
    OP <= "000";
    wait for Period;

    -- R(1) = R(15)
    test_phase <= 1;
    Rb <= "1111";
    Ra <= "0001";
    wait for 10 ns;
    -- W <= busW;
    OP <= "001";
    wait for 10 ns;
    Rw <= "0001"; -- R1
    RegWr <= '1';
    wait until rising_edge(CLK);
    wait for 5 ns;
    RegWr <= '0';
    wait for 10 ns;

    -- R(1) = R(1) + R(15)
    test_phase <= 2;
    Rb <= "1111";
    Ra <= "0001";
    wait for 10 ns;
    OP <= "000";
    wait for 10 ns;
    Rw <= "0001"; -- R1
    RegWr <= '1';
    wait until rising_edge(CLK);
    wait for 5 ns;
    RegWr <= '0';

    -- R(2) = R(1) + R(15)
    test_phase <= 3;
    Rb <= "1111";
    Ra <= "0001";
    wait for 10 ns;
    OP <= "000";
    wait for 10 ns;
    Rw <= "0010"; -- R2
    RegWr <= '1';
    wait until rising_edge(CLK);
    wait for 5 ns;
    RegWr <= '0';

    -- R(3) = R(1) - R(15)
    test_phase <= 4;
    Rb <= "1111";
    Ra <= "0001";
    wait for 10 ns;
    OP <= "010";
    wait for 10 ns;
    Rw <= "0011"; -- R3
    RegWr <= '1';
    wait until rising_edge(CLK);
    wait for 5 ns;
    RegWr <= '0';

    -- R(5) = R(7) - R(15)
    test_phase <= 5;
    Rb <= "1111";
    Ra <= "0111";
    wait for 10 ns;
    OP <= "010";
    wait for 10 ns;
    Rw <= "0101"; -- R5
    RegWr <= '1';
    wait until rising_edge(CLK);
    wait for 5 ns;
    RegWr <= '0';

    wait;
  end process;

  Check: process
  begin
    wait until test_phase = 1;
    wait for 20 ns;
    report "Starting test 1: R(1) = R(15)";
    assert N = '0' report "Error on N Flag" severity warning;
    assert Z = '0' report "Error on N Flag" severity warning;
    assert C = '0' report "Error on N Flag" severity warning;
    assert V = '0' report "Error on N Flag" severity warning;
    assert busW = busB report "Error on OP 001: Y = B" severity warning;

    wait until test_phase = 2;
    wait for 20 ns;
    report "Starting test 2: R(1) = R(1) + R(15)";
    assert N = '0' report "Error on N Flag" severity warning;
    assert Z = '0' report "Error on N Flag" severity warning;
    assert C = '0' report "Error on N Flag" severity warning;
    assert V = '0' report "Error on N Flag" severity warning;
    assert busW = x"00000060" report "Error on OP 000: Y = A + B" severity warning;

    wait until test_phase = 3;
    wait for 20 ns;
    report "Starting test 3: R(2) = R(1) + R(15)";
    assert N = '0' report "Error on N Flag" severity warning;
    assert Z = '0' report "Error on N Flag" severity warning;
    assert C = '0' report "Error on N Flag" severity warning;
    assert V = '0' report "Error on N Flag" severity warning;
    assert busW = x"00000090" report "Error on OP 000: Y = A + B" severity warning;
    
    wait until test_phase = 4;
    wait for 20 ns;
    report "Starting test 4: R(3) = R(1) - R(15)";
    assert N = '0' report "Error on N Flag" severity warning;
    assert Z = '0' report "Error on N Flag" severity warning;
    assert C = '0' report "Error on N Flag" severity warning;
    assert V = '0' report "Error on N Flag" severity warning;
    assert busW = x"00000030" report "Error on OP 010: Y = A - B" severity warning;

    wait until test_phase = 5;
    wait for 20 ns;
    report "Starting test 5: R(5) = R(7) - R(15)";
    assert N = '1' report "Error on N Flag" severity warning;
    assert Z = '0' report "Error on N Flag" severity warning;
    assert C = '1' report "Error on N Flag" severity warning;
    assert V = '0' report "Error on N Flag" severity warning;
    assert busW = x"FFFFFFD0" report "Error on OP 000: Y = A + B" severity warning;
    
    report "End of test. Check that no error was reported.";
    wait;
  end process;

end architecture;