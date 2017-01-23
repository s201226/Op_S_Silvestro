library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_interface_TX is
	port(CLK, nRST:in std_logic;
		DATA_VALID:in std_logic;
		DATA_in:in std_logic_vector(71 downto 0);
		TX:out std_logic);
end serial_interface_TX;

architecture behaviour of serial_interface_TX is

component serial_TX_lev1_CU is
	port(CLK,nRST: in std_logic;
		START_IN,TIMER_END: in std_logic;
		READY,OUT_ENABLE,SEND_START,SEND_STOP: out std_logic);
end component;

component serial_TX_lev2_CU is
	port(CLK,nRST: in std_logic;
		START,subREADY: in std_logic;
		READY,OUT_ENABLE,SEND_START,SEND_STOP: out std_logic);
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

signal RST_CNT_SERIAL_sync,RST_CNT_SERIAL,SAMPLING_TIME,SAMPLING_TIME_sync:std_logic;
signal NUMBER:unsigned(8 downto 0);
signal START_LEV1,READY_LEV1,SHIFT_REG_LEV1_EN,to_TX: std_logic;
signal START_bit,STOP_bit,START_byte,STOP_byte: std_logic;
signal READY_LEV2,ACC_LIV1_EN,ACC_LIV1_S_nP,ACC_LIV2_EN,ACC_LIV2_S_nP: std_logic;

signal TX_vect: std_logic_vector(0 downto 0);
signal DATA_byte,DATA_out: std_logic_vector(7 downto 0);

begin
	process(nRST,RST_CNT_SERIAL_sync,CLK)
	begin
		if RST_CNT_SERIAL_sync='0' or nRST='0' then
			NUMBER<=(others=>'0');
		elsif CLK'event and CLK='1' then
			NUMBER<=NUMBER+1;
		end if;
	end process;
	
	process(NUMBER)
	begin
		SAMPLING_TIME<='0';
		RST_CNT_SERIAL<='1';
		case NUMBER is
			when "110000110"=> SAMPLING_TIME<='1'; RST_CNT_SERIAL<='0';
			when others=> null;
		end case;
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

	LEV1:serial_TX_lev1_CU port map(CLK=>CLK,
		nRST=>nRST,
		START_IN=>START_LEV1,
		TIMER_END=>SAMPLING_TIME,
		READY=>READY_LEV1,
		OUT_ENABLE=>SHIFT_REG_LEV1_EN,
		SEND_START=>START_bit);
		
	ACC_LIV1_EN<=SHIFT_REG_LEV1_EN or (START_LEV1 and READY_LEV1);
	ACC_LIV1_S_nP<=not READY_LEV1;
		
	ACC_LIV1:accumulator_generic generic map(N_in=>1,N_out=>8)
		port map(CLK=>CLK,
			nRST=>nRST,
			EN=>ACC_LIV1_EN,
			SERIAL_nPARALLEL=>ACC_LIV1_S_nP,
			DATA_IN_serial=>"1",
			DATA_IN_parallel=>DATA_byte,
			DATA_OUT_serial=>TX_vect);
			
	process(START_bit,SHIFT_REG_LEV1_EN,TX_vect(0))
	begin
		if START_bit='1' then to_TX<='0';
		elsif SHIFT_REG_LEV1_EN='1' then to_TX<=not TX_vect(0);
		else to_TX<='1';
		end if;
	end process;
	
	process(nRST,CLK)
	begin
		if nRST='0' then
			TX<='1';
		elsif CLK'event and CLK='1' then
			if SAMPLING_TIME_sync='1' then
				TX<=to_TX;
			end if;
		end if;
	end process;
			
	LEV2:serial_TX_lev2_CU port map(CLK=>CLK,
		nRST=>nRST,
		START=>DATA_VALID,
		subREADY=>READY_LEV1,
		READY=>READY_LEV2,
		OUT_ENABLE=>START_LEV1,
		SEND_START=>START_byte);

	ACC_LIV2_EN<=START_LEV1 or (DATA_VALID and READY_LEV2);
	ACC_LIV2_S_nP<=not READY_LEV2;
		
	ACC_LIV2:accumulator_generic generic map(N_in=>8,N_out=>9)
		port map(CLK=>CLK,
			nRST=>nRST,
			EN=>ACC_LIV2_EN,
			SERIAL_nPARALLEL=>ACC_LIV2_S_nP,
			DATA_IN_serial=>"00000000",
			DATA_IN_parallel=>DATA_in,
			DATA_OUT_serial=>DATA_out);
			
	process(START_byte,START_LEV1,DATA_out)
	begin
		if START_byte='1' then DATA_byte<=(others=>'1');
		elsif START_LEV1='1' then DATA_byte<=DATA_out;
		else DATA_byte<=(others=>'0');
		end if;
	end process;
	
end behaviour;