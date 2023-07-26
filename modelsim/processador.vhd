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
            S : in std_logic_vector(1 downto 0);
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
            X : in std_logic_vector(31 downto 0);
            Y : out std_logic_vector(31 downto 0)
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
            instr : in std_logic_vector(31 downto 0);
            imm32 : out std_logic_vector(31 downto 0)
        );
    end component;

    component control_unit is
        port(
            instr : in std_logic_vector(31 downto 0);
            -- ex
            alu_op : out std_logic_vector(3 downto 0);
            alu_srcA : out std_logic_vector(1 downto 0);
            alu_srcB : out std_logic_vector(1 downto 0);
            -- mem
            mem_read : out std_logic;
            mem_write : out std_logic;
            branch_cond : out std_logic;
            branch_uncond : out std_logic;
            branch_src : out std_logic;
            -- wb
            reg_write : out std_logic;
            mem_to_reg : out std_logic
        );
    end component;

    -- wires:
    signal nextPC_IF, selectedNextPC_IF, nextPC0_IF, nextPC1_IF, curPC_IF : std_logic_vector(31 downto 0) := (others => '0');
    signal PCSrc : std_logic_vector(1 downto 0) := (others => '0');

    signal curPC_ID, imm_ID : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction_ID : std_logic_vector(31 downto 0) := (others => '0');
    signal rs1_ID,rd_ID, rs2_ID, rd_WB : std_logic_vector(4 downto 0) := (others => '0');
    signal ro1_ID, ro2_ID : std_logic_vector(31 downto 0) := (others => '0');

    signal ALUSrcA_ID, ALUSrcB_ID : std_logic_vector(1 downto 0) := (others => '0');
    signal branchCond_ID, branchUnc_ID, branchSrc_ID, regWrite_ID, memRead_ID, memWrite_ID, memToReg_ID : std_logic := '0';
    signal ALUOp_ID : std_logic_vector(3 downto 0) := (others => '0');

        
    signal ALUSrcA_EX, ALUSrcB_EX : std_logic_vector(1 downto 0) := (others => '0');
    signal branchCond_EX, branchUnc_EX, branchSrc_EX, regWrite_EX, memRead_EX, memWrite_EX, memToReg_EX : std_logic := '0';
    signal ALUOp_EX : std_logic_vector(3 downto 0) := (others => '0');
    signal ALUResult_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUZero_EX : std_logic := '0';

    
    signal curPC_EX, imm_EX, branchAddress_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal ro1_EX, ro2_EX, ULAB_EX, ULAA_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal funct7_EX : std_logic := '0';
    signal funct3_EX : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_EX : std_logic_vector(4 downto 0) := (others => '0');

    
    signal branchCond_MEM, branchUnc_MEM, regWrite_MEM, memRead_MEM, memWrite_MEM, memToReg_MEM : std_logic := '0';

    signal shouldBranch_MEM : std_logic := '0';
    
    signal ALUResult_MEM : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUZero_MEM : std_logic := '0';
    signal ro2_MEM, branchAddress_MEM : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_MEM : std_logic_vector(4 downto 0) := (others => '0');

    signal memToReg_WB, regWrite_WB : std_logic := '0';
    signal xregsData_WB, memData_WB, ALUResult_WB : std_logic_vector(31 downto 0) := (others => '0');
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
        S => PCSrc,
        Y => nextPC_IF
    );

    selectedNextPC_IF <= nextPC_IF when shouldBranch_MEM     = '0' else branchAddress_MEM;

    PC : register32 port map(
        clk => CLK,
        write_enabled => '1',
        -- TODO: mudar isso para funcionar pelo hazard control
        X => selectedNextPC_IF,
        Y => curPC_IF
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
        X => curPC_IF,
        Y => curPC_ID
    );

    instructionRegister_IF_ID : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => instruction,
        Y => instruction_ID
    );

    -- decode
    immGen_ID : imm32_generator port map(
        instr => instruction_ID,
        imm32 => imm_ID
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

    controlUnit_ID : control_unit port map(
        instr => instruction_ID,
        -- ex
        alu_op => ALUOp_ID,
        alu_srcA => ALUSrcA_ID,
        alu_srcB => ALUSrcB_ID,
        -- mem
        mem_read => memRead_ID,
        mem_write => memWrite_ID,
        branch_uncond => branchUnc_ID,
        branch_src => branchSrc_ID,
        branch_cond => branchCond_ID,
        -- wb
        reg_write => regWrite_ID,
        mem_to_reg => memToReg_ID
    );

    controlRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X(0) => memToReg_ID,
        X(1) => regWrite_ID,
        X(2) => memWrite_ID,
        X(3) => memRead_ID,
        X(4) => branchCond_ID,
        X(5) => branchUnc_ID,
        X(6) => branchSrc_ID,
        X(10 downto 7) => ALUOp_ID,
        X(12 downto 11) => ALUSrcA_ID,
        X(14 downto 13) => ALUSrcB_ID,
        X(31 downto 15) => ignoreBits(31 downto 15),
        
        Y(0) => memToReg_EX,
        Y(1) => regWrite_EX,
        Y(2) => memWrite_EX,
        Y(3) => memRead_EX,
        Y(4) => branchCond_EX,
        Y(5) => branchUnc_EX,
        Y(6) => branchSrc_EX,
        Y(10 downto 7) => ALUOp_EX,
        Y(12 downto 11) => ALUSrcA_EX,
        Y(14 downto 13) => ALUSrcB_EX,
        Y(31 downto 15) => ignoreBits(31 downto 15)
    );

    ro1Register_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => ro1_ID,
        Y => ro1_EX
    );

    ro2Register_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => ro2_ID,
        Y => ro2_EX
    );
    
    immmRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => imm_ID,
        Y => imm_EX
    );

    PCRdRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => curPC_ID,
        Y => curPC_EX
    );

    -- parece que functs é totalmente desnecessário aqui
    functsAndRdRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X(31 downto 9) => (others => '0'),
        X(8 downto 4) => rd_ID,
        X(3) => instruction_ID(30),
        X(2 downto 0) => instruction_ID(14 downto 12),
        Y(3) => funct7_EX,
        Y(2 downto 0) => funct3_EX,
        Y(8 downto 4) => rd_EX,
        Y(31 downto 9) => ignoreBits(31 downto 9)
    );

    -- execute
    branchAddress_EX <=
        std_logic_vector(signed(curPC_EX) + signed(imm_EX) + signed(ro2_EX)) when branchSrc_EX = '1'
        else std_logic_vector(signed(curPC_EX) + signed(imm_EX(30 downto 0) & '0'));

    

    ulaBMux_EX : mux4x1 port map(
        D0 => ro2_EX,
        D1 => imm_EX,
        D2 => std_logic_vector(to_signed(4, 32)),
        D3 => ignoreBits,
        S => ALUSrcB_EX,
        Y => ULAB_EX
    );

    ulaAMux_EX : mux4x1 port map(
        D0 => ro1_EX,
        D1 => curPC_EX,
        D2 => std_logic_vector(to_signed(0, 32)),
        D3 => ignoreBits,
        S => ALUSrcB_EX,
        Y => ULAA_EX
    );

    ula_EX : ULA port map(
        opcode => ALUOp_EX,
        A => ULAA_EX,
        B => ULAB_EX,
        Y => ALUResult_EX,
        zero => ALUZero_EX
    );

    


    ro2Register_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => ro2_EX,
        Y => ro2_MEM
    );

    branchAddressRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => branchAddress_EX,
        Y => branchAddress_MEM
    );

    controlAndALUZeroAndRdRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X(0) => memToReg_EX,
        X(1) => regWrite_EX,
        X(2) => memWrite_EX,
        X(3) => memRead_EX,
        X(4) => branchCond_EX,
        X(5) => branchUnc_EX,
        X(6) => ALUZero_EX,
        X(11 downto 7) => rd_EX,
        X(31 downto 12) => ignoreBits(31 downto 12),
        
        Y(0) => memToReg_MEM,
        Y(1) => regWrite_MEM,
        Y(2) => memWrite_MEM,
        Y(3) => memRead_MEM,
        Y(4) => branchCond_MEM,
        Y(5) => branchUnc_MEM,

        Y(6) => ALUZero_MEM,
        
        Y(11 downto 7) => rd_MEM,
        Y(31 downto 12) => ignoreBits(31 downto 12)
    );

    ALUResultRegister_EX_MEM : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => ALUResult_EX,
        Y => ALUResult_MEM
    );


    -- memory access
    data_mem_addr <= ALUResult_MEM(9 downto 0);
    data_mem_write <= memWrite_MEM;
    data_mem_read <= memRead_MEM;
    data_mem_write_data <= ro2_MEM;

    
    -- TODO: implementar branch direito (hazard)
    shouldBranch_MEM <=
        '1' when (branchCond_MEM = '1' and ALUZero_MEM = '1') or branchUnc_MEM = '1'
        else '0';

    controlRegister_MEM_WB : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X(0) => memToReg_MEM,
        X(1) => regWrite_MEM,
        X(6 downto 2) => rd_MEM,
        X(31 downto 7) => ignoreBits(31 downto 7),

        Y(0) => memToReg_WB,
        Y(1) => regWrite_WB,
        Y(6 downto 2) => rd_WB,
        Y(31 downto 7) => ignoreBits(31 downto 7)
    );

    memDataRegister_MEM_WB : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => data_mem_read_data,
        Y => memData_WB
    );

    ALUResultRegister_MEM_WB : register32 port map(
        clk => CLK,
        write_enabled => '1',
        X => ALUResult_MEM,
        Y => ALUResult_WB
    );

    -- write back

    mux_WB : mux4x1 port map(
        D0 => ALUResult_WB,
        D1 => memData_WB,
        D2 => ignoreBits,
        D3 => ignoreBits,
        S => '0' & memToReg_WB,
        Y => xregsData_WB
    );
end RISCV_pipeline_arch;

