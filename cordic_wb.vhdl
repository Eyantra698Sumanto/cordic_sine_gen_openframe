library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_wb is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Wishbone interface
        wb_adr_i   : in  std_ulogic_vector(31 downto 0);
        wb_dat_i   : in  std_ulogic_vector(31 downto 0);
        wb_dat_o   : out std_ulogic_vector(31 downto 0);
        wb_we_i    : in  std_ulogic;
        wb_stb_i   : in  std_ulogic;
        wb_cyc_i   : in  std_ulogic;
        wb_ack_o   : out std_ulogic;

        cordic_x     : out std_ulogic_vector(31 downto 0);
        cordic_y     : out std_ulogic_vector(31 downto 0);
        cordic_start : out std_ulogic;
        cordic_done  : in  std_ulogic;
        cordic_result : in std_ulogic_vector(31 downto 0)

    );
end;

architecture rtl of cordic_wb is
    signal x_reg, y_reg : std_logic_vector(31 downto 0);
    signal start_reg    : std_logic := '0';
begin

    cordic_x <= x_reg;
    cordic_y <= y_reg;
    cordic_start <= start_reg;

    -- Wishbone response
    process(clk)
    begin
        if rising_edge(clk) then
            wb_ack_o <= '0';

            if wb_stb_i = '1' and wb_cyc_i = '1' then
                wb_ack_o <= '1';

                if wb_we_i = '1' then  -- write
                    case wb_adr_i(4 downto 2) is
                        when "000" => x_reg <= wb_dat_i;
                        when "001" => y_reg <= wb_dat_i;
                        when "010" => start_reg <= wb_dat_i(0);
                        when others => null;
                    end case;
                else  -- read
                    case wb_adr_i(4 downto 2) is
                        when "000" => wb_dat_o <= x_reg;
                        when "001" => wb_dat_o <= y_reg;
                        when "011" => wb_dat_o(0) <= cordic_done;
                        when "100" => wb_dat_o <= cordic_result;
                        when others => wb_dat_o <= (others => '0');
                    end case;
                end if;
            end if;

            -- auto clear start
            if cordic_done = '1' then
                start_reg <= '0';
            end if;
        end if;
    end process;

end rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_wb is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Wishbone interface
        wb_adr_i   : in  std_logic_vector(31 downto 0);
        wb_dat_i   : in  std_logic_vector(31 downto 0);
        wb_dat_o   : out std_logic_vector(31 downto 0);
        wb_we_i    : in  std_logic;
        wb_stb_i   : in  std_logic;
        wb_cyc_i   : in  std_logic;
        wb_ack_o   : out std_logic;

        -- Your CORDIC ports
        cordic_x   : out std_logic_vector(31 downto 0);
        cordic_y   : out std_logic_vector(31 downto 0);
        cordic_start : out std_logic;
        cordic_done  : in  std_logic;
        cordic_result : in std_logic_vector(31 downto 0)
    );
end;

architecture rtl of cordic_wb is
    signal x_reg, y_reg : std_logic_vector(31 downto 0);
    signal start_reg    : std_logic := '0';
begin

    cordic_x <= x_reg;
    cordic_y <= y_reg;
    cordic_start <= start_reg;

    -- Wishbone response
    process(clk)
    begin
        if rising_edge(clk) then
            wb_ack_o <= '0';

            if wb_stb_i = '1' and wb_cyc_i = '1' then
                wb_ack_o <= '1';

                if wb_we_i = '1' then  -- write
                    case wb_adr_i(4 downto 2) is
                        when "000" => x_reg <= wb_dat_i;
                        when "001" => y_reg <= wb_dat_i;
                        when "010" => start_reg <= wb_dat_i(0);
                        when others => null;
                    end case;
                else  -- read
                    case wb_adr_i(4 downto 2) is
                        when "000" => wb_dat_o <= x_reg;
                        when "001" => wb_dat_o <= y_reg;
                        when "011" => wb_dat_o(0) <= cordic_done;
                        when "100" => wb_dat_o <= cordic_result;
                        when others => wb_dat_o <= (others => '0');
                    end case;
                end if;
            end if;

            -- auto clear start
            if cordic_done = '1' then
                start_reg <= '0';
            end if;
        end if;
    end process;

end rtl;

