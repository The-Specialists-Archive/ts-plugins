//////////////////////////
//    Made for RDRP     //
//    by Shin Lee       //
//    06.04.2007        //
//////////////////////////

//this simple plugin allows public peoples take hostages


#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>

new hostage[33]

public plugin_init()
{
	//Register plugin
	register_plugin("cuff/gunsearch", "x.6", "Shin Lee")
	
	//Client Command
	register_clcmd("say /hostage", "cmd_thostage")
        register_clcmd("say /unhostage", "cmd_restore")
        register_clcmd("say /searchgun", "cmd_searchwep")
}
public cmd_thostage(id)
{
	new target,hitbox,Float:distance
	distance = get_user_aiming(id,target,hitbox,9999)

	if(!is_user_alive(target) || !is_user_connected(target))
		return PLUGIN_HANDLED;

	if(!is_user_alive(id))
		return PLUGIN_HANDLED;

	if(distance <= 100.0)
	{
		new name[32],tname[32]
		get_user_name(id,name,31)
		get_user_name(target,tname,31)
                hostage[target] = 1
        	for(new i=1;i<=35;i++)
	{
		client_cmd(target,"weapon_%d; drop",i)
	}
		//cuff Action
                set_user_rendering(target,kRenderFxGlowShell,0,0,255,kRenderNormal,25)
	        set_user_maxspeed(target,get_user_maxspeed(id)-200.0)
		client_print(target,print_chat,"[PubCuff] You have been cuffed by %s!",name)
		client_print(id,print_chat,"[PubCuff] You have cuffed %s!",tname)
	}
	return PLUGIN_HANDLED;
}
public cmd_restore(id)
{
	new target,hitbox,Float:distance
	distance = get_user_aiming(id,target,hitbox,9999)

	if(!is_user_alive(target) || !is_user_connected(target))
		return PLUGIN_HANDLED;

	if(!is_user_alive(id))
		return PLUGIN_HANDLED;

	if(distance <= 100.0)
	{
		new name[32],tname[32]
		get_user_name(id,name,31)
		get_user_name(target,tname,31)
                hostage[target] = 0

		//uncuff Action
		set_user_rendering(target,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	        set_user_maxspeed(target,get_user_maxspeed(id)+200.0)
		client_print(target,print_chat,"[PubCuff] You have been uncuffed by %s!",name)
		client_print(id,print_chat,"[PubCuff] You have uncuffed %s!",tname)
	}
	return PLUGIN_HANDLED;
}
public cmd_searchwep(id)
{
	new target,hitbox,Float:distance
	distance = get_user_aiming(id,target,hitbox,9999)

	if(!is_user_alive(target) || !is_user_connected(target))
		return PLUGIN_HANDLED;

	if(!is_user_alive(id))
		return PLUGIN_HANDLED;

	if(distance <= 100.0)
	{
		new name[32],tname[32]
		get_user_name(id,name,31)
		get_user_name(target,tname,31)
        	for(new i=1;i<=35;i++)
	{
		client_cmd(target,"weapon_%d; drop",i)
	}
		//search Action
                client_print(target,print_chat,"[GunSearch] %s is searching you for guns!",name)
		client_print(id,print_chat,"[GunSearch] You searching %s for guns!",tname)
	}
	return PLUGIN_HANDLED;
}
// To stop user Jump/Kick/Hit/Press buttons etc...
public client_PreThink(target)
{
	if(!is_user_alive(target)) return PLUGIN_CONTINUE
	if(hostage[target] == 1)
	{
		new bufferstop = entity_get_int(target,EV_INT_button)

		if(bufferstop != 0) {
			entity_set_int(target,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE)
		}

		if((bufferstop & IN_JUMP) && (entity_get_int(target,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) {
			entity_set_int(target,EV_INT_button,entity_get_int(target,EV_INT_button) & ~IN_JUMP)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
