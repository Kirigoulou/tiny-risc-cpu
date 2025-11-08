library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity tb_cpu is
end;

architecture test of tb_cpu is

  signal CLK      :  std_logic := '0';
  signal RST      :  std_logic;

  constant Period : time := 1 us; -- 1 MHz
  signal DONE : boolean;
  signal test_phase: integer := 0;

  signal DisplayOutput : std_logic_vector(31 downto 0);

begin

  CLK <= '0' when DONE else not CLK after Period / 2;
  RST <= '1', '0' after Period;
  DONE <= true after 1.5 sec;

  CPU: entity work.CPU
   port map(
      CLK => CLK,
      RESET => RST,
      DisplayOutput => DisplayOutput
  );

end architecture;