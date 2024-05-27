#include <amxmodx>
#include <amxmisc>
#include <fun>

new bool:speed[33]
new bool:speedall

new speed_cvar

public plugin_init()
{
	register_plugin("Legal Speed Hack","2.0","GHW_Chronic")
	register_concmd("+speed2","plus_speed",ADMIN_LEVEL_C,"Speed Hack Bind: Bind Key +speed2 ")
	register_concmd("-speed2","minus_speed",ADMIN_LEVEL_C," Ignore This Command ")
	register_concmd("amx_speed","SetSpeed",ADMIN_LEVEL_C," <nick or @all> <1=on or 0=off> ")
	speed_cvar = register_cvar("speedhack_speed","1000")
	register_event("CurWeapon","curweap","be","1=1")
	register_event("ResetHUD","curweap","b")
	server_cmd("sv_maxspeed 100000000")
}

public client_disconnect(id) speed[id]=false

public curweap(id)
{
	if(is_user_alive(id) && (speed[id] || speedall))
	{
		client_cmd(id,"cl_forwardspeed %d",get_pcvar_num(speed_cvar))
		client_cmd(id,"cl_sidespeed %d",get_pcvar_num(speed_cvar))
		client_cmd(id,"cl_backspeed %d",get_pcvar_num(speed_cvar))
		set_user_maxspeed(id,9999999.0)
	}
}

public minus_speed(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	client_cmd(id,"cl_forwardspeed 400")
	client_cmd(id,"cl_sidespeed 400")
	client_cmd(id,"cl_backspeed 400")
	set_user_maxspeed(id,300.0)
	speed[id]=false
	return PLUGIN_HANDLED
}

public plus_speed(id,level,cid)
{
	if(!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}
	client_cmd(id,"cl_forwardspeed %d",get_pcvar_num(speed_cvar))
	client_cmd(id,"cl_sidespeed %d",get_pcvar_num(speed_cvar))
	client_cmd(id,"cl_backspeed %d",get_pcvar_num(speed_cvar))
	set_user_maxspeed(id,9999999.0)
	speed[id]=true
	return PLUGIN_HANDLED
}

public SetSpeed(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
	{
		return PLUGIN_HANDLED
	}

	new arg1[32],arg2[32]
	read_argv(1,arg1,31)
	read_argv(2,arg2,31)

	if(equali(arg1,"@all"))
	{
		if(str_to_num(arg2))
		{
			speedall=true
			for(new i=1;i<=32;i++) curweap(i)
	  		console_print(id,"[AMXX] Put Speed Hack enabled on everyone")
	  		client_print(0,print_chat,"[AMXX] An admin has enabled speedhack on everyone.")
		}
		else
		{
			speedall=false
			for(new i=1;i<=32;i++) curweap(i)
	  		console_print(id,"[AMXX] Put Speed Hack disabled off of everyone")
	  		client_print(0,print_chat,"[AMXX] An admin has disabled speedhack off of everyone.")
		}
	}
	else
	{
		new player = cmd_target(id,arg1,3)
		if(!player)
			return PLUGIN_HANDLED

		new pName[32]
		get_user_name(player,pName,31)
		if(str_to_num(arg2))
		{
			if(!speed[player])
			{
				client_cmd(player,"cl_forwardspeed %d",get_pcvar_num(speed_cvar))
				client_cmd(player,"cl_sidespeed %d",get_pcvar_num(speed_cvar))
				client_cmd(player,"cl_backspeed %d",get_pcvar_num(speed_cvar))
				set_user_maxspeed(player,9999999.0)
				speed[player]=true
				console_print(id,"[AMXX] Put Speed Hack On %s",pName)
				client_print(player,print_chat,"[AMXX] An admin has given %s speed hack.",pName)
			}
			else
			{
				console_print(id,"[AMXX] %s already has speed hack.",pName)
			}
		}
		else
		{
			if(speed[player])
			{
				client_cmd(player,"cl_forwardspeed 400")
				client_cmd(player,"cl_sidespeed 400")
				client_cmd(player,"cl_backspeed 400")
				set_user_maxspeed(player,300.0)
				speed[player]=false
				console_print(id,"[AMXX] %s No Longer Has Speed Hack",pName)
				client_print(player,print_chat,"[AMXX] An admin took %s's speed hack away.",pName)
			}
			if(!speed[player])
			{
				console_print(id,"[AMXX] %s doesn't have speed hack.",pName)
			}
		}
	}
	return PLUGIN_HANDLED
}
