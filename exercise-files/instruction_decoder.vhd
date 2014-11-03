LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity instruction_decoder is
  
  generic (
    INST_WIDTH : natural := 32
    );

  port (
    instruction : in  std_logic_vector(INST_WIDTH-1 downto 0);
    wb_instr    : out std_logic_vector(1 downto 0);  --MemtoReg, RegWrite
    mem_instr     : out std_logic_vector(1 downto 0);  --Memory write enable, Imm_to_reg
    ex_instr    : out std_logic_vector(4 downto 0)  -- ALUop, RegDst, imm_or_rt
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is

  constant OPCODE_R_TYPE	: std_logic_vector(5 downto 0) := "000000";
  constant OPCODE_BEQ	        : std_logic_vector(5 downto 0) := "000100";
  constant OPCODE_LW	        : std_logic_vector(5 downto 0) := "100011";
  constant OPCODE_SW	        : std_logic_vector(5 downto 0) := "101011";
  constant OPCODE_J	        : std_logic_vector(5 downto 0) := "000010";
  constant OPCODE_LUI	        : std_logic_vector(5 downto 0) := "001111";
--We assume that LUI uses rs = 0. Thus the imm can "travel" through the ALU.
                                                                            
  
  signal ALU_ctrl : std_logic_vector(2 downto 0);
  signal opcode : std_logic_vector(5 downto 0);  -- opcode part of instruction
  signal ex_mux : std_logic_vector(1 downto 0);  -- [RegDst, imm_or_rt]
  
begin  -- Behavioral
-------------------------------------------------------------------------------
  ALU: entity work.ALU_Ctrl(Behavioral)
    port map(
      ALU_op  => opcode(5),       --0 => R-type, 1 => LW/SW, X => others.
                                  --Should be expanded if functionality
                                  --is expanded. 
      funct   => instruction(5 downto 0),
      ALU_Out => ALU_ctrl
      );
-------------------------------------------------------------------------------

  with opcode select
    mem_instr <=                         --[Memory write enable, Imm_to_reg]
    "10" when OPCODE_SW,
    "01" when OPCODE_LUI,
    "00" when others;

  with opcode select                    --Assuming synth will optimize.
wb_instr <=                             --[MemtoReg, RegWrite]
  "11" when OPCODE_LW,
  "01" when OPCODE_R_TYPE,
  "01" when OPCODE_LUI,
  "00" when others;

with opcode select
  ex_mux <=                             -- [RegDst, imm_or_rt]
  "11" when OPCODE_LUI,                 --OPCODE_I_TYPE
  "11" when OPCODE_LW,                    
  "11" when OPCODE_SW,
  "00" when OPCODE_R_TYPE,
  "00" when others;

 ex_instr <= ALU_ctrl & ex_mux;
 opcode <= instruction(INST_WIDTH-1 downto INST_WIDTH-6);
end Behavioral;
