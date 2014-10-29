LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_ALU IS
END tb_ALU;

architecture behaviour of tb_ALU is
  constant DATA_WIDTH : natural := 32;
  
  --Inputs
  signal ALUctrl : std_logic_vector(2 downto 0):= (others => '0');  -- Control signal
  signal rs : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- Left hand register
  signal rt : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- Right hand register (subtraction reg)

  --Outputs
  signal ALUresult : std_logic_vector(DATA_WIDTH-1 downto 0);
  
  
begin  -- behaviour
ALU: entity work.ALU port map(
  ALUctrl => ALUctrl,
  rs      => rs, 
  rt      => rt,
  
  ALUresult => ALUresult);

stim_proc: process
 -----------------------------------------------------------------------------
  procedure checkSubtract (
    rs_data : in integer;
    rt_data : in integer) is

  begin
    rs <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
    rt <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
    ALUctrl <= "110";
    wait for 1 ns;
    
    assert ALUresult = std_logic_vector(to_signed(rs_data - rt_data, DATA_WIDTH)) report "Subtract: Expected value at ALUresult not found."  severity error;
               
  end checkSubtract;
 ------------------------------------------------------------------------------   
  procedure checkAdd (
    rs_data : in integer;
    rt_data : in integer) is

  begin
    rs <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
    rt <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
    ALUctrl <= "010";
    wait for 1 ns;
    
    assert ALUresult = std_logic_vector(to_signed(rs_data + rt_data, DATA_WIDTH)) report "Add: Expected value at ALUresult not found." severity error;
               
  end checkAdd;
    
-------------------------------------------------------------------------------
  procedure checkSLT (
    rs_data : in integer;
    rt_data : in integer) is

  begin
    rs <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
    rt <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
    ALUctrl <= "011";
    wait for 1 ns;          

    assert ((ALUresult = x"00000000") and (rs_data >= rt_data))
      or   ((ALUresult = x"00000001") and (rs_data < rt_data))
      report "SLT: Expected value at ALUresult not found." severity error;

    --ALUctrl <= "111";
    --wait for 1 ns;
    
    --assert ((ALUresult = x"00000000") and (rs_data >= rt_data))
    --  or   ((ALUresult = x"00000001") and (rs_data < rt_data))
    --  report "SLT: Expected value at ALUresult not found." severity error;

  end checkSLT;
    
-------------------------------------------------------------------------------
  procedure checkOR (
    rs_data : in integer;
    rt_data : in integer) is

  begin
    rs <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
    rt <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
    ALUctrl <= "001";
    wait for 1 ns;
    
    assert ALUresult = (rs or rt) report "OR: Expected value at ALUresult not found." severity error;

    --ALUctrl <= "101";
    --wait for 1 ns;

    
    --assert ALUresult = (rs or rt) report "OR: Expected value at ALUresult not found." severity error;
               
  end checkOR;
-------------------------------------------------------------------------------
 procedure checkAND (
    rs_data : in integer;
    rt_data : in integer) is

  begin
    rs <= std_logic_vector(to_signed(rs_data, DATA_WIDTH));
    rt <= std_logic_vector(to_signed(rt_data, DATA_WIDTH));    
    ALUctrl <= "000";
    wait for 1 ns;

    assert ALUresult = (rs AND rt) report "AND: Expected value at ALUresult not found." severity error;

    --ALUctrl <= "100";
    --wait for 1 ns;
    
    --assert ALUresult = (rs AND rt) report "AND: Expected value at ALUresult not found." severity error;
               
  end checkAND;
-------------------------------------------------------------------------------
    procedure checkValue(
    rs_data : in integer;
    rt_data : in integer) is

    begin
      checkSubtract(rs_data, rt_data);
      checkAdd(rs_data, rt_data);
      checkSLT(rs_data, rt_data);
      checkOR(rs_data, rt_data);
      checkAND(rs_data, rt_data);
           
    end checkValue;
-------------------------------------------------------------------------------

 begin
   assert false report "Running tesetbench for ALU" severity note;
   
   --Corner case checking
   checkValue(integer'low, integer'low);
   checkValue(0, 0);
   checkValue(integer'high, integer'high);
   checkValue(integer'high, integer'low); 
   checkValue(integer'low, integer'high);
   checkValue(0, integer'low); 
   checkValue(integer'low, 0);

   --'Stuck at'-testing
   checkValue(-1431655766, 0);
   checkValue(1431655765, 0);
   checkValue(0, -1431655766);
   checkValue(0, 1431655765);
   checkValue(-1431655766, -1431655766);
   checkValue(1431655765, -1431655766);
   checkValue(-1431655766, 1431655765);
   checkValue(1431655765, 1431655765);
   
   --exhaustive testing of expected behaviour
   --for rs_data in integer'low to integer'high loop 
   --    for rt_data in integer'low to integer'high loop
   --    checkValue(rs_data, rt_data);
   --  end loop;  -- rt_data
   --end loop;  -- rs_data

   assert false report "Finished tb_ALU" severity note;
   wait;
 end process;
  
end;

 
