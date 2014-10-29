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

-------------------------------------------------------------------------------
  --From synopsis std_logic_misc package.
  function OR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
    variable result: STD_LOGIC;
  begin
    result := '0';
    for i in ARG'range loop
      result := result or ARG(i);
    end loop;
    return result;
  end;
-------------------------------------------------------------------------------
 
end ALU;

architecture behavioral of ALU is

signal SLTout : std_logic_vector(DATA_WIDTH-1 downto 0);  -- Output of SLT
signal SUBout : std_logic_vector(DATA_WIDTH-1 downto 0);
signal ADDout : std_logic_vector(DATA_WIDTH-1 downto 0);


begin  -- behavioural

  ADDout <= signed(rs) - signed(rt);
  SUBout <= signed(rs) - signed(rt);
  SLTout <= x"00000001" when (signed(rs) < signed(rt)) else x"00000000";
  --zero <= not or_reduce(ADDout);  --or ADDout supported in VHDL2008
  
--Output Mux
  with ALUctrl select
    ALUresult <=
    rt and rs     when "000",
    rt or rs      when "001",
    SLTout        when "011",
    ADDout        when "010",
    SUBout        when "110",
    (others => '0') when others;

end behavioral;
