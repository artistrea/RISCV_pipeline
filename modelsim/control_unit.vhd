library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        instr : in std_logic_vector(31 downto 0);
        -- ex
        alu_op : out std_logic_vector(3 downto 0) := (others => '0');
        alu_srcA : out std_logic_vector(1 downto 0) := (others => '0');
        alu_srcB : out std_logic_vector(1 downto 0) := (others => '0');
        -- mem
        mem_read : out std_logic := '0';
        mem_write : out std_logic := '0';
        branch_cond : out std_logic := '0';
        branch_uncond : out std_logic := '0';
        branch_src : out std_logic := '0';
        -- wb
        reg_write : out std_logic := '0';
        mem_to_reg : out std_logic := '0'
    );
end control_unit;

architecture control_unit_arch of control_unit is
    type instruction_enum is (
        INS_ADD, INS_ADDi, INS_SUB, INS_SUBi, INS_AND, INS_ANDi, INS_LUI, INS_SLT, INS_OR, INS_ORi, INS_XOR, INS_XORi, INS_SLLi, INS_SRLi, INS_SRAi, INS_SLTi, INS_SLTU, INS_SLTUi, INS_AUIPC, INS_JAL, INS_JALR, INS_BEQ, INS_BNE, INS_BLT, INS_BGE, INS_BGEU, INS_BLTU, INS_LW, INS_SW, Unknown_instruction
    );
    signal instruction_is : instruction_enum;
    
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

begin
    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    --         when INS_SUBi =>
    --             reg_write <= '1';
    --             alu_srcB <= "01";
    alu_op <= "0001" when instruction_is = INS_SUB else
              "0001" when instruction_is = INS_SUBi else
              "0010" when instruction_is = INS_AND else
              "0010" when instruction_is = INS_ANDi else
              "0011" when instruction_is = INS_OR else
              "0011" when instruction_is = INS_ORi else
              "0100" when instruction_is = INS_XOR else
              "0100" when instruction_is = INS_XORi else
              "1001" when instruction_is = INS_SLT else
              "0101" when instruction_is = INS_SLLi else
              "0111" when instruction_is = INS_SRLi else
              "1000" when instruction_is = INS_SRAi else
              "1001" when instruction_is = INS_SLTi else
              "1010" when instruction_is = INS_SLTU else
              "1010" when instruction_is = INS_SLTUi else
              "1101" when instruction_is = INS_BEQ else
              "1110" when instruction_is = INS_BNE else
              "1001" when instruction_is = INS_BLT else
              "1011" when instruction_is = INS_BGE else
              "1100" when instruction_is = INS_BGEU else
              "1010" when instruction_is = INS_BLTU else
              "0000";
-- done
    alu_srcA <=
        "10" when instruction_is = INS_LUI else
        "01" when instruction_is = INS_JAL else
        "01" when instruction_is = INS_JALR else
        "01" when instruction_is = INS_AUIPC else
        "00";

    alu_srcB <=
        "01" when instruction_is = INS_ADDi else
        "01" when instruction_is = INS_SUBi else
        "01" when instruction_is = INS_ANDi else
        "01" when instruction_is = INS_ORi else
        "01" when instruction_is = INS_XORi else
        "01" when instruction_is = INS_SLLi else
        "01" when instruction_is = INS_SRLi else
        "01" when instruction_is = INS_SRAi else
        "01" when instruction_is = INS_SLTi else
        "01" when instruction_is = INS_SLTUi else
        "01" when instruction_is = INS_LW else
        "01" when instruction_is = INS_SW else
        "01" when instruction_is = INS_LUI else
        "10" when instruction_is = INS_JAL else
        "10" when instruction_is = INS_JALR else
        "01" when instruction_is = INS_AUIPC else
        "00";

-- done
    mem_read <= '1' when instruction_is = INS_LW else '0';
-- done
    mem_write <= '1' when instruction_is = INS_SW else '0';
