LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity CPU is
    port
    (
        CLK        : IN STD_LOGIC;
        RESET      : IN STD_LOGIC;
        DisplayOutput : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity CPU;

architecture RTL of CPU is
    signal Instruction : std_logic_vector(31 downto 0);
    signal PCOffset : std_logic_vector(23 downto 0) := Instruction(23 downto 0);
    signal Rd : std_logic_vector(3 downto 0) := Instruction(15 downto 12);
    signal Rn : std_logic_vector(3 downto 0) := Instruction(19 downto 16);
    signal Rm : std_logic_vector(3 downto 0) := Instruction(3 downto 0);
    signal Immediate : std_logic_vector(7 downto 0) := Instruction(7 downto 0);

    signal N, Z, C, V : std_logic;

    signal Rb : std_logic_vector(3 downto 0);
    signal PSRInput : std_logic_vector(31 downto 0);
    signal RegBOut : std_logic_vector(31 downto 0);

    -- Decoder signals
    signal PSR : std_logic_vector(31 downto 0);
    signal nPC_SEL : std_logic;
    signal PSREn : std_logic;
    signal RegWr : std_logic;
    signal RegSel : std_logic;
    signal ALUCtrl : std_logic_vector(2 downto 0);
    signal ALUSrc : std_logic;
    signal WrSrc : std_logic;
    signal MemWr : std_logic;
    signal RegAff : std_logic;
begin
    
PCOffset <= Instruction(23 downto 0);
Rd <= Instruction(15 downto 12);
Rn <= Instruction(19 downto 16);
Rm <= Instruction(3 downto 0);
Immediate <= Instruction(7 downto 0);

InstructionControlUnit : entity work.InstructionControlUnit port map (
    CLK => CLK,
    RESET => RESET,
    nPCsel => nPC_SEL,
    Offset => PCOffset,
    Instruction => Instruction
);

RbMUX : entity work.MUX21 generic map (N => 4) port map (
    A => Rd,
    B => Rm,
    COM => RegSel,
    S => Rb
);

ProcessingUnit : entity work.ProcessingUnit port map (
    CLK => CLK,
    Reset => RESET,
    RegWr => RegWr,
    MuxRegSel => ALUSrc,
    MuxMemSel => WrSrc,
    WrEn => MemWr,
    OP => ALUCtrl,
    Rw => Rd,
    Ra => Rn,
    Rb => Rb,
    Imm => Immediate,
    N => N,
    Z => Z,
    C => C,
    V => V,
    RegBOut => RegBOut
);

PSRInput <= N & Z & C & V & (27 downto 0 => '0');
PSRRegister: entity work.Register32b
 port map(
    CLK => CLK,
    RESET => RESET,
    DATAIN => PSRInput,
    WE => PSREn,
    DATAOUT => PSR
);

DisplayRegister: entity work.Register32b
 port map(
    CLK => CLK,
    RESET => RESET,
    DATAIN => RegBOut,
    WE => RegAff,
    DATAOUT => DisplayOutput
);

InstructionDecoder: entity work.InstructionDecoder
 port map(
    Instruction => Instruction,
    PSR => PSR,
    nPC_SEL => nPC_SEL,
    PSREn => PSREn,
    RegWr => RegWr,
    RegSel => RegSel,
    ALUCtrl => ALUCtrl,
    ALUSrc => ALUSrc,
    WrSrc => WrSrc,
    MemWr => MemWr,
    RegAff => RegAff
);

end architecture;