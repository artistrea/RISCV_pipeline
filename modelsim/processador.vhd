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

    -- wires:
    signal nextPC_IF, nextPC0_IF, nextPC1_IF, curPC_IF : std_logic_vector(31 downto 0) := (others => '0');
    signal PCSrc : std_logic_vector(1 downto 0) := (others => '0');

    signal curPC_ID : std_logic_vector(31 downto 0) := (others => '0');
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


    fetchPC_regist : register32 port map(
        clk => CLK,
        write_enabled => '1',
        data_in => curPC_IF,
        data_out => curPC_ID
    );

    -- decode
    

end RISCV_pipeline_arch;

