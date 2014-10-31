-- ***********************************************************************/
-- Microsemi Corporation Proprietary and Confidential
-- Copyright 2013 Microsemi Corporation.  All rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
-- ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
-- IN ADVANCE IN WRITING.
--
-- Description:	Control state machine for mastering peripheral
--              configuration from fabric.
--              AHB-Lite master used to read config instructions/data
--              (typically from eNVM) and write the data to peripherals
--              via FIC_0 -> MSS -> FIC_2.
--
--
-- SVN Revision Information:
-- SVN $Revision: 22399 $
-- SVN $Date: 2014-04-19 21:44:50 +0100 (Sat, 19 Apr 2014) $
--
-- Notes:
--
-- ***********************************************************************/

-- ========================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package coreconfigmaster_support is
    function or_br (val:std_logic_vector) return std_logic;
end coreconfigmaster_support;

package body coreconfigmaster_support is
    function or_br (val:std_logic_vector) return std_logic is
    variable rtn : std_logic := '0';
    begin
        for index in val'RANGE loop
            rtn := rtn or val(index);
        end loop;
        return(rtn);
    end or_br;

end coreconfigmaster_support;
-- ========================================================================

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.std_logic_unsigned.all;
    USE ieee.numeric_std.all;
    USE work.coreconfigmaster_support.all;


