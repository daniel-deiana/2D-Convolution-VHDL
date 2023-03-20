library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_reg is 
    generic (
        N : natural := 8;
        M : natural := 4
    );
    port (
        clk_s : in std_logic;
        reset: in std_logic; 
        data_in: in std_logic_vector(N-1 downto 0);
        data_out: out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture str of shift_reg is
 
    --  signals 
    type vec is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal propagate : vec;
    
    -- declaration of d flip-flop with enable signal
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

GEN: for i in 0 to M - 1 generate

    FIRST: if i = 0 generate
      DDF_N_1: DFCE_N
        generic map ( N  => 8 )
        port map (
          clk     => clk_s,
          en      => '1',
          resetn => reset,
          di       => data_in,
          do       => propagate(i)
        );
    end generate;

    SECONDS: if i > 0 and i < M generate
      DDF_N_2: DFCE_N
        generic map ( N  => 8 )
        port map (
          clk     => clk_s,
          en      => '1',
          resetn => reset,
          di       => propagate(i-1),
          do       => propagate(i)
        );
    end generate;
  end generate;

  data_out <= propagate(M-1);
end architecture;        
