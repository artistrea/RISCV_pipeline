library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity tb_complex_ops is
end tb_complex_ops;

architecture tb_complex_ops_arch of tb_complex_ops is
    signal clk, processor_clk, data_mem_write_PRC, data_mem_read_PRC, data_mem_read_TB_or_PRC, write_signal_instr_TB_or_PRC, write_signal_instr_TB, write_signal_data_TB_or_PRC, write_signal_data_TB : std_logic := '0';
    signal instr_address_PRC, data_address_PRC : std_logic_vector(9 downto 0) := (others => '0');
    signal data_mem_read_data_DM, write_data_instr_TB, write_data_TB_or_PRC, write_data_TB,  instruction_IM, write_data_PRC : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_address_TB_or_PRC, instr_address_TB, data_address_TB_or_PRC, data_address_TB : std_logic_vector(7 downto 0) := (others => '0');

    signal testbench_controls : boolean := true;

    file text_file : text open read_mode is "../rars/complexOps/bge/instr_dump.txt";
    file data_file : text open read_mode is "../rars/complexOps/bge/data_dump.txt";
    file data_after_file : text open read_mode is "../rars/complexOps/bge/data_after_dump.txt";
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

    constant T : time := 20 ps;

begin
    processor : RISCV_pipeline port map (
        CLK => processor_clk,
        instruction => instruction_IM,
        instruction_mem_addr => instr_address_PRC,
        data_mem_addr => data_address_PRC,
        data_mem_write => data_mem_write_PRC,
        data_mem_read => data_mem_read_PRC,
        data_mem_write_data => write_data_PRC,

        data_mem_read_data => data_mem_read_data_DM
    );
    instr_memory : memory port map (
        clk => clk,
        address => instr_address_TB_or_PRC,
        write_signal => write_signal_instr_TB_or_PRC,
        read_signal => '1',
        write_data => write_data_instr_TB,

        read_data => instruction_IM
    );
    data_memory : memory port map (
        clk => clk,
        address => data_address_TB_or_PRC,
        write_signal => write_signal_data_TB_or_PRC,
        read_signal => data_mem_read_TB_or_PRC,
        write_data => write_data_TB_or_PRC,

        read_data => data_mem_read_data_DM
    );

    -- data mem control
    data_address_TB_or_PRC  <=      data_address_TB         when testbench_controls else data_address_PRC(9 downto 2);
    write_signal_data_TB_or_PRC <=  write_signal_data_TB    when testbench_controls else data_mem_write_PRC;
    data_mem_read_TB_or_PRC <=      '1'                     when testbench_controls else data_mem_read_PRC;
    write_data_TB_or_PRC    <=      write_data_TB           when testbench_controls else write_data_PRC;
    
    -- instr mem control
    write_signal_instr_TB_or_PRC   <=      write_signal_instr_TB    when testbench_controls else '0';
    instr_address_TB_or_PRC <=      instr_address_TB        when testbench_controls else instr_address_PRC(9 downto 2);
    -- processor clk control
    processor_clk           <=      '0'                     when testbench_controls else clk;
    

    process
        variable hexa_read : std_logic_vector(31 downto 0);
        variable text_line : line;
    begin
        report "Setting up testbench processor" severity NOTE;
        testbench_controls <= true;
        write_signal_data_TB <= '0';
        write_signal_instr_TB <= '1';
        for i in 0 to 255 loop
            readline(text_file, text_line);
            hread(text_line, hexa_read);
            write_data_instr_TB <= hexa_read;
            instr_address_TB <= std_logic_vector(to_unsigned(i, 8));
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end loop;
        write_signal_instr_TB <= '0';
        write_signal_data_TB <= '1';
        for i in 0 to 255 loop
            readline(data_file, text_line);
            hread(text_line, hexa_read);
            write_data_TB <= hexa_read;
            data_address_TB <= std_logic_vector(to_unsigned(i, 8));
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end loop;
        write_signal_data_TB <= '0';


        report "Ended testbench setup. Processor running" severity NOTE;
        testbench_controls <= false;

        for i in 0 to 200 loop
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end loop;

        report "Finished running the hardcoded cycles. Tesbench running" severity NOTE;
        testbench_controls <= true;

        for i in 0 to 255 loop
            readline(data_after_file, text_line);
            hread(text_line, hexa_read);
            data_address_TB <= std_logic_vector(to_unsigned(i, 8));
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
            assert data_mem_read_data_DM = hexa_read
            report "[ADDR:"& to_hstring(data_address_TB) &"]data_mem_read_data_DM should be "& to_hstring(hexa_read) &", but is "& to_hstring(data_mem_read_data_DM) severity ERROR;
        end loop;

        report "Finished Testbench" severity NOTE;
        wait;
    end process;
end tb_complex_ops_arch;
