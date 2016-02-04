
-- Thanks for XHDL
--/////////////////////////////////////////////////////////////////
--////                                    //////
--/////////////////////////////////////////////////////////////////
--/                                                             ///
--/ This file is generated by Viterbi HDL Code Generator(VHCG)  ///
--/ which is written by Mike Johnson at OpenCores.org  and      ///
--/ distributed under GPL license.                              ///
--/                                                             ///
--/ If you have any advice,                                     ///
--/ please email to jhonson.zhu@gmail.com                       ///
--/                                                             ///
--/////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////
--////                                    //////
--/////////////////////////////////////////////////////////////////
--/                                                             ///
--/ This file is generated by Viterbi HDL Code Generator(VHCG)  ///
--/ which is written by Mike Johnson at OpenCores.org  and      ///
--/ distributed under GPL license.                              ///
--/                                                             ///
--/ If you have any advice,                                     ///
--/ please email to jhonson.zhu@gmail.com                       ///
--/                                                             ///
--/////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
ENTITY decoder IS
   PORT (
      mclk                    : IN std_logic;
      rst                     : IN std_logic;
      srst                    : IN std_logic;
      valid_in                : IN std_logic;
      symbol0                 : IN std_logic_vector(3 - 1 DOWNTO 0);
      symbol1                 : IN std_logic_vector(3 - 1 DOWNTO 0);
      pattern                 : IN std_logic_vector(2 - 1 DOWNTO 0);
      bit_out                 : OUT std_logic;
      valid_out               : OUT std_logic);
END decoder;

