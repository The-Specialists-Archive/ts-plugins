#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <dbi>

#define MAXPLAYERS 32
#define CAR_SPEND 300
#define ITEMS 35
#define MAXCARKEYS 20
#define MAXIUMSTR 1024	
#define CARLICENSE 400
#define CARINSURANCE 401
#define licenseon 0
#define breakablecars 0

#if breakablecars == 1
#define CARINSURANCE 401
#endif
#if licenseon == 1
#define CARLICENSE 400
#endif

new const Plugin[] = "CarMod"
new const Version[] = "35.0"
new const Author[] = "Wonsae"

// Global variables
new g_incar[MAXPLAYERS + 1]
new Float:g_oldspeed[MAXPLAYERS + 1]
new Float:g_oldfric[MAXPLAYERS + 1]
new g_oldmodel[MAXPLAYERS + 1][33]
new g_carmodel[MAXPLAYERS + 1][33]
new g_usedcar[MAXPLAYERS + 1]
new g_iscop[MAXPLAYERS + 1]
new g_fine[MAXPLAYERS + 1]
new g_carseat[MAXPLAYERS + 1]
new g_carseats[MAXPLAYERS + 1][8]
new g_maxcarseats[MAXPLAYERS + 1]
new g_carstore[MAXPLAYERS + 1][2]
new Float:g_friction[MAXPLAYERS + 1]
new g_carspeed[MAXPLAYERS + 1]
new g_hasbomb[MAXPLAYERS + 1]
new g_SpriteExplosion
new g_usedlight[MAXPLAYERS + 1]
new gmsgItems
new g_car[MAXPLAYERS + 1]
new g_impounded[MAXPLAYERS + 1]
new g_key[MAXPLAYERS]
new spam[MAXPLAYERS]
new forced[MAXPLAYERS]
new g_hasnos[MAXPLAYERS]

// cvar stuff
new NOSspeed

//DBI varibles
new Sql:dbc
new Result:result
new query[256]

public plugin_init() 
{
	// Registers plugin name
	register_plugin(Plugin,Version,Author)
	
	// Commands
	register_clcmd("amx_ticket","givefine")
	
	register_clcmd("say /drive","car_in")
	register_clcmd("say /payticket","payfine")
	register_clcmd("say /removecar","removecar")
	register_clcmd("say /getout","car_seat_getout")
	register_clcmd("say /carmenu","car_menu")
	register_clcmd("say /impound","impound")
	register_clcmd("say /park","uncar")
	register_clcmd("say /radio","radio")
	register_clcmd("say /honk","horn")
	register_clcmd("say /siren","siren")
	register_clcmd("say /lights","headlights")
	register_clcmd("say /headlights","headlights")
	register_clcmd("amx_givecarkey","givekeyaccess")
	
	//Items
	register_srvcmd("item_car","item_car")
	register_srvcmd("item_gas","item_gas")
	register_srvcmd("item_carbomb","item_carbomb")
	register_srvcmd("item_repair","item_repair")
	register_srvcmd("item_hotwire","item_hotwire")
	register_srvcmd("item_engine","item_engine")
	register_srvcmd("item_neon","item_neon")
	register_srvcmd("item_nos","item_nos")
	
	// Cvars
	register_cvar("rp_police_start","1")
	register_cvar("rp_police_end","16")
	NOSspeed = register_cvar("rp_nos_speed","200")
	server_cmd("sv_maxspeed 1000")
	
	// Menus
	register_menu("CarMenu",1023,"car_menu_action",0)
	register_menu("Radio Menu",1023456789,"radio_menu",0)
	register_menu("CarInvite",1023,"car_invite_action",0)
	register_menu("CarKick",1023,"car_kick_action",0)
	
	// crashing system
	register_touch("player","player","crash")
	
	// Tasks
	set_task(1.0,"initcc",0,"",0,"b")
	set_task(1.0,"sql_init")
	set_task(1.0,"check_near_car",_,"",_,"b")
	
	// Events
	gmsgItems = get_user_msgid("ActItems")
	register_event("DeathMsg","death_msg","a")
}


public plugin_precache()
{	
	// Sounds
	precache_sound("carmod/crash.wav")
	precache_sound("carmod/start.wav")
	precache_sound("carmod/engine2.wav")
	precache_sound("carmod/car_horn2.wav")
	precache_sound("carmod/rev.wav")
	precache_sound("carmod/siren2.wav")
	precache_model("models/carmod/neons1.mdl")
	precache_model("models/carmod/carview1.mdl") 
	
	// car bomb
	g_SpriteExplosion = precache_model("sprites/bexplo.spr")
	
	// file precaching
	new model[128], file[128], x 
	format(file,127,"addons/amxmodx/configs/carmod_models.cfg"); 
	
	if(!file_exists(file)) 
	{ 
		server_print("[CarMod] File Missing: %s",file); 
		write_file(file,";Add models here, example - models/player/carmodel/carmodel.mdl",-1)
		return PLUGIN_CONTINUE; 
	} 
	
	for(new i=0;i<512;i++) 
	{ 
		format(model,127,""); 
		read_file(file,i,model,127,x); 
		
		if(equali(model,"")) 
			continue; 
		if(model[0] == ';') 
			continue; 
		
		precache_model(model); 
		server_print("%s is precached",model)
	} 
	
	return PLUGIN_CONTINUE;
}

////////////////////////////////////
///////// CLIENT STUFF ////////////
//////////////////////////////////

