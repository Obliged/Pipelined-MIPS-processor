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
    mem_instr   : out std_logic_vector(2 downto 0);  --Memory Read enable, Memory write enable, Imm_to_reg, 
    ex_instr    : out std_logic_vector(4 downto 0);  -- ALUop, RegDst, imm_or_rt
    id_instr	: out std_logic_vector(1 downto 0)   -- Branch, Jump
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is

  constant OPCODE_R_TYPE	: std_logic_vector(5 downto 0) := "000000";
  constant OPCODE_BEQ	        : std_logic_vector(5 downto 0) := "000100";
  constant OPCODE_LW	        : std_logic_vector(5 downto 0) := "100011";
  constant OPCODE_SW	        : std_logic_vector(5 downto 0) := "101011";
  constant OPCODE_J	        : std_logic_vector(5 downto 0) := "000010";
  constant OPCODE_LUI	        : std_logic_vector(5 downto 0) := "001111";
  --Assumed: LUI uses rs = 0. Thus the imm can "travel" through the ALU.
  constant IFUNCT_ADDI          : std_logic_vector(5 downto 0) := "00" & x"8";
  constant IFUNCT_ANDI          : std_logic_vector(5 downto 0) := "00" & x"C";
  constant IFUNCT_ORI           : std_logic_vector(5 downto 0) := "00" & x"D";
  constant IFUNCT_SLTI          : std_logic_vector(5 downto 0) := "00" & x"A";                                                                       
  signal ALU_ctrl	: std_logic_vector(2 downto 0);
  signal opcode		: std_logic_vector(5 downto 0);  -- opcode part of instruction
  signal ex_mux		: std_logic_vector(1 downto 0);  -- [RegDst, imm_or_rt]
  signal opcode_is_i_type  : std_logic;  -- Asserted when inctruction is I-type.
  signal opcode_is_r_type  : std_logic;  -- Asserted when inctruction is I-type.
  signal MemtoReg       : std_logic;
  signal RegWrite       : std_logic;
  
begin  -- Behavioral
-------------------------------------------------------------------------------
  ALU: entity work.ALU_Ctrl(Behavioral)
    port map(
      ALU_op  => opcode,
      funct   => instruction(5 downto 0),
      ALU_Out => ALU_ctrl               --Name change to increase readability.
      );
-------------------------------------------------------------------------------

  with opcode select
    mem_instr <=        --[Memory read enable, Memory write enable, Imm_to_reg]
    "100" when OPCODE_LW,
    "010" when OPCODE_SW,
    "001" when OPCODE_LUI,
    "000" when others;

  with opcode select
    id_instr <=     --[Branch, Jump]
    "01" when OPCODE_J,
    "10" when OPCODE_BEQ,
    "00" when others;

  
  --with opcode select                    
  --  wb_instr <=       --[MemtoReg, RegWrite]
  --  --write from mem to Reg
  --  "11" when OPCODE_LW,
  --  --Write from ALU to Reg
  --  "01" when OPCODE_R_TYPE,
  --  "01" when OPCODE_LUI,
  --  "01" when IFUNCT_ADDI,
  --  "01" when IFUNCT_ANDI,
  --  "01" when IFUNCT_ORI ,
  --  "01" when IFUNCT_SLTI,
  --  --Don't write reg
  --  "00" when others;
  MemtoReg <= '1' when opcode = OPCODE_LW else '0';
  RegWrite <= '1' when ((opcode_is_i_type or opcode_is_r_type) = '1') else '0';
  wb_instr <= (MemtoReg, RegWrite);


 -- with opcode_i_type select
 --  ex_mux <=              -- [RegDst, imm_or_rt]
 --   "11" when '1',
 --   "00" when others;
  opcode_is_i_type <= '0' when
                   (((opcode(5) nor opcode(3)) nor opcode(2))  --None of these
                   and ((opcode(4) or opcode(1))  --And at least one of these
                   or (opcode_is_r_type))) = '1' --or none of them
                   else '1';
  
  opcode_is_r_type <= '1' when opcode = OPCODE_R_TYPE else '0';
    
  ex_instr <= ALU_ctrl & (opcode_is_i_type, opcode_is_i_type);
  opcode <= instruction(INST_WIDTH-1 downto INST_WIDTH-6);
end Behavioral;


-- 000000
-- 010000
-- 010001
-- 010010
-- 010011
-- 000011
-- 000010
