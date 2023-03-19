library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity conv_tb is
    end entity;
    
    architecture beh of conv_tb is 
    
        constant clk_period : time := 100 ns;
        constant N_image : positive := 3;
        constant M_kernel : positive := 2;
    
        component conv 
            generic (
                DIM_IMG : positive;
                DIM_KER : positive
            );
            port (
                clk : in std_logic;
                reset: in std_logic; 
                in_image: in std_logic_vector(7 downto 0);
                in_kernel: in std_logic_vector(7 downto 0)
                out_conv: out std_logic_vector(7 downto 0)
            );
        end component;    
    
        signal clk_ext : std_logic := '0';
        signal reset_ext : std_logic := '0';
        signal image_ext :  std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(0,8));
        signal kernel_ext :  std_logic_vector(7 downto 0);
        signal out_ext :  std_logic_vector(7 downto 0);
        signal testing : boolean := true; 

        begin 
            clk_ext <= not clk_ext after clk_period/2 when testing else '0';

            DUT: conv 
                generic map (
                    DIM_IMG => N_image,
                    DIM_KER => M_kernel
                )
                port map (
                    clk => clk_ext,
                    reset => reset_ext,
                    in_image => image_ext,
                    in_kernel => kernel_ext,
                    out_conv => out_ext
                );

    STIMULI: process(clk_ext, reset_ext)  -- process used to make the testbench signals change synchronously with the rising edge of the clock
    variable t : integer := 0;  -- variable used to count the clock cycle after the reset
    begin
        if(reset_ext = '0') then
        image_ext <= (others => '0');
        t := 0;
        elsif(rising_edge(clk_ext)) then
        case(t) is
            when 30 => image_ext   <= x"1";
            when 31 => image_ext   <= x"2";
            when 32 => image_ext    <= x"3";
            when 33 => image_ext    <= x"4";
            when 34 => image_ext    <= x"5";
            when 35 => image_ext    <= x"6";
            when 36 => image_ext    <= x"7";
            when 37 => image_ext    <= x"8";
            when 38 => image_ext    <= x"9";
            when 40 => end_sim <= '0';  -- This command stops the simulation when t = 10
            when others => null;        -- Specifying that nothing happens in the other cases
        end case;

        t := t + 1;  -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
        end if;
    end process;

    end architecture;
