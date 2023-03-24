library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library work;
    use work.utilities.all;
    use work.common_pkg.all;


entity convolution_tb  is
    end entity;
    
    architecture beh of convolution_tb is 
    
        constant T_RESET : time := 25 ns;
        constant clk_period : time := 10 ns;
        constant N_image : positive := 4;
        constant M_kernel : positive := 2;

        component convolution is 
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
            data_out_kernel : in VECTOR(M_kernel*M_kernel-1 downto 0)

        );
        end component;
    
        signal clk_ext : std_logic := '0';
        signal reset_ext : std_logic := '0';
        signal image_ext :  std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(0,8));
        signal kernel_ext :  std_logic_vector(7 downto 0);
        signal out_ext : std_logic_vector(7 downto 0);
        signal end_sim : std_logic := '1'; 
        signal y_valid_ext : std_logic ;
        signal data_out_kernel_ext : VECTOR(M_kernel*M_kernel-1 downto 0) := (others=> std_logic_vector(to_unsigned(1,8)));

        begin 
            clk_ext <= (not clk_ext and end_sim) after clk_period/2;
            reset_ext <= '1' after T_RESET; 

            DUT: convolution
                generic map (
                    DIM_IMG => N_image,
                    DIM_KER => M_kernel,
                    N_BIT => 8
                )
                port map (
                    clk => clk_ext,
                    reset => reset_ext,
                    x => image_ext,
                    if_signal => '1',
                    x_valid => '1',
                    y_valid => y_valid_ext,
                    y => out_ext,
                    data_out_kernel => data_out_kernel_ext
                );

        STIMULI: process(clk_ext, reset_ext)  -- process used to make the testbench signals change synchronously with the rising edge of the clock
        variable t : integer := 0;  -- variable used to count the clock cycle after the reset
        begin
            if(reset_ext = '0') then
                image_ext <= (others => '0');
                t := 0;
            elsif(rising_edge(clk_ext)) then
                case(t) is
                    when 30 => image_ext   <= std_logic_vector(to_unsigned(1,8));
                    when 31 => image_ext   <= std_logic_vector(to_unsigned(2,8));
                    when 32 => image_ext   <= std_logic_vector(to_unsigned(3,8));
                    when 33 => image_ext   <= std_logic_vector(to_unsigned(4,8));
                    when 34 => image_ext   <= std_logic_vector(to_unsigned(5,8));
                    when 35 => image_ext   <= std_logic_vector(to_unsigned(6,8));
                    when 36 => image_ext   <= std_logic_vector(to_unsigned(7,8));
                    when 37 => image_ext   <= std_logic_vector(to_unsigned(8,8));
                    when 38 => image_ext   <= std_logic_vector(to_unsigned(9,8));
                    when 39 => image_ext   <= std_logic_vector(to_unsigned(10,8));
                    when 40 => image_ext   <= std_logic_vector(to_unsigned(11,8));
                    when 41 => image_ext   <= std_logic_vector(to_unsigned(12,8));
                    when 42 => image_ext   <= std_logic_vector(to_unsigned(13,8));
                    when 43 => image_ext   <= std_logic_vector(to_unsigned(14,8));
                    when 44 => image_ext   <= std_logic_vector(to_unsigned(15,8));
                    when 45 => image_ext   <= std_logic_vector(to_unsigned(16,8));

                    when 50 => end_sim <= '0';  -- This command stops the simulation when t = 10
                    when others => null;        -- Specifying that nothing happens in the other cases
                end case;
            t := t + 1;  
            end if;
        end process;

    end architecture;
