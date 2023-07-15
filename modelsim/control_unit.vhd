library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        instr : in std_logic_vector(31 downto 0);
        -- ex
        alu_op : out std_logic_vector(3 downto 0);
        alu_src : out std_logic;
        -- mem
        mem_read : out std_logic;
        mem_write : out std_logic;
        branch : out std_logic;
        -- wb
        reg_write : out std_logic;
        mem_to_reg : out std_logic
    );
end control_unit;

architecture control_unit_arch of control_unit is
    type FORMAT_RV is ( R_type, I_type, S_type, SB_type, UJ_type, U_type, Unknown_type );

    signal format : FORMAT_RV;


begin
    process(instr)
    begin
        case instr(6 downto 0) is
            when "0110011" => format <= R_type;
            when "0000011" => format <= I_type;
            when "0010011" => format <= I_type;
            when "1100111" => format <= I_type;
            when "0100011" => format <= S_type;
            when "1100011" => format <= SB_type;
            when "0110111" => format <= U_type;
            when "1101111" => format <= UJ_type;
            when others => format <= Unknown_type;
        end case;
    end process;

    process(format, instr)
    begin

    end process;

end control_unit_arch;

