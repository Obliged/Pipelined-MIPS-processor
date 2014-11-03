												-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSProcessor.vhd
-- The MIPS processor component to be used in Exercise 1 and 2.

-- TODO replace the architecture DummyArch with a working Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSProcessor is
	generic (
		ADDR_WIDTH : integer := 8;
		DATA_WIDTH : integer := 32
	);
	port (
		clk, reset 	: in std_logic;
		processor_enable: in std_logic;
		imem_data_in	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		imem_address	: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_in	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_address	: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_write_enable : out std_logic
	);
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is
  constant REG_ADDR_WIDTH : natural := 5;
  
  --ALU signals
  signal rt             : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rs             : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ALUctrl        : std_logic_vector(2 downto 0);
  signal ALUresult      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal zero           : std_logic;

  --register file signals
  signal rt_read        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rs_read        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wr_en          : std_logic;
  signal rt_addr        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
  signal rs_addr        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
  signal rd_addr        : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
  signal wr_data        : std_logic_vector(DATA_WIDTH-1 downto 0);
  
  --Control signals
  signal Reg_Dst 	: std_logic;
  signal Branch      	: std_logic;
  signal Mem_Read 	: std_logic;    --Unecessary? No output for this.
  signal Mem_To_Reg     : std_logic;
  signal ALU_Out 	: std_logic_vector(3 downto 0);
  signal Mem_Write 	: std_logic;
  signal ALU_Src 	: std_logic;
  signal Reg_Write 	: std_logic;
  signal PC_Update      : std_logic;
 -- signal State	        : std_logic_vector(2 downto 0);
  signal Jump           : std_logic;
  signal Imm_To_Reg     : std_logic;
   
  --Internals
  signal PC_out : std_logic_vector(ADDR_WIDTH-1 downto 0);  --Output of PC.
  --signal PC_out_top : std_logic_vector(DATA_WIDTH-1 downto 26);  -- for
  --Jump/Branch. Removed because immidiate is larger than address space.
  signal PC_new : std_logic_vector(ADDR_WIDTH-1 downto 0);  -- updated value
  signal branch_or_iterate : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal jump_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal ALU_or_dmem : std_logic_vector(DATA_WIDTH-1 downto 0);
  
begin
-----------------------------------------------------------------------------
--instantiate the ALU
  ALU: entity work.ALU(Behavioral)
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      rt        => rt       ,
      rs        => rs       ,
      ALUctrl   => ALUctrl  ,
      ALUresult => ALUresult,
      zero      => zero     );

  -----------------------------------------------------------------------------
 --instantiate Register File
  regFile : entity work.register_file
    generic map (
    DATA_WIDTH => DATA_WIDTH,
    ADDR_WIDTH => REG_ADDR_WIDTH)           --? width = 8?
    port map (
      clk     => clk    ,
      rst     => reset  ,
      wr_en   => wr_en  ,
      rt_addr => rt_addr,
      rs_addr => rs_addr,
      rd_addr => rd_addr,
      wr_data => wr_data,    
      rs      => rs_read, 
      rt      => rt_read);

  -----------------------------------------------------------------------------
  --instantiate Control
	Control : entity work.Control(Behavioral)
		PORT MAP (
			clk 		=> clk,
			rst 	       	=> reset,
			proc_enable	=> processor_enable,
			opcode 		=> imem_data_in(DATA_WIDTH-1 downto DATA_WIDTH-6),
			funct 		=> imem_data_in(5 downto 0),
			Reg_Dst		=> Reg_Dst,
			Branch 		=> Branch,
                        Mem_To_Reg	=> Mem_To_Reg,
			ALU_Out		=> ALU_Out,
			Mem_Write 	=> Mem_Write,
			ALU_Src		=> ALU_Src,
			Reg_Write 	=> Reg_Write,
			PC_Update 	=> PC_Update,
			Imm_To_Reg	=> Imm_To_Reg,
                        Jump            => Jump
         );

  -----------------------------------------------------------------------------
 --instantiate Forwarding Unit
  forward_unit : entity work.forwarding_unit
    generic map (
    ADDR_WIDTH => ADDR_WIDTH)           
    port map (
		ex_mem_reg_write	=> ex_mem_reg_write,
		mem_wb_reg_write	=> mem_wb_reg_write,
		ex_mem_register_rd	=> ex_mem_register_rd,
		mem_wb_register_rd	=> mem_wb_register_rd,
		id_ex_register_rs	=> id_ex_register_rs,
		id_ex_register_rt	=> id_ex_register_rt,
		forward_a			=> forward_a,
		forward_b    		=> forward_b
		);
  -----------------------------------------------------------------------------
 --instantiate Hazard Detection Unit
  hazard_detection : entity work.hazard_detection_unit
    generic map (
    ADDR_WIDTH => ADDR_WIDTH)           
    port map (
		clk     			=> clk,
		rst     			=> reset,
		id_ex_mem_read		=> id_ex_mem_read,
		id_ex_register_rt	=> id_ex_register_rt,
		if_id_register_rs	=> if_id_register_rs,
		if_id_register_rt	=> if_id_register_rt,
		stall				=> stall
		);
  -----------------------------------------------------------------------------
  