ENTITY CoreConfigMaster IS
    GENERIC (
        DATA_LOCATION  : INTEGER := 0
    );
    PORT (
        HCLK           : IN STD_LOGIC;
        HRESETN        : IN STD_LOGIC;
        HADDR          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        HSIZE          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        HTRANS         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        HWRITE         : OUT STD_LOGIC;
        HWDATA         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        HMASTLOCK      : OUT STD_LOGIC;
        HBURST         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        HPROT          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        HREADY         : IN STD_LOGIC;
        HRDATA         : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END CoreConfigMaster;

ARCHITECTURE rtl OF CoreConfigMaster IS

    constant ADDR_SYSREG_SOFT_RESET : std_logic_vector(31 downto 0) := X"40038048";
    constant ADDR_SYSREG_ENVM_BUSY  : std_logic_vector(31 downto 0) := X"40038158";

    constant S0  : std_logic_vector(5 downto 0) := "000000";
    constant S1  : std_logic_vector(5 downto 0) := "000001";
    constant S2  : std_logic_vector(5 downto 0) := "000010";
    constant S3  : std_logic_vector(5 downto 0) := "000011";
    constant S4  : std_logic_vector(5 downto 0) := "000100";
    constant S5  : std_logic_vector(5 downto 0) := "000101";
    constant S6  : std_logic_vector(5 downto 0) := "000110";
    constant S7  : std_logic_vector(5 downto 0) := "000111";
    constant S8  : std_logic_vector(5 downto 0) := "001000";
    constant S9  : std_logic_vector(5 downto 0) := "001001";
    constant S10 : std_logic_vector(5 downto 0) := "001010";
    constant S11 : std_logic_vector(5 downto 0) := "001011";
    constant S12 : std_logic_vector(5 downto 0) := "001100";
    constant S13 : std_logic_vector(5 downto 0) := "001101";
    constant S14 : std_logic_vector(5 downto 0) := "001110";
    constant S15 : std_logic_vector(5 downto 0) := "001111";
    constant S16 : std_logic_vector(5 downto 0) := "010000";
    constant S17 : std_logic_vector(5 downto 0) := "010001";
    constant S18 : std_logic_vector(5 downto 0) := "010010";
    constant S19 : std_logic_vector(5 downto 0) := "010011";
    constant S20 : std_logic_vector(5 downto 0) := "010100";
    constant S21 : std_logic_vector(5 downto 0) := "010101";
    constant S22 : std_logic_vector(5 downto 0) := "010110";

    constant P0  : std_logic_vector(5 downto 0) := "100000";
    constant P1  : std_logic_vector(5 downto 0) := "100001";
    constant P2  : std_logic_vector(5 downto 0) := "100010";
    constant P3  : std_logic_vector(5 downto 0) := "100011";
    constant P4  : std_logic_vector(5 downto 0) := "100100";
    constant P5  : std_logic_vector(5 downto 0) := "100101";
    constant P6  : std_logic_vector(5 downto 0) := "100110";

    constant OP_COPY    : std_logic_vector(6 downto 0) := "0000000";
    --                                                    "0000001";
    constant OP_POLL    : std_logic_vector(6 downto 0) := "0000010";
    constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE   : std_logic_vector(6 downto 0) := "0000100";
    constant OP_AND     : std_logic_vector(6 downto 0) := "0000101";
    constant OP_OR      : std_logic_vector(6 downto 0) := "0000110";

    SIGNAL state                : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL haddr_fetch          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL haddr_write          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ins1                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ins2                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL last                 : STD_LOGIC;
    SIGNAL opcode               : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL size                 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL addrinc              : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL numbytes             : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL addr                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rdata                : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL bytecount            : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL count                : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL mask                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL expected             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL envm_soft_reset      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL envm_busy            : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL busy                 : STD_LOGIC;
    SIGNAL pause_count          : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL acc                  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL d_state              : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL d_HADDR              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_haddr_fetch        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_haddr_write        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_HSIZE              : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL d_HTRANS             : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL d_HWRITE             : STD_LOGIC;
    SIGNAL d_HWDATA             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_ins1               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_ins2               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_rdata              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_bytecount          : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL d_count              : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL d_mask               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_expected           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_envm_soft_reset    : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL d_envm_busy          : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL d_busy               : STD_LOGIC;
    SIGNAL d_pause_count        : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL d_acc                : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Declare intermediate signals for referenced outputs
    SIGNAL HADDR_int   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL HSIZE_int   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL HTRANS_int  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL HWRITE_int  : STD_LOGIC;
    SIGNAL HWDATA_int  : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    -- Drive referenced outputs
    HADDR <= HADDR_int;
    HSIZE <= HSIZE_int;
    HTRANS <= HTRANS_int;
    HWRITE <= HWRITE_int;
    HWDATA <= HWDATA_int;

    HMASTLOCK <= '0';
    HBURST <= "000";
    HPROT <= "0000";

    PROCESS (
        state,
        HADDR_int,
        haddr_fetch,
        haddr_write,
        HSIZE_int,
        HTRANS_int,
        HWRITE_int,
        HWDATA_int,
        ins1,
        ins2,
        bytecount,
        count,
        rdata,
        mask,
        expected,
        HREADY,
        HRDATA,
        opcode,
        numbytes,
        addr,
        size,
        addrinc,
        last,
        envm_soft_reset,
        envm_busy,
        busy,
        pause_count,
        acc
        )
    BEGIN
        d_state <= state;
        d_HADDR <= HADDR_int;
        d_haddr_fetch <= haddr_fetch;
        d_haddr_write <= haddr_write;
        d_HSIZE <= HSIZE_int;
        d_HTRANS <= HTRANS_int;
        d_HWRITE <= HWRITE_int;
        d_HWDATA <= HWDATA_int;
        d_ins1 <= ins1;
        d_ins2 <= ins2;
        d_bytecount <= bytecount;
        d_count <= count;
        d_rdata <= rdata;
        d_mask <= mask;
        d_expected <= expected;
        d_envm_soft_reset <= envm_soft_reset;
        d_envm_busy <= envm_busy;
        d_busy <= busy;
        d_pause_count <= pause_count;
        d_acc <= acc;
        CASE state IS
            ---------------------------------------------------------------
            -- First check that eNVM is ready to be read (i.e. not busy)
            ---------------------------------------------------------------
            WHEN P0 =>
                d_state <= P1;
                d_HTRANS <= "10";
            WHEN P1 =>
                d_HADDR <= ADDR_SYSREG_ENVM_BUSY;
                d_state <= P2;
            WHEN P2 =>
                IF (HREADY = '1') THEN
                    d_envm_soft_reset <= HRDATA(1 DOWNTO 0);
                    d_HTRANS <= "00";
                    d_state <= P3;
                END IF;
            WHEN P3 =>
                IF (HREADY = '1') THEN
                    d_envm_busy <= HRDATA(1 DOWNTO 0);
                    d_state <= P4;
                END IF;
            WHEN P4 =>
                -- envm_soft_reset bits are high if eNVM is being held in reset
                -- envm_busy bits are high if eNVM is busy
                d_busy <= or_br((NOT(envm_soft_reset) AND envm_busy));
                d_state <= P5;
            WHEN P5 =>
                IF (busy = '1') THEN
                    d_pause_count <= "00000";
                    d_state <= P6;
                ELSE
                    d_HADDR <= std_logic_vector(to_unsigned(DATA_LOCATION, 32));
                    d_state <= S0;
                END IF;
            WHEN P6 =>
                IF (pause_count = "11111") THEN
                    d_HADDR <= ADDR_SYSREG_SOFT_RESET;
                    d_state <= P0;
                ELSE
                    d_pause_count <= pause_count + '1';
                END IF;
            ---------------------------------------------------------------
            WHEN S0 =>
                d_state <= S1;
                d_HTRANS <= "10";
            WHEN S1 =>
                d_HADDR <= HADDR_int + "00000000000000000000000000000100";
                d_state <= S2;
            WHEN S2 =>
                IF (HREADY = '1') THEN
                    d_ins1 <= HRDATA;
                    d_HADDR <= HADDR_int + "00000000000000000000000000000100";
                    d_state <= S3;
                END IF;
            WHEN S3 =>
                IF (opcode = OP_COPY) THEN
                    d_bytecount <= numbytes;
                    d_haddr_fetch <= HADDR_int + "00000000000000000000000000000100";
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_HTRANS <= "00";
                        d_state <= S4;
                    END IF;
                ELSIF (opcode = OP_POLL) THEN
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_HADDR <= HADDR_int + "00000000000000000000000000000100";
                        d_state <= S10;
                    END IF;
                ELSIF (opcode = OP_LOAD) THEN
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_haddr_fetch <= HADDR_int;
                        d_HTRANS <= "00";
                        d_state <= S15;
                    END IF;
                ELSIF (opcode = OP_STORE) THEN
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_haddr_fetch <= HADDR_int;
                        d_HTRANS <= "00";
                        d_state <= S18;
                    END IF;
                ELSIF (opcode = OP_AND) THEN
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_haddr_fetch <= HADDR_int;
                        d_state <= S21;
                    END IF;
                ELSIF (opcode = OP_OR) THEN
                    IF (HREADY = '1') THEN
                        d_ins2 <= HRDATA;
                        d_haddr_fetch <= HADDR_int;
                        d_state <= S22;
                    END IF;
                ELSE -- default to ORing acc with 0x00000000
                    IF (HREADY = '1') THEN
                        d_ins2 <= "00000000000000000000000000000000";
                        d_haddr_fetch <= HADDR_int;
                        d_state <= S22;
                    END IF;
                END IF;
            ---------------------------------------------------------------
            -- Copy
            ---------------------------------------------------------------
            WHEN S4 =>
                IF (HREADY = '1') THEN
                    d_rdata <= HRDATA;
                    d_HADDR <= addr;
                    d_HTRANS <= "10";
                    d_HWRITE <= '1';
                    d_state <= S6;
                    d_count <= "00";

                    IF (size = "0010") THEN
                        d_HSIZE <= "010";
                    ELSIF (size = "0001") THEN
                        d_HSIZE <= "001";
                    ELSE
                        d_HSIZE <= "000";
                    END IF;
                END IF;
            WHEN S5 =>
                IF (HREADY = '1') THEN
                    d_rdata <= HRDATA;
                    d_haddr_fetch <= HADDR_int + "00000000000000000000000000000100";
                    d_HADDR <= haddr_write;
                    d_HTRANS <= "10";
                    d_HWRITE <= '1';
                    d_state <= S6;
                    d_count <= "00";
                END IF;
            WHEN S6 =>
                d_HADDR <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                d_state <= S7;
                IF (size = "0010") THEN
                    d_bytecount <= bytecount - "0000000000000100";
                    d_count <= count + "00";
                    d_HWDATA <= rdata;
                    d_haddr_write <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                    d_HADDR <= haddr_fetch;
                    d_HWRITE <= '0';
                    IF (bytecount = "0000000000000100") THEN
                        IF (last = '1') THEN
                            d_HTRANS <= "00";
                        END IF;
                    END IF;
                ELSIF (size = "0001") THEN
                    d_bytecount <= bytecount - "0000000000000010";
                    d_count <= count + "10";
                    IF ((count(1)) = '1') THEN
                        d_HWDATA <= (rdata(31 DOWNTO 16) & rdata(31 DOWNTO 16));
                    ELSE
                        d_HWDATA <= (rdata(15 DOWNTO 0) & rdata(15 DOWNTO 0));
                    END IF;
                    IF (bytecount = "0000000000000010") THEN
                        d_haddr_write <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                        d_HADDR <= haddr_fetch;
                        d_HWRITE <= '0';
                        IF (last = '1') THEN
                            d_HTRANS <= "00";
                        END IF;
                    END IF;
                ELSE
                    d_bytecount <= bytecount - "0000000000000001";
                    d_count <= count + "01";
                    CASE count(1 DOWNTO 0) IS
                        WHEN "00" =>
                            d_HWDATA <= (rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0));
                        WHEN "01" =>
                            d_HWDATA <= (rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8));
                        WHEN "10" =>
                            d_HWDATA <= (rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16));
                        WHEN "11" =>
                            d_HWDATA <= (rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24));
                        WHEN OTHERS =>
                            d_HWDATA <= rdata;
                    END CASE;
                    IF (bytecount = "0000000000000001") THEN
                        d_haddr_write <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                        d_HADDR <= haddr_fetch;
                        d_HWRITE <= '0';
                        IF (last = '1') THEN
                            d_HTRANS <= "00";
                        END IF;
                    END IF;
                END IF;
            WHEN S7 =>
                IF (bytecount = "0000000000000000") THEN
                    IF (last = '1') THEN
                        IF (HREADY = '1') THEN
                            d_HWRITE <= '0';
                            d_HTRANS <= "00";
                            d_state <= S9;
                        END IF;
                    ELSE
                        IF (HREADY = '1') THEN
                            d_HADDR <= HADDR_int + "00000000000000000000000000000100";
                            d_HSIZE <= "010";
                            d_HWRITE <= '0';
                            d_HTRANS <= "10";
                            d_state <= S2;
                        END IF;
                    END IF;
                ELSE
                    IF (size = "0010") THEN
                        IF (HREADY = '1') THEN
                            d_state <= S5;
                            d_HWRITE <= '0';
                            d_HTRANS <= "00";
                        END IF;
                    ELSIF (size = "0001") THEN
                        IF (count = "00") THEN
                            IF (HREADY = '1') THEN
                                d_HWRITE <= '0';
                                d_HTRANS <= "00";
                                d_state <= S5;
                            END IF;
                        ELSE
                            IF (HREADY = '1') THEN
                                d_HADDR <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                                d_count <= count + "10";
                                d_bytecount <= bytecount - "0000000000000010";
                                IF ((count(1)) = '1') THEN
                                    d_HWDATA <= (rdata(31 DOWNTO 16) & rdata(31 DOWNTO 16));
                                    d_haddr_write <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                                    d_HADDR <= haddr_fetch;
                                    d_HWRITE <= '0';
                                    d_HTRANS <= "10";
                                ELSE
                                    d_HWDATA <= (rdata(15 DOWNTO 0) & rdata(15 DOWNTO 0));
                                END IF;
                            END IF;
                        END IF;
                    ELSE
                        IF (count = "00") THEN
                            IF (HREADY = '1') THEN
                                d_HWRITE <= '0';
                                d_HTRANS <= "00";
                                d_state <= S5;
                            END IF;
                        ELSE
                            IF (HREADY = '1') THEN
                                d_HADDR <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                                d_count <= count + "01";
                                d_bytecount <= bytecount - "0000000000000001";
                                CASE count(1 DOWNTO 0) IS
                                    WHEN "00" =>
                                        d_HWDATA <= (rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0) & rdata(7 DOWNTO 0));
                                    WHEN "01" =>
                                        d_HWDATA <= (rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8) & rdata(15 DOWNTO 8));
                                    WHEN "10" =>
                                        d_HWDATA <= (rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16) & rdata(23 DOWNTO 16));
                                    WHEN "11" =>
                                        d_HWDATA <= (rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24) & rdata(31 DOWNTO 24));
                                        d_haddr_write <= HADDR_int + ("0000000000000000000000000000" & addrinc);
                                        d_HADDR <= haddr_fetch;
                                        d_HWRITE <= '0';
                                        d_HTRANS <= "10";
                                    WHEN OTHERS =>
                                        d_HWDATA <= rdata;
                                END CASE;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            ---------------------------------------------------------------
            -- Finish
            ---------------------------------------------------------------
            WHEN S9 =>
                d_state <= S9;
            ---------------------------------------------------------------
            -- Poll
            ---------------------------------------------------------------
            WHEN S10 =>
                IF (HREADY = '1') THEN
                    d_mask <= HRDATA;
                    d_HADDR <= addr;
                    d_haddr_fetch <= HADDR_int + "00000000000000000000000000000100";
                    d_state <= S11;
                END IF;
            WHEN S11 =>
                IF (HREADY = '1') THEN
                    d_expected <= HRDATA;
                    d_HTRANS <= "00";
                    d_state <= S12;
                END IF;
            WHEN S12 =>
                IF (HREADY = '1') THEN
                    d_rdata <= HRDATA;
                    d_state <= S13;
                END IF;
            WHEN S13 =>
                IF ((rdata AND mask) = expected) THEN
                    IF (last = '1') THEN
                        d_state <= S9;
                    ELSE
                        d_HADDR <= haddr_fetch;
                        d_HTRANS <= "10";
                        d_state <= S1;
                    END IF;
                ELSE
                    d_HTRANS <= "10";
                    d_state <= S14;
                END IF;
            WHEN S14 =>
                d_HTRANS <= "00";
                d_state <= S12;
            ---------------------------------------------------------------
            -- Load
            ---------------------------------------------------------------
            WHEN S15 =>
                IF (HREADY = '1') THEN
                    d_HADDR <= addr;
                    d_HTRANS <= "10";
                    d_state <= S16;
                END IF;
            WHEN S16 =>
                IF (HREADY = '1') THEN
                    d_HTRANS <= "00";
                    d_state <= S17;
                END IF;
            WHEN S17 =>
                IF (HREADY = '1') THEN
                    d_acc <= HRDATA;
                    IF (last = '1') THEN
                        d_state <= S9;
                    ELSE
                        d_HADDR <= haddr_fetch;
                        d_HTRANS <= "10";
                        d_state <= S1;
                    END IF;
                END IF;
            ---------------------------------------------------------------
            -- Store
            ---------------------------------------------------------------
            WHEN S18 =>
                IF (HREADY = '1') THEN
                    d_HADDR <= addr;
                    d_HTRANS <= "10";
                    d_HWRITE <= '1';
                    d_state <= S19;
                END IF;
            WHEN S19 =>
                IF (HREADY = '1') THEN
                    d_HWDATA <= acc;
                    d_HTRANS <= "00";
                    d_HWRITE <= '0';
                    d_state <= S20;
                END IF;
            WHEN S20 =>
                IF (HREADY = '1') THEN
                    IF (last = '1') THEN
                        d_state <= S9;
                    ELSE
                        d_HADDR <= haddr_fetch;
                        d_HTRANS <= "10";
                        d_state <= S1;
                    END IF;
                END IF;
            ---------------------------------------------------------------
            -- AND
            ---------------------------------------------------------------
            WHEN S21 =>
                d_HTRANS <= "00";
                d_acc <= acc AND ins2;
                IF (HREADY = '1') THEN
                    IF (last = '1') THEN
                        d_state <= S9;
                    ELSE
                        d_HADDR <= haddr_fetch;
                        d_HTRANS <= "10";
                        d_state <= S1;
                    END IF;
                END IF;
            ---------------------------------------------------------------
            -- OR
            ---------------------------------------------------------------
            WHEN S22 =>
                d_HTRANS <= "00";
                d_acc <= acc OR ins2;
                IF (HREADY = '1') THEN
                    IF (last = '1') THEN
                        d_state <= S9;
                    ELSE
                        d_HADDR <= haddr_fetch;
                        d_HTRANS <= "10";
                        d_state <= S1;
                    END IF;
                END IF;
            WHEN OTHERS =>
                d_state <= S9;
        END CASE;
    END PROCESS;


    PROCESS (HCLK, HRESETN)
    BEGIN
        IF ((NOT(HRESETN)) = '1') THEN
            state <= P0;
            HADDR_int <= ADDR_SYSREG_SOFT_RESET;
            haddr_fetch <= "00000000000000000000000000000000";
            haddr_write <= "00000000000000000000000000000000";
            HSIZE_int <= "010";
            HTRANS_int <= "00";
            HWRITE_int <= '0';
            HWDATA_int <= "00000000000000000000000000000000";
            ins1 <= "00000000000000000000000000000000";
            ins2 <= "00000000000000000000000000000000";
            rdata <= "00000000000000000000000000000000";
            bytecount <= "0000000000000000";
            count <= "00";
            mask <= "00000000000000000000000000000000";
            expected <= "00000000000000000000000000000000";
            envm_soft_reset <= "00";
            envm_busy       <= "00";
            busy            <= '0';
            pause_count     <= "00000";
            acc <= "00000000000000000000000000000000";
        ELSIF (HCLK'EVENT AND HCLK = '1') THEN
            state <= d_state;
            HADDR_int <= d_HADDR;
            haddr_fetch <= d_haddr_fetch;
            haddr_write <= d_haddr_write;
            HSIZE_int <= d_HSIZE;
            HTRANS_int <= d_HTRANS;
            HWRITE_int <= d_HWRITE;
            HWDATA_int <= d_HWDATA;
            ins1 <= d_ins1;
            ins2 <= d_ins2;
            rdata <= d_rdata;
            bytecount <= d_bytecount;
            count <= d_count;
            mask <= d_mask;
            expected <= d_expected;
            envm_soft_reset <= d_envm_soft_reset;
            envm_busy       <= d_envm_busy;
            busy            <= d_busy;
            pause_count     <= d_pause_count;
            acc <= d_acc;
        END IF;
    END PROCESS;


    PROCESS (ins1, ins2)
    BEGIN
        last <= ins1(31);
        opcode <= ins1(30 DOWNTO 24);
        size <= ins1(23 DOWNTO 20);
        addrinc <= ins1(19 DOWNTO 16);
        numbytes <= ins1(15 DOWNTO 0);
        addr <= ins2;
    END PROCESS;


END rtl;
