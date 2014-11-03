LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity control_pipe is
  generic (
    INST_WIDTH : natural := 32
    );

  port (
    clk         : in std_logic;
    rst         : in std_logic;
    instruction : in std_logic_vector(INST_WIDTH-1 downto 0);

    MemtoReg    : out std_logic;
    RegWrite    : out std_logic;
    MemWrite    : out std_logic;
    ALUop       : out std_logic_vector(2 downto 0);
    RegDst      : out std_logic;
    ALUSrc      : out std_logic;
    ImmtoReg    : out std_logic
    );
end control_pipe;

architecture Behavioral of control_pipe is

signal wb_instr    : std_logic_vector(1 downto 0);  --MemtoReg, RegWrite       
signal mem_instr   : std_logic_vector(1 downto 0);  --Memory write enable, ImmtoReg
signal ex_instr    : std_logic_vector(4 downto 0);  --ALUop, RegDst, ALUSrc

--Delayed signals
signal wb_out   : std_logic_vector(1 downto 0); --DELAYED:MemtoReg, RegWrite        
signal mem_out  : std_logic_vector(1 downto 0); --DELAYED: Memory write enable, ImmtoReg 
signal ex_out   : std_logic_vector(4 downto 0); --DELAYED: ALUop, RegDst, ALUSrc

begin  -- Behavioral
-------------------------------------------------------------------------------
  decoder: entity work.instruction_decoder(Behavioral)
    generic map (
      INST_WIDTH => INST_WIDTH)
    port map (
      instruction => instruction,
      wb_instr    => wb_instr   ,
      mem_instr   => mem_instr  ,
      ex_instr    => ex_instr   );
    
-------------------------------------------------------------------------------
 ex_delay: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 1,
     REG_WIDTH => 5)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => ex_instr,
     pipe_out => ex_out);

  ALUop  <= ex_out(4 downto 2);
  RegDst <= ex_out(1);
  ALUSrc <= ex_out(0);

-------------------------------------------------------------------------------
  mem_delay: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 2,
     REG_WIDTH => 2)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => mem_instr,
     pipe_out => mem_out);

   (MemWrite, ImmtoReg) <= mem_out;
  
-------------------------------------------------------------------------------
wb_delay: entity work.pipe_delay(behavioural)
   generic map (
     DELAY     => 3,
     REG_WIDTH => 2)
   port map (
     clk      => clk,
     rst      => rst,
     pipe_in  => wb_instr,
     pipe_out => wb_out);

  (MemtoReg, RegWrite) <= wb_out;
------------------------------------------------------------------------------  
  
end Behavioral;
