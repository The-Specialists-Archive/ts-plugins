/* 
Version 2.0
-Fixed major bug

Version 1.0
RealMod made
*/

#include <amxmodx>
#include <tsfun>
#include <fun>

new hit[33] = 0

public plugin_init()
{
	register_plugin("RealMod","FINAL","Wonsae")
	register_event("WeaponInfo","weapon_check","be")
	
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{
	if(!is_user_alive(attacker)) return PLUGIN_HANDLED
	if(!is_user_alive(victim)) return PLUGIN_HANDLED

	if(wpnindex == 36) return PLUGIN_HANDLED
	if(hitplace == HIT_RIGHTLEG || hitplace == HIT_LEFTLEG)
	{
		hit[victim] = 1
		set_user_maxspeed(victim, 200.0)
		set_task(10.0, "resetspeed", victim)
	}
	if(hitplace == HIT_LEFTARM || hitplace == HIT_RIGHTARM)
	{
		client_cmd(victim,"drop")
	}
	return PLUGIN_HANDLED
}

public resetspeed(id)
{
	set_user_maxspeed(id,320.0)
	hit[id] = 0
}

public weapon_check(id)
{
	if(hit[id] == 1)
	{
		set_user_maxspeed(id,200.0)
	}
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	client_cmd(id,"cl_realhud 0")
}
