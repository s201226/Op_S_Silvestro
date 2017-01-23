LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vga IS
PORT(	CLOCK_50: IN STD_LOGIC;
		nRST: IN STD_LOGIC;
		x: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		y: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		z: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		VGA_R	  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
		VGA_G :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);  
		VGA_B  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0); 
		VGA_VS	: OUT STD_LOGIC;
		VGA_HS	: OUT STD_LOGIC
		);
END vga;

ARCHITECTURE behaviour OF vga IS
 
   COMPONENT VGA_1_corrected 
		PORT (	    clk		: IN STD_LOGIC;
			reset	: IN STD_LOGIC;
			v_sync	: OUT STD_LOGIC;
			h_sync	: OUT STD_LOGIC;
			enable	: OUT STD_LOGIC;
			row 	: OUT INTEGER;
			column	: OUT INTEGER
			);
	END COMPONENT;
	
	COMPONENT vga_2 
		PORT(
			enable:	IN		STD_LOGIC;	
			row	  :	IN		INTEGER;		
			column:	IN		INTEGER;		
			x : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
			y : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			z : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			red	  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');  
			green :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');  
			blue  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0')); 
	END COMPONENT;
	
	COMPONENT clk_divider 
    PORT (
        clk_in : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
   END COMPONENT;

SIGNAL en,clk: STD_LOGIC;
SIGNAL riga,colonna: INTEGER;

BEGIN

CLK_DIV: clk_divider PORT MAP (clk_in=>CLOCK_50,
			reset=>nRST,
			clk_out=>clk);

SYNC_GENERATOR: VGA_1_corrected PORT MAP (clk=>clk,
			reset=>nRST,
			v_sync=>VGA_VS,
			h_sync=>VGA_HS,
			enable=>en,
			row=>riga,
			column=>colonna);

CONTROLLER : vga_2 PORT MAP (enable=>en,
			row=>riga,
			column=>colonna,
			x=>x,
			y=>y,
			z=>z,
			red=>VGA_R,
			green=>VGA_G,
			blue=>VGA_B);

END behaviour;