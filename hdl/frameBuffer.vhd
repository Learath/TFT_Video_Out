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
    FrameHeight : integer := 480; -- # of lines per frame
    vertical_blanking   : integer := 32; -- # of blanking lines per frame
    vertical_front_porch    : integer := 13; -- # of "front porch" lines per frame
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
    v_sync_o    : out std_logic -- Vertical sync out
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
    begin
        if rising_edge(CLK_i) then
            if (reset_i = '1') then
                active_frame_buffer <= ((others=>(others => '0')),(others=>(others=>'0')),(others=>(others=>'0')));
                inactive_frame_buffer <= ((others=>(others => '0')),(others=>(others=>'0')),(others=>(others=>'0')));
                backlight_en <= '0';
                reset_o <= '0';
                h_sync_o <= '0';
                v_sync_o <= '0';
                CLK_o <= '0';
                pixel_o <= (others =>'0');
                active_horizontal <= 0;
                active_vertical <= 0;
                inactive_horizontal <= 0;
                inactive_vertical <= 0;
            elsif (enable = '1') then
                backlight_en <= '1';
                reset_o <= '1';
                if (active_horizontal = 0) then
                    h_sync_o <= '1';
                elsif (active_horizontal = horizontal_blanking) then
                    h_sync_o <= '0';
                    if (active_vertical >= vertical_blanking) then
                        pixel_o <= active_frame_buffer((active_vertical - vertical_blanking),(active_horizontal - horizontal_blanking));
                    end if;
                elsif ((active_horizontal < (horizontal_blanking + FrameWidth)) and (active_vertical >= vertical_blanking)) then
                    pixel_o <= active_frame_buffer((active_vertical - vertical_blanking),(active_horizontal - horizontal_blanking));
                elsif (active_horizontal = (horizontal_blanking + FrameWidth + horizontal_front_porch)) then
                    active_horizontal <= 0;
                end if;
                if (active_vertical = 0) then
                    v_sync_o <= '1';
                elsif (active_vertical = vertical_blanking) then
                    v_sync_o <= '0';
                elsif (active_vertical = vertical_blanking + active_vertical + vertical_front_porch) then
                    active_vertical <= 0;
                end if;
            end if;
        end if;
    end process;
   -- architecture body
end Behavioral;
