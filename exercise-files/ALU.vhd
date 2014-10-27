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
    
    ALUresult : out std_logic_vector(DATA_WIDTH-1 downto 0);
    zero : out std_logic);

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

signal rt_in : std_logic_vector(DATA_WIDTH-1 downto 0);   -- Output of 2's comp
signal SLTout : std_logic_vector(DATA_WIDTH-1 downto 0);  -- Output of SLT
signal ADDout : std_logic_vector(DATA_WIDTH-1 downto 0);  -- Output of adder
signal sub_enable : std_logic;     -- Enable for two's complement,
signal ALUout : std_logic_vector(1 downto 0);             -- Output mux control

component full_adder
  port (
    rt     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    rs     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ADDout : out std_logic_vector(DATA_WIDTH-1 downto 0));
end component;

begin  -- behavioural

  SLTout <= x"00000001" when (signed(rs) < signed(rt)) else x"00000000";
  sub_enable <= ALUctrl(2);
  ALUout <= ALUctrl(1 downto 0);
  zero <= not or_reduce(ADDout);  --or ADDout supported in VHDL2008
  
--Output Mux
  with ALUout select
    ALUresult <=
    ADDout        when "10",
    rt or rs      when "01",
    rt and rs     when "00",
    SLTout        when "11",
    (others => '0') when others;

--Subtraction enable
  with sub_enable select
    rt_in <=
    rt                                   when '0',
    std_logic_vector(1 + signed(not rt)) when '1', --Two's complement
    (others => '0')                      when others;           
                     
--Adder
adder : full_adder port map (
  rt     => rt_in,
  rs     => rs,
  ADDout => ADDout);
  
end behavioral;
