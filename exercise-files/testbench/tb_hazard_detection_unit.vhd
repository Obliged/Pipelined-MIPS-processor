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
		clk : IN std_logic;
		rst : IN std_logic;
		id_ex_mem_read : IN std_logic;
		id_ex_register_rt : IN std_logic_vector(31 downto 0);
		if_id_register_rs : IN std_logic_vector(31 downto 0);
		if_id_register_rt : IN std_logic_vector(31 downto 0);          
		stall : OUT std_logic
		);
	END COMPONENT;

   --Inputs
   signal clk 				: std_logic := '0';
   signal rst 				: std_logic := '0';
   signal id_ex_mem_read 	: std_logic;
   signal id_ex_register_rt : std_logic_vector(31 downto 0);
   signal if_id_register_rs : std_logic_vector(31 downto 0);
   signal if_id_register_rt : std_logic_vector(31 downto 0);  


 	--Outputs
	signal stall			: std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	TYPE data_table IS RECORD
		id_ex_mem_read_col		: std_logic;
		id_ex_register_rt_col 	: std_logic_vector(31 downto 0);
		if_id_register_rs_col 	: std_logic_vector(31 downto 0);
		if_id_register_rt_col 	: std_logic_vector(31 downto 0);
		stall_col 				: std_logic;
		
	END RECORD;

	TYPE table IS ARRAY (1 TO 6) OF data_table;

	CONSTANT templates: table := (

		('1',x"00000001", x"00000000", x"00000001", '1'), -- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rt
		('1',x"0A000000", x"00000000", x"00000000", '0'), -- No stall	: NOT((id_ex_register_rt = if_id_register_rs) OR (id_ex_register_rt = if_id_register_rt))
		('0',x"00000000", x"000B0400", x"000B0400", '0'), -- No stall	: NOT(id_ex_mem_read)
		('1',x"000000A0", x"000000A0", x"000000A0", '1'), -- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rs AND id_ex_register_rt = if_id_register_rt
		('0',x"00000000", x"00000000", x"00000000", '0'), -- No stall	: NOT(id_ex_mem_read)
		('1',x"98761234", x"98761234", x"00000000", '1'));-- Stall		: id_ex_mem_read AND id_ex_register_rt = if_id_register_rs
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   Hazard_detection_uut: Hazard_detection_unit PORT MAP(
		clk => clk,
		rst => rst,
		id_ex_mem_read => id_ex_mem_read,
		id_ex_register_rt => id_ex_register_rt,
		if_id_register_rs => if_id_register_rs,
		if_id_register_rt => if_id_register_rt,
		stall => stall
	);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		rst <= '1';
      wait for 10*clk_period;	-- hold reset state for 10 clk period.
		rst <= '0';
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