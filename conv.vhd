library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--------------------------------------------------------------------
-- Package (used for declaration of array of std_logic_vector)
--------------------------------------------------------------------

package pkg is
  type array_t is array (natural range <>) of std_logic_vector(7 downto 0);
end package;

package body pkg is
end package body;

library work;
use work.pkg.all;

--------------------------------------------------------------------
-- Interface Declaration
--------------------------------------------------------------------

entity conv is 
    generic(
        DIM_IMG : positive := 3;
        DIM_KER : positive := 2
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        in_image: in std_logic_vector(7 downto 0);
        in_kernel: in std_logic_vector(7 downto 0);
        out_conv: out array_t(0 to DIM_KER*DIM_KER-1 )
    );
end entity;


--------------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------------
architecture arch of conv is

    type vec is array (0 to DIM_KER*DIM_KER) of std_logic_vector(7 downto 0);
    signal path : vec ;

    component fifo
        generic(
            -- dimension of the fifo buffer
            DEPTH : positive;
            -- size of dffs
            DATA_WIDTH : positive
        );
        port (
            clk : in std_logic;
            a_rst_n: in std_logic;
            data_in: in std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(7 downto 0)
        );
    end component;
    
    begin

    --------------------------------------------------------------------
    -- We use for generate to build up the pipeline, using fifo buffers
    -- DFFs are fifo with DEPTH = 1
    --------------------------------------------------------------------

    l1_for:for i in 0 to (DIM_KER-1)*(DIM_KER+1) generate


    --------------------------------------------------------------------
    -- Start of the pipeline 
    --------------------------------------------------------------------
        
        l1_if: if i = 0 generate
        dff0: fifo generic map(
            DEPTH => 1,
            DATA_WIDTH => 8
        )
        port map(
            clk => clk,
            a_rst_n => reset,
            data_in => in_image,
            data_out => path(i)
        );
        end generate;

    --------------------------------------------------------------------
    -- Internal components of the pipeline, when i%DIM_KER != 0 we use 
    -- a fifo with DEPTH = 1 (to declare a DFF) 
    --------------------------------------------------------------------    
        l2_if: if i > 0 and i mod DIM_KER /= 0 generate
        dff0: fifo generic map(
            DEPTH => 1,
            DATA_WIDTH => 8
        )
        port map(
            clk => clk,
            a_rst_n => reset,
            data_in => path(i-1),
            data_out => path(i)
        );
        end generate;

    --------------------------------------------------------------------
    -- Internal components of the pipeline, when i%DIM_KER != 0 we use 
    -- a fifo with DEPTH = DIM_IMG - DIM_KER (to declare a fifo buffer 
    -- used to store matrix values that in a cycle we dont use for computations) 
    --------------------------------------------------------------------

        l3_if: if i > 0 and i mod DIM_KER = 0 generate
        dff0: fifo generic map(
            DEPTH => DIM_IMG - DIM_KER ,
            DATA_WIDTH => 8
        )
        port map(
            clk => clk,
            a_rst_n => reset,
            data_in => path(i-1),
            data_out => path(i)
        );
        end generate;
    end generate;

    --------------------------------------------------------------------
    -- Last level of the pipeline, we don't need a fifo buffer at the end 
    --------------------------------------------------------------------

    l2_for:for i in (DIM_KER-1)*(DIM_KER+1) + 1 to (DIM_KER-1)*(DIM_KER+1) + DIM_KER - 1  generate
        dfflast: fifo generic map(
            DEPTH => 1,
            DATA_WIDTH => 8
        )
        port map(
            clk => clk,
            a_rst_n => reset,
            data_in => path(i-1),
            data_out => path(i)
        );
    end generate;
end architecture;
