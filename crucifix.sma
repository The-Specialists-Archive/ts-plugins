/*=======================================*\
|* Crucifix                              *|
|*=======================================*|
|* ©Copyright 2006 by James J. Kelly Jr. *|
\*=======================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <engine_stocks>
#include <fun>

#define Author	"James J. Kelly Jr."
#define Version	"Alpha"
#define Plugin	"CrucifixMod"

#define ACT_IDLE				0

#define Painful_Sound			"player/pl_fallpain3.wav"

#define model_crucifix			"models/crucifix.mdl"
#define model_crucifix_offset	62.0

#define PI						3.14159265358979323846

#define TE_BLOOD		103
#define TE_BLOODSTREAM	101

new gPlayerCrucifix[32];
new gPlayerLastUpdate[32];

public plugin_init()
{
	
	register_plugin(Plugin,Version,Author);
	
	register_srvcmd("item_crucifix","item_crucifix");
	
	register_event("DeathMsg","client_death","a");
	
	set_task(0.01,"crucifixMonitor",0,"",0,"b");
	
}

public plugin_precache()
{

	precache_model(model_crucifix);
	
	precache_sound(Painful_Sound);
		
}

public Float:degtorad(Float:angle)
{
	return angle * PI / 180;
}

public Float:radtodeg(Float:angle)
{
	return angle * 180 / PI;
}

public client_connect(id)
{

	if( gPlayerCrucifix[id] > 0 && is_valid_ent(gPlayerCrucifix[id]) )
	{
		
		new params[1];
		params[0] = gPlayerCrucifix[id];
		
		set_task(5.0,"crucifixRemove",0,params,1)
		
	}
	
	gPlayerCrucifix[id] = 0;
		
}

public client_disconnect(id)
{
	
	if( gPlayerCrucifix[id] > 0 && is_valid_ent(gPlayerCrucifix[id]) )
	{
		
		new params[1];
		params[0] = gPlayerCrucifix[id];
		
		set_task(5.0,"crucifixRemove",0,params,1)
		
	}

	gPlayerCrucifix[id] = 0;
		
}

public client_death()
{

	new id = read_data(2);
	
	if( gPlayerCrucifix[id] > 0 && is_valid_ent(gPlayerCrucifix[id]) )
	{
		
		new params[1];
		params[0] = gPlayerCrucifix[id];
		
		set_task(5.0,"crucifixRemove",0,params,1)
		
	}
	
	gPlayerCrucifix[id] = 0;
		
}

public client_PreThink(id) 
{ 

	if( gPlayerCrucifix[id] > 0 && is_valid_ent(gPlayerCrucifix[id]) )
	{
	
		new bufferStop = entity_get_int(id,EV_INT_button);

		if( bufferStop != 0 )
		{
			entity_set_int(id,EV_INT_button,bufferStop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE & ~IN_DUCK);
		} 

		if((bufferStop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) { 
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP) 
		}
	
	}
	
	return PLUGIN_CONTINUE;
	
}

public effectBlood(origin[3])
{
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BLOODSTREAM);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2])  
	write_coord(0);
	write_coord(0);
	write_coord(1);
	write_byte(249);
	write_byte(50);
	message_end();
	
	return PLUGIN_HANDLED;
	
}

public crucifixRemove(params[])
{
	
	if( params[0] > 0 && is_valid_ent(params[0]) )
	{
	
		remove_entity(params[0]);
			
	}
	
	return PLUGIN_HANDLED;
	
}

public crucifixMonitor()
{

	new player[32], playerCount;
	get_players(player,playerCount,"ac");
	
	for( new i = 0; i < playerCount; i++ )
	{
	
		new id = player[i];
		
		if( gPlayerCrucifix[id] > 0 && is_valid_ent(gPlayerCrucifix[id]) )
		{
			
			set_user_maxspeed(id,0.1);	
			
			new entOrigin[3];
			new Float:fentOrigin[3];
			
			set_user_velocity(id,fentOrigin);
			
			entity_get_vector(gPlayerCrucifix[id],EV_VEC_origin,fentOrigin);

			new Float:fentAngles[3];
			entity_get_vector(gPlayerCrucifix[id],EV_VEC_angles,fentAngles);
			
			fentOrigin[0] += floatcos(fentAngles[2]);
			fentOrigin[1] += floatsin(fentAngles[2]); 
			
			fentOrigin[2] += model_crucifix_offset;
			
			FVecIVec(fentOrigin,entOrigin);
				
			set_user_origin(id,entOrigin);
			
			if( (get_systime() - gPlayerLastUpdate[id]) >= 5 )
			{
				
				fakedamage(id,"Crucification",1.0,DMG_GENERIC);
				
				emit_sound(id, CHAN_ITEM, Painful_Sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
				
				gPlayerLastUpdate[id] = get_systime();
					
			}
			
		}
			
	}
	
	return PLUGIN_HANDLED;
		
}

/*
public crucify(id)
{
	
	new entId = create_entity("info_target");
	
	if( !entId ) return PLUGIN_HANDLED;
	
	entity_set_string(entId,EV_SZ_classname,"item_crucifix");
	
	entity_set_float(entId,EV_FL_animtime,30.0);
	entity_set_float(entId,EV_FL_framerate,0.5);
	entity_set_int(entId,EV_INT_sequence,ACT_IDLE);
	
	entity_set_int(entId,EV_INT_solid,SOLID_TRIGGER);
	entity_set_int(entId,EV_INT_movetype,MOVETYPE_NONE);
	
	entity_set_model(entId,model_crucifix);

	new Float:minBox[3] = { -20.0, -20.0, -20.0 };
	new Float:maxBox[3] = { 20.0, 20.0, -20.0 };
	
	entity_set_size(entId,minBox,maxBox);
	
	new Float:fplayerAngles[3];
	new playerAngles[3];
	
	entity_get_vector(id,EV_VEC_angles,fplayerAngles);
	
	FVecIVec(fplayerAngles,playerAngles);
	
	fplayerAngles[0] = 0.0;
	fplayerAngles[2] = 0.0;
	
	entity_set_vector(entId,EV_VEC_angles,fplayerAngles);
	
	new Float:fplayerOrigin[3];
	entity_get_vector(id,EV_VEC_origin,fplayerOrigin);
	
	entity_set_vector(entId,EV_VEC_origin,fplayerOrigin);
	
	new oldSolid = entity_get_int(id,EV_INT_solid);
	entity_set_int(id,EV_INT_solid,SOLID_NOT);
	
	drop_to_floor(entId);
	
	entity_set_int(id,EV_INT_solid,oldSolid);
	
	DispatchSpawn(entId);
	
	gPlayerLastUpdate[id] = get_systime();
	
	gPlayerCrucifix[id] = entId;

	return PLUGIN_HANDLED;
	
}
*/

