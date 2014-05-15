--*****************************************************************************
-- (c) Copyright 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor             : Xilinx
-- \   \   \/     Version            : 3.92
--  \   \         Application        : MIG
--  /   /         Filename           : example_top.vhd
-- /___/   /\     Date Last Modified : $Date: 2011/06/02 07:16:56 $
-- \   \  /  \    Date Created       : Jul 03 2009
--  \___\/\___\
--
--Device           : Spartan-6
--Design Name      : DDR/DDR2/DDR3/LPDDR 
--Purpose          : This is the design top level. which instantiates top wrapper,
--                   test bench top and infrastructure modules.
--Reference        :
--Revision History :
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;
entity example_top is
generic
  (
            C3_P0_MASK_SIZE           : integer := 4;
          C3_P0_DATA_PORT_SIZE      : integer := 32;
          C3_P1_MASK_SIZE           : integer := 4;
          C3_P1_DATA_PORT_SIZE      : integer := 32;
    C3_MEMCLK_PERIOD        : integer := 3000; 
                                       -- Memory data transfer clock period.
    C3_RST_ACT_LOW          : integer := 0; 
                                       -- # = 1 for active low reset,
                                       -- # = 0 for active high reset.
    C3_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; 
                                       -- input clock type DIFFERENTIAL or SINGLE_ENDED.
    C3_CALIB_SOFT_IP        : string := "TRUE"; 
                                       -- # = TRUE, Enables the soft calibration logic,
                                       -- # = FALSE, Disables the soft calibration logic.
    C3_SIMULATION           : string := "FALSE"; 
                                       -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                       -- # = FALSE, Implementing the design.
    C3_HW_TESTING           : string := "FALSE"; 
                                       -- Determines the address space accessed by the traffic generator,
                                       -- # = FALSE, Smaller address space,
                                       -- # = TRUE, Large address space.
    DEBUG_EN                : integer := 0; 
                                       -- # = 1, Enable debug signals/controls,
                                       --   = 0, Disable debug signals/controls.
    C3_MEM_ADDR_ORDER       : string := "ROW_BANK_COLUMN"; 
                                       -- The order in which user address is provided to the memory controller,
                                       -- ROW_BANK_COLUMN or BANK_ROW_COLUMN.
    C3_NUM_DQ_PINS          : integer := 16; 
                                       -- External memory data width.
    C3_MEM_ADDR_WIDTH       : integer := 13; 
                                       -- External memory address width.
    C3_MEM_BANKADDR_WIDTH   : integer := 3 
                                       -- External memory bank address width.
  );
   
  port
  (
   CLK_I             : in std_logic;
   RESET_I           : in std_logic;
   --calib_done                              : out std_logic;
   --error                                   : out std_logic; -- See ug388.pdf page 30 for details below.
   mcb3_dram_dq      : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0); -- Bidirectional data bus to memory device.
   mcb3_dram_a       : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0); -- Address bus to the memory device.
   mcb3_dram_ba      : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0); -- Bank Address bus to the memory device.
   mcb3_dram_ras_n   : out std_logic; -- This active-Low signal is the row address strobe to the memory device.
   mcb3_dram_cas_n   : out std_logic; -- This signal is the active-Low column addr strobe to the memory device.
   mcb3_dram_we_n    : out std_logic; -- This signal is the active-Low write enable to the memory device.
   mcb3_dram_odt     : out std_logic; -- This output is the on-die termination signal. ODT is supported for DDR2 & DDR3.
   mcb3_dram_cke     : out std_logic; -- This active-High signal is the clock enable to the memory device.
   mcb3_dram_dm      : out std_logic; -- This output is the data mask for the lower data byte (DQ[7:0]) for x16, x8, or x4 configs.
   mcb3_dram_udqs    : inout  std_logic; -- Bidir data strobe for DQ[15:8]. This signal is an input during Read transactionsa dn an output during Write transactions.
   mcb3_dram_udqs_n  : inout  std_logic; -- Bidir complementary data strobe for DQ[15:8]. This signal is an input during Read transactions and an output during Write transactions.
   mcb3_rzq          : inout  std_logic; -- Required pin for all MCB desines. 
   mcb3_zio          : inout  std_logic; -- No connect signal used with the soft calibration module when Calibrated Input Termination is selected.
   mcb3_dram_udm     : out std_logic; -- This output is the data mask for the upper data byte(DQ[15:8]) when interfacing to a x16 device.
   c3_sys_clk        : in  std_logic;
   c3_sys_rst_i      : in  std_logic;
   mcb3_dram_dqs     : inout  std_logic; -- Bidirectional data strobe for DQ[7:0]. This signal is an input during Read transactions and and output during Write transactions.
   mcb3_dram_dqs_n   : inout  std_logic; -- Bidirectional complemenatry data strobe for DQ[7:0]. This signal is an input during Read transactions and an output during Write transactions.
   mcb3_dram_ck      : out std_logic; -- This output is the differential clock (p output) to the memory device.
   mcb3_dram_ck_n    : out std_logic; -- This output is the differential clock (n output) to the memory device.
   
   led_out       : out   std_logic_vector(7 downto 0); -- eight LEDs
   sw_in         : in    std_logic_vector(7 downto 0)  -- eight switches
  );
end example_top;

architecture arc of example_top is

 

component memc3_infrastructure is
    generic (
      C_RST_ACT_LOW        : integer;
      C_INPUT_CLK_TYPE     : string;
      C_CLKOUT0_DIVIDE     : integer;
      C_CLKOUT1_DIVIDE     : integer;
      C_CLKOUT2_DIVIDE     : integer;
      C_CLKOUT3_DIVIDE     : integer;
      C_CLKFBOUT_MULT      : integer;
      C_DIVCLK_DIVIDE      : integer;
      C_INCLK_PERIOD       : integer

      );
    port (
      sys_clk_p                              : in    std_logic;
      sys_clk_n                              : in    std_logic;
      sys_clk                                : in    std_logic;
      sys_rst_i                              : in    std_logic;
      clk0                                   : out   std_logic;
      rst0                                   : out   std_logic;
      async_rst                              : out   std_logic;
      sysclk_2x                              : out   std_logic;
      sysclk_2x_180                          : out   std_logic;
      pll_ce_0                               : out   std_logic;
      pll_ce_90                              : out   std_logic;
      pll_lock                               : out   std_logic;
      mcb_drp_clk                            : out   std_logic

      );
  end component;


