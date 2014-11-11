LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity ex_mem is
	generic (ADDR_WIDTH 	: natural := 8;
			REG_ADDR_WIDTH 	: natural := 5;
			DATA_WIDTH 		: integer := 32
			);
	port(clk				: in std_logic;
		ALU_result_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rt_read_in			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_in			: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
                id_ex_imm                       : in std_logic_vector(15 downto 0);
		
		ALU_result_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rt_read_out			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_addr_out			: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
                ex_mem_imm : out std_logic_vector(15 downto 0)
		);	
end ex_mem;
architecture Behavioral of ex_mem is
  begin
    process (clk)
      begin
        if (rising_edge(clk)) then
			ALU_result_out 		<= ALU_result_in;
			rt_read_out 		<= rt_read_in;
			rd_addr_out 		<= rd_addr_in;
                        ex_mem_imm <= id_ex_imm;
                        
        end if;
    end process;
end Behavioral;


  
