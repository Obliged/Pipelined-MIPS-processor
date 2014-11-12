--------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_hazard_detection_unit IS
END tb_hazard_detection_unit;
 
ARCHITECTURE behavior OF tb_hazard_detection_unit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Hazard_detection_unit
	PORT(
		id_ex_mem_read : IN std_logic;
		id_ex_register_rt : IN std_logic_vector(4 downto 0);
		if_id_register_rs : IN std_logic_vector(4 downto 0);
		if_id_register_rt : IN std_logic_vector(4 downto 0);          
		stall : OUT std_logic
		);
	END COMPONENT;

   --Inputs
   signal id_ex_mem_read 	: std_logic;
   signal id_ex_register_rt : std_logic_vector(4 downto 0);
   signal if_id_register_rs : std_logic_vector(4 downto 0);
   signal if_id_register_rt : std_logic_vector(4 downto 0);  


 	--Outputs
	signal stall			: std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	TYPE data_table IS RECORD
		id_ex_mem_read_col		: std_logic;
		id_ex_register_rt_col 	: std_logic_vector(4 downto 0);
		if_id_register_rs_col 	: std_logic_vector(4 downto 0);
		if_id_register_rt_col 	: std_logic_vector(4 downto 0);
		stall_col 				: std_logic;
		
	END RECORD;

	TYPE table IS ARRAY (1 TO 6) OF data_table;

	CONSTANT templates: table := (

		('1',"00001", "00000", "00001", '1'), -- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rt
		('1',"10000", "00000", "00000", '0'), -- No stall	: NOT((id_ex_register_rt = if_id_register_rs) OR (id_ex_register_rt = if_id_register_rt))
		('0',"00000", "10100", "10100", '0'), -- No stall	: NOT(id_ex_mem_read)
		('1',"00010", "00010", "00010", '1'), -- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rs AND id_ex_register_rt = if_id_register_rt
		('0',"00000", "00000", "00000", '0'), -- No stall	: NOT(id_ex_mem_read)
		('1',"11111", "11111", "00000", '1'));-- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rs
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   Hazard_detection_uut: Hazard_detection_unit PORT MAP(
		id_ex_mem_read => id_ex_mem_read,
		id_ex_register_rt => id_ex_register_rt,
		if_id_register_rs => if_id_register_rs,
		if_id_register_rt => if_id_register_rt,
		stall => stall
	);
 

   -- Stimulus process
   stim_proc: process
   begin
		wait for 0.5*clk_period;
		--wait until falling_edge(clk)
		FOR i IN 1 to 6 LOOP  -- 
			id_ex_mem_read 	<=	templates(i).id_ex_mem_read_col;
			id_ex_register_rt	<=	templates(i).id_ex_register_rt_col;
			if_id_register_rs	<=	templates(i).if_id_register_rs_col;
			if_id_register_rt	<=	templates(i).if_id_register_rt_col;
			WAIT for 0.5*clk_period;
			ASSERT stall=templates(i).stall_col
				REPORT "Mismatch in stall at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			WAIT for 0.5*clk_period;
		END LOOP;
		ASSERT FALSE
			REPORT "No error found!"
			SEVERITY NOTE;
      -- insert stimulus here 

      wait;
   end process;

END;