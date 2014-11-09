LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mem_wb is
	generic (REG_ADDR_WIDTH : natural := 5;
			 DATA_WIDTH 	: natural := 32
			 );
	port(clk				: in std_logic;
		mem_data_in			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		ALU_result_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_in			: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		
		mem_data_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		ALU_result_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_out			: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0)
		);	
end mem_wb;
architecture Behavioral of mem_wb is
  begin
    process (clk)
      begin
        if (rising_edge(clk)) then
			mem_data_out	<= mem_data_in;
			ALU_result_out 		<= ALU_result_in;
			rd_addr_out 		<= rd_addr_in;
        end if;
    end process;
end Behavioral;


  