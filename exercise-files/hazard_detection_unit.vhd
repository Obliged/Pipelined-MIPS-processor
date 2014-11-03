--------------------------------------------------
-- Hazard_detection_unit. Stalls pipeline if  	--
-- hazard is detected							--
--------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hazard_detection_unit is

	generic (
		ADDR_WIDTH : natural := 32);

	Port(
		clk					: in STD_LOGIC;
		rst					: in STD_LOGIC;
		id_ex_mem_read		: in STD_LOGIC;
		id_ex_register_rt	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		if_id_register_rs	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		if_id_register_rt	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		stall				: out STD_LOGIC
		);

end Hazard_detection_unit;

architecture Behavioral of Hazard_detection_unit is
begin
	process (clk, rst) is
	
	begin
	
		if(rst = '1') then
			stall <= '0';
		elsif(falling_edge(clk)) then
			if((id_ex_mem_read = '1') AND ((id_ex_register_rt = if_id_register_rs) OR (id_ex_register_rt = if_id_register_rt))) then 
				stall <= '1';
			else 
				stall <= '0';
			end if;
		end if;
	
	end process;
end Behavioral;
