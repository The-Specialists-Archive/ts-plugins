 /////////////////////////////////
 //       Coded for RDRP        //
 //      Made by Shin Lee       //   
 /////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <tsx>
#include <engine_stocks>
#include <fun>
#include <tsfun>
 
// Defines
#define PLUGIN "-RD- TSRP Addons"
#define VERSION "x.21"
#define AUTHOR "Shin Lee"
 
 // Sit bool
 new sitting[33];
 // deathmessage disabler
 new dmcvar
 // for the farting =D
 new fartsmoke

public plugin_init()
{
 	// Register Plugin
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Say Commands
	register_clcmd("say","handlesay",-1); 
	
	// No Deathmessage
	dmcvar = register_cvar("amx_blockdeathmessage","1")
	register_message(get_user_msgid("DeathMsg"),"msg")
	
	// Print Console
	console_print(0,"*** Succesfully Loaded Shin's -RD- TSRP Addons %s ***",VERSION)
}
 
public plugin_precache() 
{ 
	//sound
	if (file_exists("sound/fart.wav"))
		precache_sound("fart.wav") 
	//models,sprites
	fartsmoke = precache_model("sprites/xsmoke1.spr");
	return PLUGIN_CONTINUE 
}

// put in Server
public client_putinserver(id)
{
	sitting[id] = 0;
}
public handlesay(id) 
{
	new arg[64], arg1[32], arg2[256];
	
	read_args(arg,63); // get text
	remove_quotes(arg); // remove quotes
	
	strtok(arg,arg1,255,arg2,255,' ',1); // split text into parts
	
	// eliminate extra spaces from the text
	trim(arg2); // our right side
	
	// if player is dead
	if(is_user_alive(id) == 0) 
	{
		return PLUGIN_CONTINUE;
		
	}
	if(equali(arg1,"/searchgun") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		cmd_searchwep(id)
		return PLUGIN_HANDLED;
	}
	if(equali(arg1,"/sit") == 1) 
	{
		sit(id)
		return PLUGIN_HANDLED;
	}
	/*if(equali(arg1,"/fart") == 1) 
	{
		fart_action(id)
		return PLUGIN_HANDLED;
	}*/
	if(equali(arg1,"/help") == 1) 
	{
		help(id)
		return PLUGIN_HANDLED;
	}
	if(equali(arg1,"/showcommands"))
	{
		motd_show(id,"rp_commands")
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/laws"))
	{
		motd_show(id,"rp_laws")
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/rules"))
	{
		motd_show(id,"rp_rules")
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/gunprice"))
	{
		motd_show(id,"rp_wprices")
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/givekatana") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		ts_giveweapon(id, 34, 0, 0)
		client_print(id,print_chat," * [Red dragon] You have put out a Katana!")
		return PLUGIN_HANDLED;
	}
	if(equali(arg1,"/restart") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		client_print(id,print_chat,"[Red Dragon] OK, the Server will restart in 5 seconds!")
		client_print(0,print_chat, "WARNING: Server is restarting in 5 seconds!!!")
		client_print(0,print_chat, "WARNING: Server is restarting in 5 seconds!!!")
		client_print(0,print_chat, "WARNING: Server is restarting in 5 seconds!!!")
		set_task(5.0,"restart_him",0,"",0,"b")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

// sit command
public sit(id)
{
	if(sitting[id])
	{
		sitting[id] = 0;
		client_cmd(id,"say /me stands up!;wait;-duck");
		client_print(id,print_chat,"[RD] You stand up!");
	}
	else
	{
		sitting[id] = 1;
		client_cmd(id,"say /me sits down!;wait;+duck");
		client_print(id,print_chat,"[RD] You sit down!");
	}

	return PLUGIN_HANDLED;
}
 
// Code for Help Commands menu
public help(id)
{
	new helpmotd[2000], len = sizeof(helpmotd) - 1
	format(helpmotd,len,"Please type in you chat the category your help belongs to^n^n^n")
	add(helpmotd,len,"/showcommands - To view all the commands the server has^n")
	add(helpmotd,len,"/rules - To view the server rules, obey them or get banned from our server^n")
	add(helpmotd,len,"/laws - Server laws if Police catch you breaking these you will get a fine and jailtime^n")
	show_motd(id,helpmotd,"Red Dragon RP - Help Index")
}

public motd_show(id,file[])
{
	new dir[256], addon[32]
	get_configsdir(dir,255)
	format(addon,31,"/rdrp/%s.txt",file)
	add(dir,255,addon)
	show_motd(id,dir,"Red Dragon RP")
}

// Kill Deathmessage
public msg() {
	if(get_pcvar_num(dmcvar)) return PLUGIN_HANDLED // block
	return PLUGIN_CONTINUE // dont block
}

// SearchScript || to search a user for weapons
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
        	for(new i=1;i<=37;i++)
	{
		client_cmd(target,"weapon_%d; drop",i)
	}
		//search Action
		client_print(target,print_chat,"[RD] %s is searching you for guns!",name)
		client_print(id,print_chat,"[RD] You searching %s for guns!",tname)
	}
	return PLUGIN_HANDLED;
}
// Farting Stuff
//fart action
public fart_action(id)
{
	
	{
		client_cmd(id,"say /me Farts Loudly!");
		client_print(id,print_chat,"[RD] You Fart Loud!");
		emit_sound(id,CHAN_VOICE,"fart.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		fart_effect(id)
	}

	return PLUGIN_HANDLED;
}
//fart effect
public fart_effect(id)
{
	  new origin[3];
	  get_user_origin(id, origin, 0);
	  origin[1] = origin[1] -10;
	  message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	  write_byte(17);
	  write_coord(origin[0]);
	  write_coord(origin[1]);
	  write_coord(origin[2]);
	  write_short(fartsmoke);
	  write_byte(10);
	  write_byte(150);
	  message_end();
	  return PLUGIN_HANDLED;
}	
// Restart Server Task (used after 5 seconds)
public restart_him()
{
	server_cmd("restart")
	return PLUGIN_HANDLED
}		

