/* CS "Hack" constants
*
* by Damaged Soul
*
* This file is provided as is (no warranties).
*/

#if defined _cshack_const_included
  #endinput
#endif
#define _cshack_const_included

/* Default item costs */
#define DEFAULT_COST_GLOCK18           400
#define DEFAULT_COST_USP               500
#define DEFAULT_COST_P228              600
#define DEFAULT_COST_DEAGLE            650
#define DEFAULT_COST_ELITE             800
#define DEFAULT_COST_FIVESEVEN         750
#define DEFAULT_COST_M3                1700
#define DEFAULT_COST_XM1014            3000
#define DEFAULT_COST_MAC10             1400
#define DEFAULT_COST_TMP               1250
#define DEFAULT_COST_MP5NAVY           1500
#define DEFAULT_COST_UMP45             1700
#define DEFAULT_COST_P90               2350
#define DEFAULT_COST_GALIL             2000
#define DEFAULT_COST_FAMAS             2250
#define DEFAULT_COST_AK47              2500
#define DEFAULT_COST_M4A1              3100
#define DEFAULT_COST_SCOUT             2750
#define DEFAULT_COST_SG552             3500
#define DEFAULT_COST_AUG               3500
#define DEFAULT_COST_AWP               4750
#define DEFAULT_COST_G3SG1             5000
#define DEFAULT_COST_SG550             4200
#define DEFAULT_COST_M249              5750
#define DEFAULT_COST_AMMO_338MAGNUM    125
#define DEFAULT_COST_AMMO_357SIG       50
#define DEFAULT_COST_AMMO_45ACP        25
#define DEFAULT_COST_AMMO_50AE         40
#define DEFAULT_COST_AMMO_556NATO      60
#define DEFAULT_COST_AMMO_57MM         50
#define DEFAULT_COST_AMMO_762NATO      80
#define DEFAULT_COST_AMMO_9MM          20
#define DEFAULT_COST_AMMO_BUCKSHOT     65
#define DEFAULT_COST_KEVLAR            650
#define DEFAULT_COST_ASSAULTSUIT       1000
#define DEFAULT_COST_FLASHBANG         200
#define DEFAULT_COST_HEGRENADE         300
#define DEFAULT_COST_SMOKEGRENADE      300
#define DEFAULT_COST_DEFUSER           200
#define DEFAULT_COST_NIGHTVISION       1250
#define DEFAULT_COST_SHIELD            2200

/* Default cvar limit values */
#define DEFAULT_ROUNDTIME_MIN          1.0
#define DEFAULT_ROUNDTIME_MAX          9.0
#define DEFAULT_FREEZETIME_MAX         60
#define DEFAULT_C4TIMER_MIN            10
#define DEFAULT_C4TIMER_MAX            90
#define DEFAULT_STARTMONEY_MIN         800
#define DEFAULT_STARTMONEY_MAX         16000
#define DEFAULT_RESTARTROUND_MAX       60

/* All items in CS that cost money, including weapons */
enum CsItems {
	// Pistols
	CSI_GLOCK18 = 0,
	CSI_USP,
	CSI_P228,
	CSI_DEAGLE,
	CSI_ELITE,
	CSI_FIVESEVEN,
	
	// Shotguns
	CSI_M3,
	CSI_XM1014,
	
	// SMGs
	CSI_MAC10,
	CSI_TMP,
	CSI_MP5NAVY,
	CSI_UMP45,
	CSI_P90,
	
	// Rifles
	CSI_GALIL,
	CSI_FAMAS,
	CSI_AK47,
	CSI_M4A1,
	CSI_SCOUT,
	CSI_SG552,
	CSI_AUG,
	CSI_AWP,
	CSI_G3SG1,
	CSI_SG550,
	
	// Machine Guns
	CSI_M249,
	
	// Ammo
	CSI_AMMO_338MAGNUM,
	CSI_AMMO_357SIG,
	CSI_AMMO_45ACP,
	CSI_AMMO_50AE,
	CSI_AMMO_556NATO,
	CSI_AMMO_57MM,
	CSI_AMMO_762NATO,
	CSI_AMMO_9MM,
	CSI_AMMO_BUCKSHOT,
	
	// Equipment
	CSI_KEVLAR,
	CSI_ASSAULTSUIT,
	CSI_FLASHBANG,
	CSI_HEGRENADE,
	CSI_SMOKEGRENADE,
	CSI_DEFUSER,
	CSI_NIGHTVISION,
	CSI_SHIELD
};