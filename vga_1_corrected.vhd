LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY VGA_1_corrected IS
	GENERIC(
		h_pulse 	:	INTEGER := 95;    	--horiztonal sync pulse width in pixels
		h_bp	 	:	INTEGER := 47;		--horiztonal back porch width in pixels
		h_pixels	:	INTEGER := 640;		--horiztonal display width in pixels
		h_fp	 	:	INTEGER := 15;		--horiztonal front porch width in pixels
		v_pulse 	:	INTEGER := 2;			--vertical sync pulse width in rows
		v_bp	 	:	INTEGER := 33;			--vertical back porch width in rows
		v_pixels	:	INTEGER := 480;		--vertical display width in rows
		v_fp	 	:	INTEGER := 10);			--vertical front porch width in rows

	PORT (	clk		: IN STD_LOGIC;
			reset	: IN STD_LOGIC;
			v_sync	: OUT STD_LOGIC;
			h_sync	: OUT STD_LOGIC;
			enable	: OUT STD_LOGIC;
			row 	: OUT INTEGER;
			column	: OUT INTEGER
			);
END VGA_1_corrected;


ARCHITECTURE behavior OF VGA_1_corrected IS
		CONSTANT	h_period	:	INTEGER := h_pulse + h_bp + h_pixels + h_fp;  --total number of pixel clocks in a row
		CONSTANT	v_period	:	INTEGER := v_pulse + v_bp + v_pixels + v_fp;  --total number of rows in column
	
BEGIN
PROCESS(clk, reset)
	VARIABLE h_count	:	INTEGER RANGE 0 TO h_period - 1 := 0;  --horizontal counter (counts the columns)
	VARIABLE v_count	:	INTEGER RANGE 0 TO v_period - 1 := 0;  --vertical counter (counts the rows)
	
	BEGIN
		IF(reset = '0') THEN		--reset asserted
		h_count := 0;				--reset horizontal counter
		v_count := 0;				--reset vertical counter
		h_sync <= '1';		--deassert horizontal sync
		v_sync <= '1';		--deassert vertical sync
		enable <= '0';			--disable display
		column <= 0;				--reset column pixel coordinate
		row <= 0;					--reset row pixel coordinate
		ELSIF(clk'EVENT AND clk = '1') THEN
			--counters---------------
			IF(h_count < h_period - 1) THEN		--horizontal counter (pixels)
				h_count := h_count + 1;
			ELSE
				h_count := 0;
				-----------------------
				IF(v_count < v_period - 1) THEN	--veritcal counter (rows)
					v_count := v_count + 1;
				ELSE
					v_count := 0;
				END IF;
				---------------------
			END IF;
			------------------------
		END IF;

  
		--horizontal sync signal
		IF(h_count > h_bp + h_pixels + h_fp) THEN
			h_sync <= '0';		--deassert horiztonal sync pulse
		ELSE
			h_sync <= '1';			--assert horiztonal sync pulse
		END IF;
		
		--vertical sync signal
		IF(v_count > v_bp + v_pixels + v_fp) THEN
			v_sync <= '0';		--deassert vertical sync pulse
		ELSE
			v_sync <= '1';			--assert vertical sync pulse
		END IF;
		
		--set pixel coordinates
		IF(h_count > h_bp and h_count < h_bp + h_pixels) THEN  	--horiztonal display time
			column <= h_count-h_bp;			--set horiztonal pixel coordinate
		ELSE column <=0;
		END IF;
		
		IF(v_count > v_bp and v_count < v_bp + v_pixels) THEN	--vertical display time
			row <= v_count-v_bp;				--set vertical pixel coordinate
		ELSE row <=0;
		END IF;
		
		--set display enable output
		IF(h_count > h_bp and h_count < h_bp + h_pixels AND v_count > v_bp and v_count < v_bp + v_pixels) THEN  	--display time
			enable <= '1';											 	--enable display
		ELSE																	--blanking time
			enable <= '0';												--disable display
		END IF;
END PROCESS;

END behavior;