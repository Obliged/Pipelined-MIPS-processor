library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
  
  generic (
    DATA_WIDTH : natural := 32;
    ADDR_WIDTH : natural := 5);

  port (
    clk : in std_logic;
    rst : in std_logic;
    wr_en : in std_logic;
    
    rt_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    rs_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    rd_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    wr_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

    rs : out std_logic_vector(DATA_WIDTH-1 downto 0);
    rt : out std_logic_vector(DATA_WIDTH-1 downto 0));
    
end register_file;

architecture behavioural of register_file is

type RegisterFileType is array(0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal regFile : RegisterFileType ;

begin

  write: process (clk, rst, wr_en) is
  begin
    if rst = '1' then   
      regFile <= (others => (others => '0'));
    else
      if wr_en = '1' and rising_edge(clk) then  
        regFile(to_integer(unsigned(rd_addr))) <= wr_data ;  --Gate-dekodere
      end if;
    end if;
  end process;

  
  read: process (rs_addr, rt_addr, rd_addr, wr_en, wr_data) is
  begin  -- process read
    rs_forwarding: if (rs_addr = rd_addr) and wr_en = '1' then
       rs <= wr_data;
    else
      rs <= regFile(to_integer(unsigned(rs_addr)));
    end if;

    rt_forwarding: if (rt_addr = rd_addr) and wr_en = '1' then
      rt <= wr_data;
    else
      rt <= regFile(to_integer(unsigned(rt_addr)));
    end if;
  end process read;
    
end behavioural;
