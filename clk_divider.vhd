library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_divider is
    Port (
        clk_in : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
end clk_divider;

architecture Behavioral of clk_divider is

signal tmp:std_logic;

begin
    frequency_divider: process (reset, clk_in)
	begin
        if (reset = '0') then
            tmp <= '0';
        elsif rising_edge(clk_in) then
            tmp<=not tmp;
        end if;
    end process;
    
	clk_out<=tmp;
	
end Behavioral;