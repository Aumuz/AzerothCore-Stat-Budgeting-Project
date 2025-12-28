===========================================================================================================================================

  Filename:    Developer-Handbook.md

  Title:       A Developers Handbook to Stat Budgeting Custom Items in AzerothCore.
  Description: This document defines the recommended workflow for stat budgeting custom items in AzerothCore 3.3.5.
               This document provides a concise reference for developers creating custom items in AzerothCore.
               This document will provide developers with the necessary information to properly assign stats to custom items.

  Information: All calculations are derived from the AzerothCore database (ACDB 335.14-dev).
               ChatGPT was utilized in the creation of this document, to assist with analysis and formatting.
               All results and conclusions were manually verified.

  Author:      Aumuz Messick

  Version:     1.0

  Created:     2025-12-16
  Updated:     2025-12-28

===========================================================================================================================================



===========================================================================================================================================
  A Developers Handbook to Stat Budgeting Custom Items in AzerothCore. v1.0
===========================================================================================================================================



===========================================================================================================================================
  Introduction and Workflow:
===========================================================================================================================================

      The purpose of this document is to provide developers with a simple and concise framework for stat budgeting custom
  equipment and weapon items in AzerothCore. Using this framework, developers can assign stats that produce an appropriate
  power level for a given ItemLevel (iLvl) and Quality. This document also defines the procedure for calculating item
  buy and sell prices based on the Final Budget.



  Workflow: Each step of this workflow builds directly on the previous step.

   - Step 1: Determine the Base Budget from the "ItemLevel to Budget Table".
   - Step 2: Calculate the Final Budget by applying the appropriate Slot Multiplier.
   - Step 3: Allocate the Final Budget using the "Stat to Cost Table".
   - Step 4: Use the Final Budget to calculate the item's buy and sell price.



===========================================================================================================================================
  Step 1: Determine the Base Budget from the "ItemLevel to Budget Table".
===========================================================================================================================================

      The ItemLevel to Budget Table defines base stat budgets in 10 ItemLevel increments. To determine an item's Base Budget,
  locate the row corresponding to the item's ItemLevel bracket and the column corresponding to its Quality Tier. The value
  at this intersection is the Base Budget.

      For ItemLevels that do not fall exactly on a 10-level bracket, the Base Budget may be interpolated linearly between
  the two nearest brackets. To do this, take the difference between the higher and lower bracket values, multiply that
  difference by 0.10 for each ItemLevel above the lower bracket, and add the result to the lower bracket value.

      This interpolation is optional and is provided for developers who wish to calculate an exact ItemLevel budget rather
  than using the nearest bracket.



  ItemLevel to Budget Table:

  +------+------+--------+----------+------+------+-----------+
  | iLvl | Poor | Common | Uncommon | Rare | Epic | Legendary |
  +------+------+--------+----------+------+------+-----------+
  |   10 |    7 |     9  |     14   |   22 |   24 |      24   |
  |   20 |   11 |    14  |     22   |   27 |   29 |      29   |
  |   30 |   17 |    23  |     29   |   37 |   37 |      37   |
  |   40 |   22 |    29  |     40   |   47 |   54 |      54   |
  |   50 |   29 |    39  |     49   |   59 |   66 |      66   |
  |   60 |   32 |    43  |     57   |   69 |   81 |      81   |
  |   70 |   34 |    48  |     78   |   78 |  101 |     101   |
  |   80 |   39 |    55  |     85   |   94 |  108 |     108   |
  |   90 |   47 |    67  |     86   |  102 |  115 |     115   |
  |  100 |   46 |    66  |     88   |  128 |  130 |     135   |
  |  110 |   51 |    72  |     99   |  129 |  161 |     161   |
  |  120 |   63 |    90  |    111   |  157 |  178 |     178   |
  |  130 |   67 |    96  |    131   |  177 |  190 |     190   |
  |  140 |   78 |   112  |    148   |  202 |  221 |     221   |
  |  150 |   84 |   129  |    149   |  207 |  255 |     255   |
  |  160 |   95 |   146  |    158   |  228 |  288 |     320   |
  |  170 |   99 |   152  |    165   |  253 |  300 |     334   |
  |  180 |  106 |   163  |    186   |  281 |  323 |     359   |
  |  190 |  113 |   175  |    196   |  281 |  345 |     384   |
  |  200 |  121 |   186  |    209   |  309 |  367 |     409   |
  |  210 |  144 |   222  |    249   |  358 |  439 |     489   |
  |  220 |  156 |   240  |    269   |  386 |  474 |     527   |
  |  230 |  171 |   263  |    295   |  424 |  520 |     579   |
  |  240 |  185 |   285  |    320   |  459 |  563 |     642   |
  |  250 |  232 |   357  |    400   |  575 |  705 |     784   |
  |  260 |  260 |   400  |    448   |  644 |  790 |     879   |
  |  270 |  264 |   407  |    456   |  655 |  804 |     894   |
  |  280 |  275 |   423  |    474   |  681 |  835 |     929   |
  |  290 |  282 |   434  |    487   |  699 |  858 |     955   |
  |  300 |  290 |   446  |    500   |  718 |  881 |     980   |
  +------+------+--------+----------+------+------+-----------+

    * All values are rounded for usability; no further normalization is applied.



