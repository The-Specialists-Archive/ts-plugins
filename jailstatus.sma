/*=======================================*\
|* JailStatus                            *|
|*=======================================*|
|* ©Copyright 2006 by James J. Kelly Jr. *|
\*=======================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <engine_stocks>
#include <string>
#include <fun>
#include <harbu>

#define Author	"James J. Kelly Jr."
#define Version	"Beta"
#define Plugin	"Jail Status"

new bool:gPlayerDisplay[32];

new gPlayerJailTime[32];
new gPlayerJailCell[32];

new gJailPosition[4][3];
new Float:gJailRange[4];

new gJailString[512];

new mcpdjobs[2];

public plugin_init()
{

	register_plugin(Plugin,Version,Author);
	
	register_cvar("rp_jailhud_pos_x","1.0")	// X Position of EconomyHud on players screen
	register_cvar("rp_jailhud_pos_y","0")	// Y Position of EconomyHud on players screen
	register_cvar("rp_jailhud_red","200")		// Hud Colors
	register_cvar("rp_jailhud_green","0")
	register_cvar("rp_jailhud_blue","0")
	
	register_cvar("rp_jailstatus_position_jailone","-2710 2214 -314")	// Coordinates for Jails
	register_cvar("rp_jailstatus_position_jailtwo","-2710 2082 -314")
	register_cvar("rp_jailstatus_position_jailthree","-2710 1949 -314")
	register_cvar("rp_jailstatus_position_jailfour","-2710 1839 -314")
	
	register_cvar("rp_jailstatus_range_jailone","100.0")	// Coordinates for Jails
	register_cvar("rp_jailstatus_range_jailtwo","100.0")
	register_cvar("rp_jailstatus_range_jailthree","100.0")
	register_cvar("rp_jailstatus_range_jailfour","100.0")
	
	register_cvar("rp_jailstatus_jobid_mcpd","1 39");
	
	register_event("DeathMsg","client_death","a");
	
	register_clcmd("say /jailhud","jail_hud");
	
	server_cmd("exec addons/amxmodx/configs/jailstatus.cfg");
	server_cmd("exec addons/amxmodx/configs/HarbuRP/harbu_rp_config.cfg");
	
	cvar_to_array("rp_jailstatus_position_jailone",31,gJailPosition[0],3);
	cvar_to_array("rp_jailstatus_position_jailtwo",31,gJailPosition[1],3);
	cvar_to_array("rp_jailstatus_position_jailthree",31,gJailPosition[2],3);
	cvar_to_array("rp_jailstatus_position_jailfour",31,gJailPosition[3],3);
	
	cvar_to_array("rp_jailstatus_jobid_mcpd",31,mcpdjobs,2);
	
	gJailRange[0] = get_cvar_float("rp_jailstatus_range_jailone");
	gJailRange[1] = get_cvar_float("rp_jailstatus_range_jailtwo");
	gJailRange[2] = get_cvar_float("rp_jailstatus_range_jailthree");
	gJailRange[3] = get_cvar_float("rp_jailstatus_range_jailfour");
	
	set_task(1.0,"timer",0,"",0,"b");
		
}

public client_connect(id)
{

	gPlayerDisplay[id] = false;
	gPlayerJailTime[id] = 0;
	gPlayerJailCell[id] = 0;
		
}

public client_disconnect(id)
{
	
	gPlayerDisplay[id] = false;
	gPlayerJailTime[id] = 0;
	gPlayerJailCell[id] = 0;
	
}

public client_death()
{
	
	new id = read_data(2);

	gPlayerJailTime[id] = 0;
	gPlayerJailCell[id] = 0;
	
}
public updateJails()
{
 new job = get_user_job(id);
		
	if( job >= mcpdjobs[0] && job <= mcpdjobs[1] )
	{

	new player[32], playerCount;
	get_players(player,playerCount,"ac");
	
	format(gJailString,511," |Name | Cell | Minutes| ^n");
	
	for( new i = 0; i < playerCount; i++ )
	{
	
		new id = player[i];
		
		if( gPlayerJailTime[id] > 0 && gPlayerJailCell[id] > 0 )
		{
		
			new playerOrigin[3];
			get_user_origin(id,playerOrigin);
		
			new playerName[64];
			get_user_name(id,playerName,63);
			
			new jailTime = (gPlayerJailTime[id] / 60);
			
			new newLine[128];
			format(newLine,127," %s / %i / %i ^n",playerName,gPlayerJailCell[id],jailTime);
			add(gJailString,511,newLine);
				
		}
			
	}
	
	return PLUGIN_HANDLED;
		
}

public timer()
{
	
	updateJails();
	
	new player[32], playerCount;
	get_players(player,playerCount,"ac");
	
	for( new i = 0; i < playerCount; i++ )
	{
	
		new id = player[i];
		
		new playerOrigin[3];
		get_user_origin(id,playerOrigin);
		
		if( get_distance(playerOrigin,gJailPosition[0]) <= gJailRange[0] )
		{
			gPlayerJailTime[id] += 1;
			gPlayerJailCell[id] = 1;
		}
		else if( get_distance(playerOrigin,gJailPosition[1]) <= gJailRange[1] )
		{
			gPlayerJailTime[id] += 1;
			gPlayerJailCell[id] = 2;
		}
		else if( get_distance(playerOrigin,gJailPosition[2]) <= gJailRange[2] )
		{
			gPlayerJailTime[id] += 1;
			gPlayerJailCell[id] = 3;
		}
		else if( get_distance(playerOrigin,gJailPosition[3]) <= gJailRange[3])
		{
			gPlayerJailTime[id] += 1;
			gPlayerJailCell[id] = 4;
		}
		else
		{
			gPlayerJailTime[id] = 0;	
			gPlayerJailCell[id] = 0;
		}
		
		new job = get_user_job(id);
		
		if( gPlayerDisplay[id] && (job >= mcpdjobs[0] && job <= mcpdjobs[1]) )
		{
			
			set_hudmessage(get_cvar_num("rp_jailhud_red"),get_cvar_num("rp_jailhud_green"),get_cvar_num("rp_jailhud_blue"),get_cvar_float("rp_jailhud_pos_x"),get_cvar_float("rp_jailhud_pos_y"),0,0.0,99.9,0.0,0.0,4)
			show_hudmessage(id,gJailString);
			
		}
		else
		{
			
			set_hudmessage(get_cvar_num("rp_jailhud_red"),get_cvar_num("rp_jailhud_green"),get_cvar_num("rp_jailhud_blue"),get_cvar_float("rp_jailhud_pos_x"),get_cvar_float("rp_jailhud_pos_y"),0,0.0,99.9,0.0,0.0,4)
			show_hudmessage(id,"");
			
		}
			
	}
	
	return PLUGIN_HANDLED;
		
}