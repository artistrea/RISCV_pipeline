library ieee;

use ieee.std_logic_1164.all;
-- 4x1 necessário caso sejam feitas as otimizações
-- 2x1 pode ser usado caso elas não sejam feitas
entity mux4x1 is
    port(
        D0, D1, D2, D3 : in std_logic_vector(31 downto 0);
        S: in STD_LOGIC_VECTOR(1 downto 0);
        Y : out std_logic_vector(31 downto 0)
    );
end mux4x1;


architecture mux4x1_arch1 of mux4x1 is
begin
    Y <=    D0 when S = "00" else
            D1 when S = "01" else
            D2 when S = "10" else
            D3;
end mux4x1_arch1;