===========================================================================================================================================
  Step 2: Calculate the Final Budget by applying the appropriate Slot Multiplier.
===========================================================================================================================================

      The Slot Multiplier adjusts an item's Base Budget based on its class, subclass, and InventoryType. To determine the
  correct multiplier, identify the item's class and use the corresponding table below. Then locate the row matching the
  item's subclass and the column matching its InventoryType. The value at this intersection is the Slot Multiplier.

      Multiply the Base Budget obtained in Step 1 by the Slot Multiplier to calculate the Final Budget.



  Slot Multiplier Table: Weapon

  +------------------------+------------------------------------------------------------------------+
  | Weapon                 |                        InventoryType multiplier                        |
  +------------------------+----------+-----------+----------+----------+---------+--------+--------+
  | class = 2              |    13    |     21    |    22    |    17    |    15   |   25   |   26   |
  +----------+-------------+----------+-----------+----------+----------+---------+--------+--------+
  | subclass | Name        | One-Hand | Main-Hand | Off-Hand | Two-Hand |   Bow   | Thrown | Ranged |
  +----------+-------------+----------+-----------+----------+----------+---------+--------+--------+
  |     0    | 1H-Axe      |   0.80   |    0.84   |   0.70   |          |         |        |        |
  |     1    | 2H-Axe      |          |           |          |   1.19   |         |        |        |
  |     2    | Bow         |          |           |          |          |   0.71  |        |        |
  |     3    | Gun         |          |           |          |          |         |        |  0.70  |
  |     4    | 1H-Mace     |   0.79   |    1.01   |   0.71   |          |         |        |        |
  |     5    | 2H-Mace     |          |           |          |   1.26   |         |        |        |
  |     6    | Polearm     |          |           |          |   1.23   |         |        |        |
  |     7    | 1H-Sword    |   0.79   |    0.96   |   0.73   |          |         |        |        |
  |     8    | 2H-Sword    |          |           |          |   1.20   |         |        |        |
  |    10    | Staff       |          |           |          |   1.39   |         |        |        |
  |    13    | Fist-Weapon |   0.88   |    0.73   |   0.73   |          |         |        |        |
  |    15    | Dagger      |   0.75   |    1.15   |   0.70   |          |         |        |        |
  |    16    | Thrown      |          |           |          |          |         |  0.99  |        |
  |    18    | Crossbow    |          |           |          |          |         |        |  0.73  |
  |    19    | Wand        |          |           |          |          |         |        |  1.12  |
  +----------+-------------+----------+-----------+----------+----------+---------+--------+--------+



  Slot Multiplier Table: Equipment

  +------------------------------------+------------------------------------------------+
  | Equipment                          |               subclass multiplier              |
  +------------------------------------+------+-------+---------+------+-------+--------+
  | class = 4                          |   0  |   1   |    2    |   3  |   4   |    6   |
  +---------------+--------------------+------+-------+---------+------+-------+--------+
  | InventoryType | Name               | Misc | Cloth | Leather | Mail | Plate | Shield |
  +---------------+--------------------+------+-------+---------+------+-------+--------+
  |        1      | Head               |      |  0.71 |   0.93  | 1.34 |  1.85 |        |
  |        2      | Neck               | 0.37 |       |         |      |       |        |
  |        3      | Shoulder           |      |  0.58 |   0.79  | 1.18 |  1.60 |        |
  |        5      | Chest              |      |  0.59 |   1.07  | 1.65 |  2.13 |        |
  |        6      | Waist              |      |  0.49 |   0.70  | 1.05 |  1.43 |        |
  |        7      | Legs               |      |  0.72 |   0.98  | 1.48 |  1.95 |        |
  |        8      | Feet               |      |  0.53 |   0.77  | 1.23 |  1.67 |        |
  |        9      | Wrists             |      |  0.37 |   0.53  | 0.82 |  1.11 |        |
  |       10      | Hands              |      |  0.53 |   0.71  | 1.09 |  1.43 |        |
  |       11      | Finger             | 0.36 |       |         |      |       |        |
  |       14      | Shield             |      |       |         |      |       |  6.43  |
  |       16      | Back               |      |  0.41 |         |      |       |        |
  |       20      | Robe               |      |  0.76 |   1.01  | 1.40 |       |        |
  |       23      | Off-Hand-Equipment | 0.32 |       |         |      |       |        |
  +---------------+--------------------+------+-------+---------+------+-------+--------+



