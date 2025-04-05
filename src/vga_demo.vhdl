library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tt_um_vga_example is
  port (
    ui_in   : in std_logic_vector(7 downto 0);
    uo_out  : out std_logic_vector(7 downto 0);
    uio_in  : in std_logic_vector(7 downto 0);
    uio_out : out std_logic_vector(7 downto 0);
    uio_oe  : out std_logic_vector(7 downto 0);
    ena     : in std_logic;
    clk     : in std_logic;
    rst_n   : in std_logic
  );
end tt_um_vga_example;

architecture rtl of tt_um_vga_example is

  signal hsync, vsync : std_logic;
  signal R, G, B      : std_logic_vector(1 downto 0);
  signal video_active : std_logic;
  signal pix_x, pix_y : std_logic_vector(9 downto 0);
  signal counter : unsigned(8 downto 0);
  signal process_event : std_logic;
  signal top : signed(9 downto 0) := to_signed(230, 10);
  signal bottom : signed(9 downto 0) := to_signed(250, 10);
  signal left : signed(10 downto 0) := to_signed(310, 11);
  signal right : signed(10 downto 0) := to_signed(330, 11);
  signal switch : std_logic;
  signal x_dir, y_dir : signed(1 downto 0) := to_signed(1, 2); 
begin

  uo_out <= hsync & B(0) & G(0) & R(0) & vsync & B(1) & G(1) & R(1);


  clock_divider : process(clk) is 
    begin
        if rising_edge(clk) then
            counter <= counter +1;
        end if;
    end process;


  process(clk) is 

  begin   
    if rising_edge(clk) then
        if rst_n = '0' then
            top <= to_signed(230, 10);
            bottom <= to_signed(250, 10);
            left <= to_signed(310, 11);
            right <= to_signed(330, 11);
            
        else
            if unsigned(pix_y) = 480 and counter = "000000000" then
                if right >= 620 then
                    x_dir <= to_signed(-1, 2);
                elsif left <= 20 then
                    x_dir <= to_signed(1, 2);
                end if;

                if bottom >= 460 then
                    y_dir <= to_signed(-1,2);
                elsif top <= 20 then
                    y_dir <= to_signed(1,2);
                end if;
                top <= top + y_dir;
                bottom <= bottom + y_dir;
                left <= left + x_dir;
                right <= right + x_dir;
            end if;
        end if;
    end if;
  end process;

  
  vga_sync_gen_inst : entity work.vga_sync_gen
    port map
    (
      clk        => clk,
      reset      => rst_n,
      hsync      => hsync,
      vsync      => vsync,
      display_on => video_active,
      hpos       => pix_x,
      vpos       => pix_y
    );

  R <= (pix_x(0) & pix_y(6)) when video_active = '1' and ((unsigned(pix_y) < 20 or unsigned(pix_y) > 460) or (unsigned(pix_x) < 20 or unsigned(pix_x) > 620)) else
    "00";
  B <= pix_x(0) & pix_y(4) 
     when video_active = '1' and 
          (unsigned(pix_x) > unsigned(left) and unsigned(pix_x) < unsigned(right) and 
           unsigned(pix_y) > unsigned(top) and unsigned(pix_y) < unsigned(bottom)) 
     else 
     "00";  -- default value when condition is false

  G <= "00";

  uio_oe  <= "00000000";
  uio_out <= "00000000";

end architecture;