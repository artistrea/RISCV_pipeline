library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port (
        address : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        write_signal : in std_logic;
        read_signal : in std_logic;
        write_data : in std_logic_vector(31 downto 0);
        read_data : out std_logic_vector(31 downto 0)
    );
end memory;

architecture memory_arch of memory is
    type mem is array(0 to 255) of std_logic_vector(31 downto 0);
    signal mem_data : mem;
begin
    on_clk_up : process(clk)
    begin
        if rising_edge(clk) then
            if write_signal = '1' then
                mem_data(to_integer(unsigned(address))) <= write_data;
                read_data <= mem_data(to_integer(unsigned(address)));
            end if;
            if read_signal = '1' then
                read_data <= mem_data(to_integer(unsigned(address)));
            end if;
        end if;
    end process on_clk_up;
end memory_arch;
