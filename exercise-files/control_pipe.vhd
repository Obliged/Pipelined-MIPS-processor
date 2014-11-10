LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity control_pipe is
  generic (
    INST_WIDTH : natural := 32
    );

  port (
    clk         	: in std_logic;
    rst         	: in std_logic;
    stall               : in std_logic;
    proc_enable         : in std_logic;
    flush_delayed         : in std_logic;
    instruction 	: in std_logic_vector(INST_WIDTH-1 downto 0);
	
    MEM_WB_MemtoReg     : out std_logic;
	
    EX_MEM_RegWrite     : out std_logic;
    MEM_WB_RegWrite     : out std_logic;
	
    EX_MEM_MemWrite     : out std_logic;
	
    ID_EX_MemRead       : out std_logic;
    
    IF_ID_Jump	        : out std_logic;
    IF_ID_Branch	: out std_logic;
	
    ID_EX_ALUop		: out std_logic_vector(2 downto 0);
    ID_EX_RegDst        : out std_logic;
    ID_EX_ALUSrc        : out std_logic;
        
    EX_MEM_ImmtoReg     : out std_logic
    );
end control_pipe;

architecture Behavioral of control_pipe is

--From decoder
signal if_id_id_instr_in   : std_logic_vector(1 downto 0);	 --Branch, Jump
signal if_id_wb_instr_in   : std_logic_vector(1 downto 0);  --MemtoReg, RegWrite       
signal if_id_mem_instr_in  : std_logic_vector(2 downto 0);  --Memory write enable, ImmtoReg
signal if_id_ex_instr_in   : std_logic_vector(4 downto 0);  --ALUop, RegDst, ALUSrc
  
signal if_id_id_instr	: std_logic_vector(1 downto 0);	 --Branch, Jump
signal if_id_wb_instr   : std_logic_vector(1 downto 0);  --MemtoReg, RegWrite       
signal if_id_mem_instr  : std_logic_vector(2 downto 0);  --Memory write enable, ImmtoReg
signal if_id_ex_instr   : std_logic_vector(4 downto 0);  --ALUop, RegDst, ALUSrc

--Delayed signals
signal ex_mem_wb_out	: std_logic_vector(1 downto 0); --PARTLY DELAYED:MemtoReg, RegWrite  
signal id_ex_mem_out	: std_logic_vector(2 downto 0); --PARTLY DELAYED:MemRead, MemWrite, ImmtoReg 

signal mem_wb_wb_out	: std_logic_vector(1 downto 0); --FULLY DELAYED: MemtoReg, RegWrite        
signal ex_mem_mem_out	: std_logic_vector(1 downto 0); --FULLY DELAYED: MemWrite, ImmtoReg 
signal if_id_ex_out	: std_logic_vector(4 downto 0); --FULLY DELAYED: ALUop, RegDst, ALUSrc
signal NOP : std_logic;                 -- No operation

begin  -- Behavioral
-------------------------------------------------------------------------------
  decoder: entity work.instruction_decoder(Behavioral)
    generic map (
      INST_WIDTH => INST_WIDTH)
    port map (
      instruction => instruction,
      wb_instr    => if_id_wb_instr_in ,
      mem_instr   => if_id_mem_instr_in,
      ex_instr    => if_id_ex_instr_in ,
      id_instr	  => if_id_id_instr_in );

--No operation "multiplexer".
  NOP <= stall or not proc_enable or flush_delayed;
  if_id_wb_instr  <= if_id_wb_instr_in  and (not NOP, not NOP);   
  if_id_mem_instr <= if_id_mem_instr_in and (not NOP, not NOP, not NOP);   
  if_id_ex_instr  <= if_id_ex_instr_in  and (not NOP, not NOP, not NOP, not NOP, not NOP);   
  if_id_id_instr  <= if_id_id_instr_in  and (not NOP, not NOP);   
  
  
-------------------------------------------------------------------------------
-- ID DELAY (0 clk)
  IF_ID_Branch <= if_id_id_instr(1);
  IF_ID_Jump   <= if_id_id_instr(0);
-------------------------------------------------------------------------------


--EX DELAY(1 clk)
-------------------------------------------------------------------------------  
  ex_delay: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 1,
     REG_WIDTH => 5)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => if_id_ex_instr,
     pipe_out => if_id_ex_out);

  ID_EX_ALUop  <= if_id_ex_out(4 downto 2);
  ID_EX_RegDst <= if_id_ex_out(1);
  ID_EX_ALUSrc <= if_id_ex_out(0);

-------------------------------------------------------------------------------

  
--MEM DELAY(2 clk)
-------------------------------------------------------------------------------  
  mem_delay_1: entity work.pipe_delay(behavioural)  --MemRead needed in ID_EX.
   generic map (
     DELAY     => 1,
     REG_WIDTH => 3)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => if_id_mem_instr,
     pipe_out => id_ex_mem_out);
	 
  ID_EX_MemRead	<= id_ex_mem_out(2);
  
-------------------------------------------------------------------------------
  mem_delay_2: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 1,
     REG_WIDTH => 2)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => id_ex_mem_out(1 downto 0),
     pipe_out => ex_mem_mem_out);

  EX_MEM_MemWrite	<= ex_mem_mem_out(1);
  EX_MEM_ImmtoReg	<= ex_mem_mem_out(0);

-------------------------------------------------------------------------------


--WB DELAY(3 clk)
-------------------------------------------------------------------------------
wb_delay_1: entity work.pipe_delay(behavioural)  --Forwarding needs RegWrite
   generic map (
     DELAY     => 2,
     REG_WIDTH => 2)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => if_id_wb_instr,
     pipe_out => ex_mem_wb_out);
	 
  EX_MEM_RegWrite <= ex_mem_wb_out(0);
  
------------------------------------------------------------------------------  
wb_delay_2: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 1,
     REG_WIDTH => 2)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => ex_mem_wb_out,
     pipe_out => mem_wb_wb_out);
	
  MEM_WB_MemtoReg <= mem_wb_wb_out(1);
  MEM_WB_RegWrite <= mem_wb_wb_out(0);
------------------------------------------------------------------------------  
 
end Behavioral;
