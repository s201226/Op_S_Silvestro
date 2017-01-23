library ieee;
use ieee.std_logic_1164.all;

entity accumulator_generic is
	generic(N_in:integer:=1;N_out:integer:=8);
	port(CLK, nRST,EN:in std_logic;
		SERIAL_nPARALLEL:in std_logic;
		DATA_IN_serial:in std_logic_vector(N_in-1 downto 0);
		DATA_IN_parallel:in std_logic_vector(N_in*N_out-1 downto 0);
		DATA_OUT_serial:out std_logic_vector(N_in-1 downto 0);
		DATA_OUT_parallel:out std_logic_vector(N_in*N_out-1 downto 0));
end accumulator_generic;

architecture behaviour of accumulator_generic is

component reg_Nbit is
generic(N:integer:=1);
port(D:in std_logic_vector(N-1 downto 0);
	nRST,CLK,EN:in std_logic;
	Q:out std_logic_vector(N-1 downto 0));
end component;

signal line_in,line_out: std_logic_vector(N_in*N_out-1 downto 0);

begin
	process(DATA_IN_serial,DATA_IN_parallel,SERIAL_nPARALLEL,line_out)
	begin
		if SERIAL_nPARALLEL='1' then line_in<=DATA_IN_serial&line_out(N_in*N_out-1 downto N_in);
		else line_in<=DATA_IN_parallel;
		end if;
	end process;
	
	generate1:for i in 0 to N_out-1 generate
		REG:reg_Nbit generic map(N=>N_in)
				port map(D=>line_in(N_in*(i+1)-1 downto N_in*i),
					nRST=>nRST,
					CLK=>CLK,
					EN=>EN,
					Q=>line_out(N_in*(i+1)-1 downto N_in*i));
	end generate generate1;
	
	process(line_out)
	begin
		for i in 0 to N_in*N_out-1 loop
			DATA_OUT_parallel(i)<=line_out(N_in*N_out-1-i);
		end loop;
	end process;
	
	DATA_OUT_serial<=line_out(N_in-1 downto 0);
	
end behaviour;