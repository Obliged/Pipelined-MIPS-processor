LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mem_wb is
	generic (REG_ADDR_WIDTH : natural := 5;
			 DATA_WIDTH 	: natural := 32
			 );
	port(clk				: in std_logic;
		ALU_result_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_in			: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
                ex_mem_imm :in std_logic_vector(15 downto 0);
		
		ALU_result_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_out			: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
                mem_wb_imm : out std_logic_vector(15 downto 0)
		);	
end mem_wb;
architecture Behavioral of mem_wb is
  begin
    process (clk)
      begin
        if (rising_edge(clk)) then
			ALU_result_out 		<= ALU_result_in;
			rd_addr_out 		<= rd_addr_in;
                        mem_wb_imm <= ex_mem_imm ;
        end if;
    end process;
end Behavioral;


  
