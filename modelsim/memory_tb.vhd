library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity memory_tb is
end memory_tb;

architecture memory_tb_arch of memory_tb is
    signal address : std_logic_vector(7 downto 0);
    signal clk : std_logic;
    signal write_signal : std_logic;
    signal read_signal : std_logic;
    signal write_data : std_logic_vector(31 downto 0);
    signal read_data : std_logic_vector(31 downto 0);
    file text_file : text open read_mode is "../rars/prime/instr_dump.txt";
    component memory
        port (
            address : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            write_signal : in std_logic;
            read_signal : in std_logic;
            write_data : in std_logic_vector(31 downto 0);
            read_data : out std_logic_vector(31 downto 0)
        );
    end component;

    begin
        i1 : memory
        port map (
            address => address,
            clk => clk,
            write_signal => write_signal,
            read_signal => read_signal,
            write_data => write_data,
            read_data => read_data
        );

    clock : process
    begin
        clk <= '0';
        wait for 10 ps;
        clk <= '1';
        wait for 10 ps;
    end process clock;
    
    init : process
    variable data : std_logic_vector(31 downto 0);
    variable text_line : line;
    begin
        -- read every line from text loop
        write_signal <= '1';
        read_signal <= '1';
        for i in 0 to 255 loop
            readline(text_file, text_line);
            hread(text_line, data);
            write_data <= data;
            address <= std_logic_vector(to_unsigned(i, 8));
            wait for 20 ps;
        end loop;
        write_signal <= '0';
        wait for 20 ps;
        for i in 0 to 255 loop
            address <= std_logic_vector(to_unsigned(i, 8));
            wait for 20 ps;
        end loop;
        wait;
    end process init;
end memory_tb_arch;