component memc3_wrapper is
    generic (
      C_MEMCLK_PERIOD      : integer;
      C_CALIB_SOFT_IP      : string;
      C_SIMULATION         : string;
      C_P0_MASK_SIZE       : integer;
      C_P0_DATA_PORT_SIZE   : integer;
      C_P1_MASK_SIZE       : integer;
      C_P1_DATA_PORT_SIZE   : integer;
      C_ARB_NUM_TIME_SLOTS   : integer;
      C_ARB_TIME_SLOT_0    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_1    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_2    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_3    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_4    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_5    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_6    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_7    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_8    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_9    : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_10   : bit_vector(11 downto 0);
      C_ARB_TIME_SLOT_11   : bit_vector(11 downto 0);
      C_MEM_TRAS           : integer;
      C_MEM_TRCD           : integer;
      C_MEM_TREFI          : integer;
      C_MEM_TRFC           : integer;
      C_MEM_TRP            : integer;
      C_MEM_TWR            : integer;
      C_MEM_TRTP           : integer;
      C_MEM_TWTR           : integer;
      C_MEM_ADDR_ORDER     : string;
      C_NUM_DQ_PINS        : integer;
      C_MEM_TYPE           : string;
      C_MEM_DENSITY        : string;
      C_MEM_BURST_LEN      : integer;
      C_MEM_CAS_LATENCY    : integer;
      C_MEM_ADDR_WIDTH     : integer;
      C_MEM_BANKADDR_WIDTH   : integer;
      C_MEM_NUM_COL_BITS   : integer;
      C_MEM_DDR1_2_ODS     : string;
      C_MEM_DDR2_RTT       : string;
      C_MEM_DDR2_DIFF_DQS_EN   : string;
      C_MEM_DDR2_3_PA_SR   : string;
      C_MEM_DDR2_3_HIGH_TEMP_SR   : string;
      C_MEM_DDR3_CAS_LATENCY   : integer;
      C_MEM_DDR3_ODS       : string;
      C_MEM_DDR3_RTT       : string;
      C_MEM_DDR3_CAS_WR_LATENCY   : integer;
      C_MEM_DDR3_AUTO_SR   : string;
      C_MEM_DDR3_DYN_WRT_ODT   : string;
      C_MEM_MOBILE_PA_SR   : string;
      C_MEM_MDDR_ODS       : string;
      C_MC_CALIB_BYPASS    : string;
      C_MC_CALIBRATION_MODE   : string;
      C_MC_CALIBRATION_DELAY   : string;
      C_SKIP_IN_TERM_CAL   : integer;
      C_SKIP_DYNAMIC_CAL   : integer;
      C_LDQSP_TAP_DELAY_VAL   : integer;
      C_LDQSN_TAP_DELAY_VAL   : integer;
      C_UDQSP_TAP_DELAY_VAL   : integer;
      C_UDQSN_TAP_DELAY_VAL   : integer;
      C_DQ0_TAP_DELAY_VAL   : integer;
      C_DQ1_TAP_DELAY_VAL   : integer;
      C_DQ2_TAP_DELAY_VAL   : integer;
      C_DQ3_TAP_DELAY_VAL   : integer;
      C_DQ4_TAP_DELAY_VAL   : integer;
      C_DQ5_TAP_DELAY_VAL   : integer;
      C_DQ6_TAP_DELAY_VAL   : integer;
      C_DQ7_TAP_DELAY_VAL   : integer;
      C_DQ8_TAP_DELAY_VAL   : integer;
      C_DQ9_TAP_DELAY_VAL   : integer;
      C_DQ10_TAP_DELAY_VAL   : integer;
      C_DQ11_TAP_DELAY_VAL   : integer;
      C_DQ12_TAP_DELAY_VAL   : integer;
      C_DQ13_TAP_DELAY_VAL   : integer;
      C_DQ14_TAP_DELAY_VAL   : integer;
      C_DQ15_TAP_DELAY_VAL   : integer
      );
    port (
      mcb3_dram_dq                           : inout  std_logic_vector((C_NUM_DQ_PINS-1) downto 0);
      mcb3_dram_a                            : out  std_logic_vector((C_MEM_ADDR_WIDTH-1) downto 0);
      mcb3_dram_ba                           : out  std_logic_vector((C_MEM_BANKADDR_WIDTH-1) downto 0);
      mcb3_dram_ras_n                        : out  std_logic;
      mcb3_dram_cas_n                        : out  std_logic;
      mcb3_dram_we_n                         : out  std_logic;
      mcb3_dram_odt                          : out  std_logic;
      mcb3_dram_cke                          : out  std_logic;
      mcb3_dram_dm                           : out  std_logic;
      mcb3_dram_udqs                         : inout  std_logic;
      mcb3_dram_udqs_n                       : inout  std_logic;
      mcb3_rzq                               : inout  std_logic;
      mcb3_zio                               : inout  std_logic;
      mcb3_dram_udm                          : out  std_logic;
      calib_done                             : out  std_logic;
      async_rst                              : in  std_logic;
      sysclk_2x                              : in  std_logic;
      sysclk_2x_180                          : in  std_logic;
      pll_ce_0                               : in  std_logic;
      pll_ce_90                              : in  std_logic;
      pll_lock                               : in  std_logic;
      mcb_drp_clk                            : in  std_logic;
      mcb3_dram_dqs                          : inout  std_logic;
      mcb3_dram_dqs_n                        : inout  std_logic;
      mcb3_dram_ck                           : out  std_logic;
      mcb3_dram_ck_n                         : out  std_logic;
      
      -- See ug388.pdf for more info on the comments below, pg 50
      p0_cmd_clk                            : in std_logic;
      p0_cmd_en                             : in std_logic;
      p0_cmd_instr                          : in std_logic_vector(2 downto 0);
         -- Write    000   Memory Write. Writes the # of data words specified by pX_cmd_bl[5:0] to the
         --                   memory device beginning at the byte addr specified by pX_cmd_addr[29:0].
         --
         -- Read     001   Memory Read. Reads the # of data words specified by pX_cmd_bl[5:0] from the 
         --                   memory device beginning at the byte addr specified by pX_cmd_addr[29:0].
         --
         -- Write    010   
         -- w/ Auto
         -- Precharge
         --
         -- Read     011   
         -- w/ Auto
         -- Precharge
         --
         -- Refresh  1xx
         
      p0_cmd_bl                             : in std_logic_vector(5 downto 0);
      p0_cmd_byte_addr                      : in std_logic_vector(29 downto 0);
      p0_cmd_empty                          : out std_logic;
      p0_cmd_full                           : out std_logic;
      
      p0_wr_clk                             : in std_logic;
      p0_wr_en                              : in std_logic;
      p0_wr_mask                            : in std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
      p0_wr_data                            : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_wr_full                            : out std_logic;
      p0_wr_empty                           : out std_logic;
      p0_wr_count                           : out std_logic_vector(6 downto 0);
      p0_wr_underrun                        : out std_logic;
      p0_wr_error                           : out std_logic;
      
      p0_rd_clk                             : in std_logic;
      p0_rd_en                              : in std_logic;
      p0_rd_data                            : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_rd_full                            : out std_logic;
      p0_rd_empty                           : out std_logic;
      p0_rd_count                           : out std_logic_vector(6 downto 0);
      p0_rd_overflow                        : out std_logic;
      p0_rd_error                           : out std_logic;
      
      p1_cmd_clk                            : in std_logic;
      p1_cmd_en                             : in std_logic;
      p1_cmd_instr                          : in std_logic_vector(2 downto 0);
      p1_cmd_bl                             : in std_logic_vector(5 downto 0);
      p1_cmd_byte_addr                      : in std_logic_vector(29 downto 0);
      p1_cmd_empty                          : out std_logic;
      p1_cmd_full                           : out std_logic;
      
      p1_wr_clk                             : in std_logic;
      p1_wr_en                              : in std_logic;
      p1_wr_mask                            : in std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
      p1_wr_data                            : in std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_wr_full                            : out std_logic;
      p1_wr_empty                           : out std_logic;
      p1_wr_count                           : out std_logic_vector(6 downto 0);
      p1_wr_underrun                        : out std_logic;
      p1_wr_error                           : out std_logic;
      
      p1_rd_clk                             : in std_logic;
      p1_rd_en                              : in std_logic;
      p1_rd_data                            : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_rd_full                            : out std_logic;
      p1_rd_empty                           : out std_logic;
      p1_rd_count                           : out std_logic_vector(6 downto 0);
      p1_rd_overflow                        : out std_logic;
      p1_rd_error                           : out std_logic;
      
      p2_cmd_clk                            : in std_logic;
      p2_cmd_en                             : in std_logic;
      p2_cmd_instr                          : in std_logic_vector(2 downto 0);
      p2_cmd_bl                             : in std_logic_vector(5 downto 0);
      p2_cmd_byte_addr                      : in std_logic_vector(29 downto 0);
      p2_cmd_empty                          : out std_logic;
      p2_cmd_full                           : out std_logic;
      
      p2_wr_clk                             : in std_logic;
      p2_wr_en                              : in std_logic;
      p2_wr_mask                            : in std_logic_vector(3 downto 0);
      p2_wr_data                            : in std_logic_vector(31 downto 0);
      p2_wr_full                            : out std_logic;
      p2_wr_empty                           : out std_logic;
      p2_wr_count                           : out std_logic_vector(6 downto 0);
      p2_wr_underrun                        : out std_logic;
      p2_wr_error                           : out std_logic;
      
      p2_rd_clk                             : in std_logic;
      p2_rd_en                              : in std_logic;
      p2_rd_data                            : out std_logic_vector(31 downto 0);
      p2_rd_full                            : out std_logic;
      p2_rd_empty                           : out std_logic;
      p2_rd_count                           : out std_logic_vector(6 downto 0);
      p2_rd_overflow                        : out std_logic;
      p2_rd_error                           : out std_logic;
      
      p3_cmd_clk                            : in std_logic;
      p3_cmd_en                             : in std_logic;
      p3_cmd_instr                          : in std_logic_vector(2 downto 0);
      p3_cmd_bl                             : in std_logic_vector(5 downto 0);
      p3_cmd_byte_addr                      : in std_logic_vector(29 downto 0);
      p3_cmd_empty                          : out std_logic;
      p3_cmd_full                           : out std_logic;
      
      p3_wr_clk                             : in std_logic;
      p3_wr_en                              : in std_logic;
      p3_wr_mask                            : in std_logic_vector(3 downto 0);
      p3_wr_data                            : in std_logic_vector(31 downto 0);
      p3_wr_full                            : out std_logic;
      p3_wr_empty                           : out std_logic;
      p3_wr_count                           : out std_logic_vector(6 downto 0);
      p3_wr_underrun                        : out std_logic;
      p3_wr_error                           : out std_logic;
      
      p3_rd_clk                             : in std_logic;
      p3_rd_en                              : in std_logic;
      p3_rd_data                            : out std_logic_vector(31 downto 0);
      p3_rd_full                            : out std_logic;
      p3_rd_empty                           : out std_logic;
      p3_rd_count                           : out std_logic_vector(6 downto 0);
      p3_rd_overflow                        : out std_logic;
      p3_rd_error                           : out std_logic;
      
      selfrefresh_enter                     : in std_logic;
      selfrefresh_mode                      : out std_logic

      );
  end component;


