library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU_Ctrl is
  
end tb_ALU_Ctrl;

architecture behavior of tb_ALU_Ctrl is

component ALU_Ctrl
  Port (
    ALU_op		: in  STD_LOGIC_VECTOR (5 downto 0);
    funct		: in  STD_LOGIC_VECTOR (5 downto 0);
    ALU_Out		: out STD_LOGIC_VECTOR (2 downto 0)
    );
end component;

signal ALU_op		: STD_LOGIC_VECTOR (5 downto 0);
signal funct		: STD_LOGIC_VECTOR (5 downto 0);

--Output
signal ALU_Out		: STD_LOGIC_VECTOR (2 downto 0);

constant        FUNCT_ADD	: std_logic_vector(5 downto 0) := "100000";
constant 	FUNCT_AND	: std_logic_vector(5 downto 0) := "100100";
constant 	FUNCT_OR	: std_logic_vector(5 downto 0) := "100101";
constant 	FUNCT_SLT	: std_logic_vector(5 downto 0) := "101010";
constant 	FUNCT_SUB	: std_logic_vector(5 downto 0) := "100010";

constant        IFUNCT_ADDI     : std_logic_vector(5 downto 0) := "00" & x"8";
constant        IFUNCT_ANDI     : std_logic_vector(5 downto 0) := "00" & x"C";
constant        IFUNCT_ORI      : std_logic_vector(5 downto 0) := "00" & x"D";
constant        IFUNCT_SLTI     : std_logic_vector(5 downto 0) := "00" & x"A";

constant        UNUSED          : std_logic_vector(5 downto 0) := "11" & x"F"; -- Unused funct/opcode. To test behaviour for unexpected inputs.

begin  -- behavior
uut: ALU_Ctrl port map(
  ALU_op  => ALU_op , 
  funct   => funct  ,
  ALU_Out => ALU_Out
  );

stim :process
-------------------------------------------------------------------------------
begin
  assert false report "Running tesetbench for ALU_Ctrl" severity note;

--Testing functs.
-------------------------------------------------------------------------------
  funct <= FUNCT_ADD;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  funct <= FUNCT_AND;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "000" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------  
  funct <= FUNCT_OR ;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "001" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  funct <= FUNCT_SLT;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "111" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  funct <= FUNCT_SUB;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "110" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------

  funct <= UNUSED;
  ALU_op <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;

  ALU_op <= "00" & x"0";
  wait for 1ns;
  assert ALU_Out = "000" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------

  
--Testing opcodes
-------------------------------------------------------------------------------
  ALU_op <= IFUNCT_ADDI;
  funct <= UNUSED;
  wait for 1ns;
  assert ALU_Out = "010" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  ALU_op <= IFUNCT_ANDI;
  wait for 1ns;
  assert ALU_Out = "000" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------  
  ALU_op <= IFUNCT_ORI ;
  wait for 1ns;
  assert ALU_Out = "001" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  ALU_op <= IFUNCT_SLTI;
  wait for 1ns;
  assert ALU_Out = "111" report "Unexpected value at ALU_Out." severity error;
-------------------------------------------------------------------------------
  assert false report "Finished tb_ALU_Ctrl" severity note;
  wait;
end process;

end behavior;
