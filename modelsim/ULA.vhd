LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        opcode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(31 downto 0);
        Y : out std_logic_vector(31 downto 0);
        zero : out std_logic
    );
end ULA;

architecture ULA_arch of ULA is
    signal out32 : std_logic_vector(31 downto 0);

    type OPERATIONS is (
        ADD_OP, SUB_OP, AND_OP, OR_OP, XOR_OP, SLL_OP, SLA_OP,SRL_OP,
        SRA_OP, SLT_OP, SLTU_OP, SGE_OP, SGEU_OP, SEQ_OP, SNE_OP
    );
    signal operation : OPERATIONS;
begin
    Y <= out32;
    
    gen_zero: process (out32) begin
        if (out32 = X"00000000") then zero <= '1'; else zero <= '0'; end if;
    end process;

    gen_out: process (operation, opcode, A, B) begin
        case( operation ) is
            when ADD_OP => out32 <= std_logic_vector(signed(A)+signed(B));
            when SUB_OP => out32 <= std_logic_vector(signed(A)-signed(B));
            when AND_OP => out32 <= A and B;
            when OR_OP => out32 <= A or B;
            when XOR_OP => out32 <= A xor B;
            when SLL_OP => out32 <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B(4 downto 0))));
            when SLA_OP => out32 <= 
                A(31) & std_logic_vector(resize(unsigned(A) sll to_integer(unsigned(B(4 downto 0))), 31));
            when SRL_OP => out32 <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B(4 downto 0))));
            when SRA_OP => out32 <= std_logic_vector(signed(A) sra to_integer(unsigned(B(4 downto 0))));
            when SLT_OP => if (signed(A) < signed(B))
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when SLTU_OP => if (unsigned(A) < unsigned(B))
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when SGE_OP => if (signed(A) >= signed(B))
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when SGEU_OP => if (unsigned(A) >= unsigned(B))
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when SEQ_OP => if (A = B)
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when SNE_OP => if (A /= B)
                then out32 <= x"00000001";
                else out32 <= x"00000000";
                end if;
            when others => out32<=std_logic_vector(signed(A)+signed(B));
        end case;
    end process;

    get_op: process (opcode) begin
        case( opcode ) is
            when "0000" => operation <= ADD_OP;
            when "0001" => operation <= SUB_OP;
            when "0010" => operation <= AND_OP;
            when "0011" => operation <= OR_OP;
            when "0100" => operation <= XOR_OP;
            when "0101" => operation <= SLL_OP;
            when "0110" => operation <= SLA_OP;
            when "0111" => operation <= SRL_OP;
            when "1000" => operation <= SRA_OP;
            when "1001" => operation <= SLT_OP;
            when "1010" => operation <= SLTU_OP;
            when "1011" => operation <= SGE_OP;
            when "1100" => operation <= SGEU_OP;
            when "1101" => operation <= SEQ_OP;
            when "1110" => operation <= SNE_OP;
            when others => operation <= ADD_OP;
        end case ;
    end process;
    
end architecture;


