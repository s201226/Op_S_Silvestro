library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_interface_RX is
	port(CLK, nRST:in std_logic;
		RX:in std_logic;
		DATA_VALID:out std_logic;
		DATA_out:out std_logic_vector(71 downto 0));
end serial_interface_RX;

architecture behaviour of serial_interface_RX is

component serial_RX_lev1_CU is
		port(CLK,nRST: in std_logic;
		special_RST,START_DETECTED,STOP_DETECTED,TIMER_END: in std_logic;
		ACTIVATE_SAMPLING,SERIAL_CLOCK,DATA_VALID,FRAMMING_ERROR: out std_logic);
end component;

component serial_RX_lev2_CU is
	port(CLK,nRST: in std_logic;
		INPUT_VALID,FRAMMING_ERROR,START_DETECTED,STOP_DETECTED: in std_logic;
		SHIFT_REG_EN,DATA_VALID,special_RST: out std_logic);
end component;

component accumulator_generic is
	generic(N_in:integer:=1;N_out:integer:=8);
	port(CLK, nRST,EN:in std_logic;
		SERIAL_nPARALLEL:in std_logic;
		DATA_IN_serial:in std_logic_vector(N_in-1 downto 0);
		DATA_IN_parallel:in std_logic_vector(N_in*N_out-1 downto 0);
		DATA_OUT_serial:out std_logic_vector(N_in-1 downto 0);
		DATA_OUT_parallel:out std_logic_vector(N_in*N_out-1 downto 0));
end component;

			
signal SAMPLING_TIME,SAMPLING_TIME_sync,RST_CNT_SERIAL,RST_CNT_SERIAL_sync,EN_COUNTER:std_logic;
signal DATA_in_vect:std_logic_vector(0 downto 0);
signal NUMBER:unsigned(8 downto 0);
signal LEV1_START_DETECT,FRAMMING_ERROR,LEV1_special_RST,SERIAL_CLOCK:std_logic;
signal DATA_8bit:std_logic_vector(7 downto 0);
signal LEV2_INPUT_VALID,LEV2_START_DETECTED,LEV2_STOP_DETECTED,LEV2_SHIFT_REG_EN:std_logic;
signal void,line_out:std_logic_vector(71 downto 0);

begin	
	process(nRST,RST_CNT_SERIAL_sync,CLK)
	begin
		if RST_CNT_SERIAL_sync='0' or nRST='0' then
			NUMBER<=(others=>'0');
		elsif CLK'event and CLK='1' then
			NUMBER<=NUMBER+1;
		end if;
	end process;
	
	process(NUMBER,SERIAL_CLOCK)
	begin
		SAMPLING_TIME<='0';
		RST_CNT_SERIAL<='1';
		
		if SERIAL_CLOCK='0' then
			case NUMBER is
				when "000100111"=> SAMPLING_TIME<='1'; RST_CNT_SERIAL<='0';
				when others=> null;
			end case;
		else
			case NUMBER is
				when "110000110"=> SAMPLING_TIME<='1'; RST_CNT_SERIAL<='0';
				when others=> null;
			end case;
		end if;
	end process;
	
	process(nRST,CLK)
	begin
		if nRST='0' then
			RST_CNT_SERIAL_sync<='0';
			SAMPLING_TIME_sync<='0';
		elsif CLK'event and CLK='1' then
			RST_CNT_SERIAL_sync<=RST_CNT_SERIAL;
			SAMPLING_TIME_sync<=SAMPLING_TIME;
		end if;
	end process;

	LEV1_START_DETECT<=not RX;

	LV1:serial_RX_lev1_CU port map(CLK=> CLK,
		nRST=> nRST,
		special_RST=>LEV1_special_RST,
		START_DETECTED=>LEV1_START_DETECT,
		STOP_DETECTED=>RX,
		TIMER_END=>SAMPLING_TIME_sync,
		ACTIVATE_SAMPLING=>EN_COUNTER,
		SERIAL_CLOCK=>SERIAL_CLOCK,
		DATA_VALID=> LEV2_INPUT_VALID,
		FRAMMING_ERROR=> FRAMMING_ERROR);
		
	DATA_in_vect(0)<=not RX;
	
	ACC_LV1:accumulator_generic generic map(N_in=>1,N_out=>8)
				port map(CLK=> CLK,
						nRST=> nRST,
						EN=> EN_COUNTER,
						SERIAL_nPARALLEL=>'1',
						DATA_IN_serial=>DATA_in_vect,
						DATA_IN_parallel=> "00000000",
						DATA_OUT_parallel=> DATA_8bit);
						
	process(DATA_8bit)
	begin
		LEV2_START_DETECTED<='0';
		LEV2_STOP_DETECTED<='0';
		
		case DATA_8bit is
			when "11111111"=>LEV2_START_DETECTED<='1';
			when "00000000"=>LEV2_STOP_DETECTED<='1';
			when others=>null;
		end case;
	end process;
		
	LV2:serial_RX_lev2_CU port map(CLK=> CLK,
		nRST=> nRST,
		INPUT_VALID=> LEV2_INPUT_VALID,
		FRAMMING_ERROR=> FRAMMING_ERROR,
		START_DETECTED=> LEV2_START_DETECTED,
		STOP_DETECTED=> LEV2_STOP_DETECTED,
		SHIFT_REG_EN=> LEV2_SHIFT_REG_EN,
		DATA_VALID=> DATA_VALID,
		special_RST=> LEV1_special_RST);
		
	void<=(others=>'0');

	ACC_LV2:accumulator_generic generic map(N_in=>8,N_out=>9)
				port map(CLK=> CLK,
						nRST=> nRST,
						EN=> LEV2_SHIFT_REG_EN,	
						SERIAL_nPARALLEL=>'1',
						DATA_IN_serial=> DATA_8bit,
						DATA_IN_parallel=> void,
						DATA_OUT_parallel=> line_out);
						
	process(line_out)
	begin
		for i in 0 to 71 loop
			DATA_out(i)<=line_out(71-i);
		end loop;
	end process;
end behaviour;