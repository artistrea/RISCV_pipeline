library ieee;
use ieee.std_logic_1164.all;

entity register32 is
    port(
        X : in std_logic_vector(31 downto 0);
        Y : out std_logic_vector(31 downto 0);
        clk : in std_logic
    );
end register32;


architecture register32_arch1 of register32 is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            Y <= X;
        end if;
    end process;
end register32_arch1;