ARCHITECTURE translated OF decoder IS

   COMPONENT filo
      PORT (
         clk                     : IN  std_logic;
         rst                     : IN  std_logic;
         en_filo_in              : IN  std_logic;
         filo_in                 : IN  std_logic;
         en_filo_out             : IN  std_logic;
         filo_out                : OUT std_logic;
         valid_out               : OUT std_logic);
   END COMPONENT;

   COMPONENT sync_mem
      GENERIC (
          DATA_WIDTH                     :  integer := 32;
          ADDRESS_WIDTH                  :  integer := 10);
         -- sync_mem is not
      PORT (
         clk                     : IN  std_logic;
         wr_data                 : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
         wr_adr                  : IN  std_logic_vector(ADDRESS_WIDTH - 1 DOWNTO 0);
         wr_en                   : IN  std_logic;
         rd_adr                  : IN  std_logic_vector(ADDRESS_WIDTH - 1 DOWNTO 0);
         rd_en                   : IN  std_logic;
         rd_data                 : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0));
   END COMPONENT;

   COMPONENT traceback
      PORT (
         clk                     : IN  std_logic;
         rst                     : IN  std_logic;
         srst                    : IN  std_logic;
         valid_in                : IN  std_logic;
         dec0                    : IN  std_logic;
         dec1                    : IN  std_logic;
         dec2                    : IN  std_logic;
         dec3                    : IN  std_logic;
         dec4                    : IN  std_logic;
         dec5                    : IN  std_logic;
         dec6                    : IN  std_logic;
         dec7                    : IN  std_logic;
         dec8                    : IN  std_logic;
         dec9                    : IN  std_logic;
         dec10                   : IN  std_logic;
         dec11                   : IN  std_logic;
         dec12                   : IN  std_logic;
         dec13                   : IN  std_logic;
         dec14                   : IN  std_logic;
         dec15                   : IN  std_logic;
         dec16                   : IN  std_logic;
         dec17                   : IN  std_logic;
         dec18                   : IN  std_logic;
         dec19                   : IN  std_logic;
         dec20                   : IN  std_logic;
         dec21                   : IN  std_logic;
         dec22                   : IN  std_logic;
         dec23                   : IN  std_logic;
         dec24                   : IN  std_logic;
         dec25                   : IN  std_logic;
         dec26                   : IN  std_logic;
         dec27                   : IN  std_logic;
         dec28                   : IN  std_logic;
         dec29                   : IN  std_logic;
         dec30                   : IN  std_logic;
         dec31                   : IN  std_logic;
         wr_en                   : OUT std_logic;
         wr_data                 : OUT std_logic_vector(32 - 1 DOWNTO 0);
         wr_adr                  : OUT std_logic_vector(10 - 1 DOWNTO 0);
         rd_en                   : OUT std_logic;
         rd_data                 : IN  std_logic_vector(32 - 1 DOWNTO 0);
         rd_adr                  : OUT std_logic_vector(10 - 1 DOWNTO 0);
         en_filo_in              : OUT std_logic;
         filo_in                 : OUT std_logic);
   END COMPONENT;

   COMPONENT vit
      PORT (
         mclk                    : IN  std_logic;
         rst                     : IN  std_logic;
         valid                   : IN  std_logic;
         symbol0                 : IN  std_logic_vector(3 - 1 DOWNTO 0);
         symbol1                 : IN  std_logic_vector(3 - 1 DOWNTO 0);
         pattern                 : IN  std_logic_vector(2 - 1 DOWNTO 0);
         dec0                    : OUT std_logic;
         dec1                    : OUT std_logic;
         dec2                    : OUT std_logic;
         dec3                    : OUT std_logic;
         dec4                    : OUT std_logic;
         dec5                    : OUT std_logic;
         dec6                    : OUT std_logic;
         dec7                    : OUT std_logic;
         dec8                    : OUT std_logic;
         dec9                    : OUT std_logic;
         dec10                   : OUT std_logic;
         dec11                   : OUT std_logic;
         dec12                   : OUT std_logic;
         dec13                   : OUT std_logic;
         dec14                   : OUT std_logic;
         dec15                   : OUT std_logic;
         dec16                   : OUT std_logic;
         dec17                   : OUT std_logic;
         dec18                   : OUT std_logic;
         dec19                   : OUT std_logic;
         dec20                   : OUT std_logic;
         dec21                   : OUT std_logic;
         dec22                   : OUT std_logic;
         dec23                   : OUT std_logic;
         dec24                   : OUT std_logic;
         dec25                   : OUT std_logic;
         dec26                   : OUT std_logic;
         dec27                   : OUT std_logic;
         dec28                   : OUT std_logic;
         dec29                   : OUT std_logic;
         dec30                   : OUT std_logic;
         dec31                   : OUT std_logic;
         valid_decs              : OUT std_logic);
   END COMPONENT;


   SIGNAL valid_decs               :  std_logic;
   SIGNAL dec0                     :  std_logic;
   SIGNAL dec1                     :  std_logic;
   SIGNAL dec2                     :  std_logic;
   SIGNAL dec3                     :  std_logic;
   SIGNAL dec4                     :  std_logic;
   SIGNAL dec5                     :  std_logic;
   SIGNAL dec6                     :  std_logic;
   SIGNAL dec7                     :  std_logic;
   SIGNAL dec8                     :  std_logic;
   SIGNAL dec9                     :  std_logic;
   SIGNAL dec10                    :  std_logic;
   SIGNAL dec11                    :  std_logic;
   SIGNAL dec12                    :  std_logic;
   SIGNAL dec13                    :  std_logic;
   SIGNAL dec14                    :  std_logic;
   SIGNAL dec15                    :  std_logic;
   SIGNAL dec16                    :  std_logic;
   SIGNAL dec17                    :  std_logic;
   SIGNAL dec18                    :  std_logic;
   SIGNAL dec19                    :  std_logic;
   SIGNAL dec20                    :  std_logic;
   SIGNAL dec21                    :  std_logic;
   SIGNAL dec22                    :  std_logic;
   SIGNAL dec23                    :  std_logic;
   SIGNAL dec24                    :  std_logic;
   SIGNAL dec25                    :  std_logic;
   SIGNAL dec26                    :  std_logic;
   SIGNAL dec27                    :  std_logic;
   SIGNAL dec28                    :  std_logic;
   SIGNAL dec29                    :  std_logic;
   SIGNAL dec30                    :  std_logic;
   SIGNAL dec31                    :  std_logic;
   SIGNAL wr_en                    :  std_logic;
   SIGNAL rd_en                    :  std_logic;
   SIGNAL en_filo_in               :  std_logic;
   SIGNAL filo_in                  :  std_logic;
   SIGNAL wr_data                  :  std_logic_vector(32 - 1 DOWNTO 0);
   SIGNAL rd_data                  :  std_logic_vector(32 - 1 DOWNTO 0);
   SIGNAL wr_adr                   :  std_logic_vector(10 - 1 DOWNTO 0);
   SIGNAL rd_adr                   :  std_logic_vector(10 - 1 DOWNTO 0);
   SIGNAL port_vhcg94              :  std_logic;
   SIGNAL bit_out_vhcg1            :  std_logic;
   SIGNAL valid_out_vhcg2          :  std_logic;

