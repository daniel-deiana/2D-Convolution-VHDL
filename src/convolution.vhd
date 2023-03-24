library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library work;
    use work.common_pkg.all;
    use work.utilities.all;


--------------------------------------------------------------------
-- Interface Declaration
--------------------------------------------------------------------

entity convolution is 
    generic (
        DIM_KER : positive := 2;
        DIM_IMG : positive := 4;
        N_BIT : positive : 8
    );
    port (
        clk : in std_logic;
        reset : in std_logic; 
        x : in std_logic_vector(N_BIT - 1 downto 0);
        if_signal : in std_logic;
        x_valid : in std_logic;
        y_valid : out std_logic;
        y : out std_Logic_vector(N_BIT - 1 downto 0)

    );
end entity;

--------------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------------

architecture conv of convolution is
    
    signal data_out_pipeline is VECTOR(DIM_KER*DIM_KER-1 downto 0);
    signal to_alu is VECTOR(2*DIM_KER*DIM_KER - 1 downto 0)

    begin

    component pipeline 
    generic (
        DEPTH : positive;
        DATA_WIDTH : positive
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        in_image: in std_logic_vector(7 downto 0);
        in_kernel: in std_logic_vector(7 downto 0);
        out_conv: out arr(DIM_KER*DIM_KER-1 downto 0)
    );
    end component;

    component alu 
    generic (
        K : positive
    );
    port (
        INPUT  : in  VECTOR((2*K*K)-1 downto 0);
        OUTPUT : out std_logic_vector(N_BIT-1 downto 0)
    );
    end component;

    assignments: process(to_alu)
    for i in 0 to 2 * DIM_KER * DIM_KER - 1 loop
        if i < DIM_KER*DIM_KER then
            to_alu(i) <= data_out_pipeline(i); 
        else
            -- static value assignements for debug
            to_alu(i) <= std_logic_vector(to_unsigned(1,N_BIT));
        end if;
    end loop;
    end process;


    --------------------------------------------------------------------
    -- Pipeline unit istantiation
    --------------------------------------------------------------------

    pipeline: pipeline
    generic map(
        DIM_KER => DIM_KER,
        DIM_IMG => DIM_IMG
    )
    port map(
        clk => clk,
        reset => reset,
        in_image => x,
        out_conv => data_out_pipeline
    );


    --------------------------------------------------------------------
    -- Alu unit istantiation
    --------------------------------------------------------------------

    alu: alu 
    generic map(
        K => DIM_KER
    )  
    port map(
        INPUT => to_alu,
        OUTPUT => y
    );

end architecture;