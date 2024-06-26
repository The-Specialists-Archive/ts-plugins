/* tfcX functions
 *
 * (c) 2004, SidLuke
 * This file is provided as is (no warranties).
 */

#if defined _tfcx_included
  #endinput
#endif
#define _tfcx_included

#include <tfcconst>
#include <tfcstats>

#pragma library tfcx

/************* Shared Natives Start ********************************/

/* Forward types */
enum {
  XMF_DAMAGE = 0,
  XMF_DEATH,
}

/* Use this function to register forwards */
native register_statsfwd( ftype );

/* Function is called after player to player attacks ,
* if players were damaged by teammate TA is set to 1 */
forward client_damage(attacker,victim,damage,wpnindex,hitplace,TA);

/* Function is called after player death ,
* if player was killed by teammate TK is set to 1 */
forward client_death(killer,victim,wpnindex,hitplace,TK);

/* Custom Weapon Support */
/* function will return index of new weapon */
native custom_weapon_add( wpnname[],melee = 0,logname[]="" ); 
/* Function will pass damage done by this custom weapon to stats module and other plugins */
native custom_weapon_dmg( weapon, att, vic, damage, hitplace=0 ); 
/* Function will pass info about custom weapon shot to stats module */
native custom_weapon_shot( weapon,index ); // weapon id , player id

/* function will return 1 if true */
native xmod_is_melee_wpn(wpnindex);

/* Returns weapon name. */
native xmod_get_wpnname(wpnindex,name[],len);

/* Returns weapon logname. */
native xmod_get_wpnlogname(wpnindex,name[],len);

/* Returns weapons array size */
native xmod_get_maxweapons();

/* Returns stats array size ex. 8 in TS , 9 in DoD */
native xmod_get_stats_size();

/* Returns 1 if true */
native xmod_is_custom_wpn(wpnindex);

/************* Shared Natives End ********************************/

stock tfc_isgrenade( weapon ){
  switch( weapon )
  {
    case TFC_WPN_CALTROP,
         TFC_WPN_CONCUSSIONGRENADE,
         TFC_WPN_NORMALGRENADE,
         TFC_WPN_NAILGRENADE,
         TFC_WPN_MIRVGRENADE,
         TFC_WPN_NAPALMGRENADE,
         TFC_WPN_GASGRENADE,
         TFC_WPN_EMPGRENADE:
      return 1;
    default: return 0;
  }
  return 0;
}

native tfc_userkill( index );

/* Use this function to set private data offsets if needed 
Default offsets:
	timer: 932
	sentrygun: 83
from AssKicR
	shells: 53
	bullets: 55
	cells: 57
	rockets: 59
	nade1: 14
	nade2: 15
*/
native tfc_setpddata(timer,sentrygun,shells,bullets,cells,rockets,nade1,nade2);

/*********************************************************************/

native 	tfc_setmodel(index, const Model[], const Skin[]);
native 	tfc_clearmodel(index);

/* Get amount of ammo in backpack on a user for a specific weapon */
/* Ammo Types in tfcconst.inc */
native 	tfc_getbammo(index, ammo);

/* Set amount of ammo in backpack on a user for a specific weapon */
native 	tfc_setbammo(index, ammo, value);

/* Returns amount of ammo in weapon's clip (backpack) */
/* Weapons list in tfcconst.inc */
native tfc_getweaponbammo(index, weapon);

/* Sets amount of ammo in weapon's clip (backpack) */
native tfc_setweaponbammo(index, weapon, value);