/*

    LandmineMod for AMXX 1.01 or greater, adds dropable landmines to Half-Life
    Copyright (C) 2006  James J. Kelly Jr.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <engine_stocks>
#include <string>
#include <fun>

#define Author	"James J. Kelly Jr."
#define Version	"FINAL"
#define Plugin	"LandmineMod"

#define WORLD_MODEL "models/landmine.mdl"
#define WORLD_MODEL_STEALTH "models/landmine_stealth.mdl"

#define SOUND_STEP "weapons/gr_pull.wav"

#define SPRITE_EXPLOSION "sprites/explode1.spr"

#define TASK_BEGIN 60000

#define DETONATE_DISTANCE 50.0
#define KILL_DISTANCE 200.0

#define DEFUSE_DISTANCE 100

new EXPLOSION;

new DEFUSE_IDENT[32];

public plugin_init()
{

	register_plugin(Plugin,Version,Author);
	
	register_srvcmd("item_landmine","item_landmine");
	register_srvcmd("item_landmine_defuse","item_landmine_defuse");
	
	register_clcmd("defuse_landmine","test_defuse_landmine");
	register_clcmd("drop_landmine","test_landmine");
	register_clcmd("drop_landmine_stealth","test_landmine_stealth");
	
	register_cvar("landmine_allowConsoleDrop","0");
	register_cvar("landmine_allowConsoleDefuse","0");
	
	register_event("DeathMsg","client_death","a")
	
	register_touch("func_landmine","player","landmineExplode");
	
	server_cmd("exec addons/amxmodx/configs/landmine.cfg;");
	server_exec();

}

public plugin_precache()
{

	precache_model(WORLD_MODEL);
	precache_model(WORLD_MODEL_STEALTH);
	
	precache_sound(SOUND_STEP);
	
	EXPLOSION = precache_model(SPRITE_EXPLOSION);

}

public client_connect(id)
{

	DEFUSE_IDENT[id] = 0;
	
	return PLUGIN_CONTINUE;

}

public client_disconnect(id)
{

	DEFUSE_IDENT[id] = 0;
	
	return PLUGIN_CONTINUE;

}

public client_death()
{

	new id = read_data(2);
	
	DEFUSE_IDENT[id] = 0;
	
	return PLUGIN_CONTINUE;

}

public test_defuse_landmine(id)
{

	if( get_cvar_num("landmine_allowConsoleDefuse") < 1 ) return PLUGIN_CONTINUE;

	server_cmd("item_landmine_defuse %i;",id);
	server_exec();

	return PLUGIN_HANDLED;

}

public test_landmine(id)
{

	if( get_cvar_num("landmine_allowConsoleDrop") < 1 ) return PLUGIN_CONTINUE;

	server_cmd("item_landmine %i 0;",id);
	server_exec();
	
	return PLUGIN_HANDLED;

}

public test_landmine_stealth(id)
{

	if( get_cvar_num("landmine_allowConsoleDrop") < 1 ) return PLUGIN_CONTINUE;

	server_cmd("item_landmine %i 1;",id);
	server_exec();
	
	return PLUGIN_HANDLED;

}

public item_landmine_defuse()
{

	new strArguments[1][32];
	
	read_argv(1,strArguments[0],31);
	
	if( equali(strArguments[0],"") ) return PLUGIN_HANDLED;
	
	new numArguments[1];
	
	numArguments[0] = str_to_num(strArguments[0]);
	
	if( !numArguments[0] || !(is_user_connected(numArguments[0]) && is_user_alive(numArguments[0])) ) return PLUGIN_HANDLED;
	
	new entId, entBody;
	
	get_user_aiming(numArguments[0],entId,entBody,DEFUSE_DISTANCE);
	
	if( !entId || !is_valid_ent(entId) ) return PLUGIN_HANDLED;
	
	new mineClass[32];
	
	entity_get_string(entId,EV_SZ_classname,mineClass,31);
	
	if( equali(mineClass,"func_landmine") )
	{
	
		new playerOrigin[3];
		
		get_user_origin(numArguments[0],playerOrigin);
		
		new Float:fmineOrigin[3];
		new mineOrigin[3];
		
		entity_get_vector(entId,EV_VEC_origin,fmineOrigin);
		FVecIVec(fmineOrigin,mineOrigin);
		
		if( get_distance(playerOrigin,mineOrigin) <= DEFUSE_DISTANCE )
		{
		
			DEFUSE_IDENT[numArguments[0]] = random_num(10000,50000);
		
			client_print(numArguments[0],print_chat,"[Landmine] You are defusing the landmine!^n");
		
			entity_set_edict(entId,EV_ENT_owner,numArguments[0]);
		
			new taskParams[3];
			taskParams[0] = entId;
			taskParams[1] = numArguments[0];
			taskParams[2] = DEFUSE_IDENT[numArguments[0]];
		
			set_task(float(random_num(8,15)),"landmineDefuse",0,taskParams,3,"a",1);
		
		}
	
	}

	return PLUGIN_HANDLED;

}

public landmineDefuse(params[],id)
{

	if( !params[0] || !is_valid_ent(params[0]) ) return PLUGIN_HANDLED;
	if( !params[1] || !(is_user_connected(params[1]) && is_user_alive(params[1])) ) return PLUGIN_HANDLED;

	if( params[2] != DEFUSE_IDENT[params[1]] || !(DEFUSE_IDENT[params[1]] >= 10000 && DEFUSE_IDENT[params[1]] <= 50000) ) return PLUGIN_HANDLED;
		
	new playerOrigin[3];
		
	get_user_origin(params[1],playerOrigin);
		
	new Float:fmineOrigin[3];
	new mineOrigin[3];
		
	entity_get_vector(params[0],EV_VEC_origin,fmineOrigin);
	FVecIVec(fmineOrigin,mineOrigin);
		
	if( get_distance(playerOrigin,mineOrigin) <= DEFUSE_DISTANCE )
	{
		
		new mineOwner = entity_get_edict(params[0],EV_ENT_owner);
		
		remove_entity(params[0]);
		
		new deathChance = random_num(1,8);
		
		if( mineOwner == params[0] ) deathChance = 4;
			
		if( deathChance == 4 )
		{
			
			client_print(params[1],print_chat,"[Landmine] OH SHIT! You cut the wrong wire!^n");
				
			explodeArea(mineOrigin,KILL_DISTANCE);
			
		}
		else
		{
			
			client_print(params[1],print_chat,"[Landmine] You have defused the mine!^n");
			
		}
		
		DEFUSE_IDENT[params[1]] = 0;
		
	}
		
	return PLUGIN_HANDLED;
		
}

public item_landmine()
{

	new strArguments[2][32];
	
	read_argv(1,strArguments[0],31);
	read_argv(2,strArguments[1],31);
	
	if( equali(strArguments[0],"") ) return PLUGIN_HANDLED;
	
	new numArguments[2];
	
	numArguments[0] = str_to_num(strArguments[0]);
	numArguments[1] = str_to_num(strArguments[1]);
	
	if( !numArguments[0] || !(is_user_connected(numArguments[0]) && is_user_alive(numArguments[0])) ) return PLUGIN_HANDLED;
	
	new playerPos[3];
	get_user_origin(numArguments[0],playerPos);
	
	new Float:fPlayerPos[3];
	IVecFVec(playerPos,fPlayerPos);
	
	new entId = create_entity("func_wall");
	
	if( !entId || !is_valid_ent(entId) ) return PLUGIN_HANDLED;
	
	entity_set_string(entId,EV_SZ_classname,"func_landmine");
	
	entity_set_string(entId,EV_SZ_targetname,"landmine_off");
	
	if( numArguments[1] > 0 )
	{
		entity_set_model(entId,WORLD_MODEL_STEALTH);
	}
	else
	{
		entity_set_model(entId,WORLD_MODEL);
	}
	
	entity_set_vector(entId,EV_VEC_origin,fPlayerPos);
	
	new Float:maxBox[3] = { 2.15 , 4.3 , 2.15 };
	new Float:minBox[3] = { -2.15 , -4.3 , -2.15 };
	
	entity_set_size(entId,minBox,maxBox);
	
	entity_set_int(entId,EV_INT_solid,SOLID_BBOX);
	entity_set_int(entId,EV_INT_movetype,MOVETYPE_TOSS);
	
	entity_set_edict(entId,EV_ENT_owner,numArguments[0]);
	
	drop_to_floor(entId);
	
	new taskParams[1];
	taskParams[0] = entId;
	
	set_task(2.0,"landmineActivate",0,taskParams,1,"a",1);
	
	return PLUGIN_HANDLED;

}

public landmineActivate(params[],id)
{

	if( !params[0] || !is_valid_ent(params[0]) ) return PLUGIN_HANDLED;
	
	new mineState[32];

	entity_get_string(params[0],EV_SZ_targetname,mineState,31);
	
	if( equali(mineState,"landmine_off") )
	{
	
		entity_set_string(params[0],EV_SZ_targetname,"landmine_on");
		entity_set_edict(params[0],EV_ENT_owner,0);
	
	}
	
	return PLUGIN_HANDLED;

}

public landmineExplode(entid,id)
{

	new mineState[32];

	entity_get_string(entid,EV_SZ_targetname,mineState,31);
	
	if( equali(mineState,"landmine_on") )
	{
	
		new mineOwner = entity_get_edict(entid,EV_ENT_owner);
		
		if( !mineOwner )
		{
		
			emit_sound(entid,CHAN_ITEM,SOUND_STEP,1.0,ATTN_NORM,0,PITCH_NORM);
		
			client_print(id,print_chat,"[Landmine] OH SHIT! You stepped on a mine!");
			
			entity_set_edict(entid,EV_ENT_owner,id);
			
			new taskParams[2];
			taskParams[0] = entid;
			taskParams[1] = id;
			
			set_task(0.35,"landmineMonitor",entid+TASK_BEGIN,taskParams,2,"b");
		
		}
		
		return PLUGIN_HANDLED;
		
	}
	
	return PLUGIN_CONTINUE;

}

public landmineMonitor(params[],id)
{

	new mineState[32];

	entity_get_string(params[0],EV_SZ_targetname,mineState,31);
	
	if( equali(mineState,"landmine_on") )
	{

		new mineOwner = entity_get_edict(params[0],EV_ENT_owner);
		
		if( mineOwner )
		{
		
			new playerOrigin[3];
			new Float:fmineOrigin[3];
			new mineOrigin[3];
			
			get_user_origin(params[1],playerOrigin);
			
			entity_get_vector(params[0],EV_VEC_origin,fmineOrigin);
			FVecIVec(fmineOrigin,mineOrigin);

			if( (!is_user_connected(params[1]) || !is_user_alive(params[1])) || get_distance(playerOrigin,mineOrigin) >= DETONATE_DISTANCE )
			{
				
				DEFUSE_IDENT[params[1]] = 0;
				
				remove_entity(params[0]);
				
				explodeArea(mineOrigin,KILL_DISTANCE);
				
				remove_task(params[0]+TASK_BEGIN);
			
			}
		
		}
	
	}

	return PLUGIN_HANDLED;

}

public explodeArea(origin[3],Float:radius)
{

	effectExplosion(origin);

	new player[32], playerCount;
	get_players(player,playerCount,"ac");
				
	for( new i = 0; i < playerCount; i++ )
	{
				
		new deathOrigin[3];
		get_user_origin(player[i],deathOrigin);
					
		if( get_distance(deathOrigin,origin) <= radius )
		{
						
			new health = get_user_health(player[i]);
						
			health -= random_num(80,150);
				
			if( health <= 0 )
			{
				
				user_kill(player[i]);
				
			}
			else
			{
						
				user_slap(player[i],0,1);
				set_user_health(player[i],health);
						
			}
					
		}
				
	}
	
	return PLUGIN_HANDLED;

}

stock effectExplosion(origin[3])
{

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(12);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_byte(200);
	write_byte(10);
	message_end();

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(3);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(EXPLOSION);
	write_byte(60);
	write_byte(10);
	write_byte(0);
	message_end();
	
	return PLUGIN_HANDLED;
	
}

stock drop_to_nearest(id)
{

	new Float:fentOrigin[3];
	
	entity_get_vector(id,EV_VEC_origin,fentOrigin);
	
	new Float:fvector[3];
	
	fvector[0] = fentOrigin[0];
	fvector[1] = fentOrigin[1];
	fvector[2] = fentOrigin[2] - 10000.0;
	
	new fvectorReturn[3];
	
	trace_line(0,fentOrigin,fvector,fvectorReturn);
	
	entity_set_vector(id,EV_VEC_origin,fvectorReturn);

	return PLUGIN_HANDLED;

}
