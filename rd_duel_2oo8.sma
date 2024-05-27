///////////////////////////////////////////////////
// Red Dragon Duel System 2oo8 by Shin Lee
// www.red-dragon-rp.com (copy and i cut ur cock)
///////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <fun>
#include <tsx>
#include <tsfun>

#define PLUGIN "-RD- Duel-System"
#define VERSION "x.21"
#define AUTHOR "Shin Lee"

// Menu Defines
#define Keysrdmenu (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 123450

//--- Aura ---
new aura, aura1
//new moonaura, sunaura

//--- Katana ---
new katana_vmodel[] = "models/duel/v_katana_admin.mdl"
new katana_pmodel[] = "models/duel/p_katana_admin.mdl"

//--- Special Attacks ---
new fireballr, sunballr

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// Say Cmd´s
	register_clcmd("say","handlesay",-1); 
	
	// Menu
	register_menucmd(register_menuid("rdmenu"), Keysrdmenu, "Pressedrdmenu");
	
	// Hud Cvars
	register_cvar("duel_hud_red","255")      // Hud Colors
	register_cvar("duel_hud_green","0")
	register_cvar("duel_hud_blue","0")
	
	// Change Gamename
	register_cvar( "amx_gametype", "Duel" )
	register_forward( FM_GetGameDescription, "GameType" )
	
	// Events
	register_event("WeaponInfo", "event_WeaponInfo", "b", "1=34")
	
	// Print Console
	console_print(0,"*** Succesfully Loaded Shin's -RD- Duel-System %s ***",VERSION)
	
	// Tasks
	set_task(2.0,"activehud",0,"",0,"b")
	//set_task(2.0,"playerlook",0,"",0,"b")
	set_task(3.0,"mapchanger",0,"",0,"b")
}
public plugin_precache() 
{
	aura = precache_model("models/chakra_aura_test.mdl")
	aura1 = precache_model("models/lightningaura1.mdl")
	//moonaura = precache_model("models/Circle_Power.mdl")
	//sunaura = precache_model("models/Circle_Shadow.mdl")
	precache_model(katana_vmodel)
	precache_model(katana_pmodel)
	fireballr = precache_model("sprites/fireworks/rflare.spr")
	sunballr = precache_model("sprites/yelflare1.spr")
	precache_sound("harburp/fireball.wav")	
}
//active hud (see your infos)
public activehud(id)
{
	new playername[33],authid[32],num,players[32]
	get_players(players,num,"ac")
	for(new i=0; i<num; i++)
	{
		get_user_authid(players[i],authid,31)
		get_user_name(players[i],playername,sizeof(playername))
		new kills,death,health
		{
			kills = get_user_frags(players[i])
			death = get_user_deaths(players[i])
			health = get_user_health(players[i])
			{
				set_hudmessage(get_cvar_num("duel_hud_red"),get_cvar_num("duel_hud_green"),get_cvar_num("duel_hud_blue"),-1.9,-10.0,0,0.0,99.9,0.0,0.0,1)
				show_hudmessage(players[i], "-----Red Dragon----- ^n www.red-dragon-rp.com ^n ------------------ ^n Name: %s ^n Health: %i ^n Kills: %i ^n Deaths: %i ^n ------------------",playername,health,kills,death)
			}

		}

	}
	return PLUGIN_HANDLED
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
	if(is_user_alive(id) == 0) {
		return PLUGIN_CONTINUE;
		
	}
	if(equali(arg1,"/aura") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		rd_attachsprite(id,aura,600)
		
		client_print(id,print_chat," * [Red dragon] You feel much better now!")
		set_user_health(id, 1000) // OMG ^^
		
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/aura2") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		rd_attachsprite(id,aura1,600)
		
		client_print(id,print_chat," * [Red dragon] You feel like Heeeeman!")
		set_user_health(id, 100000) // OMG ^^
		
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/firebeam") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		firebeam(id)
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/sunbeam") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		sunbeam(id)
		return PLUGIN_HANDLED
	}
	if(equali(arg1,"/rdmenu") == 1) 
	{
		if(access(id, ADMIN_IMMUNITY))
		Showrdmenu(id)
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
		set_hudmessage(get_cvar_num("duel_hud_red"),get_cvar_num("duel_hud_green"),get_cvar_num("duel_hud_blue"),-1.0,0.4,0,0.0,3.9,0.0,0.0,3) 
		show_hudmessage(0, "WARNING: Server is restarting in 5 seconds!!!")
		set_task(5.0,"restart_him",0,"",0,"b")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public rd_attachsprite(id,sprite,timer) 
{
	message_begin(MSG_ALL,SVC_TEMPENTITY);	
	write_byte(124)       // attaches a TENT to a player (this is a high-priority tent)
	write_byte(id)// byte (entity index of player)
	write_coord(0)   // coord (vertical offset) ( attachment origin.z = player origin.z + vertical offset )
	write_short(sprite)       // short (model index)
	write_short(timer)      // short (life * 10 ); 
	message_end();
}

public Showrdmenu(id) 
{
	show_menu(id, Keysrdmenu, "---Red Dragon---^n^n1. Coming soon^n2. Coming soon^n3. Coming soon^n4. Coming soon^n5. Coming soon^n0. Exit", -1, "rdmenu") // Display menu
}
public Pressedrdmenu(id, key) 
{
	/* Menu:
	* 
	* 1. Coming soon
	* 2. Coming soon
	* 3. Coming soon
	* 4. Coming soon
	* 5. Coming soon
	* 
	* 0. Cancel
	*/
	
	switch (key) 
	{
		case 0: 
		{ // 1
			
			
		}
		case 1: 
		{ // 2

			
		}
		case 2: 
		{ // 3
			
		}
		case 3: 
		{ // 4

			
		}
		case 4: 
		{ // 5

			
		}
		case 9: 
		{ // 0
			
			
		}
	}
	
}
//change gametype
public GameType( ) 
{ 
     new gamename[32]; 
     get_cvar_string( "amx_gametype", gamename, 31 ); 
     forward_return( FMV_STRING, gamename ); 
     return FMRES_SUPERCEDE; 
} 
// Restart Server Task (used after 5 seconds)
public restart_him()
{
	server_cmd("restart")
	return PLUGIN_HANDLED
}
// Change Admin Katana
public event_WeaponInfo(id)
{
    new num, players[32],authid[32]
    get_players(players,num,"ac")
    for( new i = 0;  i < num; i++ )
    get_user_authid(players[i],authid,31)
    if(access(id, ADMIN_IMMUNITY))
    {
    	set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, katana_vmodel))
    }
    if(access(id, ADMIN_IMMUNITY))
    {
    	set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, katana_pmodel))
    }
    return PLUGIN_HANDLED
}
public firebeam(id)
{
          if(access(id, ADMIN_IMMUNITY))
	 {
		new origin[3], origin2[3], targetid, entbody
	
		get_user_aiming(id,targetid,entbody,999999)
		if(!is_user_alive(targetid)) return PLUGIN_HANDLED
	
		get_user_origin(id,origin)
		get_user_origin(targetid,origin2)
		
		basic_firebolt(origin,origin2,10)
		basic_shake(targetid,8,12)
	
		emit_sound(id, CHAN_ITEM, "harburp/fireball.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
		set_user_health(targetid,get_user_health(targetid)-40)
	
	         for(new i=1;i<=37;i++)
		{
			client_cmd(targetid,"weapon_%d; drop",i)
		}
		client_print(id,print_chat,"[Red Dragon] You have shot a Fire Beam Attack.")
	}
	return PLUGIN_HANDLED
}
public sunbeam(id)
{
          if(access(id, ADMIN_IMMUNITY))
	 {
		new origin[3], origin2[3], targetid, entbody
	
		get_user_aiming(id,targetid,entbody,999999)
		if(!is_user_alive(targetid)) return PLUGIN_HANDLED
	
		get_user_origin(id,origin)
		get_user_origin(targetid,origin2)
		
		basic_firebolt(origin,origin2,10)
		basic_shake(targetid,8,12)
	
		emit_sound(id, CHAN_ITEM, "harburp/fireball.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
		set_user_health(targetid,get_user_health(targetid)-80)
	
	         for(new i=1;i<=37;i++)
		{
			client_cmd(targetid,"weapon_%d; drop",i)
		}
		client_print(id,print_chat,"[Red Dragon] You have shot a Sun Beam Attack.")
	}
	return PLUGIN_HANDLED
}
public mapchanger()
{
	new g_map[32] 
	get_mapname(g_map,31)
	
	if(equali(g_map,"CarolinCity_b1"))
	{
		server_cmd("amx_map Duel_RD_4K_Dojo_Final")
	}
	return PLUGIN_HANDLED
}
stock basic_firebolt(s_origin[3],e_origin[3],life = 8)
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 0 )
	write_coord(s_origin[0])
	write_coord(s_origin[1])
	write_coord(s_origin[2])
	write_coord(e_origin[0])
	write_coord(e_origin[1])
	write_coord(e_origin[2])
	write_short(fireballr)
	write_byte( 1 ) // framestart
	write_byte( 5 ) // framerate
	write_byte( life ) // life
	write_byte( 20 ) // width
	write_byte( 30 ) // noise
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // brightness
	write_byte( 200 ) // speed
	message_end()
	
	message_begin( MSG_PVS, SVC_TEMPENTITY,e_origin)
	write_byte( 9 )
	write_coord( e_origin[0] )
	write_coord( e_origin[1] )
	write_coord( e_origin[2] )
	message_end()
	return PLUGIN_HANDLED
}
stock basic_sunbolt(s_origin[3],e_origin[3],life = 8)
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 0 )
	write_coord(s_origin[0])
	write_coord(s_origin[1])
	write_coord(s_origin[2])
	write_coord(e_origin[0])
	write_coord(e_origin[1])
	write_coord(e_origin[2])
	write_short(sunballr)
	write_byte( 1 ) // framestart
	write_byte( 5 ) // framerate
	write_byte( life ) // life
	write_byte( 20 ) // width
	write_byte( 30 ) // noise
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // brightness
	write_byte( 200 ) // speed
	message_end()
	
	message_begin( MSG_PVS, SVC_TEMPENTITY,e_origin)
	write_byte( 9 )
	write_coord( e_origin[0] )
	write_coord( e_origin[1] )
	write_coord( e_origin[2] )
	message_end()
	return PLUGIN_HANDLED
}
// Shaking a users screen
stock basic_shake(id,amount = 14, length = 14)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, id)
	write_short(255<< amount ) //ammount 
	write_short(10 << length) //lasts this long 
	write_short(255<< 14) //frequency 
	message_end()
}
