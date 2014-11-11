LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity if_id is  
	generic (INST_WIDTH : natural := 32;
			 ADDR_WIDTH : natural := 8
			 );
	port(
          clk			: in std_logic;
		sig_in			: in std_logic;  
		sig_out			: out std_logic
		); 		
end if_id;

architecture Behavioral of if_id is  

begin  
    process (clk)
      begin
        if (rising_edge(clk)) then 
          sig_out <= not sig_in;
        end if;
    end process;  
end Behavioral; 


  