--component memc3_tb_top is
--    generic (
--      C_SIMULATION         : string;
--      C_P0_MASK_SIZE       : integer;
--      C_P0_DATA_PORT_SIZE   : integer;
--      C_P1_MASK_SIZE       : integer;
--      C_P1_DATA_PORT_SIZE   : integer;
--      C_NUM_DQ_PINS        : integer;
--      C_MEM_BURST_LEN      : integer;
--      C_MEM_NUM_COL_BITS   : integer;
--      C_SMALL_DEVICE       : string;
--      C_p0_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0); 
--      C_p0_DATA_MODE                          : std_logic_vector(3 downto 0); 
--      C_p0_END_ADDRESS                        : std_logic_vector(31 downto 0); 
--      C_p0_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p0_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p1_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0); 
--      C_p1_DATA_MODE                          : std_logic_vector(3 downto 0); 
--      C_p1_END_ADDRESS                        : std_logic_vector(31 downto 0); 
--      C_p1_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p1_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p2_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0); 
--      C_p2_DATA_MODE                          : std_logic_vector(3 downto 0); 
--      C_p2_END_ADDRESS                        : std_logic_vector(31 downto 0); 
--      C_p2_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p2_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p3_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0); 
--      C_p3_DATA_MODE                          : std_logic_vector(3 downto 0); 
--      C_p3_END_ADDRESS                        : std_logic_vector(31 downto 0); 
--      C_p3_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0); 
--      C_p3_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0) 
--
--      );
--    port (
--      error                                  : out   std_logic;
--      calib_done                             : in    std_logic;
--      clk0                                   : in    std_logic;
--      rst0                                   : in    std_logic;
--      cmp_error                              : out   std_logic;
--      cmp_data_valid                         : out   std_logic;
--      vio_modify_enable                      : in    std_logic;
--      error_status                           : out   std_logic_vector(127 downto 0);
--      vio_data_mode_value                    : in  std_logic_vector(2 downto 0);
--      vio_addr_mode_value                    : in  std_logic_vector(2 downto 0);
--      cmp_data                               : out  std_logic_vector(31 downto 0);
--      p0_mcb_cmd_en_o                           : out std_logic;
--      p0_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
--      p0_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
--      p0_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
--      p0_mcb_cmd_full_i                         : in std_logic;
--      p0_mcb_wr_en_o                            : out std_logic;
--      p0_mcb_wr_mask_o                          : out std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
--      p0_mcb_wr_data_o                          : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
--      p0_mcb_wr_full_i                          : in std_logic;
--      p0_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p0_mcb_rd_en_o                            : out std_logic;
--      p0_mcb_rd_data_i                          : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
--      p0_mcb_rd_empty_i                         : in std_logic;
--      p0_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p1_mcb_cmd_en_o                           : out std_logic;
--      p1_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
--      p1_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
--      p1_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
--      p1_mcb_cmd_full_i                         : in std_logic;
--      p1_mcb_wr_en_o                            : out std_logic;
--      p1_mcb_wr_mask_o                          : out std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
--      p1_mcb_wr_data_o                          : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
--      p1_mcb_wr_full_i                          : in std_logic;
--      p1_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p1_mcb_rd_en_o                            : out std_logic;
--      p1_mcb_rd_data_i                          : in std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
--      p1_mcb_rd_empty_i                         : in std_logic;
--      p1_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p2_mcb_cmd_en_o                           : out std_logic;
--      p2_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
--      p2_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
--      p2_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
--      p2_mcb_cmd_full_i                         : in std_logic;
--      p2_mcb_wr_en_o                            : out std_logic;
--      p2_mcb_wr_mask_o                          : out std_logic_vector(3 downto 0);
--      p2_mcb_wr_data_o                          : out std_logic_vector(31 downto 0);
--      p2_mcb_wr_full_i                          : in std_logic;
--      p2_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p2_mcb_rd_en_o                            : out std_logic;
--      p2_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
--      p2_mcb_rd_empty_i                         : in std_logic;
--      p2_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p3_mcb_cmd_en_o                           : out std_logic;
--      p3_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
--      p3_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
--      p3_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
--      p3_mcb_cmd_full_i                         : in std_logic;
--      p3_mcb_wr_en_o                            : out std_logic;
--      p3_mcb_wr_mask_o                          : out std_logic_vector(3 downto 0);
--      p3_mcb_wr_data_o                          : out std_logic_vector(31 downto 0);
--      p3_mcb_wr_full_i                          : in std_logic;
--      p3_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);
--      p3_mcb_rd_en_o                            : out std_logic;
--      p3_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
--      p3_mcb_rd_empty_i                         : in std_logic;
--      p3_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0)
--
--      );
--  end component;



  function c3_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
   begin
   if (C3_HW_TESTING = "FALSE") then
     return val1;
   else
     return val2;
   end if;
   end function;



   constant C3_CLKOUT0_DIVIDE       : integer := 1; 
   constant C3_CLKOUT1_DIVIDE       : integer := 1; 
   constant C3_CLKOUT2_DIVIDE       : integer := 16; 
   constant C3_CLKOUT3_DIVIDE       : integer := 8; 
   constant C3_CLKFBOUT_MULT        : integer := 2; 
   constant C3_DIVCLK_DIVIDE        : integer := 1; 
   constant C3_INCLK_PERIOD         : integer := ((C3_MEMCLK_PERIOD * C3_CLKFBOUT_MULT) / (C3_DIVCLK_DIVIDE * C3_CLKOUT0_DIVIDE * 2)); 
   constant C3_ARB_NUM_TIME_SLOTS   : integer := 12; 
   constant C3_ARB_TIME_SLOT_0      : bit_vector(11 downto 0) := o"0124"; 
   constant C3_ARB_TIME_SLOT_1      : bit_vector(11 downto 0) := o"1240"; 
   constant C3_ARB_TIME_SLOT_2      : bit_vector(11 downto 0) := o"2401"; 
   constant C3_ARB_TIME_SLOT_3      : bit_vector(11 downto 0) := o"4012"; 
   constant C3_ARB_TIME_SLOT_4      : bit_vector(11 downto 0) := o"0124"; 
   constant C3_ARB_TIME_SLOT_5      : bit_vector(11 downto 0) := o"1240"; 
   constant C3_ARB_TIME_SLOT_6      : bit_vector(11 downto 0) := o"2401"; 
   constant C3_ARB_TIME_SLOT_7      : bit_vector(11 downto 0) := o"4012"; 
   constant C3_ARB_TIME_SLOT_8      : bit_vector(11 downto 0) := o"0124"; 
   constant C3_ARB_TIME_SLOT_9      : bit_vector(11 downto 0) := o"1240"; 
   constant C3_ARB_TIME_SLOT_10     : bit_vector(11 downto 0) := o"2401"; 
   constant C3_ARB_TIME_SLOT_11     : bit_vector(11 downto 0) := o"4012"; 
   constant C3_MEM_TRAS             : integer := 45000; 
   constant C3_MEM_TRCD             : integer := 12500; 
   constant C3_MEM_TREFI            : integer := 7800000; 
   constant C3_MEM_TRFC             : integer := 127500; 
   constant C3_MEM_TRP              : integer := 12500; 
   constant C3_MEM_TWR              : integer := 15000; 
   constant C3_MEM_TRTP             : integer := 7500; 
   constant C3_MEM_TWTR             : integer := 7500; 
   constant C3_MEM_TYPE             : string := "DDR2"; 
   constant C3_MEM_DENSITY          : string := "1Gb"; 
   constant C3_MEM_BURST_LEN        : integer := 4; 
   constant C3_MEM_CAS_LATENCY      : integer := 5; 
   constant C3_MEM_NUM_COL_BITS     : integer := 10; 
   constant C3_MEM_DDR1_2_ODS       : string := "FULL"; 
   constant C3_MEM_DDR2_RTT         : string := "50OHMS"; 
   constant C3_MEM_DDR2_DIFF_DQS_EN  : string := "YES"; 
   constant C3_MEM_DDR2_3_PA_SR     : string := "FULL"; 
   constant C3_MEM_DDR2_3_HIGH_TEMP_SR  : string := "NORMAL"; 
   constant C3_MEM_DDR3_CAS_LATENCY  : integer := 6; 
   constant C3_MEM_DDR3_ODS         : string := "DIV6"; 
   constant C3_MEM_DDR3_RTT         : string := "DIV2"; 
   constant C3_MEM_DDR3_CAS_WR_LATENCY  : integer := 5; 
   constant C3_MEM_DDR3_AUTO_SR     : string := "ENABLED"; 
   constant C3_MEM_DDR3_DYN_WRT_ODT  : string := "OFF"; 
   constant C3_MEM_MOBILE_PA_SR     : string := "FULL"; 
   constant C3_MEM_MDDR_ODS         : string := "FULL"; 
   constant C3_MC_CALIB_BYPASS      : string := "NO"; 
   constant C3_MC_CALIBRATION_MODE  : string := "CALIBRATION"; 
   constant C3_MC_CALIBRATION_DELAY  : string := "HALF"; 
   constant C3_SKIP_IN_TERM_CAL     : integer := 0; 
   constant C3_SKIP_DYNAMIC_CAL     : integer := 0; 
   constant C3_LDQSP_TAP_DELAY_VAL  : integer := 0; 
   constant C3_LDQSN_TAP_DELAY_VAL  : integer := 0; 
   constant C3_UDQSP_TAP_DELAY_VAL  : integer := 0; 
   constant C3_UDQSN_TAP_DELAY_VAL  : integer := 0; 
   constant C3_DQ0_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ1_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ2_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ3_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ4_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ5_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ6_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ7_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ8_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ9_TAP_DELAY_VAL    : integer := 0; 
   constant C3_DQ10_TAP_DELAY_VAL   : integer := 0; 
   constant C3_DQ11_TAP_DELAY_VAL   : integer := 0; 
   constant C3_DQ12_TAP_DELAY_VAL   : integer := 0; 
   constant C3_DQ13_TAP_DELAY_VAL   : integer := 0; 
   constant C3_DQ14_TAP_DELAY_VAL   : integer := 0; 
   constant C3_DQ15_TAP_DELAY_VAL   : integer := 0; 
   constant C3_SMALL_DEVICE         : string := "FALSE"; -- The parameter is set to TRUE for all packages of xc6slx9 device
                                                         -- as most of them cannot fit the complete example design when the
                                                         -- Chip scope modules are enabled
   constant C3_p0_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p0_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p0_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000002ff", x"02ffffff");
   constant C3_p0_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffffc00", x"fc000000");
   constant C3_p0_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p1_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p1_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p1_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000004ff", x"04ffffff");
   constant C3_p1_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff800", x"f8000000");
   constant C3_p1_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p2_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000500", x"05000000");
   constant C3_p2_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p2_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000006ff", x"06ffffff");
   constant C3_p2_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff800", x"f8000000");
   constant C3_p2_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000500", x"05000000");
   constant C3_p3_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000700", x"01000000");
   constant C3_p3_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p3_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000008ff", x"02ffffff");
   constant C3_p3_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff000", x"fc000000");
   constant C3_p3_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000700", x"01000000");

  signal  c3_sys_clk_p                             : std_logic;
  signal  c3_sys_clk_n                             : std_logic;
  signal  c3_error                                 : std_logic;
  signal  c3_calib_done                            : std_logic;
  signal  c3_clk0                                  : std_logic;
  signal  c3_rst0                                  : std_logic;
  signal  c3_async_rst                             : std_logic;
  signal  c3_sysclk_2x                             : std_logic;
  signal  c3_sysclk_2x_180                         : std_logic;
  signal  c3_pll_ce_0                              : std_logic;
  signal  c3_pll_ce_90                             : std_logic;
  signal  c3_pll_lock                              : std_logic;
  signal  c3_mcb_drp_clk                           : std_logic;
  signal  c3_cmp_error                             : std_logic;
  signal  c3_cmp_data_valid                        : std_logic;
  signal  c3_vio_modify_enable                     : std_logic;
  signal  c3_error_status                          : std_logic_vector(127 downto 0);
  signal  c3_vio_data_mode_value                   : std_logic_vector(2 downto 0);
  signal  c3_vio_addr_mode_value                   : std_logic_vector(2 downto 0);
  signal  c3_cmp_data                              : std_logic_vector(31 downto 0);
  signal  c3_p0_cmd_en                             : std_logic;
  signal  c3_p0_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p0_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p0_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p0_cmd_empty                          : std_logic;
  signal  c3_p0_cmd_full                           : std_logic;
  signal  c3_p0_wr_en                              : std_logic;
  signal  c3_p0_wr_mask                            : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
  signal  c3_p0_wr_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p0_wr_full                            : std_logic;
  signal  c3_p0_wr_empty                           : std_logic;
  signal  c3_p0_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p0_wr_underrun                        : std_logic;
  signal  c3_p0_wr_error                           : std_logic;
  signal  c3_p0_rd_en                              : std_logic;
  signal  c3_p0_rd_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p0_rd_full                            : std_logic;
  signal  c3_p0_rd_empty                           : std_logic;
  signal  c3_p0_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p0_rd_overflow                        : std_logic;
  signal  c3_p0_rd_error                           : std_logic;

  signal  c3_p1_cmd_en                             : std_logic;
  signal  c3_p1_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p1_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p1_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p1_cmd_empty                          : std_logic;
  signal  c3_p1_cmd_full                           : std_logic;
  signal  c3_p1_wr_en                              : std_logic;
  signal  c3_p1_wr_mask                            : std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
  signal  c3_p1_wr_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p1_wr_full                            : std_logic;
  signal  c3_p1_wr_empty                           : std_logic;
  signal  c3_p1_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p1_wr_underrun                        : std_logic;
  signal  c3_p1_wr_error                           : std_logic;
  signal  c3_p1_rd_en                              : std_logic;
  signal  c3_p1_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p1_rd_full                            : std_logic;
  signal  c3_p1_rd_empty                           : std_logic;
  signal  c3_p1_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p1_rd_overflow                        : std_logic;
  signal  c3_p1_rd_error                           : std_logic;

  signal  c3_p2_cmd_en                             : std_logic;
  signal  c3_p2_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p2_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p2_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p2_cmd_empty                          : std_logic;
  signal  c3_p2_cmd_full                           : std_logic;
  signal  c3_p2_wr_en                              : std_logic;
  signal  c3_p2_wr_mask                            : std_logic_vector(3 downto 0);
  signal  c3_p2_wr_data                            : std_logic_vector(31 downto 0);
  signal  c3_p2_wr_full                            : std_logic;
  signal  c3_p2_wr_empty                           : std_logic;
  signal  c3_p2_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p2_wr_underrun                        : std_logic;
  signal  c3_p2_wr_error                           : std_logic;
  signal  c3_p2_rd_en                              : std_logic;
  signal  c3_p2_rd_data                            : std_logic_vector(31 downto 0);
  signal  c3_p2_rd_full                            : std_logic;
  signal  c3_p2_rd_empty                           : std_logic;
  signal  c3_p2_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p2_rd_overflow                        : std_logic;
  signal  c3_p2_rd_error                           : std_logic;

  signal  c3_p3_cmd_en                             : std_logic;
  signal  c3_p3_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p3_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p3_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p3_cmd_empty                          : std_logic;
  signal  c3_p3_cmd_full                           : std_logic;
  signal  c3_p3_wr_en                              : std_logic;
  signal  c3_p3_wr_mask                            : std_logic_vector(3 downto 0);
  signal  c3_p3_wr_data                            : std_logic_vector(31 downto 0);
  signal  c3_p3_wr_full                            : std_logic;
  signal  c3_p3_wr_empty                           : std_logic;
  signal  c3_p3_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p3_wr_underrun                        : std_logic;
  signal  c3_p3_wr_error                           : std_logic;
  signal  c3_p3_rd_en                              : std_logic;
  signal  c3_p3_rd_data                            : std_logic_vector(31 downto 0);
  signal  c3_p3_rd_full                            : std_logic;
  signal  c3_p3_rd_empty                           : std_logic;
  signal  c3_p3_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p3_rd_overflow                        : std_logic;
  signal  c3_p3_rd_error                           : std_logic;

  signal  c3_selfrefresh_enter                     : std_logic;
  signal  c3_selfrefresh_mode                      : std_logic;

   signal calib_done : std_logic;
   signal error : std_logic;

   signal st : std_logic_vector(3 downto 0) := "0000";
   signal outer : std_logic_vector(7 downto 0) := "00000000";

