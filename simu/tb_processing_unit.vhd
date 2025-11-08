library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity tb_processing_unit is
end;

architecture test of tb_processing_unit is

  signal CLK      :  std_logic := '0';
  signal RST      :  std_logic;

  constant Period : time := 1 us; -- 1 MHz
  signal DONE : boolean;
  signal test_phase: integer := 0;

  signal RegWr      : STD_LOGIC;  -- 16x32 register board
  signal MuxRegSel  : STD_LOGIC;  -- Selector for MUX between busB and Immediate
  signal MuxMemSel  : STD_LOGIC;  -- Selector for MUX between ALU and Memory
  signal WrEn       : STD_LOGIC;  -- 64x32 memory board
  signal OP         : STD_LOGIC_VECTOR(2 downto 0);
  signal Rw, Ra, Rb : STD_LOGIC_VECTOR(3 downto 0);
  signal Imm        : STD_LOGIC_VECTOR(7 downto 0);
  signal N, Z, C, V : STD_LOGIC;
  signal OutValue   : STD_LOGIC_VECTOR(31 downto 0);

begin

  CLK <= '0' when DONE else not CLK after Period / 2;
  RST <= '1', '0' after Period;
  DONE <= true after 1.5 sec;

  ProcessingUnit: entity work.ProcessingUnit port map (
    CLK => CLK,
    Reset => RST,
    RegWr => RegWr,
    MuxRegSel => MuxRegSel,
    MuxMemSel => MuxMemSel,
    WrEn => WrEn,
    OP => OP,
    Rw => Rw,
    Ra => Ra,
    Rb => Rb,
    Imm => Imm,
    N => N,
    Z => Z,
    C => C,
    V => V,
    OutValue => OutValue
  );

  Stim: process
  begin
    RegWr <= '0';
    MuxRegSel <= '0';
    MuxMemSel <= '0';
    WrEn <= '0';
    OP <= "000";
    Rw <= "0000";
    Ra <= "0000";
    Rb <= "0000";
    Imm <= "00000000";
    wait for Period;

    -- R(1) + R(15)
    test_phase <= 1;
    Rb <= "1111";
    Ra <= "0001";
    MuxRegSel <= '0'; -- Select register value B instead of Immediate
    wait for 10 ns;
    OP <= "000";
    wait for 10 ns;

    -- R(15) + Imm
    test_phase <= 2;
    Ra <= "1111";
    -- Rb <= "0001";  we do not need this value
    Imm <= x"FF";
    MuxRegSel <= '1'; -- Select Immediate
    wait for 10 ns;
    OP <= "000";
    wait for 10 ns;

    -- R(1) - R(15)
    test_phase <= 3;
    Rb <= "1111";
    Ra <= "0001";
    MuxRegSel <= '0'; -- Select register value B instead of Immediate
    wait for 10 ns;
    OP <= "010";
    wait for 10 ns;

    -- R(15) - Imm
    test_phase <= 4;
    Ra <= "1111";
    -- Rb <= "0001";  we do not need this value
    Imm <= x"30";
    MuxRegSel <= '1'; -- Select Immediate
    wait for 10 ns;
    OP <= "010";
    wait for 10 ns;

    -- R(1) = R(15)
    test_phase <= 5;
    Rb <= "1111";
    Ra <= "0001";
    MuxRegSel <= '0'; -- Select register value B instead of Immediate
    wait for 10 ns;
    OP <= "001";
    wait for 10 ns;
    Rw <= "0001"; -- R1
    RegWr <= '1';
    wait until rising_edge(CLK);
    RegWr <= '0';
    Rb <= "0001"; -- Checking that R(15) (0x00000030) has been written into R(1)
    wait for 10 ns;

    -- Mem(0) = R(15)
    test_phase <= 6;
    Rb <= "1111";
    Ra <= "0000";
    MuxRegSel <= '0'; -- Select register value B instead of Immediate
    MuxMemSel <= '1'; -- Select memory value instead of ALU output
    wait for 10 ns;
    OP <= "011";
    WrEn <= '1';
    wait until rising_edge(CLK);
    WrEn <= '0';
    wait for 10 ns;

    -- R(0) = Mem(0)
    test_phase <= 7;
    -- Rb <= "1111"; This register does not matter
    Ra <= "0000";
    MuxMemSel <= '1'; -- Select memory value instead of ALU output
    wait for 10 ns;
    OP <= "011";
    Rw <= "0000";
    RegWr <= '1';
    wait until rising_edge(CLK);
    RegWr <= '0';
    MuxMemSel <= '0';
    -- Here the output should be equal to 0x00000030 since the ALU returns the value of the cell 0
    -- which is pointed to by Ra and written into previously
    -- Switching the multiplexer allows for retrieving the ALU value instead of the memory output.

    wait;
  end process;

  Check: process
  begin

    wait until test_phase = 1;
    report "Starting test 1: R(1) + R(15)";
    wait for 20 ns;
    -- At first, the cell 15 of the register is the only non zero cell (it is set to 0x00000030 during initialization)
    -- The addition of those two registers should therefore give 0x00000030
    assert OutValue = x"00000030" report "R(1) + R(15) = 0x00000000 + 0x00000030 should be equal to 0x00000030" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '0' report "Expected Z = 0; Got Z = 1";
    assert C = '0' report "Expected C = 0; Got C = 1";
    assert V = '0' report "Expected V = 0; Got V = 1";

    wait until test_phase = 2;
    report "Starting test 2: R(15) + Imm (0xFF)";
    -- A subtle nuance here, the Immediate value's MSB is 1, indicating a negative number.
    -- Since the module expands the Immediate value using sign expansion, we would get, as a result, 0xFFFFFFFF
    -- Which corresponds to -1. Therefore, this addition is equivalent to substracting 1.
    wait for 20 ns;
    assert OutValue = x"0000002F" report "R(15) + Imm = 0x00000030 + 0xFFFFFFFF (-1) should be equal to 0x0000002F" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '0' report "Expected Z = 0; Got Z = 1";
    assert C = '1' report "Expected C = 1; Got C = 0";
    assert V = '0' report "Expected V = 0; Got V = 1";

    wait until test_phase = 3;
    report "Starting test 3: R(1) - R(15)";
    wait for 20 ns;
    assert OutValue = x"FFFFFFD0" report "R(1) - R(15) = 0x00000000 - 0x00000030 should be equal to 0xFFFFFFD0" severity warning;
    assert N = '1' report "Expected N = 1; Got N = 0";
    assert Z = '0' report "Expected Z = 0; Got Z = 1";
    assert C = '1' report "Expected C = 1; Got C = 0";
    assert V = '0' report "Expected V = 0; Got V = 1";

    wait until test_phase = 4;
    report "Starting test 4: R(15) - Imm (0x30)";
    wait for 20 ns;
    assert OutValue = x"00000000" report "R(15) (0x00000030) - Imm (0x30) should be equal to 0x00000000" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '1' report "Expected Z = 1; Got Z = 0";
    assert C = '0' report "Expected C = 0; Got C = 1";
    assert V = '0' report "Expected V = 0; Got V = 1";


    wait until test_phase = 5;
    report "Starting test 5: R(1) = R(15)";
    -- If we look at the Stim process for this test, the UAL first retrieves the value at the register 15,
    -- which is written into the register 1.
    -- This cell's content is then returned by the UAL and can be observed in the OutValue signal.
    wait for 20 ns;
    wait until rising_edge(CLK);
    assert OutValue = x"00000030" report "R(1) = R(15) (0x00000030), R(1) should be equal to 0x00000030" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '0' report "Expected Z = 0; Got Z = 1";
    assert C = '0' report "Expected C = 0; Got C = 1";
    assert V = '0' report "Expected V = 0; Got V = 1";

    wait until test_phase = 6;
    report "Starting test 6: Mem(0) = R(15)";
    -- Same process as the check above. We write the content of register 15 into the memory at index pointed to
    -- by the content of register 0 (which should be 0 because it has never been modified).
    wait for 10 ns;
    wait until rising_edge(CLK);
    wait for 5 ns; -- Small delay to register that the memory has been updated, the testbench starts tweaking otherwise.
    assert OutValue = x"00000030" report "Mem(0) = R(15) (0x00000030), Mem(0) should be equal to 0x00000030" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '1' report "Expected Z = 1; Got Z = 0"; -- During this process, the ALU does Y = A = R(0) = 0
    assert C = '0' report "Expected C = 0; Got C = 1";
    assert V = '0' report "Expected V = 0; Got V = 1";


    wait until test_phase = 7;
    report "Starting test 7: R(0) = Mem(0)";
    -- Roughly the same idea as the testcase 6 but the memory and register are reversed.
    wait for 10 ns;
    wait until rising_edge(CLK);
    assert OutValue = x"00000030" report "R(0) = Mem(0) (0x00000030), R(0) should be equal to 0x00000030" severity warning;
    assert N = '0' report "Expected N = 0; Got N = 1";
    assert Z = '1' report "Expected Z = 1; Got Z = 0"; -- During this process, the ALU does Y = A = R(0) = 0
    assert C = '0' report "Expected C = 0; Got C = 1";
    assert V = '0' report "Expected V = 0; Got V = 1";

    report "End of test. Check that no error was reported.";
    wait;
  end process;

end architecture;