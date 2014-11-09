LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity tb_instruction_decoder is
end tb_instruction_decoder;

architecture behavior of tb_instruction_decoder is

  component instruction_decoder
    generic (
      INST_WIDTH : natural := 32
      );

    port (
      instruction : in  std_logic_vector(INST_WIDTH-1 downto 0);
      wb_instr    : out std_logic_vector(1 downto 0);  --MemtoReg, RegWrite
      mem_instr   : out std_logic_vector(2 downto 0);  --Memory Read enable, Memory write enable, Imm_to_reg, 
      ex_instr    : out std_logic_vector(4 downto 0);  -- ALUop, RegDst, imm_or_rt
      id_instr	  : out std_logic_vector(1 downto 0)   -- Branch, Jump
      );
  end component;
  
  constant INST_WIDTH   : natural := 32;
  signal instruction    : std_logic_vector(INST_WIDTH-1 downto 0);
  signal wb_instr       : std_logic_vector(1 downto 0);  --MemtoReg, RegWrite
  signal mem_instr      : std_logic_vector(2 downto 0);  --Memory Read enable, Memory write enable, Imm_to_reg, 
  signal ex_instr       : std_logic_vector(4 downto 0);  -- ALUop, RegDst, imm_or_rt
  signal id_instr       : std_logic_vector(1 downto 0);   -- Branch, Jump

  signal RegDst 	: std_logic;
  signal Branch 	: std_logic;
  signal MemRead 	: std_logic;
  signal MemtoReg       : std_logic;
  signal ALUop 	        : std_logic_vector(2 downto 0);
  signal MemWrite 	: std_logic;
  signal ALUSrc 	: std_logic;
  signal RegWrite 	: std_logic;
  signal Jump	      	: std_logic;
  signal ImmtoReg       : std_logic;
  
TYPE data_table IS RECORD
  opcode_col		: STD_LOGIC_VECTOR(5 DOWNTO 0);  --1
  funct_col		: STD_LOGIC_VECTOR(5 DOWNTO 0);  --2
  ALUop_col		: STD_LOGIC_VECTOR(2 DOWNTO 0);  --3
  RegDst_col 	        : STD_LOGIC;    --4
  ALUSrc_col 	        : STD_LOGIC;    --5
  MemtoReg_col	        : STD_LOGIC;    --6
  RegWrite_col	        : STD_LOGIC;    --7
  MemRead_col 	        : STD_LOGIC;    --8
  MemWrite_col 	        : STD_LOGIC;    --9
  Branch_col 		: STD_LOGIC;    --10
  Jump_col 		: STD_LOGIC;    --11
  ImmtoReg_col          : std_logic;    --12
		
	END RECORD;
  
TYPE table IS ARRAY (1 TO 14) OF data_table;

CONSTANT templates: table := (
-- OPCODE  FUNCT    ALUop   4    5    6    7    8    9    10   11  12
("100011","000000", "010", '1', '1', '1', '1', '1', '0', '0', '0','0'), -- LW, second col dontcare.
("101011","000000", "010", '1', '1', '0', '0', '0', '1', '0', '0','0'), -- SW, second col dontcare.
("000100","000000", "010", '1', '1', '0', '0', '0', '0', '1', '0','0'), -- BEQ, second col dontcare.
("000000","100000", "010", '0', '0', '0', '1', '0', '0', '0', '0','0'), -- ADD
("000000","100010", "110", '0', '0', '0', '1', '0', '0', '0', '0','0'), -- SUB 
("000000","100100", "000", '0', '0', '0', '1', '0', '0', '0', '0','0'), -- AND 
("000000","100101", "001", '0', '0', '0', '1', '0', '0', '0', '0','0'), -- OR 
("000000","101010", "111", '0', '0', '0', '1', '0', '0', '0', '0','0'), -- SLT 
("000010","000000", "010", '0', '0', '0', '0', '0', '0', '0', '1','0'), -- J, second & third col dontcare.

("001111","000000", "010", '1', '1', '0', '1', '0', '0', '0', '0','1'), -- LUI, funct_col dontcare
("001000","000000", "010", '1', '1', '0', '1', '0', '0', '0', '0','0'), -- ADDI, funct_col dontcare
("001100","000000", "000", '1', '1', '0', '1', '0', '0', '0', '0','0'), -- ANDI, funct_col dontcare
("001101","000000", "001", '1', '1', '0', '1', '0', '0', '0', '0','0'), -- ORI, funct_col dontcare
("001010","000000", "111", '1', '1', '0', '1', '0', '0', '0', '0','0')  -- SLTI, funct_col dontcare
);

  
begin  -- behavior

  uut: instruction_decoder
    generic map (
      INST_WIDTH => INST_WIDTH)
    port map(
    instruction => instruction , 
    wb_instr    => wb_instr    ,
    mem_instr   => mem_instr   ,
    ex_instr    => ex_instr    ,
    id_instr    => id_instr    );	     
  
  ALUop         <=  ex_instr(4 downto 2);
  RegDst        <=  ex_instr(1);
  ALUSrc        <=  ex_instr(0);
  MemRead  	<=  mem_instr(2);
  MemWrite 	<=  mem_instr(1);
  ImmtoReg      <=  mem_instr(0);  
  MemtoReg 	<=  wb_instr(1);
  RegWrite 	<=  wb_instr(0);
  Branch        <=  id_instr(1);
  Jump          <=  id_instr(0);
  
  stim: process
    variable opcode : std_logic_vector(5 downto 0);
    variable funct  : std_logic_vector(5 downto 0);
  begin
    assert false report "Running tb_instuction_decoder." severity note;
    
    FOR i IN 1 to 14 LOOP
      opcode 	:=	templates(i).opcode_col;
      funct	:=	templates(i).funct_col;
      instruction <= opcode & x"00000" & funct;
      wait for 1 ns;
      ASSERT ALUop=templates(i).ALUop_col
        REPORT "Mismatch in ALUout at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT RegDst=templates(i).RegDst_col
        REPORT "Mismatch in RegDst at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT ALUSrc=templates(i).ALUSrc_col
        REPORT "Mismatch in ALUSrc at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT MemToReg=templates(i).MemToReg_col
        REPORT "Mismatch in MemToReg at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT RegWrite=templates(i).RegWrite_col
        REPORT "Mismatch in RegWrite at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT MemRead=templates(i).MemRead_col
        REPORT "Mismatch in MemRead at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT MemWrite=templates(i).MemWrite_col
        REPORT "Mismatch in MemWrite at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT Branch=templates(i).Branch_col
        REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT Jump=templates(i).Jump_col
        REPORT "Mismatch in Branch at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
      ASSERT ImmtoReg=templates(i).ImmtoReg_col
        REPORT "Mismatch in ImmtoReg at iteration=" & INTEGER'IMAGE(i)
        SEVERITY ERROR;
    END LOOP;

    ASSERT FALSE REPORT "No error found!" SEVERITY NOTE;
    
    wait;  
  end process;
end behavior;
  