begin
error <= c3_error;
calib_done <= c3_calib_done;
c3_sys_clk_p <= '0';
c3_sys_clk_n <= '0';
c3_selfrefresh_enter <= '0';


memc3_infrastructure_inst : memc3_infrastructure

generic map
 (
   C_RST_ACT_LOW                     => C3_RST_ACT_LOW,
   C_INPUT_CLK_TYPE                  => C3_INPUT_CLK_TYPE,
   C_CLKOUT0_DIVIDE                  => C3_CLKOUT0_DIVIDE,
   C_CLKOUT1_DIVIDE                  => C3_CLKOUT1_DIVIDE,
   C_CLKOUT2_DIVIDE                  => C3_CLKOUT2_DIVIDE,
   C_CLKOUT3_DIVIDE                  => C3_CLKOUT3_DIVIDE,
   C_CLKFBOUT_MULT                   => C3_CLKFBOUT_MULT,
   C_DIVCLK_DIVIDE                   => C3_DIVCLK_DIVIDE,
   C_INCLK_PERIOD                    => C3_INCLK_PERIOD
   )
port map
 (
   sys_clk_p                       => c3_sys_clk_p,
   sys_clk_n                       => c3_sys_clk_n,
   sys_clk                         => c3_sys_clk,
   sys_rst_i                       => c3_sys_rst_i,
   clk0                            => c3_clk0,
   rst0                            => c3_rst0,
   async_rst                       => c3_async_rst,
   sysclk_2x                       => c3_sysclk_2x,
   sysclk_2x_180                   => c3_sysclk_2x_180,
   pll_ce_0                        => c3_pll_ce_0,
   pll_ce_90                       => c3_pll_ce_90,
   pll_lock                        => c3_pll_lock,
   mcb_drp_clk                     => c3_mcb_drp_clk
   );


