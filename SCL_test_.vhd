library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.array2d.all;

entity SCL_test is
end SCL_test;

architecture SCL_test_arch of SCL_test is
	constant L	        : positive := 1000; -- specify L and M here
	constant M	        : positive := 30;
	-- modify the pathes
	constant INPATH     	: string := "/home/kamal/Documents/sem/SCL-selection_seminar-WS2223/testcases/inputs/L" & integer'image(L) & "_M" & integer'image(M) & ".txt";
	constant OUTPATH    	: string := "/home/kamal/Documents/sem/SCL-selection_seminar-WS2223/testcases/outputs/L" & integer'image(L) & "_M" & integer'image(M) & "_out.txt";

component SCL_selection
	generic(
		L: positive;
		M: positive
	);
	port(
		rst: 		in std_logic;
	        clk: 		in std_logic;
		enable:		in std_logic;
		metrics:	in port2d(0 to 2*L-1, 0 to M-1);
		F:		out std_logic_vector(0 to 2*L-1);
		ready:		out std_logic
	);
end component; 
	
	
	signal  rst: 		std_logic;
	signal  clk: 		std_logic;
	signal	enable:		std_logic := '0' ;
	signal	metrics: 	port2d(0 to 2*L-1, 0 to M-1);
	signal	F: 		std_logic_vector(0 to 2*L-1);
	signal	ready:		std_logic;
	signal  success:    	std_logic := '1';
    	signal  succ:    	std_logic;
begin
	dut: SCL_selection
		generic map (
			L => L,
			M => M)
		port map (
			rst => rst,
			clk => clk,
			enable => enable,
			metrics => metrics,
			F => F,
			ready => ready
		);

	gen_clock: process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	gen_stimuli: process
		file in_file		: text open read_mode is INPATH;
		file out_file		: text open read_mode is OUTPATH;
		variable textlinei	: line;
		variable textlineo	: line;
		variable metric		: integer;
		variable count		: integer;
		variable temp		: std_logic_vector(0 to M-1);
		variable res		: std_logic_vector(0 to 2*L-1);
	begin
		rst <= '1';
		wait for 10 ns;	
			
        	rst <= '0';
		while not endfile(in_file) loop
			readline(in_file, textlinei);
			for i in 0 to (2*L-1) loop
				read(textlinei, metric); -- read from the input file
				temp := std_logic_vector(to_unsigned(metric, temp'length));
				for j in 0 to M-1 loop
				    metrics(i,j) <= temp(j);
				end loop;
			end loop;
			enable <= '1';
			wait for 10 ns;
			enable <= '0';
			wait on ready;
			--read from the output file and compare
			readline(out_file, textlineo);
			read(textlineo, res);

			if F /= res then
			     succ <= '0'; success <= '0';
			     report "Test failed";
			else
			     succ <= '1';
			     report "Test passed";
			end if;
			wait for 10 ns;
		end loop;
        
        if success = '1' then
            REPORT "All tests passed" SEVERITY FAILURE;
        else
            REPORT "Some testcases failed" SEVERITY FAILURE;
        end if;
        
	end process;
end;
