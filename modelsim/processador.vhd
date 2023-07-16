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

begin
    -- fetch
    

end RISCV_pipeline_arch;

