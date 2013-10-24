------------------------------------------------------------------------
--     S3demo.vhd -- Demonstrate basic Pegasus function
------------------------------------------------------------------------
-- Author:  Clint Cole
--          Copyright 2004 Digilent, Inc.
------------------------------------------------------------------------
-- This module tests basic device function and connectivity on the Pegasus
-- board. It was developed using the Xilinx WebPack tools.
--
--  Inputs:
--		mclk		- system clock (50Mhz Oscillator on Pegasus board)
--		bn			- buttons on the Pegasus board
--		swt		- switches on the Pegasus board (8 switches)
--
--  Outputs:
--		led		- discrete LEDs on the Pegasus board (8 leds)
--		an			- anode lines for the 7-seg displays on Pegasus
--		ssg		- cathodes (segment lines) for the displays on Pegasus
--
--  VGA Components:
--		hs			- horizontal monitor sync
--		vs			- vertical monitor sync
--		red		- red pixel color
--		green		- green pixel color
--		blue		- blue pixel color
--
--	 Keyboard Components:
--		kd			- keyboard data in
--		kc			- keyboard clock in
--
------------------------------------------------------------------------
-- Revision History:
--  01/15/2004(ClintC): created
--  07/07/2004(BarronB): Added, VGA, and Keyboard Input
--  07/12/2004(BarronB): Modified for Spartan 3
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity S3demo is
    Port (
        mclk    : in std_logic;
        btn     : in std_logic_vector(3 downto 0);
        swt     : in std_logic_vector(7 downto 0);
        led     : out std_logic_vector(7 downto 0);
        an      : out std_logic_vector(3 downto 0);
        ssg     : out std_logic_vector(7 downto 0);
		  hs		 : out std_logic;
		  vs		 : out std_logic;
		  red, grn, blu : out std_logic;
		  kd, kc	 : in std_logic);
end S3demo;
										
architecture Behavioral of S3demo is

	------------------------------------------------------------------------
	-- Component Declarations
	------------------------------------------------------------------------
 	component vgaController is
    	Port ( mclk : in std_logic;
           hs : out std_logic;
           vs : out std_logic;
           red : out std_logic;
           grn : out std_logic;
           blu : out std_logic);
	end component;

	component keyboardVhdl is
	Port (	CLK, RST, KD, KC: in std_logic;
				an: out std_logic_vector (3 downto 0);
				sseg: out std_logic_vector (6 downto 0));
	end component;
	------------------------------------------------------------------------
	-- Signal Declarations
	------------------------------------------------------------------------

	signal clkdiv  : std_logic_vector(23 downto 0);
	signal cntr    : std_logic_vector(3 downto 0);
	signal cclk    : std_logic;
	signal dig     : std_logic_vector(6 downto 0);
	signal ssegkb	: std_logic_vector(6 downto 0);
	signal ankb		: std_logic_vector(3 downto 0);
	signal rst		: std_logic;
	------------------------------------------------------------------------
	-- Module Implementation
	------------------------------------------------------------------------

	begin

	vga1: vgaController port map (mclk => mclk, 
	 											hs => hs, 
												vs => vs, 
												red => red, 
												grn => grn, 
												blu => blu);

	kb1: 	keyboardVhdl port map( CLK => mclk,
											RST => rst,
											KD => kd,
											KC => kc,
											an => ankb,
											sseg => ssegkb);
	rst <= btn(0);
	
	led(7 downto 1) <= swt(7 downto 1);
	led(0) <= swt(0);
	
	dig <=    "0111111" when cntr = "0000" else
			"0000110" when cntr = "0001" else
			"1011011" when cntr = "0010" else
			"1001111" when cntr = "0011" else
			"1100110" when cntr = "0100" else
			"1101101" when cntr = "0101" else
			"1111101" when cntr = "0110" else
			"0000111" when cntr = "0111" else
			"1111111" when cntr = "1000" else
			"1101111" when cntr = "1001" else
			"0000000";

	ssg(6 downto 0) <= not dig when swt(0) = '0' else
							 ssegkb;
	an <= btn when swt(0) = '0' else
			ankb;
	ssg(7) <= btn(0);

	-- Divide the master clock (50Mhz) down to a lower frequency.
	process (mclk)
		begin
			if mclk = '1' and mclk'Event then
				clkdiv <= clkdiv + 1;
			end if;
		end process;

	cclk <= clkdiv(23);

	process (cclk)
		begin
			if cclk = '1' and cclk'Event then
				if cntr = "1001" then
				    cntr <= "0000";
				else
				    cntr <= cntr + 1;
				end if;
			end if;
			
		end process;

end Behavioral;

