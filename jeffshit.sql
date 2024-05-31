/*
MySQL Data Transfer
Source Host: localhost
Source Database: arp
Target Host: localhost
Target Database: arp
Date: 9/6/2009 3:50:28 PM
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for arp_data
-- ----------------------------
DROP TABLE IF EXISTS `arp_data`;
CREATE TABLE `arp_data` (
  `classkey` varchar(64) default NULL,
  `value` text,
  UNIQUE KEY `classkey` (`classkey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_doors
-- ----------------------------
DROP TABLE IF EXISTS `arp_doors`;
CREATE TABLE `arp_doors` (
  `targetname` varchar(36) default NULL,
  `internalname` varchar(66) default NULL,
  UNIQUE KEY `targetname` (`targetname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_items
-- ----------------------------
DROP TABLE IF EXISTS `arp_items`;
CREATE TABLE `arp_items` (
  `authidname` varchar(64) default NULL,
  `num` int(11) default NULL,
  UNIQUE KEY `authidname` (`authidname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_jobs
-- ----------------------------
DROP TABLE IF EXISTS `arp_jobs`;
CREATE TABLE `arp_jobs` (
  `name` varchar(32) default NULL,
  `salary` int(11) default NULL,
  `access` varchar(27) default NULL,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_keys
-- ----------------------------
DROP TABLE IF EXISTS `arp_keys`;
CREATE TABLE `arp_keys` (
  `authidkey` varchar(64) default NULL,
  UNIQUE KEY `authidkey` (`authidkey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_property
-- ----------------------------
DROP TABLE IF EXISTS `arp_property`;
CREATE TABLE `arp_property` (
  `internalname` varchar(66) default NULL,
  `externalname` varchar(66) default NULL,
  `ownername` varchar(40) default NULL,
  `ownerauth` varchar(36) default NULL,
  `price` int(11) default NULL,
  `locked` int(11) default NULL,
  `access` varchar(27) default NULL,
  `profit` int(11) default NULL,
  UNIQUE KEY `internalname` (`internalname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for arp_users
-- ----------------------------
DROP TABLE IF EXISTS `arp_users`;
CREATE TABLE `arp_users` (
  `authid` varchar(36) default NULL,
  `bankmoney` int(11) default NULL,
  `wallet` int(11) default NULL,
  `jobname` varchar(36) default NULL,
  `hunger` int(11) default NULL,
  `access` varchar(27) default NULL,
  `jobright` varchar(27) default NULL,
  UNIQUE KEY `authid` (`authid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records 
-- ----------------------------
INSERT INTO `arp_doors` VALUES ('t|ahideout_mcpd_door', 'Black Market');
INSERT INTO `arp_doors` VALUES ('t|diner_doorup1', 'Diner');
INSERT INTO `arp_doors` VALUES ('t|diner_doorup2', 'Diner');
INSERT INTO `arp_doors` VALUES ('e|159', 'Diner');
INSERT INTO `arp_doors` VALUES ('t|apartmentE', 'Apartment E');
INSERT INTO `arp_doors` VALUES ('e|829', 'aptag');
INSERT INTO `arp_doors` VALUES ('t|apartdoora', 'aptaa');
INSERT INTO `arp_doors` VALUES ('t|apartdoorb', 'aptab');
INSERT INTO `arp_doors` VALUES ('t|scott_idea', 'aptab');
INSERT INTO `arp_doors` VALUES ('e|74', 'aptab');
INSERT INTO `arp_doors` VALUES ('e|73', 'aptab');
INSERT INTO `arp_doors` VALUES ('t|711ownerplace', 'WaWa');
INSERT INTO `arp_doors` VALUES ('t|711mngdor2', 'WaWa');
INSERT INTO `arp_doors` VALUES ('e|612', '7/11');
INSERT INTO `arp_doors` VALUES ('t|hobo2', 'box1');
INSERT INTO `arp_doors` VALUES ('t|hobo1', 'box2');
INSERT INTO `arp_doors` VALUES ('t|ricksofficedoors', '1337');
INSERT INTO `arp_doors` VALUES ('t|hobo3', 'box3');
INSERT INTO `arp_doors` VALUES ('e|59', '1337');
INSERT INTO `arp_doors` VALUES ('e|60', '1337');
INSERT INTO `arp_doors` VALUES ('e|58', '1337');
INSERT INTO `arp_doors` VALUES ('e|57', '1337');
INSERT INTO `arp_doors` VALUES ('t|nerv_headquarters', 'hideout 2');
INSERT INTO `arp_doors` VALUES ('t|hideout_3', 'hideout 3');
INSERT INTO `arp_doors` VALUES ('e|489', 'hideout 3');
INSERT INTO `arp_doors` VALUES ('t|hotelfrtdskdoor', 'Hotel Lobby');
INSERT INTO `arp_doors` VALUES ('t|hotel_door_a', 'Hotel A');
INSERT INTO `arp_doors` VALUES ('t|hotel_b', 'Hotel B');
INSERT INTO `arp_doors` VALUES ('t|hotel_door_c', 'Hotel C');
INSERT INTO `arp_doors` VALUES ('t|hotel_door_d', 'Hotel D');
INSERT INTO `arp_doors` VALUES ('e|119', 'Hotel A');
INSERT INTO `arp_doors` VALUES ('e|118', 'Hotel A');
INSERT INTO `arp_doors` VALUES ('e|448', 'Hotel B');
INSERT INTO `arp_doors` VALUES ('e|449', 'Hotel B');
INSERT INTO `arp_doors` VALUES ('e|124', 'Hotel C');
INSERT INTO `arp_doors` VALUES ('e|125', 'Hotel C');
INSERT INTO `arp_doors` VALUES ('t|donator_room', 'Le Spa');
INSERT INTO `arp_doors` VALUES ('t|window_hideout_1_door', 'Hideout 4');
INSERT INTO `arp_doors` VALUES ('e|861', 'Admin');
INSERT INTO `arp_doors` VALUES ('t|prison_door_main2', 'MCPD');
INSERT INTO `arp_doors` VALUES ('t|prison_door_main', 'MCPD');
INSERT INTO `arp_doors` VALUES ('t|prison_door_3', 'MCPD');
INSERT INTO `arp_doors` VALUES ('t|bank_door_1', 'Chase bank');
INSERT INTO `arp_doors` VALUES ('t|prison_door_hele', 'MCPD');
INSERT INTO `arp_doors` VALUES ('t|hideout_4', 'Hideout 5');
INSERT INTO `arp_doors` VALUES ('t|trapdor', 'Hideout 5');
INSERT INTO `arp_doors` VALUES ('t|neo_nazi_2', 'Hideout 5');
INSERT INTO `arp_doors` VALUES ('t|neo_nazi_1', 'Hideout 5');
INSERT INTO `arp_doors` VALUES ('t|shedroom', 'Meth Shack');
INSERT INTO `arp_doors` VALUES ('t|inn_lock2', 'Mecklenburg City Hospital');
INSERT INTO `arp_doors` VALUES ('t|md_backroom', 'Mecklenburg City Hospital');
INSERT INTO `arp_doors` VALUES ('t|md_chief', 'Mecklenburg City Hospital');
INSERT INTO `arp_doors` VALUES ('e|335', 'Mecklenburg City Hospital');
INSERT INTO `arp_doors` VALUES ('t|md_doors2', 'mcmd');
INSERT INTO `arp_doors` VALUES ('t|md_doors1', 'mcmd');
INSERT INTO `arp_doors` VALUES ('t|md_doors3', 'mcmd');
INSERT INTO `arp_doors` VALUES ('t|md_doors4', 'mcmd');
INSERT INTO `arp_doors` VALUES ('e|336', 'mcmd');
INSERT INTO `arp_doors` VALUES ('t|armory_door1', 'gunshop');
INSERT INTO `arp_doors` VALUES ('t|armory_door2', 'gunshop');
INSERT INTO `arp_doors` VALUES ('t|backdoordclun', 'stripclub');
INSERT INTO `arp_doors` VALUES ('t|dancebackward', 'stripclub');
INSERT INTO `arp_doors` VALUES ('e|526', 'storageroom');
INSERT INTO `arp_doors` VALUES ('t|rick_esc', '1337tower');
INSERT INTO `arp_doors` VALUES ('t|bank_safedoor', 'bank');
INSERT INTO `arp_doors` VALUES ('t|bardoor1', 'bar');
INSERT INTO `arp_doors` VALUES ('t|bar_door5', 'bar');
INSERT INTO `arp_doors` VALUES ('t|bar_door2', 'bar');
INSERT INTO `arp_doors` VALUES ('t|bar_door3', 'bar');
INSERT INTO `arp_doors` VALUES ('e|830', 'apartment_g');
INSERT INTO `arp_doors` VALUES ('t|interigation_door', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|prison_door_2', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|prison_door_1', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|prison_door_4', 'mcpd');
INSERT INTO `arp_doors` VALUES ('e|142', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|pd_garage', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|mall_donn', 'mcdonalds');
INSERT INTO `arp_doors` VALUES ('t|mall_security', 'mcpd');
INSERT INTO `arp_doors` VALUES ('t|Office_C', 'office_c');
INSERT INTO `arp_doors` VALUES ('t|office_b', 'office_b');
INSERT INTO `arp_doors` VALUES ('t|office_a_door', 'office_a');
INSERT INTO `arp_doors` VALUES ('t|apartdoorh', 'apartment_h');
INSERT INTO `arp_doors` VALUES ('t|apartdoord', 'apartment_d');
INSERT INTO `arp_doors` VALUES ('t|apartdoorc', 'apartment_c');
INSERT INTO `arp_doors` VALUES ('t|house1', 'house_1');
INSERT INTO `arp_doors` VALUES ('t|ghousea', 'house_1');
INSERT INTO `arp_doors` VALUES ('t|apartdoorj', 'apartment_j');
INSERT INTO `arp_doors` VALUES ('t|apartdoorI', 'apartment_j');
INSERT INTO `arp_doors` VALUES ('t|housedoor1', 'house_1');
INSERT INTO `arp_doors` VALUES ('e|155', 'hotel_c');
INSERT INTO `arp_doors` VALUES ('e|480', 'hotel_b');
INSERT INTO `arp_doors` VALUES ('e|481', 'hotel_b');
INSERT INTO `arp_doors` VALUES ('e|145', 'hotel_a');
INSERT INTO `arp_doors` VALUES ('e|146', 'hotel_a');
INSERT INTO `arp_doors` VALUES ('e|645', 'seveneleven');
INSERT INTO `arp_doors` VALUES ('e|156', 'hotel_c');
INSERT INTO `arp_doors` VALUES ('e|102', 'apartment_a');
INSERT INTO `arp_doors` VALUES ('e|103', 'apartment_a');
INSERT INTO `arp_doors` VALUES ('e|101', 'apartment_b');
INSERT INTO `arp_doors` VALUES ('e|100', 'apartment_b');
INSERT INTO `arp_doors` VALUES ('e|366', 'mcmd');
INSERT INTO `arp_doors` VALUES ('e|310', 'apartment_c');
INSERT INTO `arp_doors` VALUES ('e|311', 'apartment_c');
INSERT INTO `arp_doors` VALUES ('t|apart_c_arms', 'apartment_c');
INSERT INTO `arp_doors` VALUES ('e|537', 'office_a');
INSERT INTO `arp_doors` VALUES ('e|399', 'office_a');
INSERT INTO `arp_doors` VALUES ('t|chur_confes', 'church');
INSERT INTO `arp_doors` VALUES ('e|881', 'apartment_g');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:22072593|Weed', '177');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:26393384|Harvest Tool', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4169250|Pizza', '2');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4169250|Hotdog', '4');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:22072593|Hamburger', '8');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4169250|Sony Ericsson', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:22072593|Sony Ericsson', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4027960|Nokia 6820', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:1777416|Hamburger', '4');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:11044486|Nokia 6820', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:7451286|Hamburger', '337');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:22072593|Harvest Tool', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:0:22072593|Weed Seed', '27');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:26393384|Hamburger', '332');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:1777416|Harvest Tool', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:7451286|Harvest Tool', '2');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:7451286|Weed Seed', '7');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:7451286|Weed', '5');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4169250|Weed', '4');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:4169250|Harvest Tool', '1');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:1777416|Weed', '20');
INSERT INTO `arp_items` VALUES ('STEAM_0:1:1777416|Pizza', '1');
INSERT INTO `arp_jobs` VALUES ('Unemployed', '5', '');
INSERT INTO `arp_jobs` VALUES ('Admin', '45', 'z');
INSERT INTO `arp_jobs` VALUES ('7/11 Employee', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('7/11 Clerk', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('7/11 Guard', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Bank Guard', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Bank Clerk', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Bank Manager', '25', 'a');
INSERT INTO `arp_jobs` VALUES ('Diner Waiter', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Diner Clerk', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Diner Chef', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Hotel Servant', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Hotel Employee', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Hotel Manager', '25', 'a');
INSERT INTO `arp_jobs` VALUES ('Priest', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Hitman', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Cleaner', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Hobo', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Guard', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Advertiser', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Teacher', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Postman', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Photographer', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Pizzaboy', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Journalist', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Taxi Driver', '10', 'a');
INSERT INTO `arp_jobs` VALUES ('Economist', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Student', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Professor', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Weapons Dealer', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Reporter', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Hippie', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Blacksmith', '15', 'a');
INSERT INTO `arp_jobs` VALUES ('Salesman', '20', 'a');
INSERT INTO `arp_jobs` VALUES ('Bodyguard', '30', 'e');
INSERT INTO `arp_jobs` VALUES ('MCMD Trainee', '15', 'm');
INSERT INTO `arp_jobs` VALUES ('MCMD Doctor', '20', 'm');
INSERT INTO `arp_jobs` VALUES ('MCMD Surgeon', '25', 'm');
INSERT INTO `arp_jobs` VALUES ('MCMD Lead Doctor', '30', 'm');
INSERT INTO `arp_jobs` VALUES ('a very dumb faggot', '-1000', 'f');
INSERT INTO `arp_jobs` VALUES ('MCPD Jail Guard', '15', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Receptionist', '15', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Trainee', '20', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Explorer', '25', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Officer', '30', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Senior Officer', '40', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Detective', '45', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Forensics Specialist', '45', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Sergeant', '55', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Lieutenant', '65', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Captain', '75', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Deputy Chief', '95', 'p');
INSERT INTO `arp_jobs` VALUES ('MCPD Chief of Police', '150', 'p');
INSERT INTO `arp_jobs` VALUES ('Piciotto', '30', 'l');
INSERT INTO `arp_jobs` VALUES ('Sgarrista', '35', 'l');
INSERT INTO `arp_jobs` VALUES ('Capodecima', '45', 'l');
INSERT INTO `arp_jobs` VALUES ('Caporegime', '50', 'l');
INSERT INTO `arp_jobs` VALUES ('Contabile', '50', 'l');
INSERT INTO `arp_jobs` VALUES ('Consigliere', '60', 'l');
INSERT INTO `arp_jobs` VALUES ('Don', '80', 'l');
INSERT INTO `arp_jobs` VALUES ('Godfather', '100', 'l');
INSERT INTO `arp_jobs` VALUES ('Capo Di Tutti Capi', '180', 'l');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Dragon Head', '70', 'b');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Dai Lo', '60', 'b');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Operations Officer', '50', 'b');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Enforcer', '20', 'b');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Gangster', '10', 'b');
INSERT INTO `arp_jobs` VALUES ('Black Dragons Follower', '8', 'b');
INSERT INTO `arp_jobs` VALUES ('Mayor', '160', 'g');
INSERT INTO `arp_jobs` VALUES ('MCPD Assistant Chief', '80', 'p');
INSERT INTO `arp_jobs` VALUES ('Assistant Mayor', '150', 'g');
INSERT INTO `arp_jobs` VALUES ('City Judge', '80', 'g');
INSERT INTO `arp_jobs` VALUES ('Attorney General of State', '80', 'g');
INSERT INTO `arp_jobs` VALUES ('Attorney of State', '60', 'g');
INSERT INTO `arp_jobs` VALUES ('Head Congressman', '50', 'g');
INSERT INTO `arp_jobs` VALUES ('Congress Voter', '30', 'g');
INSERT INTO `arp_jobs` VALUES ('Taxman', '30', 'g');
INSERT INTO `arp_jobs` VALUES ('Town Jury', '20', 'g');
INSERT INTO `arp_jobs` VALUES ('Community Supporter', '10', 'g');
INSERT INTO `arp_jobs` VALUES ('Bar Bartender', '30', 'mt');
INSERT INTO `arp_jobs` VALUES ('Bar Bouncer', '25', 'mt');
INSERT INTO `arp_jobs` VALUES ('Bar Manager', '30', 'm');
INSERT INTO `arp_jobs` VALUES ('Chaffeur', '30', 't');
INSERT INTO `arp_jobs` VALUES ('Drug Dealer', '20', 't');
INSERT INTO `arp_jobs` VALUES ('Gunshop Worker', '20', 'el');
INSERT INTO `arp_jobs` VALUES ('Hotel Bellboy', '15', 'it');
INSERT INTO `arp_jobs` VALUES ('Hotel Clerk', '20', 'it');
INSERT INTO `arp_jobs` VALUES ('Lawyer', '20', 't');
INSERT INTO `arp_jobs` VALUES ('McDonalds Cashier', '15', 'nt');
INSERT INTO `arp_jobs` VALUES ('McDonalds Cook', '20', 'nt');
INSERT INTO `arp_jobs` VALUES ('McDonalds Manager', '30', 'n');
INSERT INTO `arp_jobs` VALUES ('MCMD Advanced Brain Surgeon', '80', 'b');
INSERT INTO `arp_jobs` VALUES ('MCMD Head Doctor', '65', 'b');
INSERT INTO `arp_jobs` VALUES ('MCMD Medic', '45', 'b');
INSERT INTO `arp_jobs` VALUES ('MCMD Nurse', '25', 'b');
INSERT INTO `arp_jobs` VALUES ('MCMD Paramedic', '35', 'b');
INSERT INTO `arp_jobs` VALUES ('MCPD Chief', '80', 'a');
INSERT INTO `arp_jobs` VALUES ('MCPD Trainer', '40', 'a');
INSERT INTO `arp_jobs` VALUES ('Porn Star', '20', 't');
INSERT INTO `arp_jobs` VALUES ('PxRP Daddy', '1337', 'abcdefghijklmnopqrstuvwxyz');
INSERT INTO `arp_jobs` VALUES ('S.W.A.T Experienced', '60', 'a');
INSERT INTO `arp_jobs` VALUES ('S.W.A.T Leader', '70', 'a');
INSERT INTO `arp_jobs` VALUES ('S.W.A.T Member', '55', 'a');
INSERT INTO `arp_jobs` VALUES ('S.W.A.T Rookie', '50', 'a');
INSERT INTO `arp_jobs` VALUES ('Spy', '30', 't');
INSERT INTO `arp_jobs` VALUES ('Stripper', '25', 'ft');
INSERT INTO `arp_jobs` VALUES ('Thief', '20', 't');
INSERT INTO `arp_jobs` VALUES ('Tower Guard', '25', 'gt');
INSERT INTO `arp_jobs` VALUES ('Tower Manager', '35', 'g');
INSERT INTO `arp_keys` VALUES ('STEAM_0:1:26393384|Admin');
INSERT INTO `arp_keys` VALUES ('STEAM_0:1:26393384|Admin Hideout');
INSERT INTO `arp_property` VALUES ('Swatbase', 'S.W.A.T', 'S.W.A.T', '', '0', '0', 'efj', '250');
INSERT INTO `arp_property` VALUES ('Swatbas', 'S.W.A.T', 'S.W.A.T', '', '0', '0', 'efj', '2');
INSERT INTO `arp_property` VALUES ('Diner', 'Diner', '', '', '350000', '0', 'efj', '250');
INSERT INTO `arp_property` VALUES ('Apt E', 'Apt E', 'FaLLeNGrAcE \'Jeff\'', 'STEAM_0:1:4169250', '300000', '1', 'efj', '0');
INSERT INTO `arp_property` VALUES ('S.W.A.T Base', 'S.W.A.T', 'FaLLeNGrAcE \'Jeff\'', 'STEAM_0:1:4169250', '0', '1', 'acefglnr', '0');
INSERT INTO `arp_property` VALUES ('aptag', 'Apartment G', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('aptaa', 'Apartment A', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('aptab', 'Apartment B', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('WaWa', 'WaWa', '', '', '500000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('7/11', '7-Eleven', 'City of Mecklenburg', 'COM', '0', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('box1', 'Box 1', '', '', '75000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('box2', 'Box 2', '', '', '75000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('1337', '1337', '', '', '500000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('box3', 'Box 3', '', '', '75000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Admin Hideout', 'Admin Hideout.', 'FaLLeNGrAcE \'Jeff\'', 'STEAM_0:1:4169250', '0', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hideout 2', 'Hideout 2', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hideout 3', 'Hideout 3', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Black Market', 'Black Market', 'La Costa Nostra', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Apartment E', 'Apartment E', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hotel Lobby', 'Hotel Lobby', 'Jeff', '', '0', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hotel A', 'Hotel A', '', '', '250000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hotel B', 'Hotel B', '', '', '250000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hotel C', 'Hotel C', '', '', '250000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hotel D', 'Hotel D', '', '', '250000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Le Spa', 'Le Spa', '', '', '300000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Hideout 4', 'Black Dragons', 'Armory', 'STEAM_0:1:7451286', '0', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Admin', 'Admin', 'FaLLeNGrAcE \'Jeff\'', 'STEAM_0:1:4169250', '0', '500', 'z', '0');
INSERT INTO `arp_property` VALUES ('Mecklenburg  Police Department', 'Mecklenburg Police Department', 'MCPD', '', '0', '1', '', '0');
INSERT INTO `arp_property` VALUES ('MCPD', 'MCPD', '', '', '0', '1', 'p', '0');
INSERT INTO `arp_property` VALUES ('Bank', 'Bank', '', '', '0', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Chase Bank', 'Chase bank', '', '', '0', '1', 'a', '250');
INSERT INTO `arp_property` VALUES ('Hideout 5', 'Hideout 5', '', '', '350000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Meth Shack', 'Meth Shack', '', '', '100000', '1', 'z', '0');
INSERT INTO `arp_property` VALUES ('Mecklenburg City Hospital', 'Mecklenburg City Hospital', '', '', '0', '1', 'm', '0');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:4169250', '455525', '0', 'MCMD Doctor', '30', 'z', 'abcdefghijklmnopqrstuvwxz');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:19845991', '3420', '0', 'MCPD Officer', '390', 'abcdefghijklmnopqrstuvwxyz', 'abcdefghijklmnopqrstuvwxyz');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:13642020', '10', '0', 'Unemployed', '30', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:22072593', '5830', '0', 'Caporegime', '310', 'lz', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:2781341', '10', '2000', 'Unemployed', '20', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:26423993', '700', '0', 'MCPD Explorer', '260', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:118099', '1720', '0', 'MCPD Lieutenant', '720', '', 'p');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:2128612', '110', '2000', 'Unemployed', '120', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:26393384', '15840', '0', 'Godfather', '690', 'z', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:5270800', '150', '0', 'Unemployed', '140', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:4027960', '1225', '0', 'MCPD Forensics Specialist', '250', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:1650008', '230', '2000', 'Unemployed', '270', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:14433534', '30', '2000', 'Unemployed', '30', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:11044486', '2515', '0', 'MCPD Officer', '680', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:4710487', '10', '0', 'Unemployed', '30', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:7451286', '5460', '0', 'Black Dragons Dragon Head', '90', '', 'b');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:7231089', '5', '2000', 'Unemployed', '0', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:1777416', '4745', '0', 'Bank Manager', '100', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:9339662', '15', '2000', 'Unemployed', '30', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:2969949', '5', '0', 'Unemployed', '10', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:20734595', '20', '2000', 'Unemployed', '10', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:1438526', '-1990', '0', 'a very dumb faggot', '50', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:20475049', '0', '2000', 'Unemployed', '0', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:10636106', '90', '0', 'Unemployed', '110', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:14482883', '5', '2000', 'Unemployed', '20', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:12046066', '5', '2000', 'Unemployed', '0', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:6607223', '60', '0', 'Unemployed', '60', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:820547', '0', '2000', 'Unemployed', '0', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:809854', '5', '2000', 'Unemployed', '10', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:3831639', '105', '0', 'Unemployed', '150', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:1:6997246', '10', '2000', 'Unemployed', '10', '', '');
INSERT INTO `arp_users` VALUES ('STEAM_0:0:780395', '10', '2000', 'Unemployed', '0', '', '');
