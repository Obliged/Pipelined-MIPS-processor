LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity if_id is  
	generic (INST_WIDTH : natural := 32;
			 ADDR_WIDTH : natural := 8
			 );
	port(clk			: in std_logic;
		PC_in			: in std_logic_vector(ADDR_WIDTH-1 downto 0);  
		instruction_in	: in std_logic_vector(INST_WIDTH-1 downto 0);  
		PC_out			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		instruction_out	: out std_logic_vector(INST_WIDTH-1 downto 0)
		); 		
end if_id;  
architecture Behavioral of if_id is  
  begin  
    process (clk)  
      begin  
        if (rising_edge(clk)) then 
          PC_out <= PC_in;
		  instruction_out <= instruction_in;
        end if;  
    end process;  
end Behavioral; 


  