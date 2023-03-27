library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------
-- Entity Declaration
----------------------------------------------------------------- 

entity control_logic is 
        generic (
        DIM_KER : positive := 3,
        DIM_IMG : positive := 4
        ); 
        port (
        -- input
        clk : in  std_logic;
        reset : in  std_logic;
        i_f : in std_logic;
        x_valid : in std_logic;
        -- output 
        y_valid : out std_logic;
        stall : out std_logic;
        flush : out std_logic; 
  );
end control_logic;

architecture rtl of control_logic is
type t_control_logic_fsm is (
                          ST_S0      ,
                          ST_S1      ,
                          ST_S2      ,
                          ST_S3      );

signal counter_kernel : std_logic_vector(log2(DIM_KER*DIM_KER))
signal r_st_present    : t_control_logic_fsm;
signal w_st_next       : t_control_logic_fsm;
begin

-----------------------------------------------------------------
-- Next state logic
----------------------------------------------------------------- 

p_state : process(i_clk,i_rstb)
begin
  if(i_rstb='0') then
    r_st_present            <= ST_S0;
  elsif(rising_edge(i_clk)) then
    r_st_present            <= w_st_next;
  end if;
end process p_state;

-----------------------------------------------------------------
-- Current state logic
----------------------------------------------------------------- 

p_comb : process(r_st_present, i_f , x_valid)
begin
  case r_st_present is
    
    -- S0
    when ST_S0 => 
      if (i_f = '0') and (x_valid = '1') then  
        w_st_next  <= ST_S1;
      else                                                         
        w_st_next  <= ST_S0;
      end if;
    
    -- S1
    when ST_S1 => 
      if (counter_kernel = DIM_KER*DIM_KER) then  
        w_st_next  <= ST_S2;
      else                                                         
        w_st_next  <= ST_S1;
      end if;
    
    -- S2
    when ST_S2 =>  
        if (counter_img = (DIM_KER-1)*(DIM_IMG) + DIM_KER) then
            w_st_next <= ST_S3;
        else
            w_st_next <= ST_S2;
        end if;
    
    -- S3
    when ST_S3 =>  
        if (counter_out = DIM_OUT) then
            w_st_next <= ST_S0;
        else
            w_st_next <= ST_S3;
        end if;  
    
  end case;
end process p_comb;



p_state_out : process(clk,reset)
begin
  if(i_rstb='0') then
    y_valid     <= '0';
    stall       <= '1';
    flush       <= '1';
  elsif(rising_edge(i_clk)) then
    case r_st_present is
    
    when ST_S0 =>
        stall     <= '1';
        y_valid   <= '0';
        flush     <= '0';
        counter_kernel <= std_logic_vector(to_unsigned(0,8));
        counter_img <= std_logic_vector(to_unsigned(0,8));
        counter_out <= std_logic_vector(to_unsigned(0,8));
    
    when ST_S1 =>
        counter_kernel <= counter_kernel + 1;
    
    when ST_S2 => 
        counter_img <= counter_img + 1;

    when ST_S3 => 
        counter_out <= counter_out + 1;

    end case;
  end if;

end process p_state_out;
end rtl;