public client_connect(id)
{
	client_cmd(id,"cl_forwardspeed 320;cl_sidespeed 320;cl_backspeed 320")
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	if(dbc == SQL_FAILED) return PLUGIN_HANDLED
	
	g_fine[id] = 0
	g_usedlight[id] = 0
	set_task(5.0,"advertise",id)
	new authid[33]
	get_user_authid(id, authid, 32)
	format(query,255,"SELECT steamid FROM carmod WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) <= 0)
	{
		format(query,255,"INSERT INTO carmod (steamid,fine,gas,brokencar,engine,gastank) VALUES('%s', '0', '50','0','0','0')",authid)
		dbi_query(dbc,"%s",query)
		client_print(id,print_console,"%s",query)
		server_print("%s",query)
		dbi_free_result(result)
	}
	else
	{
		format(query,255, "SELECT fine FROM carmod WHERE steamid='%s'", authid)
		result = dbi_query(dbc,"%s",query)
		if(dbi_nextrow(result) > 0)
		{
			g_fine[id] = dbi_field(result,1)
		}
		dbi_free_result(result)	
	}
	return PLUGIN_HANDLED
}

public client_infochanged(id)
{
	if(g_incar[id] == 1) 
	{
		set_user_info(id,"model",g_carmodel[id])
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	if(g_incar[id] == 1) 
	{
		set_user_hitzones(id,0,255) // if your using realmod with it
		cardrop(id)
		g_incar[id] = 0
	}
	if(g_car[id]) 
	{
		g_car[id] = 0
	}
	return PLUGIN_CONTINUE
}

////////////////////////////////////////
////////// END OF CLIENT STUFF ////////
//////////////////////////////////////

public client_PreThink(id)
{
	if(g_incar[id] != 0)
	{
		new bufferstop = entity_get_int(id,EV_INT_button)
		if(bufferstop != 0) 
		{
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK2 & ~IN_ATTACK2 & ~IN_ALT1)
		}
		
		if((bufferstop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) 
		{
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP)
		}
		if(entity_get_int(id,EV_INT_button) & IN_USE && !(entity_get_int(id,EV_INT_oldbuttons) & IN_USE))
		{
			
			nos(id)
		}
	}
	return PLUGIN_CONTINUE
}

public car_in(id)
{
	if(g_incar[id] != 0)
	{
		client_print(id,print_chat,"[CarMod] You're already in a car.")
		return PLUGIN_HANDLED
	}
	if(spam[id] == 1) return PLUGIN_HANDLED
	
	new entid, Float:Forigin[3], itemstr[33] ,name[64], message[300], authid[33]
	entity_get_vector(id,EV_VEC_origin,Forigin)
	
	while((entid = find_ent_in_sphere(entid,Forigin,50.0)) != 0)
	{
		new classname[56]
		entity_get_string(entid,EV_SZ_classname,classname,55)
		if(equali(classname,"item_car") == 1)
		{
			new locked[33]
			entity_get_string(entid,EV_SZ_target,locked,63)
			get_user_authid(id,authid,32)
			if(equal(locked,authid)) {}
			else
			{ 
				client_print(id,print_chat,"You don't have keys to this car.")
				return PLUGIN_HANDLED
			}
			#if licenseon == 1
			if(get_item_amount(id,CARLICENSE,"money") == 0)
			{
				client_print(id,print_chat,"[CarMod] You need a Driver License!^n")
				return PLUGIN_HANDLED
			}
			#endif
			if(g_impounded[id])
			{
				client_print(id,print_chat,"[CarMod] Your car was impounded.")
				return PLUGIN_HANDLED
			}
			get_user_name(id,name,63)
			format(message,299,"[CarMod] %s has gotten into his/her car.",name)
			overhear(id,300,message)
			client_print(id,print_chat,"[CarMod] You have gotten into your car.")
			get_user_info(id,"model",g_oldmodel[id], 32)
			
			entity_get_string(entid,EV_SZ_targetname,itemstr,32)
			entity_set_string(id,EV_SZ_viewmodel,"models/carmod/carview1.mdl") 
			
			g_carmodel[id] = itemstr
			set_user_info(id,"model",itemstr)
			g_oldspeed[id] = get_user_maxspeed(id)
			g_oldfric[id] = entity_get_float(id,EV_FL_friction)
			g_incar[id] = 1	
			g_car[id] = 0
			set_user_maxspeed(id,1.0)
			set_user_footsteps(id,1)
			remove_entity(entid)
			new carfine = get_carstats(id,2)
			new fuel = get_carstats(id,3)
			
			#if breakablecars == 1
			new broken = get_carstats(id,1)
			if(get_item_amount(id,CARINSURANCE,"money") == 0)
			{
				if(broken > 0)
				{
					
					set_user_maxspeed(id,1.0)
					client_print(id,print_chat,"[CarMod] Your car is broken!")
					return PLUGIN_HANDLED
				}
			}
			else
			{
				if(broken > 0)
				{
					
					edit_value(id,"carmod","brokencar","=",0)
					client_print(id,print_chat,"[CarMod] Your insurance covered the car.")
					return PLUGIN_HANDLED
				}
			}
			#endif
			if(carfine > 0)
			{
				set_user_maxspeed(id,1.0)
				client_print(id,print_chat,"[CarMod] You have a ticket of %i! type /payticket^n",carfine)
				return PLUGIN_HANDLED
			}
			if(fuel < 1)
			{
				set_user_maxspeed(id,1.0)
				client_print(id,print_chat,"[CarMod] Your car fuel is empty! Refill it first!")
				return PLUGIN_HANDLED
			}
			set_task(3.0,"setspeed",id)
			car_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public uncar(id)
{
	if(g_incar[id] != 1) return PLUGIN_HANDLED
	
	new name[64]
	get_user_name(id,name,63)
	new message[300]
	set_user_footsteps(id,0)
	format(message,299,"[CarMod] %s has turned off his/her engine and got out of the car.",name)
	overhear(id,300,message)
	client_print(id,print_chat,"[CarMod] You have turned off your engine and got out of the car.")
	set_user_maxspeed(id,320.0)
	client_cmd(id,"cl_forwardspeed 320;cl_sidespeed 320;cl_backspeed 320")
	entity_set_float(id,EV_FL_friction,g_oldfric[id])
	cardrop(id)
	set_user_info(id,"model",g_oldmodel[id])
	g_incar[id] = 0
	spam[id] = 1
	set_task(5.0,"stopspam",id)
	new targetid
	for(new i=0;i<8;i++)
	{
		targetid = g_carseats[id][i]
		if(targetid > 0)
		{
			forced[targetid] = 0
			car_seat_getout(targetid)
		}
	}
	return PLUGIN_HANDLED
}

public stopspam(id)
{
	spam[id] = 0
}

public cardrop(id)
{
	if(g_incar[id] != 1) return PLUGIN_HANDLED
	
	new origin[3], Float:originF[3]
	get_user_origin(id,origin)
	
	originF[0] = float(origin[0])
	originF[1] = float(origin[1])
	originF[2] = float(origin[2])
	
	set_user_footsteps(id,0)
	set_user_maxspeed(id,320.0)
	entity_set_string(id,EV_SZ_viewmodel,"") 
	entity_set_string(id,EV_SZ_weaponmodel,"")
	client_cmd(id,"cl_forwardspeed 320;cl_sidespeed 320;cl_backspeed 320")
	set_user_hitzones(id,0,255) // for realmod
	
	g_car[id] = create_entity("info_target")
	
	if(!g_car[id])
	{
		client_print(id,print_chat,"[CarMod] The car was not created. Error.^n")
		return PLUGIN_HANDLED
	}
	
	if(g_usedlight[id] > 0)
	{
		message_begin(MSG_BROADCAST, gmsgItems, {0,0,0}) 
		write_byte(id)
		write_byte(0)
		message_end()	
		g_usedlight[id] = 0	
		entity_set_int(id,EV_INT_effects,entity_get_int(id,EV_INT_effects) & ~EF_DIMLIGHT)
	}
	
	new Float:minbox[3] = {-88.5, -34.0, -1.0}
	new Float:maxbox[3] = {88.5, 34.0, 1.0}
	
	entity_set_float(g_car[id],EV_FL_dmg,0.0)
	entity_set_float(g_car[id],EV_FL_dmg_take,0.0)
	entity_set_float(g_car[id],EV_FL_max_health,99999.0)
	entity_set_float(g_car[id],EV_FL_health,99999.0)
	
	entity_set_int(g_car[id],EV_INT_solid,SOLID_BBOX)
	entity_set_int(g_car[id],EV_INT_movetype,MOVETYPE_FLY)
	
	entity_set_string(g_car[id],EV_SZ_targetname,g_carmodel[id])
	entity_set_string(g_car[id],EV_SZ_classname,"item_car")
	
	new Float:vRetVector[3]
	entity_get_vector(id, EV_VEC_v_angle, vRetVector)
	vRetVector[0]=float(0)
	entity_set_vector(g_car[id], EV_VEC_angles, vRetVector)
	new damodel[64]
	format(damodel,63,"models/player/%s/%s.mdl", g_carmodel[id], g_carmodel[id])
	
	entity_set_model(g_car[id],damodel)
	entity_set_origin(g_car[id],originF)
	g_incar[id] = 0
	new authid[32]
	get_user_authid(id,authid,32)
	entity_set_string(g_car[id],EV_SZ_target,authid)
	new torigin[3]
	get_user_origin(id,torigin)
	torigin[2] += 50
	set_user_origin(id,torigin)
	
	set_size(g_car[id], minbox, maxbox)
	return PLUGIN_HANDLED
}

public setspeed(id)
{
	if(g_incar[id])
	{
		new type = get_carstats(id,4)
		g_carspeed[id] += type * 100
		
		new neons = get_carstats(id,5)
		format(query,255, "SELECT maxseats,speed,friction FROM cardatabase WHERE carmodel='%s'", g_carmodel[id])
		result = dbi_query(dbc,"%s",query)
		if(dbi_nextrow(result) > 0)
		{
			g_maxcarseats[id] = dbi_field(result,1)
			g_carspeed[id] = dbi_field(result,2)
			g_friction[id] = float(dbi_field(result,3))
		}
		else
		{
			dbi_free_result(result)
			return 0
		}
		dbi_free_result(result)
		
		entity_set_float(id,EV_FL_friction,g_friction[id]/10)
		set_user_maxspeed(id,float(g_carspeed[id]))
		entity_set_float(id,EV_FL_speed,float(g_carspeed[id]))
		client_cmd(id,"cl_forwardspeed %i;cl_sidespeed %i;cl_backspeed %i",g_carspeed[id],g_carspeed[id],g_carspeed[id])
		client_print(id,print_chat,"[CarMod] You started your engine.")
		emit_sound(id, CHAN_ITEM, "carmod/start.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(1.0,"engine",id)
		car_menu(id)
		
		if(neons > 0) entity_set_string(id,EV_SZ_weaponmodel,"models/carmod/neons1.mdl")
		
		if(g_hasbomb[id] > 0)
		{
			set_task(3.0,"explodeit",id)
			client_print(id,print_chat,"[CarMod] You hear a ticking sound...")
			set_user_maxspeed(id,0.0)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public engine(id)
{
	if(g_incar[id])
	{
		emit_sound(id, CHAN_ITEM, "carmod/engine2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(1.0,"engine",id)
	}
}

public explodeit(id)
{
	new origin[3], players[32]
	get_user_origin(id,origin)
	bombexplode(origin, g_SpriteExplosion, 30, 10, 0)
	for (new i=0; i<33; i++)
	{
		new playerlocation[3]
		new resultdistance
		
		get_user_origin(players[i], playerlocation)
		
		resultdistance = get_distance(playerlocation,origin)
		
		if(resultdistance < 100)
		{
			user_slap(players[i],100,100)
			if(get_user_health(players[i] > 1))
			{
				user_silentkill(players[i])
				make_deathmsg(id,players[i],0,"Car Bomb")
			}
			#if breakablecars == 1
			edit_value(id,"carmod","brokencar","=",1)
			edit_value(entid,"carmod","brokencar","=",1)
			#endif
			
		}
	}
	return PLUGIN_HANDLED
}

public removecar(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	
	if(g_usedcar[id] > 0)
	{
		if(g_car[id] > 0)
		{
			remove_entity(g_car[id])
			set_user_footsteps(id,0)
			set_user_maxspeed(id,g_oldspeed[id])
			entity_set_float(id,EV_FL_friction,g_oldfric[id])
			set_user_info(id,"model",g_oldmodel[id])
			g_car[id] = 0
			g_usedcar[id] -= 1
			client_cmd(id,"cl_forwardspeed 320;cl_sidespeed 320;cl_backspeed 320")
			client_print(id,print_chat,"[CarMod] You put your car back into your inventory.")
			return PLUGIN_HANDLED
		}
	}
	else
	{
		client_print(id,print_chat,"[CarMod] Your car is already in your inventory!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public crash(id,entid)
{
	if(g_incar[id] && g_incar[entid])
	{
		new origin[3], players[32], playercount
		get_user_origin(id,origin)
		bombexplode(origin, g_SpriteExplosion, 30, 10, 0)
		if(get_speed(id) || get_speed(entid) > 500)
		{
			for (new i=0; i<playercount; i++)
			{
				new playerlocation[3]
				new resultdistance
				
				get_user_origin(players[i], playerlocation)
				
				resultdistance = get_distance(playerlocation,origin)
				
				if(resultdistance < 100)
				{
					fakedamage(players[i],"Car Crash",100.0,1)
					#if breakablecars == 1
					edit_value(id,"carmod","brokencar","=",1)
					edit_value(entid,"carmod","brokencar","=",1)
					#endif
					
				}
			}
		}
		else if(get_speed(id) || get_speed(entid) > 200)
		{
			fakedamage(id,"Car Crash",20.0,1)
			fakedamage(entid,"Car Crash",20.0,1)
		}
	}
	return PLUGIN_HANDLED
}

public impound(id)
{
	if(g_iscop[id])
	{
		new Float:origin[3], ent, authid[33], Float:carorigin[3]
		entity_get_vector(id,EV_VEC_origin,origin)
		ent = find_car_by_origin_steamid(origin,authid)
		new tid = get_id_by_steamid(authid)
		entity_get_vector(ent,EV_VEC_origin,carorigin)
		if(!ent)
		{
			client_print(id,print_chat,"[CarMod] You must be near a car!^n")
			return PLUGIN_HANDLED
		}
		else if(!g_impounded[tid])
		{
			carorigin[2] -= 20 
			entity_set_origin(ent,carorigin)
			client_print(id,print_chat,"[CarMod] Impounded the car.")
			g_impounded[tid] += 1
			return PLUGIN_HANDLED
		}
		else if(g_impounded[tid])
		{
			carorigin[2] += 20 
			entity_set_origin(ent,carorigin)
			client_print(id,print_chat,"[CarMod] Unpounded the car.")
			g_impounded[tid] = 0
		}
	}
	return PLUGIN_HANDLED
}

///////////////////////////////////////
//////////// ITEMS ///////////////////
/////////////////////////////////////

public item_car()
{
	new arg[33], itemstr[33], id, name[64], message[300]
	read_argv(1,arg,32)
	read_argv(2,itemstr,32)
	
	id = str_to_num(arg)
	
	if(g_usedcar[id] > 0)
	{
		client_print(id,print_chat,"[CarMod] You can't more than 1 car out.")
		return PLUGIN_HANDLED
	}
	#if licenseon == 1
	if(get_item_amount(id,CARLICENSE,"money") == 0)
	{
		client_print(id,print_chat,"[CarMod] You need a Driver License!^n")
		return PLUGIN_HANDLED
	}
	#endif
	if(g_impounded[id])
	{
		client_print(id,print_chat,"[CarMod] Your car was impounded.")
		return PLUGIN_HANDLED
	}
	if(!g_incar[id])
	{
		get_user_name(id,name,63)
		format(message,299,"[CarMod] %s has gotten into his/her car.",name)
		overhear(id,300,message)
		get_user_info(id,"model",g_oldmodel[id], 32)
		client_print(id,print_chat,"[CarMod] You have gotten into your car.")
		g_carmodel[id] = itemstr
		set_user_info(id,"model",itemstr)
		g_oldfric[id] = entity_get_float(id,EV_FL_friction)
		g_oldspeed[id] = get_user_maxspeed(id)
		g_incar[id] = 1
		g_usedcar[id] += 1
		g_car[id] = 0
		
		entity_set_string(id,EV_SZ_viewmodel,"models/carmod/carview1.mdl")
		set_user_maxspeed(id,1.0)
		new carfine = get_carstats(id,2)
		new fuel = get_carstats(id,3)
		#if breakablecars == 1
		new broken = get_carstats(id,1)
		if(get_item_amount(id,CARINSURANCE,"money") == 0)
		{
			if(broken > 0)
			{
				
				set_user_maxspeed(id,1.0)
				client_print(id,print_chat,"[CarMod] Your car is broken!")
				return PLUGIN_HANDLED
			}
		}
		else
		{
			if(broken > 0)
			{
				
				edit_value(id,"carmod","brokencar","=",0)
				client_print(id,print_chat,"[CarMod] Your insurance covered the car.")
				return PLUGIN_HANDLED
			}
		}
		#endif
		if(carfine > 0)
		{
			set_user_maxspeed(id,1.0)
			client_print(id,print_chat,"[CarMod] You have a ticket of %i! type /payticket^n",carfine)
			return PLUGIN_HANDLED
		}
		if(fuel < 1)
		{
			set_user_maxspeed(id,1.0)
			client_print(id,print_chat,"[CarMod] Your car fuel is empty! Refill it first!^n")
			return PLUGIN_HANDLED
		}
		set_task(2.0,"setspeed",id)
		set_user_footsteps(id,1)
		car_menu(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public item_gas(){
	new arg[32], arg2[32], arg3[32], id, itemid, gas
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	gas = str_to_num(arg3)
	
	new carent = find_car_by_owner(id)
	if(!carent)
	{
		client_print(id,print_chat,"[CarMod] You have to near a car you have keys to so you can refill it.")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	
	new fuel = get_carstats(id,3)
	new mfuel = get_maxfuel(g_carmodel[id])
	if(fuel > mfuel)
	{
		fuel = mfuel
		client_print(id,print_chat,"[CarMod] Successfully refilled fuel in your car!^n")
		edit_value(id,"carmod","gas","=",fuel)
		return PLUGIN_HANDLED
	}
	
	edit_value(id,"carmod","gas","+",gas)
	client_print(id,print_chat,"[CarMod] Successfully refilled fuel in your car!^n")
	return PLUGIN_HANDLED
}


public item_carbomb(){
	new arg[32], arg2[32], ent, tid, id, itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	
	new Float:origin[3], tauthid[33]
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,tauthid)
	tid = get_id_by_steamid(tauthid)
	
	new carid, car
	get_user_aiming(id,carid,car,100)
	if(carid == ent)
	{
		client_print(id,print_chat,"[CarMod] You're setting up the bomb....")
		new parm[2]
		parm[0] = id
		parm[1] = tid
		set_task(10.0,"setbomb",0,parm,2)
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_chat,"[CarMod] You need to be near a car.")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public item_repair()
{
	new arg[32], arg2[32], ent, id, itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	
	new Float:origin[3], tauthid[33]
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,tauthid)
	
	new carid, car
	get_user_aiming(id,carid,car,100)
	new broken = get_carstats(id,1)
	if(broken == 0)
	{
		client_print(id,print_chat,"[CarMod] Your car isn't broken.")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	if(carid == ent)
	{
		client_print(id,print_chat,"[CarMod] You started repairing your car....")
		set_task(20.0,"repair",id)
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_chat,"[CarMod] You need to be near a car.")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public item_hotwire()
{
	new arg[33], arg2[33], id, itemid
	read_argv(1,arg,32)
	read_argv(2,arg2,32)
	
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	
	new authid[33]
	get_user_authid(id,authid,32)
	
	new Float:origin[3], ent
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,authid)
	
	if(!ent)
	{
		client_print(id,print_chat,"[CarMod] You must be near a car!^n")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	else
	{
		set_task(15.0,"hijack",id)
		client_print(id,print_chat,"[CarMod] You're trying to hotwire this car....")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public item_engine()
{
	new arg[33], arg2[33], type, id
	read_argv(1,arg,32)
	read_argv(2,arg2,32)
	
	id = str_to_num(arg)
	type = str_to_num(arg2)
	
	new carent = find_car_by_owner(id)
	if(!carent)
	{
		client_print(id,print_chat,"[CarMod] You need to be near your car to put your engine in.^n")
		return PLUGIN_HANDLED
	}
	
	edit_value(id,"carmod","engine","=",type)
	client_print(id,print_chat,"[CarMod] You put your new engine inside.")
	return PLUGIN_HANDLED
}

public repair(id)
{
	client_print(id,print_chat,"[CarMod] You fixed your car.")
	edit_value(id,"carmod","brokencar","=",0)
	return PLUGIN_HANDLED
}

public setbomb(parm[])
{
	new id = parm[0]
	new tid = parm[1]
	client_print(id,print_chat,"[CarMod] You set up the bomb!")
	g_hasbomb[tid] += 1
	return PLUGIN_HANDLED
}

public hijack(id)
{
	new authid[33]
	get_user_authid(id,authid,32)
	new Float:origin[3], ent
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,authid)
	
	if(!ent)
	{
		client_print(id,print_chat,"[CarMod] You must be near a car!^n")
		return PLUGIN_HANDLED
	}
	else
	{
		if(random_num(1,1) == 1)
		{
			sethijackercar(id,authid)
			client_print(id,print_chat,"[CarMod] You sucessfully hotwired this car.")
		}
		else
		{
			client_print(id,print_chat,"[CarMod] You failed to hotwired this car.")
		}
	}
	return PLUGIN_HANDLED
}

public item_neon()
{
	new arg[33], id, Float:origin[3], ent, authid[33]
	read_argv(1,arg,32)
	
	id = str_to_num(arg)
	
	get_user_authid(id,authid,32)
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,authid)
	
	if(g_incar[id])
	{
		client_print(id,print_chat,"[CarMod] You can't be incar to put your neons on!")
		return PLUGIN_HANDLED
	}
	if(!ent)
	{
		client_print(id,print_chat,"[CarMod] You must be near a car!^n")
	}
	else
	{
		edit_value(id,"carmod","gastank","=",1)
		client_print(id,print_chat,"[CarMod] You put neons on your car!")
	}
	return PLUGIN_HANDLED
}

public item_nos()
{
	new arg[33], id, Float:origin[3], ent, authid[33]
	read_argv(1,arg,32)
	
	id = str_to_num(arg)
	
	get_user_authid(id,authid,32)
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,authid)
	
	if(g_incar[id])
	{
		client_print(id,print_chat,"[CarMod] You can't be incar to put your neons on!")
		return PLUGIN_HANDLED
	}
	if(ent)
	{
		client_print(id,print_chat,"[CarMod] You installed NOS into your car.")
		g_hasnos[id] = 1
	}
	else
	{
		client_print(id,print_chat,"[CarMod] You must be near your car!")
	}
	return PLUGIN_HANDLED
}

public nos(id)
{
	if(g_hasnos[id])
	{
		g_carspeed[id] += NOSspeed
		set_user_maxspeed(id,float(g_carspeed[id]))
		entity_set_float(id,EV_FL_speed,float(g_carspeed[id]))
		client_cmd(id,"cl_forwardspeed %i;cl_sidespeed %i;cl_backspeed %i",g_carspeed[id],g_carspeed[id],g_carspeed[id])
		set_task(10.0,"stopnos",id)
		emit_sound(id, CHAN_ITEM, "carmod/rev.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	return PLUGIN_HANDLED
}

public stopnos(id)
{
	if(g_hasnos[id])
	{
		g_carspeed[id] -= NOSspeed
		set_user_maxspeed(id,float(g_carspeed[id]))
		entity_set_float(id,EV_FL_speed,float(g_carspeed[id]))
		client_cmd(id,"cl_forwardspeed %i;cl_sidespeed %i;cl_backspeed %i",g_carspeed[id],g_carspeed[id],g_carspeed[id])
		g_hasnos[id] = 0
	}
	return PLUGIN_HANDLED
}

/* For later version 
public item_speedometer()
{
	new arg[33], id, tid, ent, origin[3]
	read_argv(1,arg,32)
	
	id = str_to_num(arg)
	
	get_user_origin(id,origin)
	if(!is_in_viewcone(id,origin))
	{
		client_print(id,print_chat,"[CarMod] You need to be aiming at someone.")
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_chat,"[CarMod] Target car is going at %i",get_speed(id))
	}
	return PLUGIN_HANDLED
}

*/
//////////////////////////////////////
////////// END OF ITEMS /////////////
////////////////////////////////////

///////////////////////////////////
////////// PASSENGERMOD //////////
/////////////////////////////////
public car_menu(id)
{
	if(!player_exist(id))
	{
		return PLUGIN_HANDLED
	}
	
	if(g_incar[id] == 0)
	{
		client_print(id,print_chat,"[CarMod] You must be in a car in order to use the car menu!^n")
		return PLUGIN_HANDLED
	}
	
	new menu[256]
	
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9)
	new len = format(menu,sizeof(menu),"CarMenu^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. Invite Player^n")
	len += format(menu[len],sizeof(menu)-len,"2. Kick Player^n")
	if(g_iscop[id])
	{
		len += format(menu[len],sizeof(menu)-len,"3. Force Player into car^n")
	}
	
	len += format(menu[len],sizeof(menu)-len,"0. Exit Menu")
	
	show_menu(id,key,menu,-1,"CarMenu")
	return PLUGIN_HANDLED
}

public car_menu_action(id,key)
{
	if(g_incar[id] == 0)
	{
		client_print(id,print_chat,"[CarMod] You left your car!^n")
		return PLUGIN_HANDLED
	}
	if(!player_exist(id)) return PLUGIN_HANDLED
	switch(key)
	{
		case 0: car_invite(id)
			case 1: car_kick(id)
			case 2: force_in(id)
			case 9: return PLUGIN_HANDLED
		}
	return PLUGIN_HANDLED
}


public force_in(id)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(g_incar[id] == 0)
	{
		client_print(id,print_chat,"[CarMod] You must be in a car in order to force people in!^n")
		return PLUGIN_HANDLED
	}
	
	new targetid, body, x, freeslot
	get_user_aiming(id,targetid,body,200)
	
	if(!player_exist(targetid))
	{
		client_print(id,print_chat,"[CarMod] You must be looking at another player!^n")
		car_menu(id)
		return PLUGIN_HANDLED
	}
	
	for(new i=0;i<g_maxcarseats[id]-1;i++)
	{
		if(g_carseats[id][i] > 0 && player_exist(g_carseats[id][i]))
		{
			
			x++
		}
		else 
		{ 
			freeslot = i; g_carseats[id][i] = 0
			break
		}
	}
	
	if(x >= g_maxcarseats[id]-1)
	{
		client_print(id,print_chat,"[CarMod] x = %i , Your car is full of players!^n",x)
		car_menu(id)
		return PLUGIN_HANDLED
	}
	
	new name[32], tname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,tname,31)
	
	if(g_carseat[targetid] > 0)
	{
		car_menu(id)
		client_print(id,print_chat,"[CarMod] %s is already in another person's car!^n",tname)
		return PLUGIN_HANDLED
	}
	
	if(g_incar[targetid] > 0)
	{
		car_menu(id)
		client_print(id,print_chat,"[CarMod] %s is already in a car!^n",tname)
		return PLUGIN_HANDLED
	}
	
	client_print(id,print_chat,"[CarMod] You forced %s to get in your car!^n",tname)
	
	g_carstore[targetid][0] = id
	g_carstore[targetid][1] = freeslot
	
	id = g_carstore[targetid][0]
	
	car_invite_complete(id,targetid)
	forced[targetid] = 1
	return PLUGIN_HANDLED
}

public car_invite(id)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(g_incar[id] == 0)
	{
		client_print(id,print_chat,"[CarMod] You must be in a car in order to invite people in!^n")
		return PLUGIN_HANDLED
	}
	
	new targetid, body, x, freeslot
	get_user_aiming(id,targetid,body,200)
	
	if(!player_exist(targetid))
	{
		client_print(id,print_chat,"[CarMod] You must be looking at another player!^n")
		car_menu(id)
		return PLUGIN_HANDLED
	}
	
	for(new i=0;i<g_maxcarseats[id]-1;i++)
	{
		if(g_carseats[id][i] > 0 && player_exist(g_carseats[id][i]))
		{
			
			x++
		}
		else 
		{ 
			freeslot = i; g_carseats[id][i] = 0
			break
		}
	}
	
	if(x >= g_maxcarseats[id]-1)
	{
		client_print(id,print_chat,"[CarMod] x = %i , Your car is full of players!^n",x)
		car_menu(id)
		return PLUGIN_HANDLED
	}
	
	new name[32], tname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,tname,31)
	
	if(g_carseat[targetid] > 0)
	{
		car_menu(id)
		client_print(id,print_chat,"[CarMod] %s is already in another person's car!^n",tname)
		return PLUGIN_HANDLED
	}
	
	if(g_incar[targetid] > 0)
	{
		car_menu(id)
		client_print(id,print_chat,"[CarMod] %s is already in a car!^n",tname)
		return PLUGIN_HANDLED
	}
	
	client_print(id,print_chat,"[CarMod] You invited %s to get in your car!^n",tname)
	
	g_carstore[targetid][0] = id
	g_carstore[targetid][1] = freeslot
	
	new menu[256]
	
	new key = (1<<0|1<<1)
	new len = format(menu,sizeof(menu),"Car Invitation^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"%s invited you to get in his/her car!^n^n",name)
	
	len += format(menu[len],sizeof(menu)-len,"1. Accept^n")
	len += format(menu[len],sizeof(menu)-len,"2. Decline^n")
	
	show_menu(targetid,key,menu,-1,"CarInvite")
	return PLUGIN_HANDLED
}

public car_invite_action(targetid,key)
{
	if(!player_exist(targetid)) return PLUGIN_HANDLED
	
	new id = g_carstore[targetid][0]
	
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	new name[32], tname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,tname,31)
	switch(key)
	{
		case 0: car_invite_complete(id,targetid)
			case 1:
		{
			client_print(id,print_chat,"[CarMod] %s declined your offer to get in your car!^n",tname)
			client_print(targetid,print_chat,"[CarMod] You declined %s's offer to get in his/her car!^n",name)
			g_carstore[targetid][0] = 0
			g_carstore[targetid][1] = 0
			car_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public car_invite_complete(id,targetid)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(!player_exist(targetid)) return PLUGIN_HANDLED
	
	new slot = g_carstore[targetid][1], name[32], tname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,tname,31)
	
	if(g_incar[id] < 1)
	{
		client_print(targetid,print_chat,"[CarMod] Could not get into %s's car because he left it!^n",name)
		return PLUGIN_HANDLED
	}
	
	if(g_carseats[id][slot] > 0)
	{
		new uname[32]
		get_user_name(g_carseats[id][slot],uname,31)
		client_print(targetid,print_chat,"[CarMod] %s took your seat in the car!^n",uname)
		client_print(id,print_chat,"[CarMod] %s could not get in your car because %s took his/her seat!^n",tname,uname)
		return PLUGIN_HANDLED
	}
	
	g_carseats[id][slot] = targetid
	g_carseat[targetid] = id
	
	client_print(id,print_chat,"[CarMod] %s successfully got in your car!^n",tname)
	client_print(targetid,print_chat,"[CarMod] You successfully got in %s's car!^n",name)
	
	set_task(0.01,"car_seat_update_view",targetid+5892743,"",_,"b")
	
	car_menu(id)
	
	entity_set_int(targetid,EV_INT_solid,SOLID_NOT)
	set_entity_visibility(targetid,0)
	return PLUGIN_HANDLED
}

public car_kick(id)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(g_incar[id] < 1) return PLUGIN_HANDLED
	
	new x = 0
	new tname[32], menu[256], targetid
	
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new len = format(menu,sizeof(menu),"Car Seat Kicks^n^n")
	
	for(new i=0;i<8;i++)
	{
		targetid = g_carseats[id][i]
		if(targetid > 0)
		{
			get_user_name(targetid,tname,31)
			len += format(menu[len],sizeof(menu)-len,"%i. %s^n",i+1,tname)
			x += 1
		}
		else
		{
			len += format(menu[len],sizeof(menu)-len,"%i. Empty Slot^n",i+1)
		}
	}
	
	len += format(menu[len],sizeof(menu)-len,"0. Exit")
	
	if(x == 0)
	{
		client_print(id,print_chat,"[CarMod] No one is in your car!^n")
		return PLUGIN_HANDLED
	}
	
	show_menu(id,key,menu,-1,"CarKick")
	return PLUGIN_HANDLED
}

public car_kick_action(id,key)
{
	
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(key == 9) return PLUGIN_HANDLED
	
	new targetid = g_carseats[id][key]
	
	if(targetid < 1)
	{
		client_print(id,print_chat,"[CarMod] That slot is empty!^n")
		car_kick(id)
		car_menu(id)
		return PLUGIN_HANDLED
	}
	
	car_menu(id)
	car_seat_getout(targetid)
	return PLUGIN_HANDLED
}

public car_seat_update_view(var)
{
	new id = var - 5892743
	new targetid = g_carseat[id]
	
	if(targetid < 1)
	{
		remove_task(var)
		return PLUGIN_HANDLED
	}
	
	if(g_incar[targetid] < 1)
	{
		remove_task(var)
		return PLUGIN_HANDLED
	}
	
	if(!player_exist(targetid))
	{
		remove_task(var)
		return PLUGIN_HANDLED
	}
	
	new origin[3]
	get_user_origin(targetid,origin)
	origin[2] += 80
	set_user_origin(id,origin)
	return PLUGIN_HANDLED
}

public car_seat_getout(targetid)
{	
	if(g_carseat[targetid] < 1) return PLUGIN_HANDLED
	
	new id = g_carseat[targetid]
	
	if(forced[targetid] && !g_iscop[id])
	{
		client_print(targetid,print_chat,"[CarMod] The driver locked the backdoor, you can't get out!")
		return PLUGIN_HANDLED
	}
	
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	new speed = get_speed(id), slot
	if(speed > 500)
	{
		set_user_health(targetid,get_user_health(targetid)-25)
	}
	
	for(new i=0;i<8;i++)
	{
		if(g_carseats[id][i] == targetid)
		{
			slot = i
		}
	}
	
	g_carseat[targetid] = 0
	g_carseats[id][slot] = 0
	
	new name[32],tname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,tname,31)
	
	new origin[3]
	get_user_origin(targetid,origin)
	origin[2] += 80
	set_user_origin(targetid,origin)
	
	entity_set_int(targetid,EV_INT_solid,SOLID_BBOX)
	
	set_entity_visibility(targetid,1)
	
	client_print(id,print_chat,"[CarMod] %s got out of your car!^n",tname)
	client_print(targetid,print_chat,"[CarMod] You got out of %s's car!^n",name)
	
	remove_task(targetid+5892743)
	return PLUGIN_HANDLED
}

//////////////////////////////////////////
//////// END OF PASSENGERMOD ////////////
////////////////////////////////////////

///////////////////////////////////////
////////// TICKETMOD /////////////////
//////////////////////////////////////

public givefine(id)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	if(!g_iscop[id])
	{
		console_print(id,"[CarMod] Only cops can make car fines!^n")
		return PLUGIN_HANDLED
	}
	
	new carticket = get_carstats(id,2)
	
	if(carticket > 0)
	{
		client_print(id,print_chat,"[CarMod] This car was already fined for %i!",carticket)
		return PLUGIN_HANDLED
	}
	
	new arg[33], authid[33], carfine
	read_argv(1,arg,32)
	carfine = str_to_num(arg)
	
	if(carfine < 1)
	{
		client_print(id,print_chat,"[CarMod] Your car ticket amount must be higher than zero!^n")
		return PLUGIN_HANDLED
	}
	if(carfine > 500)
	{
		client_print(id,print_chat,"[CarMod] The car ticket can't be greater than 500$.")
		return PLUGIN_HANDLED
	}
	
	new Float:origin[3], ent
	entity_get_vector(id,EV_VEC_origin,origin)
	ent = find_car_by_origin_steamid(origin,authid)
	
	if(!ent)
	{
		client_print(id,print_chat,"[CarMod] You must be near a car!^n")
		return PLUGIN_HANDLED
	}
	
	new tid = get_id_by_steamid(authid)
	if(g_iscop[tid])
	{
		client_print(id,print_chat,"[CarMod] You can't ticket another cop!")
		return PLUGIN_HANDLED
	}
	
	format(query,255,"UPDATE carmod SET fine='%d' WHERE steamid='%s'",carfine,authid)
	dbi_query(dbc,"%s",query)
	server_print("%s",query)
	
	new message[300]
	format(message,299,"[CarMod] Successfully this car(%s) for a fine of %i",authid,carfine)
	client_print(id,print_chat,"%s",message)
	log_amx("%s",message)
	return PLUGIN_HANDLED
}

public payfine(id)
{
	if(!player_exist(id)) return PLUGIN_HANDLED
	
	new authid[32]
	get_user_authid(id,authid,32)
	
	new carfine = get_carstats(id,2)
	
	if(carfine < 1)
	{
		client_print(id,print_chat,"[CarMod] Your car does not have a fine!^n")
		return PLUGIN_HANDLED
	}
	
	new inbank
	format(query,255,"SELECT balance FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	server_print("%s",query)
	if(dbi_nextrow(result) > 0)
	{
		inbank = dbi_field(result,1)
	}
	else
	{
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	dbi_free_result(result)
	
	if(inbank < carfine)
	{
		client_print(id,print_chat,"[CarMod] You don't have enough cash in bank to pay this fine!^n")
		return PLUGIN_HANDLED
	}
	
	edit_value(id,"money","balance","-",carfine)
	edit_value(id,"carmod","fine","-",carfine)
	client_print(id,print_chat,"[CarMod] You successfully paid the fine of %i!^n",carfine)
	
	g_fine[id] = 0
	carfine = 0
	
	if(g_incar[id])
	{
		set_task(0.1,"setspeed",id)
		return PLUGIN_HANDLED
	}
	car_menu(id)
	return PLUGIN_HANDLED
}

//////////////////////////////////////////
////////// END OF TICKETMOD /////////////
/////////////////////////////////////////

new station[33]
public radio(id)
{
	if(!g_incar[id]){
		client_print(id,print_chat,"[CarMod] You aren't incar to play your radio!")
		return PLUGIN_HANDLED
	}
	
	new menu[256]
	
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new len = format(menu,sizeof(menu),"Radio Menu^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"Radio Station: %s^n",station)
	len += format(menu[len],sizeof(menu)-len,"1. Radio Station 1^n")
	len += format(menu[len],sizeof(menu)-len,"2. Radio Station 2^n")
	len += format(menu[len],sizeof(menu)-len,"3. Radio Station 3^n")
	len += format(menu[len],sizeof(menu)-len,"4. Radio Station 4^n")
	len += format(menu[len],sizeof(menu)-len,"5. Radio Station 5^n")
	len += format(menu[len],sizeof(menu)-len,"6. Radio Station 6^n")
	len += format(menu[len],sizeof(menu)-len,"7. Radio Station 7^n")
	len += format(menu[len],sizeof(menu)-len,"8. Radio Station 8^n")
	len += format(menu[len],sizeof(menu)-len,"9. Stop listening to radio^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Exit Menu")
	
	show_menu(id,key,menu,-1,"Radio Menu")
	return PLUGIN_HANDLED
}

public radio_menu(id,key)
{
	switch (key) { 
		case 0: { // 1 
			client_cmd(id,"mp3 play carmod/radio/1.mp3")
			station[id] = 1
		} 
		case 1: { // 2 
			client_cmd(id,"mp3 play carmod/radio/2.mp3") 
			station[id] = 2
		} 
		case 2: { // 3 
			client_cmd(id,"mp3 play carmod/radio/3.mp3")
			station[id] = 3
		} 
		case 3: { // 4 
			client_cmd(id,"mp3 play carmod/radio/4.mp3")
			station[id] = 4
		} 
		case 4: { // 5 
			client_cmd(id,"mp3 play carmod/radio/5.mp3")
			station[id] = 5
		} 
		case 5: { // 6 
			client_cmd(id,"mp3 play carmod/radio/6.mp3") 
			station[id] = 6	
		} 
		case 6: { // 7 
			client_cmd(id,"mp3 play carmod/radio/7.mp3")   
			station[id] = 7
		} 
		case 7: { // 8 
			client_cmd(id,"mp3 play carmod/radio/8.mp3")  
			station[id] = 8
		} 
		case 8: { // 9 
			client_cmd(id,"mp3 play carmod/radio/9.mp3")   
			station[id] = 9
		} 
		case 9: { // 0 
			client_cmd(id,"mp3 stop")       
		} 
	}
}

public check_near_car()
{
	new Float:origin[3], tauthid[33], ent, targetid, name[33]
	for(new id=0;id<33;id++)
	{
		if(!player_exist(id)) continue
		
		if(g_incar[id] > 0)
		{
			car_hud(id)
		}
		else
		{
			entity_get_vector(id,EV_VEC_origin,origin)
			ent = find_car_by_origin_steamid(origin,tauthid)
			if(!ent) continue
			
			targetid = get_id_by_steamid(tauthid)
			if(!player_exist(targetid))
			{
				client_print(id,print_center,"The owner of this car is currently not in this city!")
				continue
			}
			get_user_name(targetid,name,32)
			client_print(id,print_center,"Car Owner: %s",name)
		}
	}
	return PLUGIN_CONTINUE
}

new check[33] = 0
public car_hud(id)
{
	new message[512], cspeed, mfuel, fuel
	mfuel = get_maxfuel(g_carmodel[id])
	fuel = get_carstats(id,3)
	cspeed = get_speed(id)
	
	new liters = cspeed/CAR_SPEND
	
	format(message,511,"---Car Hud--- ^n^n Fuel: %i/%i ^n^n %i TSMiles/Hour ^n^n -----------^n^n",fuel,mfuel,cspeed)
	set_hudmessage(200,0,0,1.9,0.35,0,0.0,3.0,0.0,0.0,3)
	show_hudmessage(id,message)
	
	edit_value(id,"carmod","gas","-",liters)
	
	if(fuel < 1)
	{
		set_user_maxspeed(id,1.0)
		if(check[id] < 1)
		{
			client_print(id,print_chat,"[CarMod] You are out of fuel!^n")
		}
		check[id] += 1
		set_task(60.0,"checkoff",id)
		edit_value(id,"carmod2","gas","=",0)
	}
	return PLUGIN_HANDLED
}

public checkoff(id){
	check[id] = 0
}

public advertise(id){
	engclient_print(id,engprint_console,"--------------------------------------------------------------------------------^n")
	engclient_print(id,engprint_console,"  %s made by %s. Version %s   ^n",Plugin,Author,Version)
	engclient_print(id,engprint_console,"--------------------------------------------------------------------------------^n")
}

public death_msg()
{
	new id = read_data(2)
	car_seat_getout(id)
	if(g_incar[id] == 1)
	{
		for(new i=0;i<8;i++)
		{
			new targetid = g_carseats[id][i]
			if(targetid > 0)
			{
				forced[targetid] = 0
				car_seat_getout(targetid)
			}
		}
		set_user_maxspeed(id,g_oldspeed[id])
		entity_set_float(id,EV_FL_friction,g_oldfric[id])
		set_user_info(id,"model",g_oldmodel[id])
		cardrop(id)
		g_incar[id] = 0
		set_user_hitzones(id,0,255) // for when you're using realmod also
	}
	return PLUGIN_CONTINUE
}

////////////////////////////////////
////////// adding keys ////////////
//////////////////////////////////

public givekeyaccess(id)
{
	new arg[32], arg2[32], authid2
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	
	authid2 = str_to_num(arg2)
	
	if(equali(arg,"") || equali(arg2,"")) {
		client_print(id,print_console,"amx_givecarkey <steamid>^n")
		return PLUGIN_HANDLED
	}
	
	new authid[33], acess[2048], str[64]
	get_user_authid(id,authid,32)
	format(query,255,"SELECT access FROM carmod WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		dbi_field(result,1,acess,2047)
		dbi_free_result(result)
	}
	else 
	{
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	
	if(equali(arg2,acess))
	{
		client_print(id,print_console,"[CarMod] This player already has keys to your car.")
		return PLUGIN_HANDLED
	}
	new output[MAXCARKEYS][32]
	new var = explode( output, acess, '|')
	if(var == MAXCARKEYS) {
		client_print(id,print_console,"[CarMod] Can't give more keys to anyone else due to the %i limit.",MAXCARKEYS)
		return PLUGIN_HANDLED
	}
	format(str,63,"|%s",authid2)
	add(acess,sizeof(acess),str)
	format(query,sizeof(query)+19,"UPDATE access SET access='%s' WHERE steamid='%s'",acess,authid)
	dbi_query(dbc,query)
	client_print(id,print_console,"[CarMod] Added access for SteamID: %s",authid2)
	return PLUGIN_HANDLED
}


////////////////////////////////////
// STOCKS AND IMPORTANT FUNCTIONS //
////////////////////////////////////

// Connecting to SQL, credits to harbu
public sql_init()
{
	new host[64], username[33], password[33], dbname[33], error[256]
	get_cvar_string("economy_mysql_host",host,63)
	get_cvar_string("economy_mysql_user",username,32) 
	get_cvar_string("economy_mysql_pass",password,32) 
	get_cvar_string("economy_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,255)
	if (dbc == SQL_FAILED)
	{
		set_fail_state("[CarMod] Couldn't connect to SQL Database.^n")
		server_print("[CarMod] Couldn't connect to SQL Database.^n")
	}
	else
	{
		server_print("[CarMod] Connected to SQL, have a nice day!^n")
		CheckTables()
	}
}

// Checking if tables exist or not, credits to hawk552
CheckTables(){
	if(dbc == SQL_FAILED) return PLUGIN_HANDLED
	
	format(query,255,"CREATE TABLE IF NOT EXISTS carmod (steamid varchar(64), fine int(32), gas int(32), brokencar int(32), cartype int(32), engine int(32), gastank int(32), `access` text NOT NULL, carextras int(32))")
	dbi_query(dbc,"%s",query)
	format(query,255,"CREATE TABLE IF NOT EXISTS cardatabase (carmodel varchar(64), speed int(32), friction int(32), maxfuel int(32), maxseats int(32))")
	dbi_query(dbc,"%s",query)
	return PLUGIN_CONTINUE
}

// credits to harbu
public select_string(id,table[],index[],condition[],equals[],output[])
{
	new query[256]
	format(query,255,"SELECT %s FROM %s WHERE %s='%s'",index,table,condition,equals)
	result = dbi_query(dbc,"%s",query)
	if(result >= RESULT_OK)
	{
		dbi_nextrow(result)
		dbi_field(result,1,output,64)
		dbi_free_result(result)
	}
	
}

// credits to remo
public initcc() 
{
	new players[32], num
	get_players(players,num)
	
	for(new i=0;i<num;i++)
	{
		checkcops(players[i])
	}
	return PLUGIN_HANDLED
}

// credits to remo
public checkcops(id) 
{
	new authid[33]
	get_user_authid(id,authid,32) 
	
	new buffer[33], JobID
	select_string(id,"money","JobID","steamid",authid,buffer)
	JobID = str_to_num(buffer)
	if(JobID > get_cvar_num("rp_police_start") && JobID < get_cvar_num("rp_police_end"))
	{
		g_iscop[id] = 1
	}
	else
	{
		g_iscop[id] = 0
	}
	return PLUGIN_HANDLED
}

public get_carstats(id,type)
{
	new broken, fine, gas, engine, tank, steamid[33]
	get_user_authid(id,steamid,32)
	switch(type)
	{
		case 1: format(query,255,"SELECT brokencar FROM carmod WHERE steamid='%s'",steamid)
			case 2: format(query,255,"SELECT fine FROM carmod WHERE steamid='%s'",steamid)
			case 3: format(query,255,"SELECT gas FROM carmod WHERE steamid='%s'",steamid)
			case 4: format(query,255,"SELECT engine FROM carmod WHERE steamid='%s'",steamid)
			case 5: format(query,255,"SELECT gastank FROM carmod WHERE steamid='%s'",steamid)
		}
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		switch(type)
		{
			case 1: broken = dbi_field(result,1)
				case 2: fine = dbi_field(result,1)
				case 3: gas = dbi_field(result,1)
				case 4: engine = dbi_field(result,1)
				case 5: tank = dbi_field(result,1)
			}
	}
	else
	{
		dbi_free_result(result)
		return 0
	}
	dbi_free_result(result)
	switch(type)
	{
		case 1: if(broken > 0) return broken
			case 2: if(fine > 0) return fine
			case 3: if(gas > 0 ) return gas
			case 4: if(engine > 0) return engine
			case 5: if(tank > 0) return tank
		}
	return 0
}

public get_maxfuel(carmodel[])
{
	new mfuel
	format(query,255,"SELECT maxfuel FROM cardatabase WHERE carmodel='%s'",carmodel)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		mfuel = dbi_field(result,1)
	}
	else
	{
		dbi_free_result(result)
		return 0
	}
	dbi_free_result(result)
	if(mfuel > 0)
	{
		return mfuel
	}
	return 0
}

public bombexplode(startloc[3], spritename, scale, framerate, flags)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(3) // TE_EXPLOSION
	write_coord(startloc[0])
	write_coord(startloc[1])
	write_coord(startloc[2]) // start location
	write_short(spritename) // spritename
	write_byte(scale) // scale of sprite
	write_byte(framerate) // framerate of sprite
	write_byte(flags) // flags
	message_end()
}

public edit_value(id,table[],index[],func[],amount)
{
	if(dbc < SQL_OK)
	{
		return PLUGIN_HANDLED
	}
	new authid[33], query[256]
	get_user_authid(id,authid,32)
	if(equali(func,"="))
	{
		format(query,255,"UPDATE %s SET %s=%i WHERE steamid='%s'",table,index,amount,authid)
	}
	else
	{
		format(query,255,"UPDATE %s SET %s=%s%s%i WHERE steamid='%s'",table,index,index,func,amount,authid)
	}
	dbi_query(dbc,"%s",query)
	return PLUGIN_HANDLED
}

stock player_exist(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return 0
	
	if(!is_user_alive(id) && !is_user_connected(id))
		return 0
	
	return 1
}

stock get_id_by_steamid(steamid[33])
{
	new authid[33]
	for(new i=0;i<33;i++)
	{
		get_user_authid(i,authid,32)
		if(equali(authid,steamid) && is_user_alive(i))
			return i
	}
	return 0
}

stock find_car_by_owner(id)
{
	new ent, Float:origin[3],Float:radius = 128.0, classname[64], locked[64], authid[64]
	get_user_authid(id,authid,63)
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			entity_get_string(ent,EV_SZ_target,locked,63)
			if(equali(locked,authid))
				return ent
		}
	}
	return 0
}

stock find_car_by_origin_steamid(Float:origin[3],authid[33])
{
	new ent, classname[64], Float:radius = 300.0
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			get_user_authid(ent,authid,32)
			entity_get_string(ent,EV_SZ_target,authid,32)
			return ent
		}
	}
	return 0
}

public sethijackercar(id,authid[33])
{
	new ent, Float:origin[3],Float:radius = 300.0, classname[64]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			entity_set_string(ent,EV_SZ_target,authid)
			entity_set_string(ent,EV_SZ_noise,authid)
		}
	}
	return 1
}

// credits to harbu
stock explode( output[][], input[], delimiter) 
{ 
	new nIdx = 0
	new iStringSize
	while ( input[iStringSize] ) 
		iStringSize++ 
	new nLen = (1 + copyc( output[nIdx], iStringSize-1, input, delimiter ))
	
	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], iStringSize-1, input[nLen], delimiter ))
	return nIdx + 1
}

// credits to harbu
stock get_item_amount(id,itemid,table[],customid[]="")
{
	new authid[32], amount, query[256]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
	format(query,255,"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new field[MAXIUMSTR]
		new output[ITEMS][32]
		dbi_field(result,1,field,MAXIUMSTR-1)
		dbi_free_result(result)
		new total = explode(output,field,' ')
		for(new i=0;i<total;i++)
		{
			new output2[2][32]
			explode(output2,output[i],'|')
			if(str_to_num(output2[0]) == itemid)
			{
				amount = str_to_num(output2[1]
				)
				dbi_free_result(result)
				return amount
			}
		}
	}
	dbi_free_result(result)
	return amount
}

// For Adding/Subtracting Items Quickly,  credits to harbu
stock set_item_amount(id,func[],itemid,amount,table[],customid[]="")
{
	new authid[32], query[256], itemfield[MAXIUMSTR]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
	new currentamount = get_item_amount(id,itemid,table,customid)
	format(query,255,"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,itemfield,MAXIUMSTR-1)
		dbi_free_result(result)
		
		if(equali(func,"-"))
		{
			new string[32]
			format(string,31," %i|%i",itemid,currentamount)
			if(containi(itemfield,string) != -1)
			{
				if((currentamount - amount) <= 0)
				{
					replace(itemfield,MAXIUMSTR-1,string,"")
				}
				else
				{
					new newstring[32]
					format(newstring,31," %i|%i",itemid,currentamount-amount)
					replace(itemfield,MAXIUMSTR-1,string,newstring)
				}
				format(query,255,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,query)
			}
			else
			{
				client_print(id,print_chat,"[ItemMod] Error #150 LOOP. Please contact an administrator^n")
				dbi_free_result(result)
				return PLUGIN_HANDLED
			}
		}
		if(equali(func,"+"))
		{
			if(get_item_amount(id,itemid,table,authid) == 0)
			{
				new str[32]
				format(str,31," %i|%i",itemid,(currentamount +amount))
				add(itemfield,sizeof(itemfield),str)
				format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,query)
			}
			else
			{
				if(currentamount > 0)
				{
					new newstr[32], oldstr[32]
					format(oldstr,31," %i|%i",itemid,currentamount)
					format(newstr,31," %i|%i",itemid,(currentamount +amount))
					replace(itemfield,255,oldstr,newstr)
					format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
					dbi_query(dbc,query)
				}
				else
				{
					client_print(id,print_chat,"[ItemMod] Error #200. Please contact an administrator^n")
					dbi_free_result(result)
					return PLUGIN_HANDLED
				}
			}
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

// credits to harbu
public is_user_database(id)
{
	if(dbc < SQL_OK) return 0
	
	new authid[33], query[256]
	get_user_authid(id,authid,32)
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_free_result(result)
		return 1
	}
	else
	{
		dbi_free_result(result)
	}
	return 0
}


public overhear(id,distance,Speech[])
{
	new OriginA[3], OriginB[3]
	get_user_origin(id,OriginA)
	new players[32], num
	get_players(players,num,"ac")
	for(new b=0;b<num;b++)
	{
		if(id!=players[b])
		{
			get_user_origin(players[b],OriginB)
			if(distance == -1) 
			{
				client_print(players[b],print_chat,Speech)
			}
			else
			{
				if(get_distance(OriginA,OriginB) <= distance) 
				{
					client_print(players[b],print_chat,Speech)
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public horn(id)
{
	if(g_incar[id])
	{
		emit_sound(id, CHAN_ITEM, "carmod/car_horn2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public siren(id) 
{
	if(g_incar[id])
	{
		
		if(g_iscop[id] || equali(g_carmodel[id],"car_ambulance"))
		{
			emit_sound(id, CHAN_ITEM, "carmod/siren2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return PLUGIN_HANDLED
		}
		else
		{
			client_print(id,print_chat,"[CarMod] You must be a cop or a doctor/medic.")
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public headlights(id)
{
	if(incar[id])
	{
		
		if(g_usedlight[id] < 1)
		{
			message_begin(MSG_BROADCAST, gmsgItems, {0,0,0}) 
			write_byte(id)
			write_byte(4)
			message_end()
			
			g_usedlight[id] += 1
			
			entity_set_int(id,EV_INT_effects,entity_get_int(id,EV_INT_effects) | EF_DIMLIGHT)
			client_print(id,print_chat,"[CarMod] You turned on your headlight.")
		}
		else
		{
			message_begin(MSG_BROADCAST, gmsgItems, {0,0,0}) 
			write_byte(id)
			write_byte(0)
			message_end()
			
			g_usedlight[id] = 0
			
			entity_set_int(id,EV_INT_effects,entity_get_int(id,EV_INT_effects) & ~EF_DIMLIGHT)
			client_print(id,print_chat,"[CarMod] You turned off your headlights.")
		}
	}
	return PLUGIN_HANDLED
}

public userkeys(id)
{
	new tauthid[33], output[33][32], keys[2048]
	get_user_authid(1,tauthid,32)
	
	new Float:origin[3], authid[33]
	entity_get_vector(id,EV_VEC_origin,origin)
	find_car_by_origin_steamid(origin,authid)
	
	format(query,255,"SELECT access FROM carmod WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	explode(output, keys, '|')
	if(equal(keys,tauthid))
	{
		g_key[id] = 1
	}
	return PLUGIN_HANDLED
}

public plugin_end()
{
	dbi_close(dbc)
}
/////////////////////////////////////////////////
///// END OF STOCKS AND IMPORTANT FUNCTIONS /////
////////////////////////////////////////////////
