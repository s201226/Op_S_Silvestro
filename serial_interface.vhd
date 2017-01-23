library ieee;
use ieee.std_logic_1164.all;

entity serial_interface is
	port(CLK, nRST:in std_logic;
		RX:in std_logic;
		TX:out std_logic;
		DATA_VALID_in:in std_logic;
		DATA_VALID_out:out std_logic;
		DATA_in:in std_logic_vector(71 downto 0);
		DATA_out:out std_logic_vector(71 downto 0));
end serial_interface;

architecture behaviour of serial_interface is

component serial_interface_RX is
	port(CLK, nRST:in std_logic;
		RX:in std_logic;
		DATA_VALID:out std_logic;
		DATA_out:out std_logic_vector(71 downto 0));
end component;

component serial_interface_TX is
	port(CLK, nRST:in std_logic;
		DATA_VALID:in std_logic;
		DATA_in:in std_logic_vector(71 downto 0);
		TX:out std_logic);
end component;

begin

SERIAL_IN:serial_interface_RX port map(CLK=>CLK,
		nRST=>nRST,
		RX=>RX,
		DATA_VALID=>DATA_VALID_out,
		DATA_out=>DATA_out);
		
SERIAL_OUT:serial_interface_TX port map(CLK=>CLK,
		nRST=>nRST,
		DATA_VALID=>DATA_VALID_in,
		DATA_in=>DATA_in,
		TX=>TX);

end behaviour;
