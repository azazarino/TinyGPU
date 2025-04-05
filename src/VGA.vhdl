library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync_gen is
  port (
    clk        : in std_logic;
    reset      : in std_logic;
    hsync      : out std_logic;
    vsync      : out std_logic;
    display_on : out std_logic;
    hpos       : out std_logic_vector(9 downto 0);
    vpos       : out std_logic_vector(9 downto 0)
  );
end entity;

architecture rtl of vga_sync_gen is
  -- Horizontal constants
  constant H_DISPLAY : integer := 640; -- Horizontal display width
  constant H_BACK    : integer := 48; -- Horizontal left border
  constant H_FRONT   : integer := 16; -- Horizontal right border
  constant H_SYNC    : integer := 96; -- Horizontal sync width

  -- Vertical constants
  constant V_DISPLAY : integer := 480; -- Vertical display height
  constant V_TOP     : integer := 33; -- Vertical top border
  constant V_BOTTOM  : integer := 10; -- Vertical bottom border
  constant V_SYNC    : integer := 2; -- Vertical sync lines

  -- Derived constants
  constant H_SYNC_START : integer := H_DISPLAY + H_FRONT;
  constant H_SYNC_END   : integer := H_DISPLAY + H_FRONT + H_SYNC - 1;
  constant H_MAX        : integer := H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  constant V_SYNC_START : integer := V_DISPLAY + V_BOTTOM;
  constant V_SYNC_END   : integer := V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  constant V_MAX        : integer := V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  signal hmaxxed, vmaxxed   : std_logic;
  signal hpos_cnt, vpos_cnt : unsigned(9 downto 0) := to_unsigned(0, 10);
begin
  hmaxxed <= '1' when (hpos_cnt = H_MAX or reset = '0') else
    '0';
  vmaxxed <= '1' when (vpos_cnt = V_MAX or reset = '0') else
    '0';

  hpos <= std_logic_vector(hpos_cnt);
  vpos <= std_logic_vector(vpos_cnt);

  -- Horizontal counter
  process (clk)
  begin
    if rising_edge(clk) then
        if (hpos_cnt >= H_SYNC_START and hpos_cnt <= H_SYNC_END) then
            hsync <= '1';
        else
            hsync <= '0';
        end if;
      if hmaxxed = '1' then
        hpos_cnt <= to_unsigned(0, 10);
      else
        hpos_cnt <= hpos_cnt + 1;
      end if;
    end if;
  end process;

  -- Vertical counter
  process (clk)
  begin
    if rising_edge(clk) then
      if (vpos_cnt >= V_SYNC_START and vpos_cnt <= V_SYNC_END) then
        vsync <= '1';
      else
        vsync <= '0';
      end if;
      if hmaxxed = '1' then
        if vmaxxed = '1' then
          vpos_cnt <= to_unsigned(0, 10);
        else
          vpos_cnt <= vpos_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  display_on <= '1' when ((hpos_cnt<H_DISPLAY) and (vpos_cnt<V_DISPLAY)) else '0';
end architecture;