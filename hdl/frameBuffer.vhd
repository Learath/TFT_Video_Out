--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: frameBuffer.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::IGLOO2> <Die::M2GL010T> <Package::484 FBGA>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity frameBuffer is
generic (
    FrameWidth  : integer := 800; -- # of pixels per line
    horizontal_blanking : integer := 88; -- # of blanking pixels per line
    horizontal_front_porch  : integer := 40; -- # of "front porch" pixels per line
    horizontal_pulse_width  : integer := 1;
    FrameHeight : integer := 480; -- # of lines per frame
    vertical_blanking   : integer := 32; -- # of blanking lines per frame
    vertical_front_porch    : integer := 13; -- # of "front porch" lines per frame
    vertical_pulse_width    : integer := 3;
    Pixel_Size  : integer := 24; -- # of bits per pixel
    data_clock  : integer := 30 -- Data Clock in mhz
);
port ( 
    pixel_i     : in std_logic_vector(Pixel_Size - 1 downto 0); -- Input pixel
    pixel_o     : out std_logic_vector(Pixel_Size - 1 downto 0); -- Output pixel
    CLK_i       : in std_logic; -- Input clock
    CLK_o       : out std_logic; -- Clock to LCD
    reset_i       : in std_logic; -- Revert to initial state
    reset_o     : out std_logic; -- Display reset pin
    enable      : in std_logic; -- Output enable
    backlight_en    : out std_logic; -- Backlight enable/PWM
    h_sync_i    : in std_logic; -- Horizontal Sync in
    h_sync_o    : out std_logic; -- Horiznotal Sync out
    v_sync_i    : in std_logic; -- Vertical Sync in
    v_sync_o    : out std_logic; -- Vertical sync out
    input_valid : in std_logic -- Input valid
);
end frameBuffer;
architecture Behavioral of frameBuffer is
   -- signal, component etc. declarations
type frame_buffer is array (FrameWidth downto 0, FrameHeight downto 0) of std_logic_vector(Pixel_Size - 1 downto 0);
constant REG_SIZE   : integer := integer(ceil(log2(realmax(real(FrameWidth+horizontal_blanking+horizontal_front_porch),real(FrameHeight+vertical_blanking+vertical_front_porch)))));   -- # size of register to store width count and heigh count
signal active_frame_buffer : frame_buffer; -- Active frame buffer
signal inactive_frame_buffer  : frame_buffer; -- Inactive frame buffer
signal active_horizontal : integer := 0;
signal active_vertical : integer := 0;
signal inactive_horizontal  : integer := 0;
signal inactive_vertical    : integer := 0;
begin
    process(pixel_i, CLK_i, reset_i, enable, h_sync_i, v_sync_i)
    variable i : integer;
    variable j : integer;
    begin
        if rising_edge(CLK_i) then
            if (reset_i = '1') then
--                active_frame_buffer <= ((others=>(others => '0')),(others=>(others=>'0')),(others=>(others=>'0')));  -- Checks clean, does not compile
--                inactive_frame_buffer <= ((others=>(others => '0')),(others=>(others=>'0')),(others=>(others=>'0'))); -- Checks clean, does not compile
                for i in 0 to FrameWidth loop
                    for j in 0 to FrameHeight loop
                        active_frame_buffer(i, j) <= (others=>'0');
                        inactive_frame_buffer(i, j) <= (others=>'0');
                    end loop;
                end loop;
                backlight_en <= '0';
                reset_o <= '0';
                h_sync_o <= '1';
                v_sync_o <= '1';
                CLK_o <= '0';
                pixel_o <= (others =>'0');
                active_horizontal <= 0;
                active_vertical <= 0;
                inactive_horizontal <= 0;
                inactive_vertical <= 0;
            else
                if (enable = '1') then -- Output section
                    backlight_en <= '1';
                    reset_o <= '1';
                    if (active_horizontal = 0) then
                        h_sync_o <= '0';
                        active_horizontal <= active_horizontal + 1;
                    elsif (active_horizontal = horizontal_pulse_width) then
                        h_sync_o <= '1';
                        active_horizontal <= active_horizontal + 1;
                    elsif ((active_horizontal = horizontal_blanking) and (active_vertical >= vertical_blanking)) then
                        pixel_o <= active_frame_buffer((active_horizontal - horizontal_blanking),(active_vertical - vertical_blanking));
                        active_horizontal <= active_horizontal + 1;
                    elsif ((active_horizontal < (horizontal_blanking + FrameWidth)) and (active_vertical >= vertical_blanking)) then
                        pixel_o <= active_frame_buffer((active_horizontal - horizontal_blanking),(active_vertical - vertical_blanking));
                        active_horizontal <= active_horizontal + 1;
                    elsif (active_horizontal = (horizontal_blanking + FrameWidth + horizontal_front_porch)) then
                        active_horizontal <= 0;
                        active_vertical <= active_vertical + 1;
                    else
                        active_horizontal <= active_horizontal + 1;
                    end if;
                    if (active_vertical = 0) then
                        v_sync_o <= '0';
                    elsif (active_vertical = vertical_pulse_width) then
                        v_sync_o <= '1';
                    elsif (active_vertical = vertical_blanking + active_vertical + vertical_front_porch) then
                        active_vertical <= 0;
                        active_horizontal <= 0;
                    end if;
                end if;
                if (input_valid = '1') then -- Input section
                    if (h_sync_i = '0') then
                        inactive_horizontal <= 0;
                    end if;
                    if (v_sync_i = '0') then
                        inactive_vertical <= 0;
                    end if;
                    inactive_frame_buffer(inactive_horizontal, inactive_vertical) <= pixel_i;
                    if (inactive_horizontal < FrameWidth) then
                        inactive_horizontal <= inactive_horizontal + 1;
                    else
                        inactive_horizontal <= 0;
                        inactive_vertical <= inactive_vertical + 1;
                    end if;
                    if (inactive_vertical = FrameHeight) then
                        active_frame_buffer <= inactive_frame_buffer;
                        inactive_horizontal <= 0;
                        inactive_vertical <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
   -- architecture body
end Behavioral;
