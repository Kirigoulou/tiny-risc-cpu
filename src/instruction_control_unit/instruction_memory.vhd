LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY InstructionMemory IS
    PORT (
        PC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        Instruction : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE RTL OF InstructionMemory IS
    TYPE RAM64x32 IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR (31 DOWNTO 0);

    FUNCTION init_mem RETURN RAM64x32 IS
        VARIABLE result : RAM64x32;
    BEGIN
        FOR i IN 63 DOWNTO 0 LOOP
            result (i) := (OTHERS => '0');
        END LOOP; -- PC -- INSTRUCTION -- COMMENTAIRE
        result (0) := x"E3A01020";-- 0x0 _main -- MOV R1,#0x20 -- R1 = 0x20
        result (1) := x"E3A02000";-- 0x1       -- MOV R2,#0x00 -- R2 = 0
        result (2) := x"E6110000";-- 0x2 _loop -- LDR R0,0(R1) -- R0 = DATAMEM[R1]
        result (3) := x"E0822000";-- 0x3       -- ADD R2,R2,R0 -- R2 = R2 + R0
        result (4) := x"E2811001";-- 0x4       -- ADD R1,R1,#1 -- R1 = R1 + 1
        result (5) := x"E351002A";-- 0x5       -- CMP R1,0x2A  -- Flag = R1-0x2A,si R1 <= 0x2A
        result (6) := x"BAFFFFFB";-- 0x6       -- BLT loop     -- PC =PC+1+(-5) si N = 1
        result (7) := x"E6012000";-- 0x7       -- STR R2,0(R1) -- DATAMEM[R1] = R2
        result (8) := x"E2822001";-- 0x8       -- ADD R2,R2,#1 -- R2 = R2 + 1
        result (9) := x"EAFFFFF7";-- 0x8       -- BAL main     -- PC=PC+1+(-9)
        RETURN result;
    END init_mem;

    SIGNAL mem : RAM64x32 := init_mem;
BEGIN

    Instruction <= mem(to_integer(unsigned (PC)));

END ARCHITECTURE;