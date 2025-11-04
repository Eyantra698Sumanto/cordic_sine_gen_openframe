library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_soc_tb is
end;

architecture tb of cordic_soc_tb is

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';

    -- Wishbone interface
    signal wb_adr   : std_logic_vector(63 downto 0);
    signal wb_dat_w : std_logic_vector(63 downto 0);
    signal wb_dat_r : std_logic_vector(63 downto 0);
    signal wb_sel   : std_logic_vector(7 downto 0) := (others => '1');
    signal wb_we    : std_logic := '0';
    signal wb_stb   : std_logic := '0';
    signal wb_cyc   : std_logic := '0';
    signal wb_ack   : std_logic;

    constant CORDIC_BASE : std_logic_vector(63 downto 0) := x"00000000C0000000";

begin
    clk <= not clk after 5 ns;

    dut: entity work.soc
        port map (
            system_clk    => clk,
            rst           => rst,
            wb_adr        => wb_adr,
            wb_dat_w      => wb_dat_w,
            wb_dat_r      => wb_dat_r,
            wb_sel        => wb_sel,
            wb_we         => wb_we,
            wb_stb        => wb_stb,
            wb_cyc        => wb_cyc,
            wb_ack        => wb_ack
        );

    -- Test sequence
    process
    begin
        -- RESET
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;

        -- Write angle = 45° (0.785398 rad scaled)
        wb_adr <= CORDIC_BASE;
        wb_dat_w <= x"00000000_0000C90F"; -- fixed-point approx
        wb_we <= '1';
        wb_stb <= '1';
        wb_cyc <= '1';
        wait until wb_ack = '1';
        wb_stb <= '0';
        wb_cyc <= '0';
        wb_we <= '0';

        -- Wait CORDIC computation latency
        wait for 2000 ns;

        -- Read OUT
        wb_adr <= CORDIC_BASE + x"08";
        wb_stb <= '1';
        wb_cyc <= '1';
        wait until wb_ack = '1';
        wb_stb <= '0';
        wb_cyc <= '0';

        report "CORDIC Output = " & integer'image(to_integer(signed(wb_dat_r(15 downto 0))));

        wait;
    end process;

end;

