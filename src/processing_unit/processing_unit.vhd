library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity ProcessingUnit is
    port
    (
        CLK        : IN STD_LOGIC;
        Reset      : IN STD_LOGIC;
        RegWr      : IN STD_LOGIC;  -- 16x32 register board
        MuxRegSel  : IN STD_LOGIC;  -- Selector for MUX between busB and Immediate
        MuxMemSel  : IN STD_LOGIC;  -- Selector for MUX between ALU and Memory
        WrEn       : IN STD_LOGIC;  -- 64x32 memory board
        OP         : IN STD_LOGIC_VECTOR(2 downto 0);
        Rw, Ra, Rb : IN STD_LOGIC_VECTOR(3 downto 0);
        Imm        : IN STD_LOGIC_VECTOR(7 downto 0);
        N, Z, C, V : OUT std_logic;
        OutValue   : OUT STD_LOGIC_VECTOR(31 downto 0);
        RegBOut   : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end entity ProcessingUnit;

architecture RTL of ProcessingUnit is 
    signal busA, busB, busW : std_logic_vector(31 downto 0);
    signal DataOut, ALUout  : std_logic_vector(31 downto 0);
    signal extImm           : std_logic_vector(31 downto 0);
    signal regMuxOut        : std_logic_vector(31 downto 0);
begin

Registers : entity work.RegisterBoard port map ( 
    CLK => CLK,
    RESET => Reset,
    W => busW,
    RA => Ra,
    RB => Rb,
    RW => Rw,
    WE => RegWr,
    A => busA,
    B => busB
);

ImmExpander : entity work.SignExpander generic map (N => 8) port map (
    E => Imm,
    S => extImm
);

RegMUX : entity work.MUX21 generic map (N => 32) port map (
    A => busB,
    B => extImm,
    COM => MuxRegSel,
    S => regMuxOut
);

UAL : entity work.UAL port map (
    OP => OP,
    A => busA,
    B => regMuxOut,
    S => ALUout,
    N => N,
    Z => Z,
    C => C,
    V => V
);

Memory : entity work.MemoryBoard port map (
    CLK => CLK,
    RESET => Reset,
    DATAIN => busB,
    ADDR => ALUout(5 downto 0),
    WE => WrEn,
    DATAOUT => DataOut
);

MemMUX : entity work.MUX21 generic map (N => 32) port map (
    A => ALUout,
    B => DataOut,
    COM => MuxMemSel,
    S => busW
);

OutValue <= busW;
RegBOut <= busB;

end architecture;