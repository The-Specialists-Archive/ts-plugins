#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <engine>

// how much space is required to plant it
#define SPACE_REQUIRED 30.0

// whether or not to give extra notices
// #define EXTRA_NOTICES 

// optimization
new Float:g_SpaceRequired = SPACE_REQUIRED

new g_ClassName[] = "rp_weed"

new g_StartModel[] = "models/DGF_canabis01.mdl"
new g_GrowModel[] = "models/DGF_canabis02.mdl"
new g_DoneModel[] = "models/DGF_canabis03.mdl"

new g_Weed
new g_WeedSeed

new p_SeedChance
new p_GrowthTime
new p_Delay
new p_Number

new Float:g_LastTime[33]

public ARP_Init()
{
	ARP_RegisterPlugin("Weed Mod","2.0","Hawk552","Allows players to grow, harvest and smoke weed")
	
	p_SeedChance = register_cvar("arp_weed_seedchance","0.15")
	p_GrowthTime = register_cvar("arp_weed_growthtime","10")
	p_Delay = register_cvar("arp_weed_delay","10")
	p_Number = register_cvar("arp_weed_number","5")
	
	register_think(g_ClassName,"WeedThink")
}

public ARP_RegisterItems()
{
	ARP_RegisterItem("Harvest Tool","_HarvestTool","Device used for harvesting weed.")
	ARP_RegisterItem("Plant Cut Tool","_PlantRemover","Device used for remove illegal plants.")
	g_Weed = ARP_RegisterItem("Maryjuana","_Weed","Cannabis plant rolled up to smoke it.",1)
	g_WeedSeed = ARP_RegisterItem("Maryjuana Seed","_WeedSeed","Seed used to grow the cannabis plant.")
}

public plugin_precache()
{
	precache_model(g_StartModel)
	precache_model(g_GrowModel)
	precache_model(g_DoneModel)
}

public _HarvestTool(id,ItemId)
{
	new Ent,ClassName[33],Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	while((Ent = find_ent_in_sphere(Ent,Origin,60.0)) != 0)
	{
		entity_get_string(Ent,EV_SZ_classname,ClassName,32)
		if(!equali(ClassName,g_ClassName) || entity_get_int(Ent,EV_INT_iuser4) != 3)
			continue
		
		client_print(id,print_chat,"[ARP] You have harvested this Maryjuana.")
		
		ARP_SetUserItemNum(id,g_Weed,ARP_GetUserItemNum(id,g_Weed) + get_pcvar_num(p_Number))
		
		remove_entity(Ent)
		
		return
	}
	
	client_print(id,print_chat,"[ARP] No Maryjuana has been found near you.")
}

public _PlantRemover(id,ItemId)
{
	new Ent,ClassName[33],Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	while((Ent = find_ent_in_sphere(Ent,Origin,60.0)) != 0)
	{
		entity_get_string(Ent,EV_SZ_classname,ClassName,32)
		if(!equali(ClassName,g_ClassName)) //|| entity_get_int(Ent,EV_INT_iuser4) != 3)
			continue
		
		client_print(id,print_chat,"[ARP] You have Removed this Illegal Maryjuana Plant.")
		
		remove_entity(Ent)
		
		return
	}
	
	client_print(id,print_chat,"[ARP] No illegal Maryjuana has been found near you.")
}

public _WeedSeed(id,ItemId)
{
	new Float:Time = halflife_time() - get_pcvar_float(p_Delay)
	if(Time < g_LastTime[id])
		return client_print(id,print_chat,"[ARP] You must wait %d more seconds to plant this.",g_LastTime[id] - Time)
	
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
			return client_print(id,print_chat,"[ARP] There is not enough space to plant this item here.")
		Target[Count] -= g_SpaceRequired
			
		Target[Count] -= g_SpaceRequired
		trace_line(id,Origin,Target,Return)
		if(get_distance_f(Origin,Return) <= g_SpaceRequired - 5.0)
			return client_print(id,print_chat,"[ARP] There is not enough space to plant this item here.")
		Target[Count] += g_SpaceRequired
	}
	
	client_print(id,print_chat,"[ARP] You have planted some weed.")
	
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
	
	ARP_SetUserItemNum(id,g_WeedSeed,ARP_GetUserItemNum(id,g_WeedSeed) - 1)
	
	return PLUGIN_CONTINUE
}

public _Weed(id,ItemId)
{		
	ScreenEffect(id)
	for(new Float:Count = 5.0;Count < 30.0;Count += 5.0)
		set_task(Count,"ScreenEffect",id)
	client_cmd(id,"say /me rolls a blunt and smoke!");
	
	entity_set_float(id,EV_FL_health,float(clamp(floatround(entity_get_float(id,EV_FL_health) + 100.0),0,200)))
	
	if(random_float(0.0,1.0) < get_pcvar_float(p_SeedChance))
	{
		ARP_SetUserItemNum(id,g_WeedSeed,ARP_GetUserItemNum(id,g_WeedSeed) + 1)
		client_print(id,print_chat,"[ARP] You found a maryjuana seed in the weed.")
	}	
	
	set_task(35.0,"UnGlow",id)
	
	set_rendering(id,kRenderFxGlowShell,0,255,0,kRenderNormal,16)
	
	ARP_ItemSet(id)
	
	return PLUGIN_CONTINUE
}

public ScreenEffect(id)
{
	entity_set_vector(id,EV_VEC_punchangle,Float:{200.0,200.0,200.0})
	
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("TSFade"),{0,0,0},id)
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
{
	set_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,255)
	
	ARP_ItemDone(id)
	
	client_print(id,print_chat,"[ARP] You have finished your weed.")
}

public WeedThink(Ent)
{
	if(!Ent)
		return
	
#if defined EXTRA_NOTICES
	new id = entity_get_edict(Ent,EV_ENT_owner),State = entity_get_int(Ent,EV_INT_iuser4)
#else
	new State = entity_get_int(Ent,EV_INT_iuser4)
#endif

	if(State == 1)
	{
#if defined EXTRA_NOTICES
		client_print(id,print_chat,"[ARP] Your weed has matured, but is not ready to be harvested yet.")
#endif
		entity_set_int(Ent,EV_INT_iuser4,2)
		
		entity_set_model(Ent,g_GrowModel)
		
		entity_set_float(Ent,EV_FL_nextthink,halflife_time() + get_pcvar_float(p_GrowthTime))
	}
	else if(State == 2)
	{
#if defined EXTRA_NOTICES
		client_print(id,print_chat,"[ARP] Your weed is now ready for harvest.")
#endif
		entity_set_int(Ent,EV_INT_iuser4,3)
		
		entity_set_model(Ent,g_DoneModel)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/
