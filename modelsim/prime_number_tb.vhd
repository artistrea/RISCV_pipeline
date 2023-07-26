library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity prime_number_tb is
end prime_number_tb;

architecture prime_number_tb_arch of prime_number_tb is
    signal clk, data_mem_write, data_mem_read, write_signal_instr, write_signal_data, read_signal_instr : std_logic;
    signal instruction_mem_addr, data_mem_addr : std_logic_vector(9 downto 0);
    signal instruction, data_mem_write_data, data_mem_read_data, write_data_instr, write_data_data, read_data_instr : std_logic_vector(31 downto 0);
    signal instr_address, data_address : std_logic_vector(7 downto 0);
    -- TODO: fix file paths:
    file text_file : text open read_mode is "text.txt";
    file data_file : text open read_mode is "data.txt";
    component RISCV_pipeline is
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
    end component;
    component memory is
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
        processor : RISCV_pipeline
        port map (
            CLK => clk,
            instruction => instruction,
            instruction_mem_addr => instruction_mem_addr,
            data_mem_addr => data_mem_addr,
            data_mem_write => data_mem_write,
            data_mem_read => data_mem_read,
            data_mem_write_data => data_mem_write_data,
            data_mem_read_data => data_mem_read_data
        );
        instr_memory : memory
        port map (
            address => instr_address,
            clk => clk,
            write_signal => write_signal_instr,
            read_signal => read_signal_instr,
            write_data => write_data_instr,
            read_data => read_data_instr
        );
        data_memory : memory
        port map (
            address => data_address,
            clk => clk,
            write_signal => write_signal_data,
            read_signal => data_mem_read,
            write_data => write_data_data,
            read_data => data_mem_read_data
        );

    clock : process
    begin
        clk <= '0';
        wait for 10 ps;
        clk <= '1';
        wait for 10 ps;
    end process clock;

    load_instr_mem : process
    variable instr : std_logic_vector(31 downto 0);
    variable text_line : line;
    begin
        write_signal_instr <= '1';
        read_signal_instr <= '1';
        for i in 0 to 255 loop
            readline(text_file, text_line);
            hread(text_line, instr);
            write_data_instr <= instr;
            instr_address <= std_logic_vector(to_unsigned(i, 8));
            wait for 20 ps;
        end loop;
        write_signal_instr <= '0';
        wait;
    end process load_instr_mem;
    
    load_data_mem : process
    variable data : std_logic_vector(31 downto 0);
    variable data_line : line;
    begin
        write_signal_data <= '1';
        for i in 0 to 255 loop
            readline(data_file, data_line);
            hread(data_line, data);
            write_data_data <= data;
            data_address <= std_logic_vector(to_unsigned(i, 8));
            wait for 20 ps;
        end loop;
        write_signal_data <= '0';
        wait;
    end process load_data_mem;

    init : process
    begin
        wait for 5200 ps;
        for i in 0 to 200 loop
            instr_address <= instruction_mem_addr(9 downto 2);
            instruction <= read_data_instr;
            data_address <= data_mem_addr(9 downto 2);
            write_signal_data <= data_mem_write;
            wait for 20 ps;
        end loop;
        data_address <= "00000000";
        read_signal <= '1';
        wait for 20 ps;
        assert data_mem_read_data /= X"00000002"
        report "erro primo"
        severity ERROR;
        wait for 20 ps;
        data_address <= "00001010";
        wait for 20 ps;
        assert data_mem_read_data /= X"0000001F"
        report "erro primo"
        severity ERROR;
        wait;
    end process init;
end prime_number_tb_arch;