--Write-register-MUX
 with Reg_Dst select
   rd_addr <=
   imem_data_in(15 downto 11)  when '1',
   imem_data_in(20 downto 16)  when '0',
   (others => 'X') when others;

--ALU rt input MUX
with forward_a select
  rt <=
  id_ex_register_rt 	when "00",
  ex_mem_register_rt 	when "10",
  mem_wb_register_rt	when "01",
  (others => 'X') when others;
  
--ALU rs input MUX
with forward_b select
  rs <=
  id_ex_register_rs 	when "00",
  ex_mem_register_rs 	when "10",
  mem_wb_register_rs	when "01",
  (others => 'X') 		when others;
  
-- Branch or PC+1 MUX
with (Branch and zero) select
  branch_or_iterate <=
  std_logic_vector(signed(PC_out) + 1)    when '0',
  std_logic_vector(signed(PC_out) + signed(imem_data_in(ADDR_WIDTH-1 downto 0))) when '1', --
  --IMM is larger than address-space. Using bottom least significant bits,
  --assuming that most significant bits will be sign extension.
  (others => 'X') when others;

-- Jump MUX
with Jump select
  PC_new <=
  branch_or_iterate when '0',
  jump_addr         when '1',
  (others => 'X') when others;

-- ALU/Memory _out MUX
with Mem_To_Reg select
  ALU_or_dmem <= 
  ALUresult     when '0',
  dmem_data_in  when '1',
  (others => 'X') when others;

-- Load Imm Mux
with imm_to_reg select
  wr_data <=
  ALU_or_dmem                         when '0',
  imem_data_in(15 downto 0) & x"0000" when '1',
  (others => 'X') when others;

-------------------------------------------------------------------------------  
  --Updates of instruction address is clocked.
  PC: process(clk, reset)
  begin
    if reset = '1' then
      imem_address <= (others => '0');
      PC_out <= (others => '0');
    elsif rising_edge(clk) then
      if processor_enable = '1' and (PC_Update = '1' or jump = '1') then
        imem_address <= PC_new;
        PC_out <= PC_new;
      end if;
    end if;
  end process;
-------------------------------------------------------------------------------
  --Register and ALU
  rs_addr <= imem_data_in(25 downto 21);
  rt_addr <= imem_data_in(20 downto 16);
  rs <= rs_read;
  wr_en <= Reg_Write;
  ALUctrl <= ALU_Out(2 downto 0);       --ALU_Out is wider to open for expansion.

  --Dmem and PC
  dmem_write_enable <= Mem_write;
  dmem_address <= ALUresult(ADDR_WIDTH-1 downto 0);  --Size of dmem is small.
  jump_addr <= imem_data_in(ADDR_WIDTH-1 downto 0); -- & PC_out(31 downto 26);
                                                    -- --Address space is
                                                    -- smaller than imm    
  dmem_data_out <= rt_read;
  
end Behavioral;

