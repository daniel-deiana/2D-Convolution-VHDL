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
        out_conv: out std_logic_vector(7 downto 0);
    );
end entity;


architecture arch of conv is

    type vec is array (0 to (DIM_KER*DIM_KER)-1) of std_logic_vector(7 downto 0);
    signal propagate : vec := (others => (others => '0'));

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
            d: in std_logic_vector(7 downto 0);
            q: out std_logic_vector(7 downto 0)
        );
    end component;
    
    begin
    -- we use only fifo buffers
    -- a dff is a fifo buffer with M=1

    for i in 0 to DIM_KER - 1 generate
        for j in 0 to DIM KER - 1 generate
            if j = 0 and i = 0 generate
                shift_reg generic map (
                    N => 8
                    M => 1
                )
                port map(
                    clk_s => clk,
                    reset => reset,
                    d => in_image,
                    q => propagate(i)
                )
            else
                shift_reg generic map (
                    N => 8
                    M => 1
                )
                port map(
                    clk_s => clk,
                    reset => reset,
                    d => propagate(i*DIM_KER + j -1),
                    q => propagate(i*DIM_KER + j)
                )
            end generate;
        end generate
            shift_reg generic map (
                N => 8
                M => DIM_IMG - DIM_KER
            )
            port map(
                clk_s => clk,
                reset => reset,
                d => propagate(i*DIM_KER + DIM_KER - 1),
                q => propagate(i*DIM_KER + DIM_KER)
            )
    end generate; 
end architecture;