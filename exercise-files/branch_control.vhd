library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity branch_control is
  
  generic (
    DATA_WIDTH 	: natural := 32;
    IMM_WIDTH  	: natural := 8;           -- Width of immidiate
    IADDR_WIDTH : natural := 8
    );

  port (
    ctrl_branch : in  std_logic;         --Branch control signal, from decoder
    imm_in   	: in  std_logic_vector(IMM_WIDTH-1 downto 0);   -- Immidiate
    rs_in    	: in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Read register 1
    rt_in    	: in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Read register 2
    addr_in  	: in  std_logic_vector(IADDR_WIDTH-1 downto 0); -- Instruction addr + 1
    addr_out 	: out std_logic_vector(IADDR_WIDTH-1 downto 0); -- Branch address
    branch_mux 	: out std_logic
    ); 

end branch_control;

architecture behavioral of branch_control is

signal equal : std_logic;               --Asserted if rt == rs
  
begin  -- behavioral

  equal 		<= '1' when (signed(rt_in) = signed(rs_in)) else '0';
  branch_mux 	<= equal AND ctrl_branch;
  addr_out	 	<= std_logic_vector(signed(addr_in) + signed(imm_in));
  
end behavioral;
