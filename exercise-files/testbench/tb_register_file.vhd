LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity tb_register_file IS
end tb_register_file;

architecture behaviour of tb_register_file is
  constant clk_period : time := 10 ns;  -- Clock period.
  constant ADDR_WIDTH : natural := 5;
  constant DATA_WIDTH : natural := 32;
  
  --Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal wr_en : std_logic := '0';
  
  signal rt_addr : std_logic_vector(ADDR_WIDTH-1 downto 0):= (others => '0');
  signal rs_addr : std_logic_vector(ADDR_WIDTH-1 downto 0):= (others => '0');
  signal rd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0):= (others => '0');
  signal wr_data : std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0');

  --Outputs
  signal rs : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rt : std_logic_vector(DATA_WIDTH-1 downto 0);

begin  -- behaviour
  reg: entity work.register_file port map (
    clk     => clk,      
    rst     => rst,     
    wr_en   => wr_en,    
                     
    rt_addr => rt_addr,  
    rs_addr => rs_addr, 
    rd_addr => rd_addr, 
    wr_data => wr_data,
    
    rs      => rs,
    rt      => rt);      
    
-- purpose: Clk_generator

  clk_proc: process
  begin  -- process
    wait for clk_period/2;
    clk <= not clk;
  end process;

-- purpose: Stimulus
  stim_proc: process
-------------------------------------------------------------------------------
    procedure checkReset is
    begin
      --Check all register = 0
      for addr in 0 to (2**ADDR_WIDTH)-1 loop
        rs_addr <= std_logic_vector(to_unsigned(addr, ADDR_WIDTH));
        wait for clk_period/100;        --Delay to allow values to change.
        assert(rs = (others => '0')) report "Registers were not reset correctly" severity error;         
      end loop;  -- addr

    end checkReset;
-------------------------------------------------------------------------------
--Assumes that all registers are zero
-- Sets one register, checks that it, and only it, was changed.
    procedure setAndCheckOthersZero(
      addr_in : in integer;
      data_in : in std_logic_vector(DATA_WIDTH-1 downto 0)) is

      begin
        wait until falling_edge(clk);          --Change values on falling edge

        wr_data <= data_in;
        rd_addr <= std_logic_vector(to_unsigned(addr_in, ADDR_WIDTH));
        wr_en <= '1';

        wait until rising_edge(clk);
        wait until rising_edge(clk); --Data cannot be read until next cycle.  
--        wait for clk_period/10;                 --Time for propagating result. Neccessary?
        for addr in 0 to (2**ADDR_WIDTH)-1 loop
          rs_addr <= std_logic_vector(to_unsigned(addr, ADDR_WIDTH));
          wait for clk_period/100;        --Delay to allow values to change.
          if addr = addr_in then
            assert(rs = data_in) report "Register: " & integer'image(addr) & "was not set correctly." severity error;
          else
            assert(rs = (others => '0')) report "Register: " & integer'image(addr) & "was not zero." severity error;
          end if;
        end loop;  -- addr

--Reset register
        wr_data <= (others => '0');
        wait until rising_edge(clk);
        wr_en <= '0';

      end setAndCheckOthersZero;
-----------------------------------------------------------------------------

      begin  -- process
        assert false report "Running tb_register_file" severity note;

        --Start from reset
        rst <= '1';
        wait for 32*clk_period;
        rst <= '0';
        wait for clk_period;
        checkReset;
        
        maxv: for addr in 0 to (2**ADDR_WIDTH)-1 loop
          setAndCheckOthersZero(addr, x"7FFFFFFF");
        end loop;

        minv: for addr in 0 to (2**ADDR_WIDTH)-1 loop
          setAndCheckOthersZero(addr, x"80000000");
        end loop;

        assert false report "tb_register_file Finished." severity note;
        wait;
      end process;
    end behaviour;
