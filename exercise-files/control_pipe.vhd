LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity control_pipe is
  generic (
    INST_WIDTH : natural := 32
    );

  port (
    instruction : in std_logic_vector(INST_WIDTH-1 downto 0);

    MemtoReg    : out std_logic;
    RegWrite    : out std_logic;
    MemWrite    : out std_logic;
    ALUop       : out std_logic;
    RegDst      : out std_logic;
    ALUSrc      : out std_logic;
    );
end control_pipe;