===========================================================================================================================================
  Step 3: Allocate the Final Budget using the "Stat to Cost Table".
===========================================================================================================================================

      The Final Budget is allocated by assigning stats according to their respective budget costs. The following formulas
  define how DPS, Armor, and Stat Values consume budget. The total cost of all assigned values must not exceed the Final
  Budget.



    DPS Cost   = (dmg_min1 + dmg_max1) / 2 / (delay / 1000)
    Armor Cost = armor * 0.20
    Stat Cost  = stat_value * Cost



  Stat to Cost Table:

  +-----------+-----------------------------------+------+---------+-----------+--------------------------------------------------------+
  | stat_type | Name                              | Cost | Group   | Role      | Notes                                                  |
  +-----------+-----------------------------------+------+---------+-----------+--------------------------------------------------------+
  |      -    | DPS                               | 1.00 | None    | Weapon    | 1 Budget Per 1 DPS.                                    |
  |      -    | armor                             | 0.20 | None    | Equipment | 1 Budget Per 5 armor.                                  |
  |           |                                   |      |         |           |                                                        |
  |      7    | ITEM_MOD_STAMINA                  | 1.00 | Stamina | ANY       | Increase Health.                                       |
  |           |                                   |      |         |           |                                                        |
  |      3    | ITEM_MOD_AGILITY                  | 1.10 | Primary | DPS       | Increase Attack Power of Melee and Ranged Weapons.     |
  |      4    | ITEM_MOD_STRENGTH                 | 0.85 | Primary | Melee     | Increase Melee Attack Power and Parry Rating.          |
  |      5    | ITEM_MOD_INTELLECT                | 0.90 | Primary | Caster    | Increase Spell Power and Mana Pool.                    |
  |      6    | ITEM_MOD_SPIRIT                   | 0.80 | Primary | ANY       | Increase Health and Mana Regeneration.                 |
  |           |                                   |      |         |           |                                                        |
  |     12    | ITEM_MOD_DEFENSE_SKILL_RATING     | 0.80 | Rating  | Tank      | Reduce Chance of Being Hit, or Critically Hit.         |
  |           |                                   |      |         |           | Increase Chance to Block, Dodge, and Parry an Attack.  |
  |     13    | ITEM_MOD_DODGE_RATING             | 0.85 | Rating  | Tank      | Increase Chance to Dodge an Attack.                    |
  |     14    | ITEM_MOD_PARRY_RATING             | 0.25 | Rating  | Tank      | Increase Chance to Parry an Attack.                    |
  |     15    | ITEM_MOD_BLOCK_RATING             | 0.55 | Rating  | Tank      | Increase Chance to Block an Attack.                    |
  |     31    | ITEM_MOD_HIT_RATING               | 0.85 | Rating  | DPS       | Increase Chance of Successful Hit.                     |
  |     32    | ITEM_MOD_CRIT_RATING              | 0.90 | Rating  | DPS       | Increase Chance of Critical Hit.                       |
  |     35    | ITEM_MOD_RESILIENCE_RATING        | 0.70 | Rating  | PVP       | Reduce PVP Damage Taken.                               |
  |     36    | ITEM_MOD_HASTE_RATING             | 0.90 | Rating  | DPS       | Increase Attack Speed. Reduce Cast Time.               |
  |     37    | ITEM_MOD_EXPERTISE_RATING         | 1.10 | Rating  | Melee     | Reduce Chance of Melee Attack Being Avoided by Target. |
  |     44    | ITEM_MOD_ARMOR_PENETRATION_RATING | 0.90 | Rating  | Melee DPS | Increase Amount of Armor Player Attack can Ignore.     |
  |           |                                   |      |         |           |                                                        |
  |     38    | ITEM_MOD_ATTACK_POWER             | 0.40 | Power   | Melee     | Increase Base Weapon Damage.                           |
  |     39    | ITEM_MOD_RANGED_ATTACK_POWER      | 0.40 | Power   | Ranged    | Increase Ranged Weapon Damage.                         |
  |     45    | ITEM_MOD_SPELL_POWER              | 0.90 | Power   | Caster    | Increase Effectiveness of Spells.                      |
  |           |                                   |      |         |           |                                                        |
  |     --    | OTHER                             | 0.25 | Unknown | Unknown   | All Other Stats Not Listed.                            |
  +-----------+-----------------------------------+------+---------+-----------+--------------------------------------------------------+

    * For additional guidance on selecting and distributing stats, refer to <RECOMMENDATION_DOCUMENT_NAME>.



  Socket Bonus Cost:

      Socket bonuses consume budget at 50% of the cost of the corresponding stat. To calculate the cost of a socket bonus,
  determine the stat cost using the Stat to Cost Table, then multiply that value by 0.50.

      Example:
        ITEM_MOD_STRENGTH cost = 0.85
        Socket bonus: +2 Strength
        Socket bonus cost = 2 * (0.85 * 0.50) = 0.85



  Random Property and Random Suffix Cost:

      Items with a Random Property or Random Suffix consume budget equal to 35% of the Final Budget. This cost is applied
  once per item and is independent of the specific stats granted by the random effect.



