library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        instr : in std_logic_vector(31 downto 0);
        -- ex
        alu_op : out std_logic_vector(3 downto 0);
        alu_src : out std_logic;
        -- mem
        mem_read : out std_logic;
        mem_write : out std_logic;
        branch : out std_logic;
        -- wb
        reg_write : out std_logic;
        mem_to_reg : out std_logic
    );
end control_unit;

architecture control_unit_arch of control_unit is
    type instruction_enum is (
        INS_ADD, INS_ADDi, INS_SUB, INS_SUBi, INS_AND, INS_ANDi, INS_LUI, INS_SLT, INS_OR, INS_ORi, INS_XOR, INS_XORi, INS_SLLi, INS_SRLi, INS_SRAi, INS_SLTi, INS_SLTu, INS_SLTUi, INS_AUIPC, INS_JAL, INS_JALR, INS_BEQ, INS_BNE, INS_BLT, INS_BGE, INS_BGEU, INS_BLTU, INS_LW, INS_SW, Unknown_instruction
    );
    signal instruction_is : instruction_enum;

    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    constant NON_ZERO_FUNCT7 : std_logic_vector(6 downto 0) := "0100000";
begin
    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    process(instr)
    begin
        case opcode is
            when "0110011" => -- format <= R_type;
                if funct7 = NON_ZERO_FUNCT7 and funct3 = "000" then
                    instruction_is <= INS_SUB;
                elsif funct7 = NON_ZERO_FUNCT7 then
                    instruction_is <= Unknown_instruction; -- SRA não especificado no trabalho
                else
                    case funct3 is
                        when "000" => instruction_is <= INS_ADD;
                        -- when "001" => instruction_is <= INS_SLL;
                        when "010" => instruction_is <= INS_SLT;
                        when "011" => instruction_is <= INS_SLTU;
                        when "100" => instruction_is <= INS_XOR;
                        -- when "101" => instruction_is <= INS_SRL;
                        when "110" => instruction_is <= INS_OR;
                        when "111" => instruction_is <= INS_AND;
                        when others => instruction_is <= Unknown_instruction;
                    end case;
                end if;
            -- when "0000011" => format <= I_type;
            -- when "0010011" => format <= I_type;
            -- when "1100111" => format <= I_type;
            when "0100011" => instruction_is <= INS_ADDi;
            when "1100011" => instruction_is <= INS_ADDi;
            when "0110111" => instruction_is <= INS_ADDi;
            when "0010111" => instruction_is <= INS_ADDi;
            when "1101111" => instruction_is <= INS_ADDi;
            when others => instruction_is <= Unknown_instruction;
        end case;
    end process;

    process(instruction_is, instr)
    begin
            
    end process;

end control_unit_arch;

