// Give Weapon - Remo Williams - The Specialists
// Flag 'M" To Use
// Usage: amx_giveweapon <GunID> <Ammo> <Attachments> 
// -----: amx_weaponlist - Displays a full list of weapons for ts, and attachment flags.
////////////////////////////////// 
// Change Log
////////////////////////////////////////////////////////// 
// 1.0 - First Release
// 1.1 - Fixed Compile Bug W/AMXX Update
////////////////////////////////////////////////////////// 

#include <amxmodx>
#include <amxmisc>
#include <tsfun>


public plugin_init() {
	register_plugin("Remo's Weapon Dealer Plugin","1.1","Remo Williams")
	register_concmd("amx_giveweapon","item_weapondeal",ADMIN_LEVEL_A," - <Weapon ID> <Ammo> <Attachments> Gives player weapon.")
	register_concmd("amx_weaponlist","showweapons",0," - Prints Console List of All Weapons, Etc.")
}
///////////////////////////
//Weapon Mod
///////////////////////////
public item_weapondeal(id) {
	if(!(get_user_flags(id) & ADMIN_LEVEL_A)) {
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}
	new arg[32], arg2[32], arg3[32], gunid, ammo, attach
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	gunid = str_to_num(arg)
	ammo = str_to_num(arg2)
	attach = str_to_num(arg3)
	
	if(gunid == 0) {
		client_print(id,print_console,"Gunid missing^n")
		return PLUGIN_HANDLED
	}
	if(ammo == 0) {
		client_print(id,print_console,"Ammo missing^n")
		return PLUGIN_HANDLED
	}
	
	ts_giveweapon(id,gunid,ammo,attach)
	return PLUGIN_HANDLED
}

public showweapons(id){
	client_print(id,print_console," 1: Glock 18^n 3: Mini Uzi^n 4: Benelli M3^n 5: M4A1^n 6: MP5SD^n 7: MP5K^n 8: Akimbo Berettas^n 9: Socom Mk23^n")
	client_print(id,print_console," 11: Usas12^n 12: Desert Eagle^n 13: Ak47^n 14: FiveSeven^n 15: Steyr Aug^n 17: Steyr Tmp^n 18: Barrett M82^n 19: HK Pdw^n ")
	client_print(id,print_console,"20: Spas12^n 21: Akimbo colts^n 22: Glock 20^n 23: UMP^n 25: Combat Knife^n 26: Mossberg 500^n 27: M16A4^n 28: Ruger Mk1^n 24: M61 Grenade^n ")
	client_print(id,print_console,"29: C4 - Does Not Work^n 31: Raging Bull^n 32: M60^n 33: Sawed off^n 34: Katana^n 35: Seal Knife^n^n ")
	client_print(id,print_console,"Attachments:^n ")
	client_print(id,print_console,"1: Silencer^n 2: LaserSight^n 4: Flashlight^n 8: Scope^n")
	return PLUGIN_HANDLED
}
