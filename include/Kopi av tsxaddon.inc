/*	TSX Addon Stocks
*
*	By: Avalanche, Twilight Suzuka and Harbu
*
*/

#include <tsx>
#include <tsfun>
#include <fakemeta>
#include <engine>

#if defined _tsxaddon_included
  #endinput
#endif
#define _tsxaddon_included


 // Avalanches Ammo Code (Thanks for letting me use it)
 // Set a user's ammo amount
 public ts_setuserammo(id,weapon,ammo) {

   // Kung Fu
   if(weapon == 36) {
     client_cmd(id,"weapon_0"); // switch to kung fu
     return 0; // stop now
   }

   // Invalid Weapon
   if(weapon < 0 || weapon > 35) {
     return 0; // stop now
   }

   client_cmd(id,"weapon_%d",weapon); // switch to whatever weapon

   // C4 or Katana
   if(weapon == 29 || weapon == 34) {
     return 0; // stop now
   }

   // TS AMMO OFFSETS
   new tsweaponoffset[36];
   tsweaponoffset[1] = 50;
   tsweaponoffset[3] = 50;
   tsweaponoffset[4] = 52;
   tsweaponoffset[5] = 53;
   tsweaponoffset[6] = 50;
   tsweaponoffset[7] = 50;
   tsweaponoffset[8] = 50;
   tsweaponoffset[9] = 51;
   tsweaponoffset[10] = 51;
   tsweaponoffset[11] = 52;
   tsweaponoffset[12] = 54;
   tsweaponoffset[13] = 53;
   tsweaponoffset[14] = 56;
   tsweaponoffset[15] = 53;
   tsweaponoffset[16] = 50;
   tsweaponoffset[17] = 50;
   tsweaponoffset[18] = 57;
   tsweaponoffset[19] = 56;
   tsweaponoffset[20] = 52;
   tsweaponoffset[21] = 51;
   tsweaponoffset[22] = 58;
   tsweaponoffset[23] = 51;
   tsweaponoffset[24] = 354;
   tsweaponoffset[25] = 366;
   tsweaponoffset[26] = 52;
   tsweaponoffset[27] = 53;
   tsweaponoffset[28] = 59;
   tsweaponoffset[30] = 56;
   tsweaponoffset[31] = 61;
   tsweaponoffset[32] = 53;
   tsweaponoffset[33] = 52;
   tsweaponoffset[35] = 486;

   new currentent = -1, tsgun = 0; // used for getting user's weapon_tsgun

   // get origin
   new Float:origin[3];
   entity_get_vector(id,EV_VEC_origin,origin);

   // loop through "user's" entities (whatever is stuck to user, basically)
   while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0) {
     new classname[32];
     entity_get_string(currentent,EV_SZ_classname,classname,31);

     if(equal(classname,"weapon_tsgun")) { // Found weapon_tsgun
       tsgun = currentent; // remember it
     }

   }

   // Couldn't find weapon_tsgun
   if(tsgun == 0) {
     return 0; // stop now
   }

   // Get some of their current settings
   new currclip, currammo, currmode, currextra;
   ts_getuserwpn(id,currclip,currammo,currmode,currextra);

   set_pdata_int(tsgun,tsweaponoffset[weapon],ammo); // set their ammo

   // Grenade or knife, set clip
   if(weapon == 24 || weapon == 25 || weapon == 35) {
     set_pdata_int(tsgun,41,ammo); // special clip storage
     set_pdata_int(tsgun,839,ammo); // more special clip storage
     currclip = ammo; // change what we send to WeaponInfo
     ammo = 0; // once again, change what we send to WeaponInfo
   }
   else { // Not a grenade or knife, set ammo
     set_pdata_int(tsgun,850,ammo); // special ammo storage
   }

   // Update user's HUD
   message_begin(MSG_ONE,get_user_msgid("WeaponInfo"),{0,0,0},id);
   write_byte(weapon);
   write_byte(currclip);
   write_short(ammo);
   write_byte(currmode);
   write_byte(currextra);
   message_end();

   return 1; // wooh!
 }

 public set_entity_health(door,Float:hp)
{
	if(hp == -1.0) {
		entity_set_float(door,EV_FL_max_health,9999.0)
		entity_set_float(door,EV_FL_health,9999.0)
		entity_set_float(door,EV_FL_dmg,0.0)
		entity_set_float(door,EV_FL_takedamage,0.0)
		return 1
	}
	entity_set_float(door,EV_FL_max_health,hp)
	entity_set_float(door,EV_FL_health,hp)
	return 1 
}

// The actual creating process


// Creating Ambients
public create_ambient(porigin[3],targetname[],vol[],pitch[],spawnflags,file[])
{
	new ambient = create_entity("ambient_generic")

	if(!ambient) return PLUGIN_HANDLED

	entity_set_string(ambient,EV_SZ_classname,"ambient_generic")
	entity_set_int(ambient,EV_INT_spawnflags,spawnflags)
	entity_set_float(ambient,EV_FL_health,10.0)
	entity_set_string(ambient,EV_SZ_targetname,targetname)
	entity_set_string(ambient,EV_SZ_message,file)

	DispatchKeyValue(ambient,"pitch",pitch)
	DispatchKeyValue(ambient,"volstart",vol)
	DispatchKeyValue(ambient,"pitchstart",pitch)
	DispatchSpawn(ambient)

	new Float:origin[3]
	origin[0] = float(porigin[0])
	origin[1] = float(porigin[1])
	origin[2] = float(porigin[2])

	entity_set_origin(ambient,origin)

	return PLUGIN_HANDLED
}