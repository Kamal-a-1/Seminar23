library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package array2d is
	type port2d is	array (natural range <>, natural range <>) of std_logic;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array2d.all;

entity SCL_selection is
	generic(
		L: integer := 4;
		M: integer := 8
	);
    	port(
		rst: 		in std_logic;
        	clk: 		in std_logic;
		enable:		in std_logic;
		metrics:	in port2d(0 to 2*L-1, 0 to M-1);
		F: 		out std_logic_vector(0 to 2*L-1);
		ready:		out std_logic
    	);
end SCL_selection;

architecture SCL_selection_arch of SCL_selection is 
	signal s: 		integer := 0;
	signal n0: 		integer := 0;
	signal r_f: 		integer := L;
	signal count_Sa: 	std_logic := '0';
	signal ready_s:		std_logic := '0';
	signal lastbit:     	std_logic := '0';
	signal state: 		std_logic_vector(1 downto 0) := "00";
	signal E: 		std_logic_vector(0 to 2*L-1) := (others => '0');
	signal F_s: 		std_logic_vector(0 to 2*L-1) := (others => '0');
	signal D_s: 		std_logic_vector(0 to 2*L-1) := (others => '0');

begin
	process1: process(clk)
		variable sum:   integer;
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				s <= 0;
				count_Sa <= '0';
				r_f <= L;
				ready_s <= '0';
				state <= "00";
				E <= (others => '0');
				D_s <= (others => '0');
				F_s <= (others => '0');
				lastbit <= '0';
			else
				if (ready_s = '1') then
					if(enable = '1') then 
						ready_s <= '0';
						s <= 0;
		               			count_Sa <= '0';
		               			r_f <= L;
		               			state <= "00";
					       	E <= (others => '0');
					       	D_s <= (others => '0');
					       	F_s <= (others => '0');
					       	lastbit <= '0';
		            		end if;
				elsif (state = "00") then -- state Sd
					if (count_Sa = '0') then
						count_Sa <= '1';
						s <= s + 1;
						sum := 0;
						for i in 0 to 2*L-1 loop -- count 0s
							D_s(i) <= metrics(i,s);
							if (metrics(i,s) nor E(i)) = '1' then
							     sum := sum + 1;
							end if;
						end loop;
		        			n0 <= sum;
					else --compare and jump to the next state
						count_Sa <= '0';
						if (n0 < r_f) then
							state <= "01";
						elsif (n0 > r_f) then
							state <= "10";
						else
							state <= "11";
						end if;
					end if;
				elsif (state = "01") then --state Sa
					r_f <= r_f - n0;
					F_s <= (D_s nor E) or F_s;
					E <= (not D_s) or E;
					if (s /= M) then state <= "00";
					else state <= "11"; lastbit <= '1';
					end if;
				elsif (state = "10") then --state Sb
					E <= D_s or E;
					if (s /= M) then state <= "00";
					else state <= "11"; lastbit <= '1';
					end if;
				else -- state Se
					if lastbit = '0' then
						F_s <= (D_s nor E) or F_s;
					else -- if the last bit is reached just choose r_f metrics out of unlabelled ones
						sum := r_f;
						for i in 0 to 2*L-1 loop
							if (sum /= 0) and (E(i) = '0') then
								F_s(i) <= '1';
								sum := sum - 1;
							end if;
						end loop;
					end if;
					E <= (others => '1');
					r_f <= 0;
					ready_s <= '1';
				end if;
			end if;
		end if;
	end process;

	F <= F_s;
	ready <= ready_s;

end SCL_selection_arch;
