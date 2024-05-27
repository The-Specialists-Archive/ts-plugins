#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>

new g_ClassName[] = "murder_body"
new p_Time
new p_DeathMsg

public plugin_init()
{
	register_plugin("Murder Mod","1.0","Hawk552")
	
	register_event("DeathMsg","EventDeathMsg","a")
	
	p_Time = register_cvar("amx_murder_time","60.0")
	p_DeathMsg = register_cvar("amx_murder_deathmsg","1")
	
	set_msg_block(get_user_msgid("DeathMsg"),get_pcvar_num(p_DeathMsg) ? BLOCK_SET : BLOCK_NOT)
	
	register_think(g_ClassName,"MurderThink")
}

public EventDeathMsg()
	set_task(2.0,"DelayedDeathMsg",read_data(2))

public DelayedDeathMsg(id)
{	
	new Float:Origin[3],Float:Angle[3],Model[33]
	entity_get_vector(id,EV_VEC_origin,Origin)
	entity_get_vector(id,EV_VEC_v_angle,Angle)
	entity_get_string(id,EV_SZ_model,Model,32)
	
	Origin[2] -= 40.0
	entity_set_origin(id,Origin)
	Origin[2] += 40.0
	
	new Ent = create_entity("info_target")
	
	entity_set_string(Ent,EV_SZ_classname,g_ClassName)
	entity_set_model(Ent,Model)
	entity_set_int(Ent,EV_INT_movetype,MOVETYPE_FLY)
	entity_set_int(Ent,EV_INT_sequence,100)
	entity_set_size(Ent,Float:{-6.0,-12.0,-6.0},Float:{6.0,12.0,6.0})
	entity_set_int(Ent,EV_INT_solid,SOLID_BBOX)
	entity_set_float(Ent,EV_FL_nextthink,1.0)
	entity_set_vector(Ent,EV_VEC_v_angle,Angle)
	entity_set_edict(Ent,EV_ENT_owner,id)
	
	entity_set_origin(Ent,Origin)
	drop_to_floor(Ent)
	entity_get_vector(Ent,EV_VEC_origin,Origin)
	Origin[2] += 13.0
	entity_set_origin(Ent,Origin)
	
	// we already did this, but if they changed it we want to change it too
	if(get_pcvar_num(p_DeathMsg))
		set_msg_block(get_user_msgid("DeathMsg"),BLOCK_SET)
	else
		set_msg_block(get_user_msgid("DeathMsg"),BLOCK_NOT)
		
	set_task(get_pcvar_float(p_Time),"EntRemove",Ent)
}

public client_PreThink(id)
{
	new Index,Body
	get_user_aiming(id,Index,Body,500)
	
	if(!Index)
		return
	
	static ClassName[33]
	entity_get_string(Index,EV_SZ_classname,ClassName,32)
	
	if(!equal(ClassName,g_ClassName))
		return
		
	static Name[33]
	get_user_name(entity_get_edict(Index,EV_ENT_owner),Name,32)
	
	client_print(id,print_center,Name)
}

public EntRemove(Ent)
	remove_entity(Ent)
	//entity_set_int(Ent,EV_INT_flags,entity_get_int(Ent,EV_INT_flags) & FL_KILLME)