-- wrapper instantiation
 memc3_wrapper_inst : memc3_wrapper

generic map
 (
   C_MEMCLK_PERIOD                   => C3_MEMCLK_PERIOD,
   C_CALIB_SOFT_IP                   => C3_CALIB_SOFT_IP,
   C_SIMULATION                      => C3_SIMULATION,
   C_P0_MASK_SIZE                    => C3_P0_MASK_SIZE,
   C_P0_DATA_PORT_SIZE               => C3_P0_DATA_PORT_SIZE,
   C_P1_MASK_SIZE                    => C3_P1_MASK_SIZE,
   C_P1_DATA_PORT_SIZE               => C3_P1_DATA_PORT_SIZE,
   C_ARB_NUM_TIME_SLOTS              => C3_ARB_NUM_TIME_SLOTS,
   C_ARB_TIME_SLOT_0                 => C3_ARB_TIME_SLOT_0,
   C_ARB_TIME_SLOT_1                 => C3_ARB_TIME_SLOT_1,
   C_ARB_TIME_SLOT_2                 => C3_ARB_TIME_SLOT_2,
   C_ARB_TIME_SLOT_3                 => C3_ARB_TIME_SLOT_3,
   C_ARB_TIME_SLOT_4                 => C3_ARB_TIME_SLOT_4,
   C_ARB_TIME_SLOT_5                 => C3_ARB_TIME_SLOT_5,
   C_ARB_TIME_SLOT_6                 => C3_ARB_TIME_SLOT_6,
   C_ARB_TIME_SLOT_7                 => C3_ARB_TIME_SLOT_7,
   C_ARB_TIME_SLOT_8                 => C3_ARB_TIME_SLOT_8,
   C_ARB_TIME_SLOT_9                 => C3_ARB_TIME_SLOT_9,
   C_ARB_TIME_SLOT_10                => C3_ARB_TIME_SLOT_10,
   C_ARB_TIME_SLOT_11                => C3_ARB_TIME_SLOT_11,
   C_MEM_TRAS                        => C3_MEM_TRAS,
   C_MEM_TRCD                        => C3_MEM_TRCD,
   C_MEM_TREFI                       => C3_MEM_TREFI,
   C_MEM_TRFC                        => C3_MEM_TRFC,
   C_MEM_TRP                         => C3_MEM_TRP,
   C_MEM_TWR                         => C3_MEM_TWR,
   C_MEM_TRTP                        => C3_MEM_TRTP,
   C_MEM_TWTR                        => C3_MEM_TWTR,
   C_MEM_ADDR_ORDER                  => C3_MEM_ADDR_ORDER,
   C_NUM_DQ_PINS                     => C3_NUM_DQ_PINS,
   C_MEM_TYPE                        => C3_MEM_TYPE,
   C_MEM_DENSITY                     => C3_MEM_DENSITY,
   C_MEM_BURST_LEN                   => C3_MEM_BURST_LEN,
   C_MEM_CAS_LATENCY                 => C3_MEM_CAS_LATENCY,
   C_MEM_ADDR_WIDTH                  => C3_MEM_ADDR_WIDTH,
   C_MEM_BANKADDR_WIDTH              => C3_MEM_BANKADDR_WIDTH,
   C_MEM_NUM_COL_BITS                => C3_MEM_NUM_COL_BITS,
   C_MEM_DDR1_2_ODS                  => C3_MEM_DDR1_2_ODS,
   C_MEM_DDR2_RTT                    => C3_MEM_DDR2_RTT,
   C_MEM_DDR2_DIFF_DQS_EN            => C3_MEM_DDR2_DIFF_DQS_EN,
   C_MEM_DDR2_3_PA_SR                => C3_MEM_DDR2_3_PA_SR,
   C_MEM_DDR2_3_HIGH_TEMP_SR         => C3_MEM_DDR2_3_HIGH_TEMP_SR,
   C_MEM_DDR3_CAS_LATENCY            => C3_MEM_DDR3_CAS_LATENCY,
   C_MEM_DDR3_ODS                    => C3_MEM_DDR3_ODS,
   C_MEM_DDR3_RTT                    => C3_MEM_DDR3_RTT,
   C_MEM_DDR3_CAS_WR_LATENCY         => C3_MEM_DDR3_CAS_WR_LATENCY,
   C_MEM_DDR3_AUTO_SR                => C3_MEM_DDR3_AUTO_SR,
   C_MEM_DDR3_DYN_WRT_ODT            => C3_MEM_DDR3_DYN_WRT_ODT,
   C_MEM_MOBILE_PA_SR                => C3_MEM_MOBILE_PA_SR,
   C_MEM_MDDR_ODS                    => C3_MEM_MDDR_ODS,
   C_MC_CALIB_BYPASS                 => C3_MC_CALIB_BYPASS,
   C_MC_CALIBRATION_MODE             => C3_MC_CALIBRATION_MODE,
   C_MC_CALIBRATION_DELAY            => C3_MC_CALIBRATION_DELAY,
   C_SKIP_IN_TERM_CAL                => C3_SKIP_IN_TERM_CAL,
   C_SKIP_DYNAMIC_CAL                => C3_SKIP_DYNAMIC_CAL,
   C_LDQSP_TAP_DELAY_VAL             => C3_LDQSP_TAP_DELAY_VAL,
   C_LDQSN_TAP_DELAY_VAL             => C3_LDQSN_TAP_DELAY_VAL,
   C_UDQSP_TAP_DELAY_VAL             => C3_UDQSP_TAP_DELAY_VAL,
   C_UDQSN_TAP_DELAY_VAL             => C3_UDQSN_TAP_DELAY_VAL,
   C_DQ0_TAP_DELAY_VAL               => C3_DQ0_TAP_DELAY_VAL,
   C_DQ1_TAP_DELAY_VAL               => C3_DQ1_TAP_DELAY_VAL,
   C_DQ2_TAP_DELAY_VAL               => C3_DQ2_TAP_DELAY_VAL,
   C_DQ3_TAP_DELAY_VAL               => C3_DQ3_TAP_DELAY_VAL,
   C_DQ4_TAP_DELAY_VAL               => C3_DQ4_TAP_DELAY_VAL,
   C_DQ5_TAP_DELAY_VAL               => C3_DQ5_TAP_DELAY_VAL,
   C_DQ6_TAP_DELAY_VAL               => C3_DQ6_TAP_DELAY_VAL,
   C_DQ7_TAP_DELAY_VAL               => C3_DQ7_TAP_DELAY_VAL,
   C_DQ8_TAP_DELAY_VAL               => C3_DQ8_TAP_DELAY_VAL,
   C_DQ9_TAP_DELAY_VAL               => C3_DQ9_TAP_DELAY_VAL,
   C_DQ10_TAP_DELAY_VAL              => C3_DQ10_TAP_DELAY_VAL,
   C_DQ11_TAP_DELAY_VAL              => C3_DQ11_TAP_DELAY_VAL,
   C_DQ12_TAP_DELAY_VAL              => C3_DQ12_TAP_DELAY_VAL,
   C_DQ13_TAP_DELAY_VAL              => C3_DQ13_TAP_DELAY_VAL,
   C_DQ14_TAP_DELAY_VAL              => C3_DQ14_TAP_DELAY_VAL,
   C_DQ15_TAP_DELAY_VAL              => C3_DQ15_TAP_DELAY_VAL
   )
