library ieee;
use ieee.std_logic_1164.all;

entity reg_Nbit is
generic(N:integer:=1);
port(D:in std_logic_vector(N-1 downto 0);
	nRST,CLK,EN:in std_logic;
	Q:out std_logic_vector(N-1 downto 0));
end reg_Nbit;


architecture Behavioral of reg_Nbit is
begin
	process(nRST,CLK,EN)
	begin
		if nRST='0' then
			Q<=(others=>'0');
		else if CLK'event and CLK='1' and EN='1' then
			Q<=D;
		end if;
		end if;
	end process;
end Behavioral;