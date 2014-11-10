-- Part of TDT4255 Computer Design laboratory exercises
-- Group for Computer Architecture and Design
-- Department of Computer and Information Science
-- Norwegian University of Science and Technology

-- MIPSProcessor.vhd
-- The MIPS processor component to be used in Exercise 1 and 2.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSProcessor is
	generic (
		ADDR_WIDTH : integer := 8;				-- Width of data memory address
		DATA_WIDTH : integer := 32				-- Width of data from memory
	);
	port (
		clk, reset 			: in std_logic;
		processor_enable	: in std_logic;
		imem_data_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		imem_address		: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_in		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_address		: out std_logic_vector(ADDR_WIDTH-1 downto 0);
		dmem_data_out   	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmem_write_enable 	: out std_logic
	);
end MIPSProcessor;

architecture Behavioral of MIPSProcessor is
	constant REG_ADDR_WIDTH	: natural := 5;		-- Width of register address
	constant INST_WIDTH		: natural := 32;	-- Width of instruction
	constant IMM_WIDTH		: natural := 8;		-- Width of immidiate
	constant IADDR_WIDTH	: natural := 8;		-- Width of instruction address
  
  --ALU signals
	signal rt				: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rs				: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ALUctrl			: std_logic_vector(2 downto 0);
	signal ALUresult		: std_logic_vector(DATA_WIDTH-1 downto 0);

  --register file signals
	signal rt_read			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rs_read			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rt_addr			: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal rs_addr			: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal rd_addr			: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal wr_data			: std_logic_vector(DATA_WIDTH-1 downto 0);
  
  --Control signals
  
	signal IF_ID_Branch		: std_logic;
	signal IF_ID_Jump		: std_logic;
	signal ID_EX_RegDst		: std_logic;
	signal ID_EX_MemRead	: std_logic;
	signal EX_MEM_MemWrite	: std_logic;
	signal MEM_WB_MemtoReg	: std_logic;
	signal ID_EX_ALUop		: std_logic_vector(2 downto 0);
	signal ID_EX_ALUSrc		: std_logic;
	signal EX_MEM_RegWrite	: std_logic;
	signal MEM_WB_RegWrite	: std_logic;
	signal EX_MEM_ImmtoReg	: std_logic;

  --Branch control signals
	signal branch_mux			:std_logic;

  --IF/ID out signals
	signal if_id_instruction	: std_logic_vector(INST_WIDTH-1 downto 0);
	signal if_id_pc				: std_logic_vector(IADDR_WIDTH-1 downto 0);
	
  --ID/EX out signals
	signal id_ex_rs_read		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal id_ex_rt_read		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal id_ex_rs_addr		: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal id_ex_rt_addr		: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal id_ex_rd_addr		: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal id_ex_sign_ext_imm	: std_logic_vector(DATA_WIDTH-1 downto 0);
	
  --EX/MEM out signals
	signal ex_mem_branch_target	: std_logic_vector(IADDR_WIDTH-1 downto 0);
	signal ex_mem_ALU_result	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ex_mem_rt_read		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ex_mem_rd_addr		: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	
  --MEM/WB out signals
	signal mem_wb_mem_data		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_wb_ALU_result	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_wb_rd_addr		: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);

  --Forwarding signals
	signal forward_a			: std_logic_vector(1 downto 0);
	signal forward_b			: std_logic_vector(1 downto 0);
	
  --Hazard signals
	signal stall				: std_logic;
	
  --Internals
	signal RegDst_mux			: std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
	signal PC_out				: std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Output of PC.
	signal PC_new				: std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Updated PC value
	signal PC_incremented		: std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Output of PC.
	signal PC_branch			: std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Updated PC value
	signal PC_update			: std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Updated PC value
	signal branch_or_iterate	: std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal jump_addr			: std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal ALU_or_dmem			: std_logic_vector(DATA_WIDTH-1 downto 0);
	
  
begin
-----------------------------------------------------------------------------
--instantiate the ALU
  ALU: entity work.ALU(Behavioral)
    generic map (
	DATA_WIDTH => DATA_WIDTH)
    port map (
		rt        => id_ex_rt_read,
		rs        => id_ex_rs_read,
		ALUctrl   => ID_EX_ALUop,
		ALUresult => ALUresult);

  -----------------------------------------------------------------------------
 --instantiate Register File
  regFile : entity work.register_file
    generic map (
    DATA_WIDTH => DATA_WIDTH,
    ADDR_WIDTH => REG_ADDR_WIDTH)           --? width = 8?
    port map (
      clk     => clk    ,
      rst     => reset  ,
      wr_en   => MEM_WB_RegWrite  ,
      rt_addr => if_id_instruction(20 downto 16),
      rs_addr => if_id_instruction(25 downto 21),
      rd_addr => mem_wb_rd_addr,
      wr_data => wr_data,    
      rs      => rs_read, 
      rt      => rt_read);

