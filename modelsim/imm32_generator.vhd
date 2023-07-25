
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm32_generator is
    port(
        instr : in std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
end imm32_generator;

architecture imm32_generatorArch of imm32_generator is
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
                when "0010111" => format <= U_type;
                when "1101111" => format <= UJ_type;
                when others => format <= Unknown_type;
            end case;
        end process;

        process(format, instr)
        begin
            case format is
                when R_type  => imm32 <= (others => '0');
                when I_type  => imm32 <= resize(signed(instr(31 downto 20)), 32);
                when S_type  => imm32 <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);
                when SB_type => imm32 <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32);
                when UJ_type => imm32 <= resize(signed( instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);
                when U_type  => imm32 <= signed(instr(31 downto 12) & X"000") ;
                when others  => imm32 <= (others => '0');
            end case;
        end process;
end imm32_generatorArch;
