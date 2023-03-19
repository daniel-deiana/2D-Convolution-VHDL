library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_reg is 
    generic (
        N : positive := 4;
        M : positive := 8
    );
    port (
        clk_s : in std_logic;
        reset: in std_logic; 
        d: in std_logic_vector(N-1 downto 0);
        q: out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture str of shift_reg is
 
    --  signals 
    type vec is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal propagate : vec := (others => (others => '0'));

    component DFCE_N 
        generic (
            N : positive
        );
        port (
            clk : in std_logic;
            en : in std_logic;
            resetn : in std_logic;
            di : in std_logic_vector(N-1 downto 0);
            do : out std_logic_vector(N-1 downto 0)
        );
    end component; 

    begin

    l_for: for i in 0 to M-2 generate
    
        l_first: if i = 0 generate
            first: DFCE_N 
                generic map (
                    N => N
                )
                port map (
                    clk => clk_s,
                    en => '1',
                    resetn => reset,
                    di => d,
                    do => propagate(i)
                );
        end generate;

        l_int: if i > 0 and i < M-1 generate
            int: DFCE_N 
                generic map (
                    N => N
                )
                port map (
                    clk => clk_s,
                    en => '1',
                    resetn => reset,
                    di => propagate(i-1),
                    do => propagate(i)
                );
        end generate;

        l_out: if i = M-1 generate
            outer: DFCE_N 
            generic map (
                N => N
            )
            port map (
                clk => clk_s,
                en => '1',
                resetn => reset,
                di => propagate(i-1),
                do => q
            );
        end generate;

    end generate;
end architecture;        