-----------------------------------------------------------------------------
  --instantiate pipeline register IF/ID
	if_id: entity work.if_id(behavioral)
	generic map (
	INST_WIDTH => INST_WIDTH,
    ADDR_WIDTH => ADDR_WIDTH
    )
	port map (
		clk				=> clk,	
		PC_in			=> PC_incremented,
		instruction_in	=> imem_data_in,
		PC_out			=> if_id_pc,
		instruction_out	=> if_id_instruction
	);
	
-----------------------------------------------------------------------------
  --instantiate pipeline register ID/EX
	id_ex: entity work.id_ex(Behavioral)
	generic map (
	ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH,
	REG_ADDR_WIDTH => REG_ADDR_WIDTH
    )
	port map (
		clk					=> clk,	
		rs_read_in			=> rs_read,
		rt_read_in			=> rt_read,
		rs_addr_in			=> if_id_instruction(25 downto 21),
		rt_addr_in			=> if_id_instruction(20 downto 16),
		rd_addr_in			=> if_id_instruction(15 downto 11),
		sign_ext_imm_in		=> std_logic_vector(resize(signed(if_id_instruction(15 downto 0)), INST_WIDTH)),
		rs_read_out			=> id_ex_rs_read,
		rt_read_out			=> id_ex_rt_read,
		rs_addr_out			=> id_ex_rs_addr,
		rt_addr_out			=> id_ex_rt_addr,
		rd_addr_out			=> id_ex_rd_addr,
		sign_ext_imm_out	=> id_ex_sign_ext_imm
	);
	
-----------------------------------------------------------------------------
  --instantiate pipeline register EX/MEM
	ex_mem_registers: entity work.ex_mem(Behavioral)
	generic map (
	ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => DATA_WIDTH,
	REG_ADDR_WIDTH => REG_ADDR_WIDTH
    )
	port map (
		clk					=> clk,	
		ALU_result_in		=> ALUresult,
		rt_read_in			=> id_ex_rt_read,
		rd_addr_in			=> RegDst_mux,
		
		ALU_result_out		=> ex_mem_ALU_result,
		rt_read_out			=> ex_mem_rt_read,
		rd_addr_out			=> ex_mem_rd_addr
	);
	
