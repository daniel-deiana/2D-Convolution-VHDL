library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library work;
    use work.common_pkg.all;


entity convolution is 
    generic (
        DIM_KER : positive
        DIM_IMG : positive 
    );
    port (
        clk : in std_logic;
        reset : in std_logic; 
        
    );
end entity;