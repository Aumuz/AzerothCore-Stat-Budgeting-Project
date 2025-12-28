/*============================================================================================
Filename:       ACSBV3-00-00B.sql
Title:          Phase 00 – Environment Reference Table (Map Classification)
Author:         ChatGPT + Aumuz Messick
Version:        1.1
Created:        2025-10-19
Description:    Creates and populates ACSBV3_ref_map_environment with known 3.3.5a map IDs
                classified by environment type (Raid, Dungeon, World).  This table provides a
                consistent reference for environment tagging in all Phase 00 linkage scripts.
----------------------------------------------------------------------------------------------
Notes:
 - Derived from v2 environment list used in ACSB-00-02B.sql.
 - Replaces repeated hard-coded map lists with a single authoritative table.
 - Safe to re-run: existing table is dropped and recreated.
 - v1.1 Removed duplicate raid maps.
============================================================================================*/

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;
SET collation_connection = 'utf8mb4_general_ci';

DROP TABLE IF EXISTS ACSBV3_ref_map_environment;

CREATE TABLE ACSBV3_ref_map_environment (
    map_id        INT          NOT NULL,
    environment   ENUM('Raid','Dungeon','World') NOT NULL DEFAULT 'World',
    notes         VARCHAR(64)  NULL,
    PRIMARY KEY (map_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*--------------------------------------------------------------------------------------------
  Insert canonical map classifications for all known 3.3.5a instances and raids.
  Source: AzerothCore ACDB 335.14-dev (matching map.dbc)
--------------------------------------------------------------------------------------------*/

INSERT INTO ACSBV3_ref_map_environment (map_id, environment, notes) VALUES
-- Classic Dungeons
(33,'Dungeon','Shadowfang Keep'),
(34,'Dungeon','Stormwind Stockade'),
(36,'Dungeon','Deadmines'),
(43,'Dungeon','Wailing Caverns'),
(47,'Dungeon','Razorfen Kraul'),
(48,'Dungeon','Blackfathom Deeps'),
(70,'Dungeon','Uldaman'),
(90,'Dungeon','Gnomeregan'),
(109,'Dungeon','Sunken Temple'),
(129,'Dungeon','Razorfen Downs'),
(189,'Dungeon','Scarlet Monastery'),
(209,'Dungeon','Zul\'Farrak'),
(229,'Dungeon','Blackrock Spire'),
(230,'Dungeon','Blackrock Depths'),
-- Classic Raids
(249,'Raid','Onyxia\'s Lair'),
(309,'Raid','Zul\'Gurub'),
(409,'Raid','Molten Core'),
(469,'Raid','Blackwing Lair'),
(509,'Raid','Ruins of Ahn\'Qiraj'),
(531,'Raid','Temple of Ahn\'Qiraj'),
(533,'Raid','Naxxramas (Classic)'),
-- Burning Crusade Dungeons
(540,'Dungeon','Hellfire Ramparts'),
(542,'Dungeon','Blood Furnace'),
(543,'Dungeon','Shattered Halls'),
(544,'Dungeon','Magisters\' Terrace'),
(545,'Dungeon','Steamvault'),
(546,'Dungeon','Underbog'),
(547,'Dungeon','Slave Pens'),
(548,'Dungeon','Coilfang: Serpentshrine Cavern'),
(550,'Raid','Tempest Keep'),
(552,'Dungeon','Arcatraz'),
(553,'Dungeon','Botanica'),
(554,'Dungeon','Mechanar'),
(555,'Dungeon','Shadow Labyrinth'),
(556,'Dungeon','Sethekk Halls'),
(557,'Dungeon','Mana-Tombs'),
(558,'Dungeon','Auchenai Crypts'),
(559,'Dungeon','Old Hillsbrad Foothills'),
(560,'Dungeon','Black Morass'),
-- Burning Crusade Raids
(564,'Raid','Black Temple'),
(565,'Raid','Gruul\'s Lair'),
(568,'Raid','Zul\'Aman'),
-- Wrath Dungeons
(574,'Dungeon','Utgarde Keep'),
(575,'Dungeon','Utgarde Pinnacle'),
(576,'Dungeon','Nexus'),
(578,'Dungeon','Occlusus / Oculus (Placeholder)'),
(580,'Dungeon','Sunwell Plateau'),
(595,'Dungeon','Culling of Stratholme'),
(599,'Dungeon','Halls of Stone'),
(600,'Dungeon','Drak\'Tharon Keep'),
(601,'Dungeon','Azjol-Nerub'),
(602,'Dungeon','Halls of Lightning'),
(604,'Dungeon','Gundrak'),
(608,'Dungeon','Violet Hold'),
(619,'Dungeon','Ahn\'kahet: The Old Kingdom'),
(658,'Dungeon','Pit of Saron'),
(668,'Dungeon','Halls of Reflection'),
-- Wrath Raids
(603,'Raid','Ulduar'),
(615,'Raid','The Obsidian Sanctum'),
(616,'Raid','Eye of Eternity'),
(624,'Raid','Vault of Archavon'),
(631,'Raid','Icecrown Citadel'),
(649,'Raid','Trial of the Crusader'),
(650,'Raid','Trial of the Champion'),
(724,'Raid','The Oculus'),
-- Fallback for all unlisted maps
(0,'World','Default Fallback');

/*--------------------------------------------------------------------------------------------
Verification Block
--------------------------------------------------------------------------------------------*/

SELECT
    environment,
    COUNT(*) AS maps_per_env
FROM ACSBV3_ref_map_environment
GROUP BY environment
ORDER BY environment;

/*============================================================================================
End of File
============================================================================================*/
