#include <apollorp> // apollo crap
#include <amxmodx> // Amx mod include definitions
#include <fun> // Fun Module
#include <amxmisc> // Useful functions
#include <engine> // Engine Plugin

new PLUGIN[]="AMX TNT"
new AUTHOR[]="CubicVirtuoso"
new VERSION[]="3.00"

new tntarray[32][3]
new tnts[32]
new SpriteExplosion
new functionadmin = ADMIN_ALL
new enable = 1
new Float:maxhealth = 2000.0

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR) // Register Function
	//register_concmd("say /placetnt", "CMD_placetnt", functionadmin)
	//register_concmd("say /bigboom", "CMD_explodetnt", ADMIN_USER)
	register_concmd("amx_tnt_adminonly", "CMD_adminonly", ADMIN_SLAY, "<1/0> ")
	register_concmd("amx_tnt_setdmg", "CMD_maxdamage", ADMIN_SLAY, "damage ")
	register_concmd("amx_tnt", "CMD_enabletnt", ADMIN_SLAY, "<1/0> ")
	
	for (new i=0; i<32; i++)
	{
		for (new k=0; k<3; k++)
		{
			tntarray[i][k] = 0
		}
	}
}

public ARP_RegisterItems()
{
	ARP_RegisterItem("TNT Bomb","CMD_placetnt","Place a TNT Bomb.",1)
	ARP_RegisterItem("TNT Detonater","CMD_explodetnt","Explode TNT Bomb.")
}

public plugin_precache()
{
	precache_model("models/amxtnt.mdl") // precache tnt model
	SpriteExplosion = precache_model("sprites/bexplo.spr") // precache explosion sprite
}

