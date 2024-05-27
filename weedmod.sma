#include <amxmodx>
#include <amxmisc>
#include <engine>

#define HARVEST_ID 2527
#define WEEDSEED_ID 2528
#define WEED_ID 2529

// how much space is required to plant it
#define SPACE_REQUIRED 30.0

// optimization
new Float:g_SpaceRequired = SPACE_REQUIRED

new g_ClassName[] = "rp_weed"

new g_StartModel[] = "models/uplant1.mdl"
new g_GrowModel[] = "models/uplant2.mdl"
new g_DoneModel[] = "models/uplant3.mdl"

new p_SeedChance
new p_GrowthTime
new p_Delay

new Float:g_LastTime[33]

public plugin_init()
{
	register_plugin("Weed Mod","1.0","Hawk552")
	
	register_srvcmd("item_weed_seed","CmdWeedSeed")
	register_srvcmd("item_weed_harvest","CmdHarvest")
	register_srvcmd("item_weed_smoke","CmdWeed")
	
	p_SeedChance = register_cvar("amx_weed_seedchance","0.15")
	p_GrowthTime = register_cvar("amx_weed_growthtime","10")
	p_Delay = register_cvar("amx_weed_delay","10")
	
	register_think(g_ClassName,"WeedThink")
}

public plugin_precache()
{
	precache_model(g_StartModel)
	precache_model(g_GrowModel)
	precache_model(g_DoneModel)
}

public CmdHarvest()
{
	new Arg[10]
	read_args(Arg,9)
	
	new id = str_to_num(Arg)
	
	if(!id || !is_user_alive(id))
		return
	
	new Ent,ClassName[33],Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	while((Ent = find_ent_in_sphere(Ent,Origin,60.0)) != 0)
	{
		entity_get_string(Ent,EV_SZ_classname,ClassName,32)
		if(!equali(ClassName,g_ClassName) || entity_get_int(Ent,EV_INT_iuser4) != 3)
			continue
		
		client_print(id,print_center,"You have harvested this weed.")
		
		static Name[33]
		get_user_name(id,Name,32)
		
		server_cmd("amx_additems #%d %d 5",get_user_userid(id),WEED_ID)
		
		remove_entity(Ent)
		
		return
	}
	
	client_print(id,print_center,"Could not find any weed near you.")
}

public CmdWeedSeed()
{
	new Arg[10]
	read_args(Arg,9)
	
	new id = str_to_num(Arg)
	
	if(!id || !is_user_alive(id))
		return PLUGIN_CONTINUE
		
	new Float:Time = halflife_time() - get_pcvar_float(p_Delay)
	if(Time < g_LastTime[id])
		return client_print(id,print_center,"You must wait %d more seconds to plant this.",g_LastTime[id] - Time)
	
	g_LastTime[id] = halflife_time()
		
	new Float:Origin[3],Float:Target[3],Float:Return[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	Target = Origin
	Target[2] -= 35.0
	
	for(new Count;Count < 2;Count++)
	{
		Target[Count] += g_SpaceRequired
		trace_line(id,Origin,Target,Return)
		if(get_distance_f(Origin,Return) <= g_SpaceRequired - 5.0)
			return client_print(id,print_center,"There is not enough space to plant this item here.")
		Target[Count] -= g_SpaceRequired
			
		Target[Count] -= g_SpaceRequired
		trace_line(id,Origin,Target,Return)
		if(get_distance_f(Origin,Return) <= g_SpaceRequired - 5.0)
			return client_print(id,print_center,"There is not enough space to plant this item here.")
		Target[Count] += g_SpaceRequired
	}
	
	client_print(id,print_center,"You have planted some weed.")
	
	new Ent = create_entity("info_target")
	if(!Ent)
		return PLUGIN_CONTINUE
	
	entity_set_string(Ent,EV_SZ_classname,g_ClassName)
	entity_set_origin(Ent,Target)	
	entity_set_model(Ent,g_StartModel)
	entity_set_int(Ent,EV_INT_iuser4,1)
	entity_set_edict(Ent,EV_ENT_owner,id)
	entity_set_size(Ent,Float:{-6.0,-6.0,-6.0},Float:{6.0,6.0,6.0})
	entity_set_float(Ent,EV_FL_nextthink,halflife_time() + get_pcvar_float(p_GrowthTime))
	
	static Name[33]
	get_user_name(id,Name,32)
	
	server_cmd("amx_delitems #%d %d 1",get_user_userid(id),WEEDSEED_ID)
	
	return PLUGIN_CONTINUE
}

public CmdWeed()
{
	new Arg[10]
	read_args(Arg,9)
	
	new id = str_to_num(Arg)
	
	if(!id || !is_user_alive(id))
		return PLUGIN_CONTINUE
		
	ScreenEffect(id)
	for(new Float:Count = 5.0;Count < 30.0;Count += 5.0)
		set_task(Count,"ScreenEffect",id)
	
	entity_set_float(id,EV_FL_health,float(clamp(floatround(entity_get_float(id,EV_FL_health) + 100.0),0,200)))
	
	if(random_float(0.0,1.0) < get_pcvar_float(p_SeedChance))
	{
		server_cmd("amx_additems #%d %d 1",get_user_userid(id),WEEDSEED_ID)
		client_print(id,print_center,"You found a weed seed in the weed")
	}	
	
	set_task(35.0,"UnGlow",id)
	
	set_rendering(id,kRenderFxGlowShell,0,255,0,kRenderNormal,16)
	
	return PLUGIN_CONTINUE
}

public ScreenEffect(id)
{
	entity_set_vector(id,EV_VEC_punchangle,Float:{200.0,200.0,200.0})
	
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(1<<300)
	write_short(1<<300)
	write_short(1<<12)
	write_byte(0)
	write_byte(255) 
	write_byte(0)
	write_byte(150)
	message_end()
}

public UnGlow(id)
	set_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,255)

public WeedThink(Ent)
{
	if(!Ent)
		return
	
	new id = entity_get_edict(Ent,EV_ENT_owner), State = entity_get_int(Ent,EV_INT_iuser4)

	if(State == 1)
	{
		client_print(id,print_center,"Your weed has matured, but is not ready to be harvested yet.")
		entity_set_int(Ent,EV_INT_iuser4,2)
		
		entity_set_model(Ent,g_GrowModel)
		
		entity_set_float(Ent,EV_FL_nextthink,halflife_time() + get_pcvar_float(p_GrowthTime))
	}
	else if(State == 2)
	{
		client_print(id,print_center,"Your weed is now ready for harvest.")
		entity_set_int(Ent,EV_INT_iuser4,3)
		
		entity_set_model(Ent,g_DoneModel)
	}
}
