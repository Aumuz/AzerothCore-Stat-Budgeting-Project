/*=============================================================================================================================================
  Filename:       ACSBV3-07-00C.sql
  Title:          Buy/Sell Price Research (Part 1 of 4).
  Author:         Aumuz Messick
  Version:        1.0
  Created:        2025-12-14
  Description:    These script will generate information related to Buy/Sell Price.
                  This  script will produce a single report covering all items in ACSBV3_ref_dataset, grouped by Quality, slot_group, and ItemLevelBracket.

-----------------------------------------------------------------------------------------------------------------------------------------------
  Updates:
   - v1.0 -> Script Created.

=============================================================================================================================================*/



/*=============================================================================================================================================
  0.1 - Update MYSQL Collation for AzerothCore:
=============================================================================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';



/*=============================================================================================================================================
  0.2 - Set Script Variables:
=============================================================================================================================================*/

SET @SCRIPT  := "0700C",
    @VERSION := "1.0";



/*=============================================================================================================================================
  1. Basic Research: Buy/Sell Price in ACSBV3_ref_dataset.
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "1. Basic Research: Buy/Sell Price in ACSBV3_ref_dataset." );



SET @COUNT_Total := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset                                          ),    -- Expected: 18318
    @COUNT_None  := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset WHERE `BuyPrice` = 0 AND `SellPrice` = 0 ),    -- Expected:  5214
    @COUNT_Both  := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset WHERE `BuyPrice` > 0 AND `SellPrice` > 0 ),    -- Expected: 13096
    @COUNT_Buy   := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset WHERE `BuyPrice` > 0                     ),    -- Expected: 13097
    @COUNT_Sell  := ( SELECT COUNT(*) FROM ACSBV3_ref_dataset WHERE                    `SellPrice` > 0 );    -- Expected: 13103

SET @RATIO_Total := ROUND ( ( @COUNT_Total / @COUNT_Total ) * 100, 2 ),    -- Expected: 100.00
    @RATIO_None  := ROUND ( ( @COUNT_None  / @COUNT_Total ) * 100, 2 ),    -- Expected:  71.50
    @RATIO_Both  := ROUND ( ( @COUNT_Both  / @COUNT_Total ) * 100, 2 ),    -- Expected:  71.53
    @RATIO_Buy   := ROUND ( ( @COUNT_Buy   / @COUNT_Total ) * 100, 2 ),    -- Expected:  71.49
    @RATIO_Sell  := ROUND ( ( @COUNT_Sell  / @COUNT_Total ) * 100, 2 );    -- Expected:  28.46



SELECT          "  +----------------------------------------------+---------+-----------+  "                                                              AS `` UNION ALL
SELECT          "  |                                              |  Count  |   Ratio   |  "                                                              AS `` UNION ALL
SELECT          "  +----------------------------------------------+---------+-----------+  "                                                              AS `` UNION ALL
SELECT          "  |                                              |         |           |  "                                                              AS `` UNION ALL
SELECT CONCAT ( "  |  ACSBV3_ref_dataset: Total Items             |  ", LPAD ( @COUNT_Total, 5, " " ), "  |  ", LPAD ( @RATIO_Total, 6, " " ), "%  |  " ) AS `` UNION ALL
SELECT          "  |                                              |         |           |  "                                                              AS `` UNION ALL
SELECT CONCAT ( "  |  Dataset items with a Buy  Price             |  ", LPAD ( @COUNT_Buy,   5, " " ), "  |  ", LPAD ( @RATIO_Buy,   6, " " ), "%  |  " ) AS `` UNION ALL
SELECT CONCAT ( "  |  Dataset items with a Sell Price             |  ", LPAD ( @COUNT_Sell,  5, " " ), "  |  ", LPAD ( @RATIO_Sell,  6, " " ), "%  |  " ) AS `` UNION ALL
SELECT          "  |                                              |         |           |  "                                                              AS `` UNION ALL
SELECT CONCAT ( "  |  Dataset items with both Buy and Sell Price  |  ", LPAD ( @COUNT_Both,  5, " " ), "  |  ", LPAD ( @RATIO_Both,  6, " " ), "%  |  " ) AS `` UNION ALL
SELECT CONCAT ( "  |  Dataset items without a Buy  or Sell Price  |  ", LPAD ( @COUNT_None,  5, " " ), "  |  ", LPAD ( @RATIO_None,  6, " " ), "%  |  " ) AS `` UNION ALL
SELECT          "  |                                              |         |           |  "                                                              AS `` UNION ALL
SELECT          "  +----------------------------------------------+---------+-----------+  "                                                              AS `` UNION ALL
SELECT          "                                                                          "                                                              AS ``;



CALL ACSBV3_0700A_report ( 1, "ALL", "ALL" );



/*=============================================================================================================================================
  2. Basic Research: Buy/Sell Price in ACSBV3_ref_dataset. [GROUP BY Quality, slot_group, ItemLevelBracket]
=============================================================================================================================================*/

CALL ACSBV3_print_header ( "2. Basic Research: Buy/Sell Price in ACSBV3_ref_dataset. [GROUP BY Quality, slot_group]" );

CALL ACSBV3_0700A_report ( 2, "`Quality`, `slot_group`, `ItemLevelBracket`", "ALL" );



/*=============================================================================================================================================
  End of File
=============================================================================================================================================*/
