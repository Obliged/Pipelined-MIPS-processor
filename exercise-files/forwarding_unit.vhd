--------------------------------------------------
-- Forwarding_unit. Sets forarding signals for 	--
-- muxed signals from pipeline registers		--
--------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Forwarding_unit is

	generic (
		ADDR_WIDTH : natural := 5);

	Port(
		ex_mem_reg_write	: in STD_LOGIC;
		mem_wb_reg_write	: in STD_LOGIC;
		ex_mem_register_rd	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		mem_wb_register_rd	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		id_ex_register_rs	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		id_ex_register_rt	: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
		forward_a			: out STD_LOGIC_VECTOR (1 downto 0);
		forward_b			: out STD_LOGIC_VECTOR (1 downto 0)
		);

end Forwarding_unit;

architecture Behavioral of Forwarding_unit is
begin

	process (ex_mem_reg_write, mem_wb_reg_write, ex_mem_register_rd, mem_wb_register_rd, id_ex_register_rs, id_ex_register_rt)
	begin
	
		-- EX hazard - set forward_a
		if((ex_mem_reg_write = '1') AND (ex_mem_register_rd /= "00000") AND (ex_mem_register_rd = id_ex_register_rs)) then 
			forward_a <= "10";
		
		-- MEM hazard - set forward_a
		elsif((mem_wb_reg_write = '1') AND (mem_wb_register_rd /= "00000") 
		AND NOT((ex_mem_reg_write = '1') AND (ex_mem_register_rd /= "00000") AND (ex_mem_register_rd /= id_ex_register_rs)) 
		AND (mem_wb_register_rd = id_ex_register_rs)) then 
			forward_a <= "01";
		
		-- No hazard - set forward_a
		else 
			forward_a <= "00";
		end if;
		
		-- EX hazard - set forward_b
		if((ex_mem_reg_write = '1') AND (ex_mem_register_rd /= "00000") AND (ex_mem_register_rd = id_ex_register_rt)) then 
			forward_b <= "10";
		
		-- MEM hazard - set forward_b
		elsif((mem_wb_reg_write = '1') AND (mem_wb_register_rd /= "00000") 
		AND NOT((ex_mem_reg_write = '1') AND (ex_mem_register_rd /= "00000") AND (ex_mem_register_rd /= id_ex_register_rt)) 
		AND (mem_wb_register_rd = id_ex_register_rt)) then 
			forward_b <= "01";
		
		-- No hazard - set forward_b
		else 
			forward_b <= "00";
		end if;
		
	end process;
	
end Behavioral;
