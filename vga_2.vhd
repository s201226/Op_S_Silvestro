LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vga_2 IS 
PORT(
		enable:	IN		STD_LOGIC;	
		row	  :	IN		INTEGER;		
		column:	IN		INTEGER;		
		x : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
		y : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		z : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		red	  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0); 
		green :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
		blue  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0));
END vga_2;

ARCHITECTURE behavior OF vga_2 IS


--righe :	INTEGER := 480;    
--colonne :INTEGER := 640;
SIGNAL x1: INTEGER; 
SIGNAL y1: INTEGER;
SIGNAL z1: INTEGER;

BEGIN
	
x1<=TO_INTEGER(SIGNED(x))/32768*640;
y1<=TO_INTEGER(SIGNED(y))/32768*480;
z1<= TO_INTEGER(SIGNED(z))/32768*480;

	PROCESS(enable, row, column,x1,y1,z1)
	BEGIN

		IF(enable = '1') THEN
			 IF(((row>240+y1-(5+z1)) AND (row<240+y1+(5+z1))) AND ((column>320+x1-(5+z1))AND(column <320+x1+(5+z1)))) THEN
				--z1 dobbiamo ridimensionarla tra due valori massimi e minimi e quindi dobbiamo definire degli intervalli es 10 intervalli grandezza
				red   <= "1111111111";
				green <= "0000000000";
				blue  <= "0000000000";
			ELSE 
			    red   <= "0000000000";   
				green <= "0000000000";
				blue  <= "1111111111";
			END IF;
		END IF;	
	END PROCESS;
END behavior;