BEGIN
   bit_out <= bit_out_vhcg1;
   valid_out <= valid_out_vhcg2;
   vit_i : vit
      PORT MAP (
         mclk => mclk,
         rst => rst,
         valid => valid_in,
         symbol0 => symbol0,
         symbol1 => symbol1,
         pattern => pattern,
         dec0 => dec0,
         dec1 => dec1,
         dec2 => dec2,
         dec3 => dec3,
         dec4 => dec4,
         dec5 => dec5,
         dec6 => dec6,
         dec7 => dec7,
         dec8 => dec8,
         dec9 => dec9,
         dec10 => dec10,
         dec11 => dec11,
         dec12 => dec12,
         dec13 => dec13,
         dec14 => dec14,
         dec15 => dec15,
         dec16 => dec16,
         dec17 => dec17,
         dec18 => dec18,
         dec19 => dec19,
         dec20 => dec20,
         dec21 => dec21,
         dec22 => dec22,
         dec23 => dec23,
         dec24 => dec24,
         dec25 => dec25,
         dec26 => dec26,
         dec27 => dec27,
         dec28 => dec28,
         dec29 => dec29,
         dec30 => dec30,
         dec31 => dec31,
         valid_decs => valid_decs);

   traback_i : traceback
      PORT MAP (
         clk => mclk,
         rst => rst,
         srst => srst,
         valid_in => valid_decs,
         dec0 => dec0,
         dec1 => dec1,
         dec2 => dec2,
         dec3 => dec3,
         dec4 => dec4,
         dec5 => dec5,
         dec6 => dec6,
         dec7 => dec7,
         dec8 => dec8,
         dec9 => dec9,
         dec10 => dec10,
         dec11 => dec11,
         dec12 => dec12,
         dec13 => dec13,
         dec14 => dec14,
         dec15 => dec15,
         dec16 => dec16,
         dec17 => dec17,
         dec18 => dec18,
         dec19 => dec19,
         dec20 => dec20,
         dec21 => dec21,
         dec22 => dec22,
         dec23 => dec23,
         dec24 => dec24,
         dec25 => dec25,
         dec26 => dec26,
         dec27 => dec27,
         dec28 => dec28,
         dec29 => dec29,
         dec30 => dec30,
         dec31 => dec31,
         wr_en => wr_en,
         wr_data => wr_data,
         wr_adr => wr_adr,
         rd_en => rd_en,
         rd_data => rd_data,
         rd_adr => rd_adr,
         en_filo_in => en_filo_in,
         filo_in => filo_in);

   sync_mem0 : sync_mem
      GENERIC MAP (
         DATA_WIDTH => 32,
         ADDRESS_WIDTH => 10)
      PORT MAP (
         clk => mclk,
         wr_data => wr_data,
         wr_adr => wr_adr,
         wr_en => wr_en,
         rd_adr => rd_adr,
         rd_en => rd_en,
         rd_data => rd_data);

   port_vhcg94 <= '1';
   filo_i : filo
      PORT MAP (
         clk => mclk,
         rst => rst,
         en_filo_in => en_filo_in,
         filo_in => filo_in,
         en_filo_out => port_vhcg94,
         filo_out => bit_out_vhcg1,
         valid_out => valid_out_vhcg2);


END translated;
