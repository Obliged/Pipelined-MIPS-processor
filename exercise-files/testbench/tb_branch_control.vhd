LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity tb_branch_control is
end tb_branch_control;

architecture behaviour of tb_branch_control is
  constant DATA_WIDTH : natural := 32;
  constant IADDR_WIDTH : natural := 8;
  constant IMM_WIDTH : natural := 8;

  signal ctrl_branch    : std_logic:= '0';  --Branch control signal, form decoder
  signal imm_in         : std_logic_vector(IMM_WIDTH-1 downto 0):= (others => '0');  
  signal rs_in          : std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0'); 
  signal rt_in          : std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0'); 
  signal addr_in        : std_logic_vector(IADDR_WIDTH-1 downto 0):= (others => '0');
  signal addr_out       : std_logic_vector(IADDR_WIDTH-1 downto 0):= (others => '0');
  signal branch_mux    : std_logic := '0';
  
begin  -- behaviour
branch_control : entity work.branch_control
 generic map (
   DATA_WIDTH  => DATA_WIDTH,
   IADDR_WIDTH => IADDR_WIDTH,
   IMM_WIDTH   => IMM_WIDTH)
  port map(
    ctrl_branch =>  ctrl_branch, 
    imm_in      =>  imm_in     , 
    rs_in       =>  rs_in      , 
    rt_in       =>  rt_in      , 
    addr_in     =>  addr_in    , 
    addr_out    =>  addr_out   , 
    branch_mux  =>  branch_mux);

stim_proc: process
-------------------------------------------------------------------------------
  procedure checkAdd (
    var_addr_in : in integer;
    var_imm_in  : in integer) is

    begin
    addr_in <= std_logic_vector(to_signed(var_addr_in, IADDR_WIDTH));
    imm_in  <= std_logic_vector(to_signed(var_imm_in,  IMM_WIDTH));    
    wait for 1 ns;
    
    assert addr_out = std_logic_vector(to_signed(var_addr_in + var_imm_in, IADDR_WIDTH)) report "checkAdd: Expected branch value not found." severity error;
               
  end checkAdd;
-------------------------------------------------------------------------------
  procedure checkEqual(
    rs_data : in integer;
    rt_data : in integer) is
    
    begin
      rs_in <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
      rt_in <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
      wait for 1 ns;          

    assert ((branch_mux = '1') and (rs_data = rt_data)  and (ctrl_branch = '1'))
      or   ((branch_mux = '0') and ((rs_data /= rt_data) or (ctrl_branch = '0')))
      report "checkEqual: Expected result not found." severity error;

end checkEqual;
-------------------------------------------------------------------------------

begin
  assert false report "Starting tb_branch_control." severity note;

  checkEqual(-1431655766, -1431655766);
  checkEqual(-1431655766, 0);
  checkEqual(0, -1431655766);
  checkEqual(1431655765,1431655765);
  checkEqual(0,1431655765);
  checkEqual(1431655765,0);
  checkEqual(0, 0);
  checkEqual(integer'high, integer'high);
  checkEqual(integer'high, integer'low);
  checkEqual(integer'low, integer'high);
  checkEqual(integer'low, integer'low);

  checkAdd(0, 16#AA#);
  checkAdd(16#AA#, 0);
  checkAdd(16#55#, 16#AA#);
  checkAdd(16#55#,16#55#);
  checkAdd(0,16#55#);
  checkAdd(16#55#,0);
  checkAdd(0, 0);
  checkAdd(16#7F#, 16#7F#);
  checkAdd(16#7F#, 16#80#);
  checkAdd(16#80#, 16#7F#);
  checkAdd(16#80#, 16#80#);
  
  assert false report "tb_branch_control_finished" severity note;
  wait;
end process;  

end behaviour;
