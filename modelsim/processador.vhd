-- Basear-se no design de https://aprender3.unb.br/pluginfile.php/2570924/mod_resource/content/1/Projeto%20OAC%202022-02.pdf
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- TODO: implementar hazard control
entity RISCV_pipeline is
    port(
        CLK : in std_logic;
        -- connection to external instruction memory
        instruction : in std_logic_vector(31 downto 0);
        instruction_mem_addr : out std_logic_vector(9 downto 0);
        -- connection to external data memory
        data_mem_addr : out std_logic_vector(9 downto 0);
        data_mem_write : out std_logic;
        data_mem_read : out std_logic;
        data_mem_write_data : out std_logic_vector(31 downto 0);
        data_mem_read_data : in std_logic_vector(31 downto 0)
    );
end RISCV_pipeline;

architecture RISCV_pipeline_arch of RISCV_pipeline is
    component mux4x1 is
        port(
            D0, D1, D2, D3 : in std_logic_vector(31 downto 0);
            SEL : in std_logic_vector(1 downto 0);
            Y : out std_logic_vector(31 downto 0)
        );
    end component;

    component adder is
        port(
            A, B : in std_logic_vector(31 downto 0);
            Y : out std_logic_vector(31 downto 0)
        );
    end component;

    component register32 is
        port(
            clk, write_enabled : in std_logic;
            data_in : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component ULA is
        port(
            opcode : in std_logic_vector(3 downto 0);
            A, B : in std_logic_vector(31 downto 0);
            Y : out std_logic_vector(31 downto 0);
            zero : out std_logic
        );
    end component;

    component XREGS is
        -- melhor se definido a nivel de processador e utilizado em todos os componentes:
        generic (WSIZE : natural := 32);
        port (
            clk, wren : in std_logic;
            rs1, rs2, rd : in std_logic_vector(4 downto 0);
            data : in std_logic_vector(WSIZE-1 downto 0);
            ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0) := (others => '0')
        );
    end component;

    component imm32_generator is
        port(
            instruction : in std_logic_vector(31 downto 0);
            imm : out std_logic_vector(31 downto 0)
        );
    end component;

    component control_unit is
        port(
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
    end component;

    -- wires:
    signal nextPC_IF, nextPC0_IF, nextPC1_IF, curPC_IF : std_logic_vector(31 downto 0) := (others => '0');
    signal PCSrc : std_logic_vector(1 downto 0) := (others => '0');

    signal curPC_ID, imm_ID : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction_ID : std_logic_vector(31 downto 0) := (others => '0');
    signal rs1_ID,rd_ID, rs2_ID, rd_WB : std_logic_vector(4 downto 0) := (others => '0');
    signal ro1_ID, ro2_ID : std_logic_vector(31 downto 0) := (others => '0');

    signal ALUSrc_ID, branch_ID, regWrite_ID, memRead_ID, memWrite_ID, memToReg_ID : std_logic := '0';
    signal ALUOp_ID : std_logic_vector(3 downto 0) := (others => '0');

        
    signal ALUSrc_EX, branch_EX, regWrite_EX, memRead_EX, memWrite_EX, memToReg_EX : std_logic := '0';
    signal ALUOp_EX : std_logic_vector(3 downto 0) := (others => '0');
    signal ALUResult_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUZero_EX : std_logic := '0';


    signal curPC_EX, imm_EX, branchAddress_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal ro1_EX, ro2_EX, ULAB_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal funct7_EX : std_logic := '0';
    signal funct3_EX : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_EX : std_logic_vector(4 downto 0) := (others => '0');

    
    signal branch_MEM, regWrite_MEM, memRead_MEM, memWrite_MEM, memToReg_MEM : std_logic := '0';

    signal shouldBranch_MEM : std_logic := '0';
    
    signal ALUResult_MEM : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUZero_MEM : std_logic := '0';
    signal ro2_MEM, rd_MEM, branchAddress_MEM : std_logic_vector(31 downto 0) := (others => '0');

    signal memToReg_WB, regWrite_WB : std_logic := '0';
    signal xregsData_WB, memData_WB : std_logic_vector(31 downto 0) := (others => '0');
    signal wren_WB : std_logic := '0';


    -- utility signals:
    signal ignoreBits : std_logic_vector(31 downto 0) := (others => '0');
begin
    -- fetch
    mux_IF : mux4x1 port map(
        D0 => nextPC0_IF,
        D1 => nextPC1_IF,
        D2 => (others => '0'),
        D3 => (others => '0'),
        SEL => PCSrc,
        Y => nextPC_IF
    );

    PC : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => nextPC_IF,
        data_out => curPC_IF
    );

    instruction_mem_addr <= curPC_IF(9 downto 0);

    adder_IF : adder port map(
        A => curPC_IF,
        B => std_logic_vector(to_signed(4, 32)),
        Y => nextPC0_IF
    );


    PCRegister_IF_ID : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => curPC_IF,
        data_out => curPC_ID
    );

    instructionRegister_IF_ID : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => instruction,
        data_out => instruction_ID
    );

    -- decode
    immGen_ID : imm32_generator port map(
        instruction => instruction_ID,
        imm => imm_ID
    );

    rs1_ID <= instruction_ID(19 downto 15);
    rs2_ID <= instruction_ID(24 downto 20);
    rd_ID <= instruction_ID(11 downto 7);

    xregs_ID : XREGS port map(
        clk => CLK,
        wren => wren_WB,
        rs1 => rs1_ID,
        rs2 => rs2_ID,
        rd => rd_WB,
        data => xregsData_WB,
        ro1 => ro1_ID,
        ro2 => ro2_ID
    );

    -- TODO: implementar unidade de controle
    controlUnit_ID : control_unit port map(
        instr => instruction_ID,
        -- ex
        alu_op => ALUOp_ID,
        alu_src => ALUSrc_ID,
        -- mem
        mem_read => memRead_ID,
        mem_write => memWrite_ID,
        branch => branch_ID,
        -- wb
        reg_write => regWrite_ID,
        mem_to_reg => memToReg_ID
    );

    controlRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in(0) => memToReg_ID,
        data_in(1) => regWrite_ID,
        data_in(2) => memWrite_ID,
        data_in(3) => memRead_ID,
        data_in(4) => branch_ID,
        data_in(8 downto 5) => ALUOp_ID,
        data_in(9) => ALUSrc_ID,
        data_in(31 downto 10) => ignoreBits(31 downto 10),
        
        data_out(0) => memToReg_EX,
        data_out(1) => regWrite_EX,
        data_out(2) => memWrite_EX,
        data_out(3) => memRead_EX,
        data_out(4) => branch_EX,
        data_out(8 downto 5) => ALUOp_EX,
        data_out(9) => ALUSrc_EX,
        data_out(31 downto 10) => ignoreBits(31 downto 10)
    );

    ro1Register_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => ro1_ID,
        data_out => ro1_EX
    );

    ro2Register_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => ro2_ID,
        data_out => ro2_EX
    );
    
    immmRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => imm_ID,
        data_out => imm_EX
    );

    PCRdRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => curPC_ID,
        data_out => curPC_EX
    );

    -- parece que functs é totalmente desnecessário aqui
    functsAndRdRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in(31 downto 9) => (others => '0'),
        data_in(8 downto 4) => rd_ID,
        data_in(3) => instruction_ID(30),
        data_in(2 downto 0) => instruction_ID(14 downto 12),
        data_out(3) => funct7_EX,
        data_out(2 downto 0) => funct3_EX,
        data_out(8 downto 4) => rd_EX,
        data_out(31 downto 9) => ignoreBits(31 downto 9)
    );

    -- execute
    branchCalculator_EX : adder port map(
        A => curPC_EX,
        B => imm_EX(30 downto 0) & "0",
        Y => branchAddress_EX
    );

    mux_EX : mux4x1 port map(
        D0 => ro2_EX,
        D1 => imm_EX,
        D2 => ignoreBits,
        D3 => ignoreBits,
        SEL => '0' & ALUSrc_EX,
        Y => ULAB_EX
    );

    ula_EX : ULA port map(
        opcode => ALUOp_EX,
        A => ro1_EX,
        B => ULAB_EX,
        Y => ALUResult_EX,
        zero => ALUZero_EX
    );

    


    ro2Register_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => ro2_EX,
        data_out => ro2_MEM
    );

    branchAddressRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => branchAddress_EX,
        data_out => branchAddress_MEM
    );

    controlAndALUZeroAndRdRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in(0) => memToReg_EX,
        data_in(1) => regWrite_EX,
        data_in(2) => memWrite_EX,
        data_in(3) => memRead_EX,
        data_in(4) => branch_EX,

        data_in(5) => ALUZero_EX,
        
        data_in(10 downto 6) => rd_EX,
        data_in(31 downto 11) => ignoreBits(31 downto 11),
        
        data_out(0) => memToReg_MEM,
        data_out(1) => regWrite_MEM,
        data_out(2) => memWrite_MEM,
        data_out(3) => memRead_MEM,
        data_out(4) => branch_MEM,
        
        data_out(5) => ALUZero_MEM,
        
        data_out(10 downto 6) => rd_MEM,
        data_out(31 downto 11) => ignoreBits(31 downto 11)
    );

    ALUResultRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => ALUResult_EX,
        data_out => ALUResult_MEM
    );


    -- memory access
    data_mem_addr <= ALUResult_MEM(9 downto 0);
    data_mem_write <= memWrite_MEM;
    data_mem_read <= memRead_MEM;
    data_mem_write_data <= ro2_MEM;

    
    -- TODO: implementar branch direito
    shouldBranch_MEM <= branch_MEM and ALUZero_MEM; -- beq, should have a component for this

    
    controlRegister_MEM_WB : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in(0) => memToReg_MEM,
        data_in(1) => regWrite_MEM,
        data_in(31 downto 2) => ignoreBits(31 downto 2),

        data_out(0) => memToReg_WB,
        data_out(1) => regWrite_WB,
        data_out(31 downto 2) => ignoreBits(31 downto 2)
    );

    memDataRegister_MEM_WB : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => data_mem_read_data,
        data_out => memData_WB
    );

    -- write back

    mux_WB : mux4x1 port map(
        D0 => ALUResult_MEM,
        D1 => memData_WB,
        D2 => ignoreBits,
        D3 => ignoreBits,
        SEL => '0' & memToReg_WB,
        Y => xregsData_WB
    );
end RISCV_pipeline_arch;

