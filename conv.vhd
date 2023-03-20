library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
        out_conv: out std_logic_vector(7 downto 0)
    );
end entity;


architecture arch of conv is

    type vec is array (0 to DIM_KER*DIM_KER) of std_logic_vector(7 downto 0);
    signal propagate : vec ;

    component shift_reg
        generic(
            -- dimennsion of dffs
            N : positive;
            -- dimension of fibo buffer 
            M : positive
        );
        port (
            clk_s : in std_logic;
            reset: in std_logic; 
            data_in: in std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(7 downto 0)
        );
    end component;
    
    begin

    -- we use only fifo buffers
    -- a dff is a fifo buffer with M=1

    l1_for:for i in 0 to DIM_KER - 1 generate
        l2_for: for j in 0 to DIM_KER - 1 generate
            -- first
            l1:if j = 0 and i = 0 generate
               buf0: shift_reg 
               generic map (
                    N => 8,
                    M => 1
                )
                port map(
                    clk_s => clk,
                    reset => reset,
                    data_in => in_image,
                    data_out => propagate(i*DIM_KER + j)
                );
            end generate;
            l2:if j > 0 or i > 0 generate
            -- dffs 
               buf: shift_reg 
               generic map (
                    N => 8,
                    M => 1
                )
                port map(
                    clk_s => clk,
                    reset => reset,
                    data_in => propagate(i*DIM_KER+j-1),
                    data_out => propagate(i*DIM_KER+j)
                );
            end generate;
        end generate;

        -- buffer 
        l3:if i <  DIM_KER - 1 generate
           buf1: shift_reg generic map (
                N => 8,
                M => DIM_IMG - DIM_KER
            )
            port map(
                clk_s => clk,
                reset => reset,
                data_in => propagate(i*DIM_KER + DIM_KER - 1),
                data_out => propagate(i*DIM_KER + DIM_KER)
            );
        end generate;
        end generate; 
        out_conv <= propagate(DIM_KER*DIM_KER);
end architecture;
