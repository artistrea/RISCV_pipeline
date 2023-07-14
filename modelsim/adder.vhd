library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity adder is
    port(
        A, B : in std_logic_vector(31 downto 0);
        -- Cin: in std_logic;
        Y : out std_logic_vector(31 downto 0)
        -- Cout: out std_logic
    );
end adder;

architecture adder_arch of adder is

begin
    Y <= A + B;
    -- Cout <= A and B;
end adder_arch;