public CMD_adminonly(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)) // Checks if the command user has access
		return PLUGIN_HANDLED
		
	new Arg1, Arg1Str[2] // value
	read_argv(1, Arg1Str, 1) // reads arg
	Arg1 = str_to_num(Arg1Str)
	
	if (Arg1 == 1)
	{
		client_print(id,print_console,"Set to Admin Only")
		functionadmin = ADMIN_SLAY
		return PLUGIN_HANDLED
	}
	else if (Arg1 == 0)
	{
		client_print(id,print_console,"All Players can use")
		functionadmin = ADMIN_ALL
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_console,"Invalid argument")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public CMD_maxdamage(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)) // Checks if the command user has access
		return PLUGIN_HANDLED
		
	new Arg1, Arg1Str[2] // value
	read_argv(1, Arg1Str, 4) // reads arg
	Arg1 = str_to_num(Arg1Str)
	
	
	if(Arg1 < 0)
	{
		client_print(id,print_console,"Invalid setting")
		return PLUGIN_HANDLED
	}
	else
	{
		new Float:floathealth 
		floathealth = float(Arg1)
		maxhealth = floathealth
		client_print(id,print_console,"MaxHP Set")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public CMD_enabletnt(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)) // Checks if the command user has access
		return PLUGIN_HANDLED
	
	new Arg1, Arg1Str[2] // value
	read_argv(1, Arg1Str, 1) // reads arg
	Arg1 = str_to_num(Arg1Str)
	
	if (Arg1 == 1)
	{
		client_print(id,print_console,"TNT Enabled")
		enable = 1
		return PLUGIN_HANDLED
	}
	else if (Arg1 == 0)
	{
		client_print(id,print_console,"TNT Disabled")
		enable = 0
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_console,"Invalid argument")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public client_command(id)
{
	new Arg[64] = -1
	read_argv(1, Arg, 55)
	new intvalue
	
	if(containi(Arg, "/placetnt ")==0)
	{
		if(Arg[12] >= 0)
		{
			new value[3]
			value[0] = Arg[10]
			value[1] = Arg[11]
			value[2] = Arg[12]
			intvalue = str_to_num(value)
		}
		else if(Arg[11] >= 0)
		{
			new value[2]
			value[0] = Arg[10]
			value[1] = Arg[11]
			intvalue = str_to_num(value)
		}
		else
		{
			intvalue = Arg[10]
		}
		
		new Float:floatvalue
		floatvalue = float(intvalue)
		
		if(functionadmin != ADMIN_ALL && !(get_user_flags(id) & functionadmin))
		{
			client_print(id,print_chat,"TNT Enabled for Admins only")
			return PLUGIN_HANDLED
		}
		
		if(enable == 1)
		{
			new location[3]
			get_user_origin(id,location)
			
			if (tntarray[id][0] != 0)
			{
				client_print(id, print_chat, "You already have TNT Placed")
				return PLUGIN_HANDLED
			}
			else
			{
				tntarray[id][0] = location[0]
				tntarray[id][1] = location[1]
				tntarray[id][2] = location[2]
				
				tnts[id] = create_entity("env_sprite") // creates enterance ball
				if (!tnts[id]) // if not exist
					return PLUGIN_HANDLED
					
				location[2] = location[2] - 30
				
				new Float:LocVec[3]
				IVecFVec(location, LocVec)
							
				entity_set_string(tnts[id], EV_SZ_classname, "TNT Model") // set name
				entity_set_edict(tnts[id], EV_ENT_owner, id) // set owner
				entity_set_int(tnts[id], EV_INT_solid, 1) // not a solid but interactive
				entity_set_int(tnts[id], EV_INT_movetype, 0) // set move type to toss
				entity_set_model(tnts[id], "models/amxtnt.mdl") // enterance sprite
				entity_set_origin(tnts[id], LocVec) // start posistion 
				DispatchSpawn(tnts[id]) // Dispatches the Fire
				
				set_task(floatvalue,"timedexplo",id)
				
				return PLUGIN_HANDLED
			}
			
			return PLUGIN_HANDLED
		}
		else
		{
			client_print(id, print_chat, "TNT is not enabled")
			return PLUGIN_HANDLED
		}
		
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public timedexplo(id)
{
	if (tntarray[id][0] == 0)
	{
		client_print(id, print_chat, "You do not have any TNT placed")
		return PLUGIN_HANDLED
	}
	else
	{
		new location[3]
		new players[32]
		new playercount
		
		location[0] = tntarray[id][0]
		location[1] = tntarray[id][1]
		location[2] = tntarray[id][2]
		
		explode(location, SpriteExplosion, 30, 10, 0)
		
		get_players(players,playercount,"a")
		
		for (new i=0; i<playercount; i++)
		{
			new playerlocation[3]
			new resultdistance
			
			get_user_origin(players[i], playerlocation)
			
			resultdistance = get_distance(playerlocation,location)
			
			if(resultdistance < 100)
			{
				fakedamage(players[i],"TNT",maxhealth,DMG_BLAST)
			}
		}
		
		removetnt(id)
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public CMD_placetnt(id, ItemId, cid)
{	
	if(enable == 1)
	{
		new location[3]
		get_user_origin(id,location)
		
		if (tntarray[id][0] != 0)
		{
			client_print(id, print_chat, "You already have TNT Placed")
			return PLUGIN_HANDLED
		}
		else
		{
			tntarray[id][0] = location[0]
			tntarray[id][1] = location[1]
			tntarray[id][2] = location[2]
			
			tnts[id] = create_entity("env_sprite") // creates enterance ball
			if (!tnts[id]) // if not exist
				return PLUGIN_HANDLED
				
			location[2] = location[2] - 30
			
			new Float:LocVec[3]
			IVecFVec(location, LocVec)
						
			entity_set_string(tnts[id], EV_SZ_classname, "TNT Model") // set name
			entity_set_edict(tnts[id], EV_ENT_owner, id) // set owner
			entity_set_int(tnts[id], EV_INT_solid, 1) // not a solid but interactive
			entity_set_int(tnts[id], EV_INT_movetype, 0) // set move type to toss
			entity_set_model(tnts[id], "models/amxtnt.mdl") // enterance sprite
			entity_set_origin(tnts[id], LocVec) // start posistion 
			DispatchSpawn(tnts[id]) // Dispatches the Fire
			
			return PLUGIN_HANDLED
		}
		
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id, print_chat, "TNT is not enabled")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public CMD_explodetnt(id, level, cid)
{
	if (tntarray[id][0] == 0)
	{
		client_print(id, print_chat, "You do not have any TNT placed")
		return PLUGIN_HANDLED
	}
	else
	{
		new location[3]
		new players[32]
		new playercount
		
		location[0] = tntarray[id][0]
		location[1] = tntarray[id][1]
		location[2] = tntarray[id][2]
		
		explode(location, SpriteExplosion, 30, 10, 0)
		
		get_players(players,playercount,"a")
		
		for (new i=0; i<playercount; i++)
		{
			new playerlocation[3]
			new resultdistance
			
			get_user_origin(players[i], playerlocation)
			
			resultdistance = get_distance(playerlocation,location)
			
			if(resultdistance < 100)
			{
				fakedamage(players[i],"TNT",maxhealth,DMG_BLAST)
			}
		}
		
		removetnt(id)
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

public explode(startloc[3], spritename, scale, framerate, flags)
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

public removetnt(id)
{
	remove_entity(tnts[id])
	
	tntarray[id][0] = 0
	tntarray[id][1] = 0
	tntarray[id][2] = 0
	
	return PLUGIN_CONTINUE
}