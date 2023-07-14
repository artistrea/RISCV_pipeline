
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XREGS is
    generic (WSIZE : natural := 32);
    port (
        clk, wren : in std_logic;
        rs1, rs2, rd : in std_logic_vector(4 downto 0);
        data : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0) := (others => '0')
    );
end XREGS;

architecture XREGS_arch of XREGS is
    type regs is array(31 downto 0) of std_logic_vector(WSIZE-1 downto 0);
    signal regs_data: regs := (others => (others => '0'));
begin
    on_clock_up: process(CLK)
    begin
        if rising_edge(CLK) then
            ro1 <= regs_data(to_integer(unsigned(rs1)));
            ro2 <= regs_data(to_integer(unsigned(rs2)));
            if (wren = '1' and unsigned(rd) /= "0000") then
                regs_data(to_integer(unsigned(rd))) <= data;
            end if;
        end if;
    end process on_clock_up;
end XREGS_arch;
