#include <amxmodx>
#include <amxmisc>
#include <fun>

// I'm coding this, for all those who are in need of it.
// Enjoy, +karma plz
// Made May 02, 2006, by Smokey485

#define HEAL_ACCESS ADMIN_SLAY

new timeout[33];

public plugin_init()
{
	register_plugin("amx_heal by Smokey485", "1.1", "Smokey")
	register_srvcmd("item_heal", "item_heal") // for any ItemMod for a game like The Specialists Roleplay
	register_concmd("amx_heal", "heal_player", HEAL_ACCESS, "amx_heal <part of nick> <amount>")
	
	register_cvar("amx_heal_timeout", "0") // to prevent spamming amx_heal if set to '1'
	register_cvar("amx_heal_negative", "1") // Allow healing people negative health?
	register_cvar("amx_heal_maxhealth", "200000") // max health a person can have when being healed(default 100)
}

public heal_player(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	new arg[33], amount[33]
	read_argv(1, arg, 32)
	new target = cmd_target(id, arg, 7)
	read_argv(2, amount, 32) // str_to_num this later
	new health = get_user_health(id) // health
	if(get_cvar_num("amx_heal_timeout") == 1)
	{
		if(timeout[id] == 1)
		{
			console_print(id, "[HEAL] You cannot heal players so often, try again in a few seconds.")
			return PLUGIN_HANDLED;
		}
	}
	if(get_cvar_num("amx_heal_negative") == 0)
	{
		if(str_to_num(amount) < 1)
		{
			console_print(id,"[HEAL] You cannot heal players a negative amount.")
			return PLUGIN_HANDLED;
		}
	}
	new numamount = str_to_num(amount) // Turn the string into a number
	new maxhealth = get_cvar_num("amx_heal_maxhealth")
	new healthmaxed
	if(health + numamount > maxhealth)
	{
		set_user_health(target, maxhealth)
		console_print(id, "[HEAL] Player healed to maximum health of %s.", maxhealth)
		healthmaxed = 1
	}
	if(healthmaxed == 0)
	{
		set_user_health(target, health+numamount) // confusing? nah.
	}
	healthmaxed = 0
	
	timeout[id] = 1
	set_task(2.0, "un_timeout", id)
	
	new targetname[33], myname[33]
	
	get_user_name(target,targetname,32)
	get_user_name(id, myname, 32)
	
	console_print(id, "[HEAL] You healed player %s with %i health points.", targetname, numamount)
	
	new authid[33]
	get_user_authid(id,authid, 32)
	
	log_amx("(%s) %s Healed %s with %i health points.", authid, myname, targetname, numamount)
	
	if(get_cvar_num("amx_show_activity") == 1)
	{
		//client_print(0,print_chat,"ADMIN: Heal %s with %i health.", targetname, numamount)
		return PLUGIN_HANDLED;
	}
	
	if(get_cvar_num("amx_show_activity") == 2)
	{
		//client_print(0, print_chat, "ADMIN %s: Heal %s with %i health.", myname, targetname, numamount)
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public un_timeout(id)
{
	timeout[id] = 0;
	return PLUGIN_HANDLED;
}

// because this portion of this code might not even work, Im not bothering on making it easier to read, but its there //because it might work :)
// usage of this piece of crap: item_heal <id> amount, example: amx_heal <id> 100 would heal the user of item 100 health.
public item_heal() // this might not work.
{
	new arg[33]
	new id
	read_argv(1, arg, 32)
	id = str_to_num(arg)
	if(!is_user_connected(id)) // if for some reason the user isn't connected(wtf?)
	{
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(id))
	{
		client_print(id,print_chat,"[HEAL] You cannot heal when dead. Sorry, you are not god.")
		return PLUGIN_HANDLED;
	}
	new amount[33]
	read_argv(2, amount, 32)
	if(str_to_num(amount) + get_user_health(id) > 100)
	{
		set_user_health(id, 100)
	}
	if(str_to_num(amount) + get_user_health(id) <= 100)
	{
		set_user_health(id, get_user_health(id)+str_to_num(amount))
		client_print(id,print_chat,"[HEAL] You heal yourself %i hp.", str_to_num(amount))
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}