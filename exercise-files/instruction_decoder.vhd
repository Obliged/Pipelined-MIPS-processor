LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity instruction_decoder is
  
  generic (
    INST_WIDTH : natural := 32
    OPCODE_WIDth: natural := 6
    );

  port (
    instruction : in std_logic_vector(INST_WIDTH-1 downto 0);
    wb_instr : out std_logic_vector(1 downto 0);  --MemtoReg, RegWrite
    m_instr : out std_logic;            -- Memory write enable
    ex_instr : out std_logic_vector(4 downto 0);  -- ALUop, RegDst, imm_or_rt
    if_flush : out std_logic
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is

  constant OPCODE_R_TYPE	: std_logic_vector(5 downto 0) := "000000";
  constant OPCODE_BEQ	        : std_logic_vector(5 downto 0) := "000100";
  constant OPCODE_LW	        : std_logic_vector(5 downto 0) := "100011";
  constant OPCODE_SW	        : std_logic_vector(5 downto 0) := "101011";
  constant OPCODE_J	        : std_logic_vector(5 downto 0) := "000010";
  constant OPCODE_LUI	        : std_logic_vector(5 downto 0) := "001111";
  
  signal ALU_ctrl : std_logic_vector(2 downto 0);
  signal MemtoReg : std_logic;          --Asserted when LW.
  signal opcode : std_logic_vector(5 downto 0);  -- opcode part of instruction

begin  -- Behavioral
-------------------------------------------------------------------------------
  ALU: entity ALU_ctrl(Behavioral)
    port map(
      ALU_op  => opcode(5;       --0 => R-type, 1 => LW. Should be
                                        --expanded if functionality is expanded. 
      funct   => instruction(5 downto 0);
      ALU_Out => ALU_ctrl;
      );
-------------------------------------------------------------------------------

  m_instr <= instruction(29);           --only SW => 10_1_011.
  with
  MemtoReg
  
    
end Behavioral;
