library ieee;
use ieee.std_logic_1164.all;

entity serial_TX_lev2_CU is
	port(CLK,nRST: in std_logic;
		START,subREADY: in std_logic;
		READY,OUT_ENABLE,SEND_START,SEND_STOP: out std_logic);
end serial_TX_lev2_CU;

architecture behaviour of serial_TX_lev2_CU is

type states_enum is (IDLE,wSTART1,START1,wSTART2,START2,wX1,X1,wX2,X2,wY1,Y1,wY2,Y2,wZ1,Z1,wZ2,Z2,wALPHA,ALPHA,wBETA,BETA,wGAMMA,GAMMA,wSTOP1,STOP1,wSTOP2,STOP2);
signal P_STATE,F_STATE: states_enum;

begin
		process(P_STATE)
		begin
			READY<='0';
			OUT_ENABLE<='0';
			SEND_START<='0';
			SEND_STOP<='0';

			case P_STATE is
				when IDLE => READY<='1';
				when START1|START2 => SEND_START<='1';
				when X1|X2|Y1|Y2|Z1|Z2|ALPHA|BETA|GAMMA => OUT_ENABLE<='1';
				when STOP1|STOP2 => SEND_STOP<='1';
				when others => null;
			end case;
		end process;
		
		process(nRST,CLK)
		begin
			if nRST='0' then
				P_STATE<=IDLE;
			elsif CLK'event and CLK='1' then
				P_STATE<=F_STATE;
			end if;
		end process;
		
		process(P_STATE,START,subREADY)
		begin
			case P_STATE is
				when IDLE=> if START='0' then F_STATE<=IDLE; else F_STATE<=wSTART1; end if;
				
				when wSTART1=> if subREADY='1' then F_STATE<=START1; else F_STATE<=wSTART1; end if;
				when START1=> F_STATE<=wSTART2;
				when wSTART2=> if subREADY='1' then F_STATE<=START2; else F_STATE<=wSTART2; end if;
				when START2=> F_STATE<=wX1;
				
				when wX1=> if subREADY='1' then F_STATE<=X1; else F_STATE<=wX1; end if;
				when X1=> F_STATE<=wX2;
				when wX2=> if subREADY='1' then F_STATE<=X2; else F_STATE<=wX2; end if;
				when X2=> F_STATE<=wY1;
				when wY1=> if subREADY='1' then F_STATE<=Y1; else F_STATE<=wY1; end if;
				when Y1=> F_STATE<=wY2;
				when wY2=> if subREADY='1' then F_STATE<=Y2; else F_STATE<=wY2; end if;
				when Y2=> F_STATE<=wZ1;
				when wZ1=> if subREADY='1' then F_STATE<=Z1; else F_STATE<=wZ1; end if;
				when Z1=> F_STATE<=wZ2;
				when wZ2=> if subREADY='1' then F_STATE<=Z2; else F_STATE<=wZ2; end if;
				when Z2=> F_STATE<=wALPHA;
				when wALPHA=> if subREADY='1' then F_STATE<=ALPHA; else F_STATE<=wALPHA; end if;
				when ALPHA=> F_STATE<=wBETA;
				when wBETA=> if subREADY='1' then F_STATE<=BETA; else F_STATE<=wBETA; end if;
				when BETA=> F_STATE<=wGAMMA;
				when wGAMMA=> if subREADY='1' then F_STATE<=GAMMA; else F_STATE<=wGAMMA; end if;
				when GAMMA=> F_STATE<=wSTOP1;
				
				when wSTOP1=> if subREADY='1' then F_STATE<=STOP1; else F_STATE<=wSTOP1; end if;
				when STOP1=> F_STATE<=wSTOP2;
				when wSTOP2=> if subREADY='1' then F_STATE<=STOP2; else F_STATE<=wSTOP2; end if;
				
				when others => F_STATE<=IDLE;
			end case;
		end process;
end behaviour;