public item_crucifix()
{
	
	new strArguments[3][32];
	
	read_argv(1,strArguments[0],31);
	read_argv(2,strArguments[1],31);
	read_argv(3,strArguments[2],31);
	
	if( equali(strArguments[0],"") || equali(strArguments[1],"") ) return PLUGIN_HANDLED;
	
	new numArguments[3];
	
	numArguments[0] = str_to_num(strArguments[0]);
	numArguments[1] = str_to_num(strArguments[1]);
	numArguments[2] = str_to_num(strArguments[2]);
	
	if( !(is_user_connected(numArguments[0]) && is_user_alive(numArguments[0])) )
	{
	
		return PLUGIN_HANDLED;
			
	}
	
	if( numArguments[1] > 0 )
	{
		if( !(is_user_connected(numArguments[1]) && is_user_alive(numArguments[1])) )
		{
	
			client_print(numArguments[0],print_chat,"[CrucifixMod] You must be looking at someone to crucify them!");
			return PLUGIN_HANDLED;
		
		}
	}
	
	new playerName[2][64];
	get_user_name(numArguments[0],playerName[0],63);
	get_user_name(numArguments[1],playerName[1],63);
	
	if( gPlayerCrucifix[numArguments[1]] > 0 )
	{
	
		client_print(numArguments[0],print_chat,"[CrucifixMod] %s is already crucified!",playerName[1]);
		
		return PLUGIN_HANDLED;
			
	}
	
	for( new i = 1; i <= 35; i++ )
	{
		client_cmd(numArguments[1],"weapon_%d; drop",i);
	}
	
	new entId = create_entity("info_target");
	
	if( !entId ) return PLUGIN_HANDLED;
	
	entity_set_string(entId,EV_SZ_classname,"item_crucifix");
	
	entity_set_float(entId,EV_FL_animtime,30.0);
	entity_set_float(entId,EV_FL_framerate,0.5);
	entity_set_int(entId,EV_INT_sequence,ACT_IDLE);
	
	entity_set_float(entId,EV_FL_max_health,99999.0);
	entity_set_float(entId,EV_FL_health,99999.0);
	
	entity_set_int(entId,EV_INT_solid,SOLID_BBOX);
	entity_set_int(entId,EV_INT_movetype,MOVETYPE_NONE);
	
	entity_set_model(entId,model_crucifix);

	new Float:minBox[3] = { -2.5, -2.5, -2.5 };
	new Float:maxBox[3] = { 2.5, 2.5, 2.5 };
	
	entity_set_size(entId,minBox,maxBox);
	
	new Float:fplayerAngles[3];
	new playerAngles[3];
	
	entity_get_vector(numArguments[1],EV_VEC_angles,fplayerAngles);
	
	FVecIVec(fplayerAngles,playerAngles);
	
	fplayerAngles[0] = 0.0;
	fplayerAngles[2] = 0.0;
	
	entity_set_vector(entId,EV_VEC_angles,fplayerAngles);

	new Float:fplayerOrigin[3];
	entity_get_vector(numArguments[1],EV_VEC_origin,fplayerOrigin);
	
	//fplayerOrigin[2] -= 40;
	entity_set_origin(entId,fplayerOrigin);
	
	new oldSolid = entity_get_int(numArguments[1],EV_INT_solid);
	entity_set_int(numArguments[1],EV_INT_solid,SOLID_NOT);
	
	drop_to_floor(entId);
	
	entity_set_int(numArguments[1],EV_INT_solid,oldSolid);
	
	//DispatchSpawn(entId);
	
	if( numArguments[1] >= 0 )
	{
		
		gPlayerLastUpdate[numArguments[1]] = get_systime();
		
		gPlayerCrucifix[numArguments[1]] = entId;
	
		callfunc_begin("cuffaction","HarbuRPAlpha.amxx");
		callfunc_push_int(numArguments[1]);
		callfunc_end();
		
		client_print(numArguments[0],print_chat,"[CrucifixMod] You have crucified %s!",playerName[1]);
		client_print(numArguments[1],print_chat,"[CrucifixMod] You have been crucified by %s!",playerName[0]);
		
	}
	else
	{
		
		gPlayerLastUpdate[numArguments[0]] = get_systime();
	
		gPlayerCrucifix[numArguments[0]] = entId;
	
		callfunc_begin("cuffaction","HarbuRPAlpha.amxx");
		callfunc_push_int(numArguments[0]);
		callfunc_end();
		
		client_print(numArguments[0],print_chat,"[CrucifixMod] You have crucified yourself!",playerName[1]);
		
	}
	
	if( numArguments[2] > 0 )
	{
		
		new origin[3];
		new Float:forigin[3];
		
		entity_get_vector(entId,EV_VEC_origin,forigin);
		
		FVecIVec(forigin,origin);
		
		server_cmd("server_spawnflame %i %i %i",origin[0],origin[1],origin[2]);
		server_exec();
			
	}
	
	return PLUGIN_HANDLED;
	
}