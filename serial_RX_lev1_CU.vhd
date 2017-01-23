library ieee;
use ieee.std_logic_1164.all;

entity serial_RX_lev1_CU is
	port(CLK,nRST: in std_logic;
		special_RST,START_DETECTED,STOP_DETECTED,TIMER_END: in std_logic;
		ACTIVATE_SAMPLING,SERIAL_CLOCK,DATA_VALID,FRAMMING_ERROR: out std_logic);
end serial_RX_lev1_CU;

architecture behaviour of serial_RX_lev1_CU is

type states_enum is (WAITING,wSTART_VERIFY,START_VERIFY,wREAD_BIT_1,READ_BIT_1,wREAD_BIT_2,READ_BIT_2,wREAD_BIT_3,READ_BIT_3,wREAD_BIT_4,READ_BIT_4,wREAD_BIT_5,READ_BIT_5,wREAD_BIT_6,READ_BIT_6,wREAD_BIT_7,READ_BIT_7,wREAD_BIT_8,READ_BIT_8,wSTOP,STOP,ERROR,noERROR);
signal P_STATE,F_STATE: states_enum;

begin
		process(P_STATE)
		begin
			ACTIVATE_SAMPLING<='0';
			DATA_VALID<='0';
			FRAMMING_ERROR<='0';
			SERIAL_CLOCK<='1';
			
			case P_STATE is
				when WAITING|wSTART_VERIFY|START_VERIFY => SERIAL_CLOCK<='0';
				when READ_BIT_1|READ_BIT_2|READ_BIT_3|READ_BIT_4|READ_BIT_5|READ_BIT_6|READ_BIT_7|READ_BIT_8 => ACTIVATE_SAMPLING<='1';
				when ERROR => SERIAL_CLOCK<='0';FRAMMING_ERROR<='1';
				when noERROR => SERIAL_CLOCK<='0';DATA_VALID<='1';
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
		
		process(P_STATE,START_DETECTED,STOP_DETECTED,special_RST,TIMER_END)
		begin
			case P_STATE is
				when WAITING => if TIMER_END='1'and START_DETECTED='1' then  F_STATE<=wSTART_VERIFY; else F_STATE<=WAITING; end if;
				when START_VERIFY => if START_DETECTED='1' then  F_STATE<=wREAD_BIT_1; else F_STATE<=WAITING; end if;
				when READ_BIT_1=> F_STATE<=wREAD_BIT_2;
				when READ_BIT_2=> F_STATE<=wREAD_BIT_3;
				when READ_BIT_3=> F_STATE<=wREAD_BIT_4;
				when READ_BIT_4=> F_STATE<=wREAD_BIT_5;
				when READ_BIT_5=> F_STATE<=wREAD_BIT_6;
				when READ_BIT_6=> F_STATE<=wREAD_BIT_7;
				when READ_BIT_7=> F_STATE<=wREAD_BIT_8;
				when READ_BIT_8=> F_STATE<=wSTOP;
				
				when wSTART_VERIFY => if TIMER_END='1' then  F_STATE<=START_VERIFY; else F_STATE<=wSTART_VERIFY; end if;
				when wREAD_BIT_1 => if TIMER_END='1' then  F_STATE<=READ_BIT_1; else F_STATE<=wREAD_BIT_1; end if;
				when wREAD_BIT_2 => if TIMER_END='1' then  F_STATE<=READ_BIT_2; else F_STATE<=wREAD_BIT_2; end if;
				when wREAD_BIT_3 => if TIMER_END='1' then  F_STATE<=READ_BIT_3; else F_STATE<=wREAD_BIT_3; end if;
				when wREAD_BIT_4 => if TIMER_END='1' then  F_STATE<=READ_BIT_4; else F_STATE<=wREAD_BIT_4; end if;
				when wREAD_BIT_5 => if TIMER_END='1' then  F_STATE<=READ_BIT_5; else F_STATE<=wREAD_BIT_5; end if;
				when wREAD_BIT_6 => if TIMER_END='1' then  F_STATE<=READ_BIT_6; else F_STATE<=wREAD_BIT_6; end if;
				when wREAD_BIT_7 => if TIMER_END='1' then  F_STATE<=READ_BIT_7; else F_STATE<=wREAD_BIT_7; end if;
				when wREAD_BIT_8 => if TIMER_END='1' then  F_STATE<=READ_BIT_8; else F_STATE<=wREAD_BIT_8; end if;
				
				when wSTOP => if TIMER_END='1'then  F_STATE<=STOP; else F_STATE<=wSTOP; end if;
				when STOP => if STOP_DETECTED='0' then F_STATE<=ERROR; else F_STATE<=noERROR; end if;
				
				when ERROR => if special_RST='0' then F_STATE<=ERROR; else F_STATE<=WAITING; end if;
				
				when others => F_STATE<=WAITING;
			end case;
		end process;
end behaviour;