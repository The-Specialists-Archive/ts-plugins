#include <amxmodx>
#include <amxmisc>

new bool:timeout[33];

public plugin_init()
{
	//Register plugin
	register_plugin("ShoveMod By Shin", "1.0", "Shin")
	
	//Client Command
	register_clcmd("say /shove", "cmd_shove")
}
public cmd_shove(id)
{
	if(timeout[id] == true)
	{
		client_print(id,print_chat,"[Shovemod] You can not spam shove!")
		return PLUGIN_HANDLED;
	}
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

		//Next Line by Shin
		client_cmd(target,"+back;wait;wait;wait;wait;wait;wait;wait;+alt1;wait;-alt1;wait;-back")
		client_print(target,print_chat,"[Shovemod] You have been shoved by %s!",name)
		client_print(id,print_chat,"[Shovemod] You have shoved %s!",tname)
		timeout[id] = true;
		set_task(1.0,"allow_shove",id)
	}
	return PLUGIN_HANDLED;
}
public allow_shove(id)
{
	timeout[id] = false;
	return PLUGIN_HANDLED;
}