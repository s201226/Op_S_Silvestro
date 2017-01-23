library ieee;
use ieee.std_logic_1164.all;

entity serial_RX_lev2_CU is
	port(CLK,nRST: in std_logic;
		INPUT_VALID,FRAMMING_ERROR,START_DETECTED,STOP_DETECTED: in std_logic;
		SHIFT_REG_EN,DATA_VALID,special_RST: out std_logic);
end serial_RX_lev2_CU;

architecture behaviour of serial_RX_lev2_CU is

type states_enum is (wSTART1,wSTART2,wX1,X1,wX2,X2,wY1,Y1,wY2,Y2,wZ1,Z1,wZ2,Z2,wALPHA,ALPHA,wBETA,BETA,wGAMMA,GAMMA,wSTOP1,wSTOP2,ERROR,noERROR);
signal P_STATE,F_STATE: states_enum;

begin
		process(P_STATE)
		begin
			SHIFT_REG_EN<='0';
			DATA_VALID<='0';
			special_RST<='1';
			
			case P_STATE is
				when X1|X2|Y1|Y2|Z1|Z2|ALPHA|BETA|GAMMA => SHIFT_REG_EN<='1';
				when ERROR => special_RST<='0';
				when noERROR => DATA_VALID<='1';
				when others => null;
			end case;
		end process;
		
		process(nRST,CLK)
		begin
			if nRST='0' then
				P_STATE<=ERROR;
			elsif CLK'event and CLK='1' then
				P_STATE<=F_STATE;
			end if;
		end process;
		
		process(P_STATE,INPUT_VALID,FRAMMING_ERROR,START_DETECTED,STOP_DETECTED)
		begin
			case P_STATE is
				when wSTART1 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then
									if START_DETECTED='1' then F_STATE<=wSTART2;
									else F_STATE<=wSTART1;
									end if;
								else F_STATE<=wSTART1;
								end if;
				when wSTART2 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then
									if START_DETECTED='1' then F_STATE<=wX1;
									else F_STATE<=wSTART1;
									end if;
								else F_STATE<=wSTART2;
								end if;

				when wX1 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=X1;
								else F_STATE<=wX1;
								end if;
				when X1 => F_STATE<=wX2;
				when wX2 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=X2;
								else F_STATE<=wX2;
								end if;
				when X2 => F_STATE<=wY1;
				when wY1 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=Y1;
								else F_STATE<=wY1;
								end if;
				when Y1 => F_STATE<=wY2;
				when wY2 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=Y2;
								else F_STATE<=wY2;
								end if;
				when Y2 => F_STATE<=wZ1;
				when wZ1 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=Z1;
								else F_STATE<=wZ1;
								end if;
				when Z1 => F_STATE<=wZ2;
				when wZ2 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=Z2;
								else F_STATE<=wZ2;
								end if;
				when Z2 => F_STATE<=wALPHA;
				when wALPHA => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=ALPHA;
								else F_STATE<=wALPHA;
								end if;
				when ALPHA => F_STATE<=wBETA;
				when wBETA => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=BETA;
								else F_STATE<=wBETA;
								end if;
				when BETA => F_STATE<=wGAMMA;
				when wGAMMA => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then F_STATE<=GAMMA;
								else F_STATE<=wGAMMA;
								end if;
				when GAMMA => F_STATE<=wSTOP1;
				
				when wSTOP1 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then
									if STOP_DETECTED='1' then F_STATE<=wSTOP2;
									else F_STATE<=ERROR;
									end if;
								else F_STATE<=wSTOP1;
								end if;
				when wSTOP2 => if FRAMMING_ERROR='1' then F_STATE<=ERROR;
								elsif INPUT_VALID='1' then
									if STOP_DETECTED='1' then F_STATE<=noERROR;
									else F_STATE<=ERROR;
									end if;
								else F_STATE<=wSTOP2;
								end if;
								
				when others => F_STATE<=wSTART1;
			end case;
		end process;
end behaviour;