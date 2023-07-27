LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

ENTITY control_unit_tb IS END;


ARCHITECTURE control_unit_tb_arch OF control_unit_tb IS
    component control_unit is
        generic (WSIZE : natural := 32);
        port (
            instr : in std_logic_vector(31 downto 0);
            -- ex
            alu_op : out std_logic_vector(3 downto 0) := (others => '0');
            alu_srcA : out std_logic_vector(1 downto 0) := (others => '0');
            alu_srcB : out std_logic_vector(1 downto 0) := (others => '0');
            -- mem
            mem_read : out std_logic := '0';
            mem_write : out std_logic := '0';
            branch_cond : out std_logic := '0';
            branch_uncond : out std_logic := '0';
            branch_src : out std_logic := '0';
            -- wb
            reg_write : out std_logic := '0';
            mem_to_reg : out std_logic := '0'
        );
    end component;
    
    signal instr : std_logic_vector(31 downto 0);
    -- ex
    signal alu_op : std_logic_vector(3 downto 0) := (others => '0');
    signal alu_srcA : std_logic_vector(1 downto 0) := (others => '0');
    signal alu_srcB : std_logic_vector(1 downto 0) := (others => '0');
    -- mem
    signal mem_read : std_logic := '0';
    signal mem_write : std_logic := '0';
    signal branch_cond : std_logic := '0';
    signal branch_uncond : std_logic := '0';
    signal branch_src : std_logic := '0';
    -- wb
    signal reg_write : std_logic := '0';
    signal mem_to_reg : std_logic := '0';

    signal T : time := 2 ps;
begin
    dut : control_unit
        port map (
            instr => instr,
            alu_op => alu_op,
            alu_srcA => alu_srcA,
            alu_srcB => alu_srcB,
            mem_read => mem_read,
            mem_write => mem_write,
            branch_cond => branch_cond,
            branch_uncond => branch_uncond,
            branch_src => branch_src,
            reg_write => reg_write,
            mem_to_reg => mem_to_reg
        );

    process begin
        report "control_unit_tb testbench began" severity note;
        wait for T/2;
        -- addi t1, zero, 10
        instr <= x"00a00313";
        wait for T/2;
        assert (alu_op = "0000") report "alu_op" severity error;
        assert (alu_srcA = "00") report "alu_srcA" severity error;
        assert (alu_srcB = "01") report "alu_srcB" severity error;
        assert (mem_read = '0') report "mem_read" severity error;
        assert (mem_write = '0') report "mem_write" severity error;
        assert (branch_cond = '0') report "branch_cond" severity error;
        assert (branch_uncond = '0') report "branch_uncond" severity error;
        assert (branch_src = '0') report "branch_src" severity error;
        assert (reg_write = '1') report "reg_write" severity error;
        assert (mem_to_reg = '0') report "mem_to_reg" severity error;

        -- sw t1, 0(x0)
        wait for T/2;
        instr <= x"00602023";
        wait for T/2;
        assert (alu_op = "0000") report "alu_op" severity error;
        assert (alu_srcA = "00") report "alu_srcA" severity error;
        assert (alu_srcB = "01") report "alu_srcB" severity error;
        assert (mem_read = '0') report "mem_read" severity error;
        assert (mem_write = '1') report "mem_write" severity error;
        assert (branch_cond = '0') report "branch_cond" severity error;
        assert (branch_uncond = '0') report "branch_uncond" severity error;
        assert (branch_src = '0') report "branch_src" severity error;
        assert (reg_write = '0') report "reg_write" severity error;
        assert (mem_to_reg = '0') report "mem_to_reg" severity error;

        
        wait for T/2;
        instr <= x"00a00313";
        wait for T/2;
        assert (alu_op = "0000") report "alu_op" severity error;
        assert (alu_srcA = "00") report "alu_srcA" severity error;
        assert (alu_srcB = "01") report "alu_srcB" severity error;
        assert (mem_read = '0') report "mem_read" severity error;
        assert (mem_write = '0') report "mem_write" severity error;
        assert (branch_cond = '0') report "branch_cond" severity error;
        assert (branch_uncond = '0') report "branch_uncond" severity error;
        assert (branch_src = '0') report "branch_src" severity error;
        assert (reg_write = '1') report "reg_write" severity error;
        assert (mem_to_reg = '0') report "mem_to_reg" severity error;

        wait for T/2;

        report "control_unit_tb testbench ended" severity note;
        wait;
    end process;
end control_unit_tb_arch;