-----------------------------------------------------------------------------
  --instantiate pipeline register MEM/WB
	mem_wb_registers: entity work.mem_wb(Behavioral)
	generic map (
	DATA_WIDTH => DATA_WIDTH,
	REG_ADDR_WIDTH => REG_ADDR_WIDTH
    )
	port map (
		clk					=> clk,	
		mem_data_in			=> dmem_data_in,
		ALU_result_in		=> ex_mem_ALU_result,
		rd_addr_in			=> ex_mem_rd_addr,
		
		mem_data_out		=> mem_wb_mem_data,
		ALU_result_out		=> mem_wb_ALU_result,
		rd_addr_out			=> mem_wb_rd_addr
	);
  -----------------------------------------------------------------------------
  --instantiate Control
	Control: entity work.control_pipe(behavioral)
	generic map (
    INST_WIDTH => INST_WIDTH)
	port map (
		clk         => clk,
		rst         => reset,
                stall       => stall,
                proc_enable => processor_enable,
		instruction => if_id_instruction,
		
		MEM_WB_MemtoReg => MEM_WB_MemtoReg,
		
		EX_MEM_RegWrite => EX_MEM_RegWrite,
		MEM_WB_RegWrite => MEM_WB_RegWrite,
		
		EX_MEM_MemWrite => EX_MEM_MemWrite,
		
		ID_EX_MemRead	=> ID_EX_MemRead,
		
		IF_ID_Branch	=> IF_ID_Branch,
		IF_ID_Jump		=> IF_ID_Jump,
		
		ID_EX_ALUop		=> ID_EX_ALUop,
		ID_EX_RegDst    => ID_EX_RegDst,
		ID_EX_ALUSrc    => ID_EX_ALUSrc,
		
		EX_MEM_ImmtoReg => EX_MEM_ImmtoReg
	);

  -----------------------------------------------------------------------------
  --instantiate branch control
	branch_control: entity work.branch_control(behavioral)
	generic map (
    DATA_WIDTH	=> DATA_WIDTH,
    IMM_WIDTH	=> IMM_WIDTH,          -- Width of immidiate
    IADDR_WIDTH	=> IADDR_WIDTH)
	port map (
		ctrl_branch => IF_ID_Branch,
		imm_in		=> id_ex_sign_ext_imm(IMM_WIDTH-1 downto 0),
		rs_in		=> rs_read,
		rt_in		=> rt_read,
		addr_in		=> if_id_pc,
		addr_out	=> PC_branch,
		branch_mux	=> branch_mux
	);
	
  -----------------------------------------------------------------------------
 --instantiate Forwarding Unit
  forward_unit : entity work.forwarding_unit
    generic map (
    REG_ADDR_WIDTH => REG_ADDR_WIDTH)           
    port map (
		ex_mem_reg_write	=> EX_MEM_RegWrite,
		mem_wb_reg_write	=> MEM_WB_RegWrite,
		ex_mem_register_rd	=> ex_mem_rd_addr,
		mem_wb_register_rd	=> mem_wb_rd_addr,
		id_ex_register_rs	=> id_ex_rs_addr,
		id_ex_register_rt	=> id_ex_rt_addr,
		forward_a			=> forward_a,
		forward_b    		=> forward_b
	);
  -----------------------------------------------------------------------------
 --instantiate Hazard Detection Unit
  hazard_detection : entity work.hazard_detection_unit
    generic map (
    REG_ADDR_WIDTH => REG_ADDR_WIDTH)           
    port map (
		clk     			=> clk,
		rst     			=> reset,
		id_ex_mem_read		=> ID_EX_MemRead,
		id_ex_register_rt	=> id_ex_rt_addr,
		if_id_register_rs	=> if_id_instruction(25 downto 21),
		if_id_register_rt	=> if_id_instruction(20 downto 16),
		stall				=> stall
	);
  -----------------------------------------------------------------------------
  
--Write-register-MUX 
 with ID_EX_RegDst select
   RegDst_mux <=
   id_ex_rd_addr	when '0',
   id_ex_rt_addr	when '1',
   (others => 'X')	when others;

--ALU rt input MUX
with forward_a select
  rs <=
  id_ex_rs_read		when "00",
  ex_mem_ALU_result	when "10",
  ALU_or_dmem		when "01",
  (others => 'X')	when others;
  
--ALU rs input MUX
with forward_b select
  rt <=
  id_ex_rt_read		when "00",
  ex_mem_ALU_result	when "10",
  ALU_or_dmem		when "01",
  (others => 'X')	when others;
  
-- Branch or PC+1 MUX
with branch_mux select
  branch_or_iterate <=
  PC_incremented	when '0',
  PC_branch		when '1',
  --IMM is larger than address-space. Using bottom least significant bits,
  --assuming that most significant bits will be sign extension.
  (others => 'X') when others;

-- Jump MUX
with IF_ID_Jump select
  PC_new <=
  branch_or_iterate when '0',
  jump_addr         when '1',
  (others => 'X') when others;

-- ALU/Memory_out MUX
with MEM_WB_MemtoReg select
  ALU_or_dmem <= 
  mem_wb_ALU_result	when '0',
  mem_wb_mem_data	when '1',
  (others => 'X') when others;

-- Load Imm Mux			--Obsolete if rs=0 => imm can propagate through ALU?
with EX_MEM_ImmtoReg select
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
      if processor_enable = '1' then
        imem_address <= PC_new;
        PC_out <= PC_new;
      end if;
    end if;
  end process;
-------------------------------------------------------------------------------
  ALUctrl <= ID_EX_ALUop(2 downto 0);       --ALU_Out is wider to open for expansion.

  
  --Dmem and PC
  dmem_write_enable <= EX_MEM_MemWrite;
  dmem_address <= ex_mem_ALU_result(ADDR_WIDTH-1 downto 0);  --Size of dmem is small.
  PC_incremented <= std_logic_vector(signed(PC_out) + 1);
  jump_addr <= imem_data_in(ADDR_WIDTH-1 downto 0); -- & PC_out(31 downto 26);
                                                    -- --Address space is
                                                    -- smaller than imm    
  dmem_data_out <= ex_mem_rt_read;
  
end Behavioral;

