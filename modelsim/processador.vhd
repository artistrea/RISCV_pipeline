-- Basear-se no design de https://aprender3.unb.br/pluginfile.php/2570924/mod_resource/content/1/Projeto%20OAC%202022-02.pdf
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_pipeline is
    port(
        CLK : in std_logic;
        -- connection to external instruction memory
        instruction : in std_logic_vector(31 downto 0);
        instruction_mem_addr : out std_logic_vector(31 downto 0);
        -- connection to external data memory
        data_mem_addr : out std_logic_vector(31 downto 0);
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
            A, B : in std_logic_vector(31 downto 0);
            Y : out std_logic_vector(31 downto 0);
            Z : out std_logic
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
    signal rs1_ID,rd_ID, rs2_ID, ro1_ID, ro2_ID, rd_WB : std_logic_vector(4 downto 0) := (others => '0');
    
    signal branch_ID : std_logic := '0';
    signal regWrite_ID : std_logic := '0';
    signal memRead_ID : std_logic := '0';
    signal memWrite_ID : std_logic := '0';
    signal memToReg_ID : std_logic := '0';
    signal ALUOp_ID : std_logic_vector(3 downto 0) := (others => '0');
    signal ALUSrc_ID : std_logic := '0';

    signal curPC_EX, imm_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal ro1_EX, ro2_EX : std_logic_vector(31 downto 0) := (others => '0');
    signal funct7_EX : std_logic := '0';
    signal funct3_EX : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_EX : std_logic_vector(4 downto 0) := (others => '0');

    signal xregsData_WB : std_logic_vector(31 downto 0) := (others => '0');
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

    instruction_mem_addr <= curPC_IF;

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

    immmRegister_ID_EX : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => imm_ID,
        data_out => imm_EX
    );

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
    
    



    

end RISCV_pipeline_arch;

