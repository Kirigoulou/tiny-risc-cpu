library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionDecoder is
    port
    (
        Instruction : IN STD_LOGIC_VECTOR(31 downto 0);
        PSR         : IN STD_LOGIC_VECTOR(31 downto 0);
        nPC_SEL     : OUT STD_LOGIC;
        PSREn       : OUT STD_LOGIC;
        RegWr       : OUT STD_LOGIC;
        RegSel      : OUT STD_LOGIC;
        ALUCtrl     : OUT STD_LOGIC_VECTOR(2 downto 0);
        ALUSrc      : OUT STD_LOGIC;
        WrSrc       : OUT STD_LOGIC;
        MemWr       : OUT STD_LOGIC;
        RegAff      : OUT STD_LOGIC
    );
end entity InstructionDecoder;

architecture RTL of InstructionDecoder is
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT);
    signal instr_courante: enum_instruction;
begin

process (Instruction)
begin
    case Instruction(27 downto 26) is
    when "00" =>
        -- Basic instructions between a register and a register/immediate
        case Instruction(24 downto 21) is
        when "0100" => 
            -- ADD
            if Instruction(25) = '0' then
                instr_courante <= ADDr;
            else
                instr_courante <= ADDi;
            end if;
        when "1010" => 
            -- CMP
            instr_courante <= CMP;
        when "1101" => 
            -- MOV
            instr_courante <= MOV;
        when others =>
            null;
        end case;

    when "01" => 
        -- LDR and STR instructions
        if Instruction(20) = '1' then
            -- Load
            instr_courante <= LDR;
        else
            -- Store
            instr_courante <= STR;
        end if;
    
    when "10" => 
        -- Branch instructions
        if Instruction(31 downto 28) = "1011" then
            instr_courante <= BLT;
        elsif Instruction(31 downto 28) = "1110" then
            instr_courante <= BAL;
        else
            -- Could be changed later but for now, any other condition would give a BAL
            instr_courante <= BAL;
        end if;
    
    when others =>
        null;
    
    end case;
end process;

process (Instruction, instr_courante)
begin
    case instr_courante is
    when ADDi => 
        nPC_SEL <= '0';
        RegWr <= '1';
        ALUSrc <= '1'; -- Retrieve the immediate instead of the output B of the register
        ALUCtrl <= "000";
        PSREn <= Instruction(20);
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the output of the ALU instead of the memory
        RegSel <= '0'; -- TODO: careful when creating the multiplexer, 0 should be for Rd and 1 for Rm
        RegAff <= '0';
    when ADDr => 
        nPC_SEL <= '0';
        RegWr <= '1';
        ALUSrc <= '0'; -- Retrieve the output B of the register instead of the immediate
        ALUCtrl <= "000";
        PSREn <= Instruction(20);
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the output of the ALU instead of the memory
        RegSel <= '1';
        RegAff <= '0';
    when BAL => 
        nPC_SEL <= '1'; -- Add offset to PC
        RegWr <= '0';
        ALUSrc <= '0'; -- DONT KNOW Retrieve the output B of the register instead of the immediate
        ALUCtrl <= "001";
        PSREn <= '0';
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the output of the ALU instead of the memory
        RegSel <= '0';
        RegAff <= '0';
    when BLT => 
        if PSR(31) = '1' then nPC_SEL <= '1'; else nPC_SEL <= '0'; end if;
        -- nPC_SEL <= PSR(31);
        -- nPC_SEL <= '1' when PSR(0) = '1' else '0'; -- Add offset to PC if x < y (N = 1)
        RegWr <= '0';
        ALUSrc <= '0'; -- DONT KNOW Retrieve the output B of the register instead of the immediate
        ALUCtrl <= "001";
        PSREn <= '0';
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the output of the ALU instead of the memory
        RegSel <= '0';
        RegAff <= '0';
    when CMP => 
        nPC_SEL <= '0'; -- Add 1 to PC
        RegWr <= '0';
        ALUSrc <= Instruction(25); -- If the bit is set, compare with an immediate
        ALUCtrl <= "010";
        PSREn <= '1';
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the output of the ALU instead of the memory
        RegSel <= '0';
        RegAff <= '0';
    when LDR => 
        nPC_SEL <= '0'; -- Add 1 to PC
        RegWr <= '1';
        ALUSrc <= '1'; -- maybe not
        ALUCtrl <= "000";
        PSREn <= '0';
        MemWr <= '0';
        WrSrc <= '1'; -- We want to recover the memory
        RegSel <= Instruction(25);
        RegAff <= '0';
    when MOV => 
        nPC_SEL <= '0'; -- Add 1 to PC
        RegWr <= '1';
        ALUSrc <= Instruction(25); -- If the bit is set, move an immediate value
        ALUCtrl <= "001";
        PSREn <= '0';
        MemWr <= '0';
        WrSrc <= '0'; -- We want to recover the memory
        RegSel <= '0';
        RegAff <= '0';
    when STR => 
        nPC_SEL <= '0'; -- Add 1 to PC
        RegWr <= '0';
        ALUSrc <= '1'; -- maybe not
        ALUCtrl <= "000";
        PSREn <= '0';
        MemWr <= '1';
        WrSrc <= '0';
        RegSel <= '0'; -- Instruction(25);
        RegAff <= '1';
    
    when others => 
        null;

    end case;
end process;

end architecture;