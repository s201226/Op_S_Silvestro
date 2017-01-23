library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Op_s_Tiziano is
	port(CLOCK_50:in std_logic;
		KEY:in std_logic_vector(0 downto 0);  --KEY0->RESET
		SW:in std_logic_vector(0 downto 0); --SW0->START
		GPIO_RX:in std_logic;
		GPIO_TX:out std_logic;
		VGA_R:out std_logic_vector(9 downto 0);
		VGA_G:out std_logic_vector(9 downto 0); 
		VGA_B:out std_logic_vector(9 downto 0);
		VGA_VS:out std_logic;
		VGA_HS:out std_logic);
end Op_s_Tiziano;

architecture behaviour of Op_s_Tiziano is

component vga IS
PORT(	CLOCK_50: IN STD_LOGIC;
		nRST: IN STD_LOGIC; 
		x: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		y: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		z: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		VGA_R	  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
		VGA_G :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);  
		VGA_B  :	OUT	STD_LOGIC_VECTOR(9 DOWNTO 0); 
		VGA_VS	: OUT STD_LOGIC;
		VGA_HS	: OUT STD_LOGIC
		);
END component;

component serial_interface is
	port(CLK, nRST:in std_logic;
		RX:in std_logic;
		TX:out std_logic;
		DATA_VALID_in:in std_logic;
		DATA_VALID_out:out std_logic;
		DATA_in:in std_logic_vector(71 downto 0);
		DATA_out:out std_logic_vector(71 downto 0));
end component;

component reg_Nbit is
generic(N:integer:=1);
port(D:in std_logic_vector(N-1 downto 0);
	nRST,CLK,EN:in std_logic;
	Q:out std_logic_vector(N-1 downto 0));
end component;

signal DATA_in,DATA_out,DATA_valid_in:std_logic_vector(71 downto 0);
signal BUFF_EN:std_logic;

begin
	serial_port:serial_interface port map(CLK=>CLOCK_50,
			nRST=>KEY(0),
			RX=>GPIO_RX,
			TX=>GPIO_TX,
			DATA_VALID_in=>BUFF_EN,
			DATA_VALID_out=>BUFF_EN,
			DATA_in=>DATA_in,
			DATA_out=>DATA_in);
			
	BUFF_in_serial:reg_Nbit generic map(N=>72)
			port map(D=>DATA_in,
				nRST=>KEY(0),
				CLK=>CLOCK_50,
				EN=>BUFF_EN,
				Q=>DATA_valid_in);
				
	VGA1:vga port map(CLOCK_50=>CLOCK_50,
		nRST=>KEY(0),
		x=>DATA_valid_in(71 DOWNTO 56),
		y=>DATA_valid_in(55 DOWNTO 40),
		z=>DATA_valid_in(39 DOWNTO 24),
		VGA_R=>VGA_R,
		VGA_G=>VGA_G,
		VGA_B=>VGA_B,
		VGA_VS=>VGA_VS,
		VGA_HS=>VGA_HS);
				
end behaviour;

