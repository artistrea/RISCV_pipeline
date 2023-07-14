
-- Basear-se no design de https://aprender3.unb.br/pluginfile.php/2570890/mod_resource/content/1/14_Pipeline_RISCV.pdf
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISCV_pipeline is
    port(
        Y : out std_logic_vector(31 downto 0);
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

begin

    Y <= (others => '0');
end RISCV_pipeline_arch;

