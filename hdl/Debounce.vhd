--///////////////////////////////////////////////////////////////////////////////////////////////////
--//-------------------------------------------------------------------------------
--//-- Title      : Debounce logic
--//-------------------------------------------------------------------------------
--//-- File       : Debounce.vhd
--//-- Author     : Corporate Applications Engineering
--//-- Company    : Microsemi Corporation
--//-- Device     : SmartFusion2
--//-- Standard   : VHDL
--//-------------------------------------------------------------------------------
--//-- Description: This code implementes the Debounce logic to remove the switch bounces  
--//--              and generating a single pulse to PCIe core when switch pressed on board.
--//-------------------------------------------------------------------------------
--//-- Copyright (c) 2013   Microsemi Corporation
--//--                      All rights reserved.
--//-------------------------------------------------------------------------------
--//-- Revisions  : V1.0
--//-------------------------------------------------------------------------------
--/////////////////////////////////////////////////////////////////////////////////////////////////// 

library IEEE;

use IEEE.std_logic_1164.all;
use       IEEE.std_logic_unsigned.all;

entity DEBOUNCE is
port (
	CLK, RESET_N, SWITCH : in std_logic;				-- inputs
	INTERRUPT: out std_logic 							-- output   
);
end DEBOUNCE;

architecture BEHAVIOURAL of DEBOUNCE is
   -- signal, component etc. declarations
constant N: integer := 16;
signal  DFF1, DFF2,q_add,q_reset	 : std_logic; 		-- input flip-flops and control flags	 
signal q_reg,q_next : std_logic_vector(N-1 downto 0) ;


begin
q_reset <= (DFF1  xor  DFF2);		-- xor input flip flops to look for level chage to reset counter
q_add <= not(q_reg(N-1));			-- add to counter when q_reg msb is equal to 0

-- combo counter to manage q_next	
	process ( q_reset, q_add, q_reg)
		variable state : std_logic_vector(1 downto 0);
		begin
			state := q_reset & q_add;
			case(state) is
				when	"00" =>
						q_next <= q_reg;
				when	"01" =>
						q_next <= q_reg + 1;
				when others =>
						q_next <= X"0000";
			end case; 	
		end process;

-- Flip flop inputs and q_reg update
	process ( CLK,RESET_N )
		begin			
			if(RESET_N = '0') then				
					DFF1 <= '0';
					DFF2 <= '0';
					q_reg <= X"0000";				
			else
				if (CLK'event and CLK = '1') then
					DFF1 <= SWITCH;
					DFF2 <= DFF1;
					q_reg <= q_next;
				end if;
			end if;
		end process;

-- counter control
	process( CLK,RESET_N )
		begin
			if(RESET_N = '0') then				
					INTERRUPT <= '0';				
			else		
				if (CLK'event and CLK = '1') then		
					if(q_reg(N-1) = '1') then
						INTERRUPT <= not DFF2;
					end if;
				end if;
			end if;				
		end process;

end BEHAVIOURAL;