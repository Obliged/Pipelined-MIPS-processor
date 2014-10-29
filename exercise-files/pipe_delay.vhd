library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pipe_delay is
  
  generic (
    DELAY    : natural := 3;            -- Number of flip-flops delay.
    REG_WIDTH : natural := 5);           -- Width of pipe register.

  port (
   clk : in std_logic;
   rst : in std_logic;
   pipe_in  : in  std_logic_vector(REG_WIDTH-1 downto 0);-- Pipe register input
   pipe_out : out std_logic_vector(REG_WIDTH-1 downto 0)-- Pipe register output
   );
end pipe_delay;


architecture behavioural of pipe_delay is

type data_vec_t is array (0 to DELAY-1) of std_logic_vector(REG_WIDTH-1 downto 0);
signal data_vec : data_vec_t;

begin  -- behavioural

  pipe_out <= data_vec(DELAY-1);

    propagate: process (clk, rst)
    begin  -- process propagate
      if rst = '1' then                  -- asynchronous reset (active high)
        data_vec <= (others => (others => '0'));
      elsif clk'event and clk = '1' then  -- rising clock edge
        data_vec(0) <= pipe_in;
        for i in 1 to DELAY-1 loop
          data_vec(i) <= data_vec(i-1);
        end loop;
      end if;
    end process propagate;
end architecture behavioural; 
     
