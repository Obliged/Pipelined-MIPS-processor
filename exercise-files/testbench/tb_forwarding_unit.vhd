--------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_forwarding_unit IS
END tb_forwarding_unit;
 
ARCHITECTURE behavior OF tb_forwarding_unit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Forwarding_unit
	PORT(
		ex_mem_reg_write 		: IN std_logic;
		mem_wb_reg_write 		: IN std_logic;
		ex_mem_register_rd 		: IN std_logic_vector(4 downto 0);
		mem_wb_register_rd 		: IN std_logic_vector(4 downto 0);
		id_ex_register_rs 		: IN std_logic_vector(4 downto 0);
		id_ex_register_rt 		: IN std_logic_vector(4 downto 0);          
		forward_a 				: OUT std_logic_vector(1 downto 0);
		forward_b 				: OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	

   --Inputs 
	signal ex_mem_reg_write 	: std_logic;
	signal mem_wb_reg_write 	: std_logic;
	signal ex_mem_register_rd 	: std_logic_vector(4 downto 0);
	signal mem_wb_register_rd 	: std_logic_vector(4 downto 0);
	signal id_ex_register_rs	: std_logic_vector(4 downto 0);
	signal id_ex_register_rt 	: std_logic_vector(4 downto 0);      


 	--Outputs
	signal forward_a 			: std_logic_vector(1 downto 0);
	signal forward_b 			: std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	TYPE data_table IS RECORD
		ex_mem_reg_write_col	: std_logic;
		mem_wb_reg_write_col	: std_logic;
		ex_mem_register_rd_col 	: std_logic_vector(4 downto 0);
		mem_wb_register_rd_col 	: std_logic_vector(4 downto 0);
		id_ex_register_rs_col 	: std_logic_vector(4 downto 0);
		id_ex_register_rt_col 	: std_logic_vector(4 downto 0);
		forward_a_col 			: std_logic_vector(1 downto 0);
		forward_b_col 			: std_logic_vector(1 downto 0);
		
	END RECORD;

	TYPE table IS ARRAY (1 TO 11) OF data_table;

	CONSTANT templates: table := (
		
		('1', '1', "00001", "00010", "00100", "01000", "00", "00"), -- No hazard
		('1', '0', "00001", "00000", "00001", "00000", "10", "00"), -- EX hazard rs					: ex_mem_reg_write AND ex_mem_register_rd = id_ex_register_rs
		('0', '1', "00000", "00001", "00001", "00000", "01", "00"), -- MEM hazard rs					: mem_wb_reg_write AND NOT ex_mem_reg_write AND mem_wb_register_rd = id_ex_register_rs
		('1', '0', "01110", "00000", "00000", "01110", "00", "10"), -- EX hazard rt					: ex_mem_reg_write AND ex_mem_register_rd = id_ex_register_rt
		('0', '1', "00000", "01010", "00000", "01010", "00", "01"), -- MEM hazard rt					: mem_wb_reg_write AND NOT ex_mem_reg_write AND mem_wb_register_rd = id_ex_register_rt
		('1', '0', "10101", "00000", "10101", "10101", "10", "10"), -- EX hazard rs/rt				: ex_mem_reg_write AND ex_mem_register_rd = id_ex_register_rs = id_ex_register_rt
		('0', '1', "00000", "11111", "11111", "11111", "01", "01"), -- MEM hazard rs/rt				: mem_wb_reg_write AND NOT ex_mem_reg_write AND mem_wb_register_rd = id_ex_register_rs = id_ex_register_rt
		('1', '1', "11011", "00100", "11011", "00100", "10", "00"), -- EX hazard rs/MEM hazard rt	: ex_mem_reg_write AND mem_wb_reg_write AND ex_mem_register_rd = id_ex_register_rs AND mem_wb_register_rd = id_ex_register_rt (use result from EX/MEM stage, as this is the most recent result)
		('1', '1', "01010", "10001", "10001", "01010", "00", "10"), -- EX hazard rt/MEM hazard rs	: ex_mem_reg_write AND mem_wb_reg_write AND ex_mem_register_rd = id_ex_register_rt AND mem_wb_register_rd = id_ex_register_rs (use result from EX/MEM stage, as this is the most recent result)
		('1', '1', "00111", "00111", "00111", "00000", "10", "00"), -- EX hazard rs/MEM hazard rs	: ex_mem_reg_write AND mem_wb_reg_write AND ex_mem_register_rd = id_ex_register_rs AND mem_wb_register_rd = id_ex_register_rt (use result from EX/MEM stage, as this is the most recent result)
		('1', '1', "11000", "11000", "00000", "11000", "00", "10"));-- EX hazard rt/MEM hazard rt	: ex_mem_reg_write AND mem_wb_reg_write AND ex_mem_register_rd = id_ex_register_rs AND mem_wb_register_rd = id_ex_register_rt (use result from EX/MEM stage, as this is the most recent result)
	 
	 
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   Forwarding_uut: Forwarding_unit PORT MAP(
		ex_mem_reg_write => ex_mem_reg_write,
		mem_wb_reg_write => mem_wb_reg_write,
		ex_mem_register_rd => ex_mem_register_rd,
		mem_wb_register_rd => mem_wb_register_rd,
		id_ex_register_rs => id_ex_register_rs,
		id_ex_register_rt => id_ex_register_rt,
		forward_a => forward_a,
		forward_b => forward_b
	);
 

   -- Stimulus process
   stim_proc: process
   begin
		WAIT for 5*clk_period;
		FOR i IN 1 to 11 LOOP  -- 
			ex_mem_reg_write 	<=	templates(i).ex_mem_reg_write_col;
			mem_wb_reg_write	<=	templates(i).mem_wb_reg_write_col;
			ex_mem_register_rd	<=	templates(i).ex_mem_register_rd_col;
			mem_wb_register_rd	<=	templates(i).mem_wb_register_rd_col;
			id_ex_register_rs	<=	templates(i).id_ex_register_rs_col;
			id_ex_register_rt	<=	templates(i).id_ex_register_rt_col;
			WAIT for 0.5*clk_period;
			ASSERT forward_a=templates(i).forward_a_col
				REPORT "Mismatch in forward_a at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT forward_b=templates(i).forward_b_col
				REPORT "Mismatch in forward_b at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			WAIT for 3.5*clk_period;
		END LOOP;
		ASSERT FALSE
			REPORT "Test finished! Look above for potential errors."
			SEVERITY NOTE;
      -- insert stimulus here 
		WAIT for 5*clk_period;
      wait;
   end process;

END;