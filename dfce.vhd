library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DFCE_N is 
	generic (
		N : positive := 8
	);
	port (
		clk 	: 	in std_logic;
		en 		: 	in std_logic;
		resetn	: 	in std_logic;
		
		di: in  std_logic_vector(N-1 downto 0);
		do: out std_logic_vector(N-1 downto 0)
	);
end entity;

architecture rtl of DFCE_N is 

-- segnali interni
signal di_s : std_logic_vector(N-1 downto 0);
signal do_s : std_logic_vector(N-1 downto 0);

begin 

	p_DFCE_N: process(clk,resetn)
	begin
        -- reset condition
		if resetn = '0' then 
			do_s <= std_logic_vector(to_unsigned(0,N));
        -- transparency 
		elsif rising_edge(clk) then
			do_s <= di_s;
		end if;
	
	end process;

	do <= do_s;
	di_s <= di when en = '1' else do_s; 

end architecture;

