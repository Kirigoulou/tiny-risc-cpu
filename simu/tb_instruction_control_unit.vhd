library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity tb_instruction_control_unit is
end;

architecture test of tb_instruction_control_unit is

  signal CLK      :  std_logic := '0';
  signal RST      :  std_logic;

  constant Period : time := 1 us; -- 1 MHz
  signal DONE : boolean;
  signal test_phase: integer := 0;

  signal nPCsel : std_logic;
  signal Offset : std_logic_vector(23 downto 0);
  signal Instruction : std_logic_vector(31 downto 0);
begin

  CLK <= '0' when DONE else not CLK after Period / 2;
  RST <= '1', '0' after Period;
  DONE <= true after 1.5 sec;

  InstructionControlUnit : entity work.InstructionControlUnit port map ( 
    CLK => CLK,
    RESET => RST,
    nPCsel => nPCsel,
    Offset => Offset,
    Instruction => Instruction
  );

  Check: process
    type InstructionsList is array (0 to 8) of std_logic_vector(31 downto 0);

    function init_instructions return InstructionsList is
      variable instructions : InstructionsList;
    begin
      instructions(0) := x"E3A01020";
      instructions(1) := x"E3A02000";
      instructions(2) := x"E6110000";
      instructions(3) := x"E0822000";
      instructions(4) := x"E2811001";
      instructions(5) := x"E351002A";
      instructions(6) := x"BAFFFFFB";
      instructions(7) := x"E6012000";
      instructions(8) := x"EAFFFFF7";
      return instructions;
    end init_instructions;

    variable Instructions : InstructionsList := init_instructions;
  begin
    nPCsel <= '0';
    Offset <= (others => '0');
    wait for 5 ns;

    for i in 0 to 8 loop
      wait until rising_edge(CLK);
      wait for 1 ns;
      test_phase <= i;
      report "Starting test for instruction " & integer'image(i);
      assert Instruction = Instructions(i) report "Error on instruction " & integer'image(i);
    end loop;

    report "End of test. Check that no error was reported.";
    wait;
  end process;

end architecture;