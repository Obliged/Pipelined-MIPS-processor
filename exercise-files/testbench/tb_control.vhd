--------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_control IS
END tb_control;
 
ARCHITECTURE behavior OF tb_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Control
    PORT(
         clk 			: IN  	std_logic;
         rst 			: IN  	std_logic;
			proc_enable	: IN		std_logic;
         opcode 		: IN  	std_logic_vector(5 downto 0);
         funct 		: IN  	std_logic_vector(5 downto 0);
         Reg_Dst 		: OUT  	std_logic;
         Branch 		: OUT  	std_logic;
         Mem_Read 	: OUT  	std_logic;
         Mem_To_Reg 	: OUT  	std_logic;
         ALU_Out 		: OUT  	std_logic_vector(3 downto 0);
         Mem_Write 	: OUT  	std_logic;
         ALU_Src 		: OUT  	std_logic;
         Reg_Write 	: OUT  	std_logic;
			PC_Update 	: OUT		std_logic;
			Jump			: OUT		std_logic
			--State			: OUT		std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk 			: std_logic := '0';
   signal rst 			: std_logic := '0';
	signal proc_enable: std_logic := '0';
   signal opcode 		: std_logic_vector(5 downto 0) := (others => '0');
   signal funct 		: std_logic_vector(5 downto 0) := (others => '0');

 	--Outputs
   signal Reg_Dst 	: std_logic;
   signal Branch 		: std_logic;
   signal Mem_Read 	: std_logic;
   signal Mem_To_Reg : std_logic;
   signal ALU_Out 	: std_logic_vector(3 downto 0);
   signal Mem_Write 	: std_logic;
   signal ALU_Src 	: std_logic;
   signal Reg_Write 	: std_logic;
	signal PC_Update	: std_logic;
	signal Jump			: std_logic;
	--signal State	 	: std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	TYPE data_table IS RECORD
		opcode_col		: STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_col		: STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALU_Out_col		: STD_LOGIC_VECTOR(3 DOWNTO 0);
		Reg_Dst_col 	: STD_LOGIC;
		ALU_Src_col 	: STD_LOGIC;
		Mem_To_Reg_col	: STD_LOGIC;
		Reg_Write_col	: STD_LOGIC;
		Mem_Read_col 	: STD_LOGIC;
		Mem_Write_col 	: STD_LOGIC;
		Branch_col 		: STD_LOGIC;
		Jump_col 		: STD_LOGIC;
		
	END RECORD;

	TYPE table IS ARRAY (1 TO 9) OF data_table;

	CONSTANT templates: table := (
	 -- OPCODE	 FUNCT	 ALU_out 
		("100011","000000", "0010", '0', '1', '1', '1', '1', '0', '0', '0'), -- LW, second col dontcare.
		("101011","000000", "0010", '0', '1', '0', '0', '0', '1', '0', '0'), -- SW, second col dontcare.
		("000100","000000", "0110", '0', '0', '0', '0', '0', '0', '1', '0'), -- BEQ, second col dontcare.
		("000000","100000", "0010", '1', '0', '0', '1', '0', '0', '0', '0'), -- ADD
		("000000","100010", "0110", '1', '0', '0', '1', '0', '0', '0', '0'), -- SUB 
		("000000","100100", "0000", '1', '0', '0', '1', '0', '0', '0', '0'), -- AND 
		("000000","100101", "0001", '1', '0', '0', '1', '0', '0', '0', '0'), -- OR 
		("000000","101010", "0111", '1', '0', '0', '1', '0', '0', '0', '0'), -- SLT 
		("000010","000000", "0000", '0', '0', '0', '0', '0', '0', '0', '1'));	-- J, second & third col dontcare.
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Control PORT MAP (
          clk 			=> clk,
          rst 			=> rst,
			 proc_enable=> proc_enable,
          opcode 		=> opcode,
          funct 		=> funct,
          Reg_Dst 	=> Reg_Dst,
          Branch 		=> Branch,
          Mem_Read 	=> Mem_Read,
          Mem_To_Reg	=> Mem_To_Reg,
          ALU_Out 	=> ALU_Out,
          Mem_Write 	=> Mem_Write,
          ALU_Src 	=> ALU_Src,
          Reg_Write 	=> Reg_Write,
			 PC_Update 	=> PC_Update,
			 Jump			=>	Jump
			 --State		=> State
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
      wait for clk_period;	-- hold reset state for 1 clk period.
		rst <= '0';
		wait for clk_period;
		proc_enable <= '1';
		FOR i IN 1 to 2 LOOP  -- Test LW and SW instructions
			opcode 	<=	templates(i).opcode_col;
			funct	<=	templates(i).funct_col;
			WAIT FOR 0.5 * clk_period;
			WAIT UNTIL rising_edge(clk);
			ASSERT ALU_Out=templates(i).ALU_Out_col
				REPORT "Mismatch in ALU_out at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Dst=templates(i).Reg_Dst_col
				REPORT "Mismatch in Reg_Dst at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT ALU_Src=templates(i).ALU_Src_col
				REPORT "Mismatch in ALU_Src at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_To_Reg=templates(i).Mem_To_Reg_col
				REPORT "Mismatch in Mem_To_Reg at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Write=templates(i).Reg_Write_col
				REPORT "Mismatch in Reg_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Read=templates(i).Mem_Read_col
				REPORT "Mismatch in Mem_Read at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Write=templates(i).Mem_Write_col
				REPORT "Mismatch in Mem_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Branch=templates(i).Branch_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Jump=templates(i).Jump_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			WAIT FOR 2 * clk_period;
		END LOOP;
		FOR i IN 3 to table'LENGTH-1 LOOP -- Test R-type and BEQ instructions
			opcode 	<=	templates(i).opcode_col;
			funct	<=	templates(i).funct_col;
			WAIT FOR 0.5 * clk_period;
			WAIT UNTIL rising_edge(clk);
			ASSERT ALU_Out=templates(i).ALU_Out_col
				REPORT "Mismatch in ALU_out at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Dst=templates(i).Reg_Dst_col
				REPORT "Mismatch in Reg_Dst at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT ALU_Src=templates(i).ALU_Src_col
				REPORT "Mismatch in ALU_Src at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_To_Reg=templates(i).Mem_To_Reg_col
				REPORT "Mismatch in Mem_To_Reg at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Write=templates(i).Reg_Write_col
				REPORT "Mismatch in Reg_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Read=templates(i).Mem_Read_col
				REPORT "Mismatch in Mem_Read at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Write=templates(i).Mem_Write_col
				REPORT "Mismatch in Mem_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Branch=templates(i).Branch_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Jump=templates(i).Jump_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			WAIT FOR 1 * clk_period;
		END LOOP;
		FOR i IN table'LENGTH to table'LENGTH LOOP  -- Test Jump instruction
			opcode 	<=	templates(i).opcode_col;
			funct	<=	templates(i).funct_col;
			WAIT FOR 0.5 * clk_period;
			ASSERT ALU_Out=templates(i).ALU_Out_col
				REPORT "Mismatch in ALU_out at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Dst=templates(i).Reg_Dst_col
				REPORT "Mismatch in Reg_Dst at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT ALU_Src=templates(i).ALU_Src_col
				REPORT "Mismatch in ALU_Src at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_To_Reg=templates(i).Mem_To_Reg_col
				REPORT "Mismatch in Mem_To_Reg at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Reg_Write=templates(i).Reg_Write_col
				REPORT "Mismatch in Reg_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Read=templates(i).Mem_Read_col
				REPORT "Mismatch in Mem_Read at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Mem_Write=templates(i).Mem_Write_col
				REPORT "Mismatch in Mem_Write at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Branch=templates(i).Branch_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
			ASSERT Jump=templates(i).Jump_col
				REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
				SEVERITY ERROR;
		END LOOP;
		WAIT UNTIL rising_edge(clk);
		proc_enable <= '0';
		ASSERT FALSE
			REPORT "No error found!"
			SEVERITY NOTE;
      -- insert stimulus here 

      wait;
   end process;

END;