===========================================================================================================================================
  Step 4: Use the Final Budget to calculate the item's buy and sell price.
===========================================================================================================================================

      An item's BuyPrice and SellPrice (in copper) are derived from its Final Budget and ItemLevel. SellPrice is calculated
  using the ItemLevel Multiplier defined below. BuyPrice is calculated as a fixed multiple of SellPrice.

  BuyPrice  = SellPrice * 5
  SellPrice = Final Budget * ItemLevel Multiplier



  ItemLevel Multiplier:

  +------+------------+    +------+------------+    +------+------------+
  | iLvl | Multiplier |    | iLvl | Multiplier |    | iLvl | Multiplier |
  +------+------------+    +------+------------+    +------+------------+
  |   10 |      25    |    |  110 |     354    |    |  210 |     230    |
  |   20 |      72    |    |  120 |     370    |    |  220 |     219    |
  |   30 |     142    |    |  130 |     370    |    |  230 |     202    |
  |   40 |     218    |    |  140 |     403    |    |  240 |     200    |
  |   50 |     326    |    |  150 |     403    |    |  250 |     194    |
  |   60 |     340    |    |  160 |     403    |    |  260 |     184    |
  |   70 |     398    |    |  170 |     400    |    |  270 |     184    |
  |   80 |     498    |    |  180 |     237    |    |  280 |     209    |
  |   90 |     692    |    |  190 |     237    |    |  290 |     209    |
  |  100 |     579    |    |  200 |     230    |    |  300 |     209    |
  +------+------------+    +------+------------+    +------+------------+

    * All prices are expressed in copper and rounded to whole values.



===========================================================================================================================================
  Additional Information:
===========================================================================================================================================

      This document defines a complete workflow for calculating stat budgets and item prices for custom items in
  AzerothCore. The following documents provide additional context and guidance, depending on developer needs.



  Developer Recommendations
    "Developer Recommendations for Stat Allocation of Custom Items in AzerothCore. v1.0"
    <URL of RECOMMENDATION_DOCUMENT>

    Provides guidance on selecting appropriate ItemLevel, Quality, DPS values, armor values, and stat distributions
    based on player progression and item purpose.



  Validation Reference
    "A Derivation and Validation of Stat Budgeting in AzerothCore. v1.0"
    <URL of RESEARCH_DOCUMENT>

    Documents the data sources, analysis methods, and validation steps used to derive the values presented in this handbook.



  Precision Reference
    "A Verification Guide to Stat Budgeting in AzerothCore. v1.0"
    <URL of PRECISION_DOCUMENT>

    Provides the same workflow and tables as this document using observed 3.3.5 values only, without interpolation
    or derived values. This document is intended for reference and verification. It is not optimized for day-to-day item creation.



===========================================================================================================================================
  End of Document: A Developers Handbook to Stat Budgeting Custom Items in AzerothCore. v1.0

===========================================================================================================================================
