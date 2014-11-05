entity id_ex is
	generic (ADDR_WIDTH 	: natural := 8;
			REG_ADDR_WIDTH 	: natural := 5;
			DATA_WIDTH 		: integer := 32
			 );
	port(clk			: in std_logic;
		rs_read_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rt_read_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		rs_addr_in		: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		rt_addr_in		: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		rd_addr_in		: in std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		sign_ext_imm_in	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		
		rs_read_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rt_read_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		rs_addr_out		: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		rt_addr_out		: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		rd_addr_out		: out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
		sign_ext_imm_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
		);	
end id_ex;
architecture Behavioral of id_ex is
  begin
    process (clk)
      begin
        if (rising_edge(clk)) then
			PC_out 				<= PC_in;
			rs_read_out 		<= rs_read_in;
			rt_read_out 		<= rt_read_in;
			rs_addr_out 		<= rs_addr_in;
			rt_addr_out 		<= rt_addr_in;
			rd_addr_out 		<= rd_addr_in;
			sign_ext_imm_out 	<= sign_ext_imm_in;
        end if;
    end process;
end Behavioral;


  