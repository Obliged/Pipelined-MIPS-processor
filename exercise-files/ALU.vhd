library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  
  generic (
    DATA_WIDTH : natural := 32);

  port (
    rt : in std_logic_vector(DATA_WIDTH-1 downto 0);
    rs : in std_logic_vector(DATA_WIDTH-1 downto 0);
    ALUctrl : in std_logic_vector(2 downto 0);
    
    ALUresult : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end ALU;

architecture behavioral of ALU is

signal SLTout : std_logic_vector(DATA_WIDTH-1 downto 0);
signal SUBout : std_logic_vector(DATA_WIDTH-1 downto 0);
signal ADDout : std_logic_vector(DATA_WIDTH-1 downto 0);
signal addsub : std_logic_vector(DATA_WIDTH-1 downto 0);

begin  -- behavioural

  
  ADDout <= std_logic_vector(signed(rs) + signed(rt));
  SUBout <= std_logic_vector(signed(rs) - signed(rt));
  SLTout <= x"00000001" when (signed(rs) < signed(rt)) else x"00000000";
  --zero <= not or_reduce(ADDout);  --or ADDout supported in VHDL2008
  
--Output Mux
  with ALUctrl(1 downto 0) select
    ALUresult <=
    rt and rs     when "00",
    rt or rs      when "01",
    SLTout        when "11",
    addsub        when "10",
    (others => '0') when others;

  with ALUctrl(2) select    --Explicitly defining two full muxes due to
                            --unexpected synthesis when defining a 5-input mux.
    addsub <=
    ADDout        when '0',
    SUBout        when '1',
    (others => '0') when others;

end behavioral;