-- done
    branch_cond <= '1' when instruction_is = INS_BEQ else
                   '1' when instruction_is = INS_BNE else
                   '1' when instruction_is = INS_BLT else
                   '1' when instruction_is = INS_BGE else
                   '1' when instruction_is = INS_BGEU else
                   '1' when instruction_is = INS_BLTU else
                   '0';
    
    branch_uncond <= '1' when instruction_is = INS_JAL else
                     '1' when instruction_is = INS_JALR else
                     '0';
-- done
    branch_src <= '1' when instruction_is = INS_JALR else
                    '0';
    
    reg_write <= '1' when instruction_is = INS_ADD else
                '1' when instruction_is = INS_ADDi else
                '1' when instruction_is = INS_SUB else
                '1' when instruction_is = INS_SUBi else
                '1' when instruction_is = INS_AND else
                '1' when instruction_is = INS_ANDi else
                '1' when instruction_is = INS_OR else
                '1' when instruction_is = INS_ORi else
                '1' when instruction_is = INS_XOR else
                '1' when instruction_is = INS_XORi else
                '1' when instruction_is = INS_SLT else
                '1' when instruction_is = INS_SLLi else
                '1' when instruction_is = INS_SRLi else
                '1' when instruction_is = INS_SRAi else
                '1' when instruction_is = INS_SLTi else
                '1' when instruction_is = INS_SLTU else
                '1' when instruction_is = INS_SLTUi else
                '1' when instruction_is = INS_LUI else
                '1' when instruction_is = INS_AUIPC else
                '1' when instruction_is = INS_LW else
                '1' when instruction_is = INS_JAL else
                '1' when instruction_is = INS_JALR else
                '0';

    -- done
    mem_to_reg <= '1' when instruction_is = INS_LW else
                  '0';
    
    
    instruction_is <=
        INS_SUB             when opcode = "0110011" and funct3 = "000" and funct7 = "0100000" else
        INS_ADD             when opcode = "0110011" and funct3 = "000" else
        INS_SLT             when opcode = "0110011" and funct3 = "010" else
        INS_SLTU            when opcode = "0110011" and funct3 = "011" else
        INS_XOR             when opcode = "0110011" and funct3 = "100" else
        -- INS_SRL            when opcode = "0010011" and funct3 = "101" else
        INS_OR              when opcode = "0110011" and funct3 = "110" else
        INS_AND             when opcode = "0110011" and funct3 = "111" else
        INS_LW              when opcode = "0000011" and funct3 = "010" else
        INS_ADDi            when opcode = "0010011" and funct3 = "000" else
        INS_SLTi            when opcode = "0010011" and funct3 = "010" else
        INS_SLTUi           when opcode = "0010011" and funct3 = "011" else
        INS_XORi            when opcode = "0010011" and funct3 = "100" else
        INS_ORi             when opcode = "0010011" and funct3 = "110" else
        INS_ANDi            when opcode = "0010011" and funct3 = "111" else
        INS_SLLi            when opcode = "0010011" and funct3 = "001" and funct7 = "0000000" else
        INS_SRLi            when opcode = "0010011" and funct3 = "101" and funct7 = "0000000" else
        INS_SRAi            when opcode = "0010011" and funct3 = "101" and funct7 = "0100000" else
        INS_JALR            when opcode = "1100111" and funct3 = "000" else
        INS_SW              when opcode = "0100011" and funct3 = "010" else
        INS_BEQ             when opcode = "1100011" and funct3 = "000" else
        INS_BNE             when opcode = "1100011" and funct3 = "001" else
        INS_BLT             when opcode = "1100011" and funct3 = "100" else
        INS_BGE             when opcode = "1100011" and funct3 = "101" else
        INS_BLTU            when opcode = "1100011" and funct3 = "110" else
        INS_BGEU            when opcode = "1100011" and funct3 = "111" else
        INS_LUI             when opcode = "0110111" else
        INS_AUIPC           when opcode = "0010111" else
        INS_JAL             when opcode = "1101111" else
        Unknown_instruction;
end control_unit_arch;
-- A srcs:
-- 00 -> Rs1
-- 01 -> PC
-- 10 -> 0

-- B srcs:
-- 00 -> Rs2
-- 01 -> imm
-- 10 -> 4