port map
(
   mcb3_dram_dq                         => mcb3_dram_dq,
   mcb3_dram_a                          => mcb3_dram_a,
   mcb3_dram_ba                         => mcb3_dram_ba,
   mcb3_dram_ras_n                      => mcb3_dram_ras_n,
   mcb3_dram_cas_n                      => mcb3_dram_cas_n,
   mcb3_dram_we_n                       => mcb3_dram_we_n,
   mcb3_dram_odt                        => mcb3_dram_odt,
   mcb3_dram_cke                        => mcb3_dram_cke,
   mcb3_dram_dm                         => mcb3_dram_dm,
   mcb3_dram_udqs                       => mcb3_dram_udqs,
   mcb3_dram_udqs_n                     => mcb3_dram_udqs_n,
   mcb3_rzq                             => mcb3_rzq,
   mcb3_zio                             => mcb3_zio,
   mcb3_dram_udm                        => mcb3_dram_udm,
   calib_done                      => c3_calib_done,
   async_rst                       => c3_async_rst,
   sysclk_2x                       => c3_sysclk_2x,
   sysclk_2x_180                   => c3_sysclk_2x_180,
   pll_ce_0                        => c3_pll_ce_0,
   pll_ce_90                       => c3_pll_ce_90,
   pll_lock                        => c3_pll_lock,
   mcb_drp_clk                     => c3_mcb_drp_clk,
   mcb3_dram_dqs                        => mcb3_dram_dqs,
   mcb3_dram_dqs_n                      => mcb3_dram_dqs_n,
   mcb3_dram_ck                         => mcb3_dram_ck,
   mcb3_dram_ck_n                       => mcb3_dram_ck_n,
   p0_cmd_clk                           =>  c3_clk0,
   p0_cmd_en                            =>  c3_p0_cmd_en,
   p0_cmd_instr                         =>  c3_p0_cmd_instr,
   p0_cmd_bl                            =>  c3_p0_cmd_bl,
   p0_cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
   p0_cmd_empty                         =>  c3_p0_cmd_empty,
   p0_cmd_full                          =>  c3_p0_cmd_full,
   p0_wr_clk                            =>  c3_clk0,
   p0_wr_en                             =>  c3_p0_wr_en,
   p0_wr_mask                           =>  c3_p0_wr_mask,
   p0_wr_data                           =>  c3_p0_wr_data,
   p0_wr_full                           =>  c3_p0_wr_full,
   p0_wr_empty                          =>  c3_p0_wr_empty,
   p0_wr_count                          =>  c3_p0_wr_count,
   p0_wr_underrun                       =>  c3_p0_wr_underrun,
   p0_wr_error                          =>  c3_p0_wr_error,
   p0_rd_clk                            =>  c3_clk0,
   p0_rd_en                             =>  c3_p0_rd_en,
   p0_rd_data                           =>  c3_p0_rd_data,
   p0_rd_full                           =>  c3_p0_rd_full,
   p0_rd_empty                          =>  c3_p0_rd_empty,
   p0_rd_count                          =>  c3_p0_rd_count,
   p0_rd_overflow                       =>  c3_p0_rd_overflow,
   p0_rd_error                          =>  c3_p0_rd_error,
   p1_cmd_clk                           =>  c3_clk0,
   p1_cmd_en                            =>  c3_p1_cmd_en,
   p1_cmd_instr                         =>  c3_p1_cmd_instr,
   p1_cmd_bl                            =>  c3_p1_cmd_bl,
   p1_cmd_byte_addr                     =>  c3_p1_cmd_byte_addr,
   p1_cmd_empty                         =>  c3_p1_cmd_empty,
   p1_cmd_full                          =>  c3_p1_cmd_full,
   p1_wr_clk                            =>  c3_clk0,
   p1_wr_en                             =>  c3_p1_wr_en,
   p1_wr_mask                           =>  c3_p1_wr_mask,
   p1_wr_data                           =>  c3_p1_wr_data,
   p1_wr_full                           =>  c3_p1_wr_full,
   p1_wr_empty                          =>  c3_p1_wr_empty,
   p1_wr_count                          =>  c3_p1_wr_count,
   p1_wr_underrun                       =>  c3_p1_wr_underrun,
   p1_wr_error                          =>  c3_p1_wr_error,
   p1_rd_clk                            =>  c3_clk0,
   p1_rd_en                             =>  c3_p1_rd_en,
   p1_rd_data                           =>  c3_p1_rd_data,
   p1_rd_full                           =>  c3_p1_rd_full,
   p1_rd_empty                          =>  c3_p1_rd_empty,
   p1_rd_count                          =>  c3_p1_rd_count,
   p1_rd_overflow                       =>  c3_p1_rd_overflow,
   p1_rd_error                          =>  c3_p1_rd_error,
   p2_cmd_clk                           =>  c3_clk0,
   p2_cmd_en                            =>  c3_p2_cmd_en,
   p2_cmd_instr                         =>  c3_p2_cmd_instr,
   p2_cmd_bl                            =>  c3_p2_cmd_bl,
   p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
   p2_cmd_empty                         =>  c3_p2_cmd_empty,
   p2_cmd_full                          =>  c3_p2_cmd_full,
   p2_wr_clk                            =>  c3_clk0,
   p2_wr_en                             =>  c3_p2_wr_en,
   p2_wr_mask                           =>  c3_p2_wr_mask,
   p2_wr_data                           =>  c3_p2_wr_data,
   p2_wr_full                           =>  c3_p2_wr_full,
   p2_wr_empty                          =>  c3_p2_wr_empty,
   p2_wr_count                          =>  c3_p2_wr_count,
   p2_wr_underrun                       =>  c3_p2_wr_underrun,
   p2_wr_error                          =>  c3_p2_wr_error,
   p2_rd_clk                            =>  c3_clk0,
   p2_rd_en                             =>  c3_p2_rd_en,
   p2_rd_data                           =>  c3_p2_rd_data,
   p2_rd_full                           =>  c3_p2_rd_full,
   p2_rd_empty                          =>  c3_p2_rd_empty,
   p2_rd_count                          =>  c3_p2_rd_count,
   p2_rd_overflow                       =>  c3_p2_rd_overflow,
   p2_rd_error                          =>  c3_p2_rd_error,
   p3_cmd_clk                           =>  c3_clk0,
   p3_cmd_en                            =>  c3_p3_cmd_en,
   p3_cmd_instr                         =>  c3_p3_cmd_instr,
   p3_cmd_bl                            =>  c3_p3_cmd_bl,
   p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
   p3_cmd_empty                         =>  c3_p3_cmd_empty,
   p3_cmd_full                          =>  c3_p3_cmd_full,
   p3_wr_clk                            =>  c3_clk0,
   p3_wr_en                             =>  c3_p3_wr_en,
   p3_wr_mask                           =>  c3_p3_wr_mask,
   p3_wr_data                           =>  c3_p3_wr_data,
   p3_wr_full                           =>  c3_p3_wr_full,
   p3_wr_empty                          =>  c3_p3_wr_empty,
   p3_wr_count                          =>  c3_p3_wr_count,
   p3_wr_underrun                       =>  c3_p3_wr_underrun,
   p3_wr_error                          =>  c3_p3_wr_error,
   p3_rd_clk                            =>  c3_clk0,
   p3_rd_en                             =>  c3_p3_rd_en,
   p3_rd_data                           =>  c3_p3_rd_data,
   p3_rd_full                           =>  c3_p3_rd_full,
   p3_rd_empty                          =>  c3_p3_rd_empty,
   p3_rd_count                          =>  c3_p3_rd_count,
   p3_rd_overflow                       =>  c3_p3_rd_overflow,
   p3_rd_error                          =>  c3_p3_rd_error,
   selfrefresh_enter                    =>  c3_selfrefresh_enter,
   selfrefresh_mode                     =>  c3_selfrefresh_mode
);

