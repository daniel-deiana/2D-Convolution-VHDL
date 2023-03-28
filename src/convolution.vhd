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
        N_BIT : positive := 8
    );
    port (
        clk : in std_logic;
        reset : in std_logic; 
        x : in std_logic_vector(N_BIT - 1 downto 0);
        if_signal : in std_logic;
        x_valid : in std_logic;
        y_valid : out std_logic;
        y : out std_Logic_vector(N_BIT - 1 downto 0);
        data_out_kernel : in VECTOR(DIM_KER*DIM_KER -1 downto 0)

    );
end entity;

--------------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------------

architecture conv of convolution is

    signal data_out_pipeline : VECTOR(DIM_KER*DIM_KER-1 downto 0);
    signal stall_sig : std_logic;

    component state_machine is 
    generic (
        DIM_KER : positive;
        DIM_IMG : positive    
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        i_f . in std_logic;
        x_valid : in std_logic;
        y_valid : out std_logic;
        stall : out std_logic;
    );
    end component;

    component pipeline is 
    generic (
        DIM_IMG : positive;
        DIM_KER : positive
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        in_image: in std_logic_vector(7 downto 0);
        out_conv: out VECTOR(DIM_KER*DIM_KER-1 downto 0)
    );
    end component;

    component alu is
    generic (
        K : positive
    );
    port (
        INPUT0  : in  VECTOR((K*K)-1 downto 0);
        INPUT1  : in  VECTOR((K*K)-1 downto 0);
        OUTPUT : out std_logic_vector(N_BIT-1 downto 0)
    );
    end component;

    begin

    --------------------------------------------------------------------
    -- State Machine istantiation
    --------------------------------------------------------------------
    fsm0: state_machine 
    generic map (
        DIM_KER => DIM_KER,
        DIM_IMG => DIM_IMG
    )
    port map (
        clk => clk,
        reset => reset,
        i_f => if_signal,
        x_valid => x_valid,
        y_valid => y_valid,
        stall => stall_sig
    );
    --------------------------------------------------------------------
    -- Pipeline unit istantiation
    --------------------------------------------------------------------
    pipeline0: pipeline
    generic map(
        DIM_IMG => DIM_IMG,
        DIM_KER => DIM_KER
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
    alu0: alu 
    generic map(
        K => DIM_KER
    )  
    port map(
        INPUT0 => data_out_pipeline,
        INPUT1 => data_out_kernel,  
        OUTPUT => y
    );


end architecture;