library ieee;
use ieee.std_logic_1164.all;

entity serial_TX_lev1_CU is
	port(CLK,nRST: in std_logic;
		START_IN,TIMER_END: in std_logic;
		READY,OUT_ENABLE,SEND_START,SEND_STOP: out std_logic);
end serial_TX_lev1_CU;

architecture behaviour of serial_TX_lev1_CU is

type states_enum is (WAITING,wSTART,START,wBIT1,BIT1,wBIT2,BIT2,wBIT3,BIT3,wBIT4,BIT4,wBIT5,BIT5,wBIT6,BIT6,wBIT7,BIT7,wBIT8,BIT8,wSTOP,STOP);
signal P_STATE,F_STATE: states_enum;

begin
		process(P_STATE)
		begin
			READY<='0';
			OUT_ENABLE<='0';
			SEND_START<='0';
			SEND_STOP<='0';
			
			case P_STATE is
				when WAITING => READY<='1';
				when START => SEND_START<='1';
				when BIT1|BIT2|BIT3|BIT4|BIT5|BIT6|BIT7|BIT8 => OUT_ENABLE<='1';
				when STOP => SEND_STOP<='1';
				when others => null;
			end case;
		end process;
		
		process(nRST,CLK)
		begin
			if nRST='0' then
				P_STATE<=WAITING;
			elsif CLK'event and CLK='1' then
				P_STATE<=F_STATE;
			end if;
		end process;
		
		process(P_STATE,START_IN,TIMER_END)
		begin
			case P_STATE is
				when WAITING => if START_IN='1' then F_STATE<=wSTART; else F_STATE<=WAITING; end if;
				when START => F_STATE<=wBIT1;
				when BIT1 => F_STATE<=wBIT2;
				when BIT2 => F_STATE<=wBIT3;
				when BIT3 => F_STATE<=wBIT4;
				when BIT4 => F_STATE<=wBIT5;
				when BIT5 => F_STATE<=wBIT6;
				when BIT6 => F_STATE<=wBIT7;
				when BIT7 => F_STATE<=wBIT8;
				when BIT8 => F_STATE<=wSTOP;
				
				when wSTART => if TIMER_END='0' then F_STATE<=wSTART; else F_STATE<=START; end if;
				when wBIT1 => if TIMER_END='0' then F_STATE<=wBIT1; else F_STATE<=BIT1; end if;
				when wBIT2 => if TIMER_END='0' then F_STATE<=wBIT2; else F_STATE<=BIT2; end if;
				when wBIT3 => if TIMER_END='0' then F_STATE<=wBIT3; else F_STATE<=BIT3; end if;
				when wBIT4 => if TIMER_END='0' then F_STATE<=wBIT4; else F_STATE<=BIT4; end if;
				when wBIT5 => if TIMER_END='0' then F_STATE<=wBIT5; else F_STATE<=BIT5; end if;
				when wBIT6 => if TIMER_END='0' then F_STATE<=wBIT6; else F_STATE<=BIT6; end if;
				when wBIT7 => if TIMER_END='0' then F_STATE<=wBIT7; else F_STATE<=BIT7; end if;
				when wBIT8 => if TIMER_END='0' then F_STATE<=wBIT8; else F_STATE<=BIT8; end if;
			
				when others => F_STATE<=WAITING;
			end case;
		end process;
end behaviour;