-- memc3_tb_top_inst : memc3_tb_top
--
--generic map
-- (
--   C_SIMULATION                      => C3_SIMULATION,
--   C_P0_MASK_SIZE                    => C3_P0_MASK_SIZE,
--   C_P0_DATA_PORT_SIZE               => C3_P0_DATA_PORT_SIZE,
--   C_P1_MASK_SIZE                    => C3_P1_MASK_SIZE,
--   C_P1_DATA_PORT_SIZE               => C3_P1_DATA_PORT_SIZE,
--   C_NUM_DQ_PINS                     => C3_NUM_DQ_PINS,
--   C_MEM_BURST_LEN                   => C3_MEM_BURST_LEN,
--   C_MEM_NUM_COL_BITS                => C3_MEM_NUM_COL_BITS,
--   C_SMALL_DEVICE                    => C3_SMALL_DEVICE,
--   C_p0_BEGIN_ADDRESS                       =>  C3_p0_BEGIN_ADDRESS, 
--   C_p0_DATA_MODE                           =>  C3_p0_DATA_MODE, 
--   C_p0_END_ADDRESS                         =>  C3_p0_END_ADDRESS, 
--   C_p0_PRBS_EADDR_MASK_POS                 =>  C3_p0_PRBS_EADDR_MASK_POS, 
--   C_p0_PRBS_SADDR_MASK_POS                 =>  C3_p0_PRBS_SADDR_MASK_POS, 
--   C_p1_BEGIN_ADDRESS                       =>  C3_p1_BEGIN_ADDRESS, 
--   C_p1_DATA_MODE                           =>  C3_p1_DATA_MODE, 
--   C_p1_END_ADDRESS                         =>  C3_p1_END_ADDRESS, 
--   C_p1_PRBS_EADDR_MASK_POS                 =>  C3_p1_PRBS_EADDR_MASK_POS, 
--   C_p1_PRBS_SADDR_MASK_POS                 =>  C3_p1_PRBS_SADDR_MASK_POS, 
--   C_p2_BEGIN_ADDRESS                       =>  C3_p2_BEGIN_ADDRESS, 
--   C_p2_DATA_MODE                           =>  C3_p2_DATA_MODE, 
--   C_p2_END_ADDRESS                         =>  C3_p2_END_ADDRESS, 
--   C_p2_PRBS_EADDR_MASK_POS                 =>  C3_p2_PRBS_EADDR_MASK_POS, 
--   C_p2_PRBS_SADDR_MASK_POS                 =>  C3_p2_PRBS_SADDR_MASK_POS, 
--   C_p3_BEGIN_ADDRESS                       =>  C3_p3_BEGIN_ADDRESS, 
--   C_p3_DATA_MODE                           =>  C3_p3_DATA_MODE, 
--   C_p3_END_ADDRESS                         =>  C3_p3_END_ADDRESS, 
--   C_p3_PRBS_EADDR_MASK_POS                 =>  C3_p3_PRBS_EADDR_MASK_POS, 
--   C_p3_PRBS_SADDR_MASK_POS                 =>  C3_p3_PRBS_SADDR_MASK_POS 
--   )
--port map
--(
--   error                           => c3_error,
--   calib_done                      => c3_calib_done,
--   clk0                            => c3_clk0,
--   rst0                            => c3_rst0,
--   cmp_error                       => c3_cmp_error,
--   cmp_data_valid                  => c3_cmp_data_valid,
--   vio_modify_enable               => c3_vio_modify_enable,
--   error_status                    => c3_error_status,
--   vio_data_mode_value             => c3_vio_data_mode_value,
--   vio_addr_mode_value             => c3_vio_addr_mode_value,
--   cmp_data                        => c3_cmp_data,
--   p0_mcb_cmd_en_o                          =>  c3_p0_cmd_en,
--   p0_mcb_cmd_instr_o                       =>  c3_p0_cmd_instr,
--   p0_mcb_cmd_bl_o                          =>  c3_p0_cmd_bl,
--   p0_mcb_cmd_addr_o                        =>  c3_p0_cmd_byte_addr,
--   p0_mcb_cmd_full_i                        =>  c3_p0_cmd_full,
--   p0_mcb_wr_en_o                           =>  c3_p0_wr_en,
--   p0_mcb_wr_mask_o                         =>  c3_p0_wr_mask,
--   p0_mcb_wr_data_o                         =>  c3_p0_wr_data,
--   p0_mcb_wr_full_i                         =>  c3_p0_wr_full,
--   p0_mcb_wr_fifo_counts                    =>  c3_p0_wr_count,
--   p0_mcb_rd_en_o                           =>  c3_p0_rd_en,
--   p0_mcb_rd_data_i                         =>  c3_p0_rd_data,
--   p0_mcb_rd_empty_i                        =>  c3_p0_rd_empty,
--   p0_mcb_rd_fifo_counts                    =>  c3_p0_rd_count,
--   p1_mcb_cmd_en_o                          =>  c3_p1_cmd_en,
--   p1_mcb_cmd_instr_o                       =>  c3_p1_cmd_instr,
--   p1_mcb_cmd_bl_o                          =>  c3_p1_cmd_bl,
--   p1_mcb_cmd_addr_o                        =>  c3_p1_cmd_byte_addr,
--   p1_mcb_cmd_full_i                        =>  c3_p1_cmd_full,
--   p1_mcb_wr_en_o                           =>  c3_p1_wr_en,
--   p1_mcb_wr_mask_o                         =>  c3_p1_wr_mask,
--   p1_mcb_wr_data_o                         =>  c3_p1_wr_data,
--   p1_mcb_wr_full_i                         =>  c3_p1_wr_full,
--   p1_mcb_wr_fifo_counts                    =>  c3_p1_wr_count,
--   p1_mcb_rd_en_o                           =>  c3_p1_rd_en,
--   p1_mcb_rd_data_i                         =>  c3_p1_rd_data,
--   p1_mcb_rd_empty_i                        =>  c3_p1_rd_empty,
--   p1_mcb_rd_fifo_counts                    =>  c3_p1_rd_count,
--   p2_mcb_cmd_en_o                          =>  c3_p2_cmd_en,
--   p2_mcb_cmd_instr_o                       =>  c3_p2_cmd_instr,
--   p2_mcb_cmd_bl_o                          =>  c3_p2_cmd_bl,
--   p2_mcb_cmd_addr_o                        =>  c3_p2_cmd_byte_addr,
--   p2_mcb_cmd_full_i                        =>  c3_p2_cmd_full,
--   p2_mcb_wr_en_o                           =>  c3_p2_wr_en,
--   p2_mcb_wr_mask_o                         =>  c3_p2_wr_mask,
--   p2_mcb_wr_data_o                         =>  c3_p2_wr_data,
--   p2_mcb_wr_full_i                         =>  c3_p2_wr_full,
--   p2_mcb_wr_fifo_counts                    =>  c3_p2_wr_count,
--   p2_mcb_rd_en_o                           =>  c3_p2_rd_en,
--   p2_mcb_rd_data_i                         =>  c3_p2_rd_data,
--   p2_mcb_rd_empty_i                        =>  c3_p2_rd_empty,
--   p2_mcb_rd_fifo_counts                    =>  c3_p2_rd_count,
--   p3_mcb_cmd_en_o                          =>  c3_p3_cmd_en,
--   p3_mcb_cmd_instr_o                       =>  c3_p3_cmd_instr,
--   p3_mcb_cmd_bl_o                          =>  c3_p3_cmd_bl,
--   p3_mcb_cmd_addr_o                        =>  c3_p3_cmd_byte_addr,
--   p3_mcb_cmd_full_i                        =>  c3_p3_cmd_full,
--   p3_mcb_wr_en_o                           =>  c3_p3_wr_en,
--   p3_mcb_wr_mask_o                         =>  c3_p3_wr_mask,
--   p3_mcb_wr_data_o                         =>  c3_p3_wr_data,
--   p3_mcb_wr_full_i                         =>  c3_p3_wr_full,
--   p3_mcb_wr_fifo_counts                    =>  c3_p3_wr_count,
--   p3_mcb_rd_en_o                           =>  c3_p3_rd_en,
--   p3_mcb_rd_data_i                         =>  c3_p3_rd_data,
--   p3_mcb_rd_empty_i                        =>  c3_p3_rd_empty,
--   p3_mcb_rd_fifo_counts                    =>  c3_p3_rd_count
--  );

   c3_p1_wr_data <= x"00000014"; -- 20 in dec
   
   process (CLK_I)
   begin
      if (rising_edge (CLK_I)) then
         case st is
            when "0000" =>
               c3_p1_wr_en <= '1'; -- Start writing to the FIFO
               c3_p1_cmd_instr <= "000";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0';
               c3_p1_rd_en <= '0';
               outer <= outer;
               st <= "0001";
            when "0001" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "000"; -- Prepare to write
               c3_p1_cmd_bl <= "000000"; -- a total of one word
               c3_p1_cmd_byte_addr <= "00" & x"0000010"; -- to address 16
               c3_p1_cmd_en <= '0';
               c3_p1_rd_en <= '0';
               outer <= outer;
               st <= "0010";
            when "0010" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "000";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '1'; -- Write to command FIFO
               outer <= outer;
               st <= "0011";
            when "0011" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "000";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0'; -- Stop writing to command FIFO
               outer <= outer;
               st <= "0100";
            when "0100" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "000";
               c3_p1_cmd_bl <= "000000"; -- Read 1 word (note, 0 will read one word)
               c3_p1_cmd_byte_addr <= "00" & x"0000010"; -- From address 16
               c3_p1_cmd_en <= '0';
               outer <= outer;
               st <= "0101";
            when "0101" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "001"; -- Issue a read command
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0';
               outer <= outer;
               st <= "0110";
            when "0110" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "001";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '1'; -- Write to command FIFO
               outer <= outer;
               st <= "0111";
            when "0111" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "001";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0'; -- Stop writing to command FIFO
               outer <= outer;
               st <= "1000";
            when "1000" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "001";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0';
               c3_p1_rd_en <= '1'; -- Start reading data
               outer <= outer;
               st <= "1001";
            when "1001" =>
               c3_p1_wr_en <= '0';
               c3_p1_cmd_instr <= "001";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0';
               c3_p1_rd_en <= '1';
               outer <= c3_p1_rd_data (7 downto 0);
               st <= "1010";
            when others =>
               c3_p1_wr_en <= '0'; -- Start writing to the FIFO
               c3_p1_cmd_instr <= "001";
               c3_p1_cmd_bl <= "000000";
               c3_p1_cmd_byte_addr <= "00" & x"0000010";
               c3_p1_cmd_en <= '0';
               c3_p1_rd_en <= '0';
               outer <= outer;
               st <= "0000";
         end case;
      end if;
   end process;

   led_out <= outer;

 end  arc;