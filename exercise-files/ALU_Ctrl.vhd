--------------------------------------------------------------
-- ALU_Ctrl. Selects arithmetic function performed by ALU	--
--------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_Ctrl is

	Port (ALU_op		: in  STD_LOGIC_VECTOR (5 downto 0);
              funct		: in  STD_LOGIC_VECTOR (5 downto 0);
              ALU_Out		: out STD_LOGIC_VECTOR (2 downto 0));

end ALU_Ctrl;

architecture Behavioral of ALU_Ctrl is
-- Definition of used FUNCTs
  constant 	FUNCT_ADD	: std_logic_vector(5 downto 0) := "100000";
  constant 	FUNCT_AND	: std_logic_vector(5 downto 0) := "100100";
  constant 	FUNCT_OR	: std_logic_vector(5 downto 0) := "100101";
  constant 	FUNCT_SLT	: std_logic_vector(5 downto 0) := "101010";
  constant 	FUNCT_SUB	: std_logic_vector(5 downto 0) := "100010";
  signal 	funct_sel	: std_logic_vector(2 downto 0);

--Definition of used I-type functions.
  constant      IFUNCT_ADDI     : std_logic_vector(5 downto 0) := "00" & x"8";
  constant      IFUNCT_ANDI     : std_logic_vector(5 downto 0) := "00" & x"C";
  constant      IFUNCT_ORI      : std_logic_vector(5 downto 0) := "00" & x"D";
  constant      IFUNCT_SLTI     : std_logic_vector(5 downto 0) := "00" & x"A";
  signal        opcod_sel       : std_logic_vector(2 downto 0);

begin
	with funct select  -- Select ALU-operation
          funct_sel 	<=
          "010"         when FUNCT_ADD,
          "000"         when FUNCT_AND,
          "001"       	when FUNCT_OR,
          "111"         when FUNCT_SLT,
          "110" 	when FUNCT_SUB,
          "010" 	when OTHERS;

        
        with ALU_op select
          ALU_Out <= 
          "010"         when IFUNCT_ADDI,
          "000"         when IFUNCT_ANDI,
          "001"         when IFUNCT_ORI ,
          "111"         when IFUNCT_SLTI,
          funct_sel    	when "000000",
          "010"         when OTHERS;

end Behavioral;
