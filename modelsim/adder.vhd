library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port(
        A, B : in std_logic_vector(31 downto 0);
        Y : out std_logic_vector(31 downto 0)
    -- carries would normally exist as well:
        -- Cin: in std_logic;
        -- Cout: out std_logic
    );
end adder;

architecture adder_arch of adder is

begin
    Y <= std_logic_vector(signed(A) + signed(B));
    -- Cout <= '1' when (signed(A) + signed(B) > 2**32-1) else '0';
end adder_arch;
