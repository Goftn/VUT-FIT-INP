-- Knihovny
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

--Entita
entity ledc8x8 is
	port (
			RESET : in std_logic;
			SMCLK : in std_logic;
			ROW : out std_logic_vector (0 to 7);
			LED : out std_logic_vector (0 to 7)
			);
end entity ledc8x8;

--Architektura
architecture behavioral of ledc8x8 is
-- vnitrni signaly
	signal ctrlce_cnt : std_logic_vector (21 downto 0);
	signal ce : std_logic;
	signal switch : std_logic;
	signal rowe_cnt : std_logic_vector (7 downto 0);
	signal led_cnt : std_logic_vector (7 downto 0);
	
begin

--citac ctrl_cnt
	ctrl_cnt: process (RESET, SMCLK)
	begin
			if (RESET = '1') then
				ctrlce_cnt <= (others => '0');
			elsif (SMCLK'event) and (SMCLK = '1') then
				ctrlce_cnt <= ctrlce_cnt + '1';
			end if;
	end process ctrl_cnt;
	
--signal clock enable (povolovac row_cnt)
	ce <= '1' when ctrlce_cnt(7 downto 0) = "11111111" else '0'; -- 0xFF

--signal switch
	switch <= ctrlce_cnt(21); --nastavi se dle nejvyssiho bitu ctrl_cnt
	
--rotacni registr row_cnt, POZOR na CE!!!!!!!
	row_cnt: process (RESET, SMCLK)
	begin
			if (RESET = '1') then
				rowe_cnt <= "10000000";
			elsif (SMCLK'event) and (SMCLK = '1') then
				if (ce = '1') then
					rowe_cnt <= rowe_cnt(0) & rowe_cnt(7 downto 1);
				end if;
			end if;
	end process row_cnt;
	
--dekoder dec, 0 - SVITI 1 - NESVITI!
	dec: process (rowe_cnt)
	begin
			case (rowe_cnt) is
				when "10000000" => led_cnt <= "10011010"; --0
				when "01000000" => led_cnt <= "01101101";	--1	
				when "00100000" => led_cnt <= "01111111";	--2	
				when "00010000" => led_cnt <= "10011000";	--3
				when "00001000" => led_cnt <= "11100111";	--4
				when "00000100" => led_cnt <= "01101001";	--5
				when "00000010" => led_cnt <= "10011110";	--6
				when "00000001" => led_cnt <= "11110001";	--7
				when others => led_cnt <= "11111111";
			end case;
	end process dec;
	
--multiplexor

			ROW <= rowe_cnt;
			
			with switch select
				LED <= led_cnt when '0',
						 "11111111" when others;
						
			

	
end behavioral;
	
 
