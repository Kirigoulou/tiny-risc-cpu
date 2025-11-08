library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionControlUnit is
    port
    (
        CLK         : IN STD_LOGIC;
        RESET       : IN STD_LOGIC;
        nPCsel      : IN STD_LOGIC;
        Offset      : IN STD_LOGIC_VECTOR(23 downto 0);
        Instruction : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity InstructionControlUnit;

architecture RTL of InstructionControlUnit is

    signal PC : std_logic_vector(31 downto 0) := (others => '0');
    -- signal extendedOffset : std_logic_vector(31 downto 0);
    signal muxOffset : std_logic_vector(31 downto 0);
    signal extendedOffset : std_logic_vector(31 downto 0);

    signal incrementedOffsetPC : std_logic_vector(31 downto 0);
    signal incrementedPC : std_logic_vector(31 downto 0);
begin

OffsetExtender : entity work.SignExpander generic map (N => 24) port map (
    E => Offset,
    S => extendedOffset
);

incrementedOffsetPC <= std_logic_vector(unsigned(signed(PC) + signed(extendedOffset) + to_signed(1, 32)));
incrementedPC <= std_logic_vector(unsigned(PC) + to_unsigned(1, 32));
PCSelMUX : entity work.MUX21 generic map (N => 32) port map (
    A => incrementedPC,
    B => incrementedOffsetPC,
    COM => nPCsel,
    S => muxOffset
);

ProgramCounter : entity work.ProgramCounter port map (
    CLK => CLK,
    RESET => RESET,
    NewPC => muxOffset,
    PC => PC
);

InstructionMemory : entity work.InstructionMemory port map (
    PC => PC,
    Instruction => Instruction
);

end architecture;