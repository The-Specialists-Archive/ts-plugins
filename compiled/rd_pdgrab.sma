//#define engine

#include <amxmodx>
#include <amxmisc>
#include <fun>
#if defined engine
#include <engine>
#else
#include <fakemeta>
#endif

#define ADMIN_LEVEL_Q	ADMIN_LEVEL_C

//Used for Grab
new maxplayers
new grab[33]
new Float:grab_totaldis[33]
new grab_speed_cvar
new bool:has_grab[33]

//Used for All
new beamsprite


/****************************
 Register Commands and CVARs
****************************/

public plugin_init()
{
	register_plugin("Police Grab","x.11","Shin Lee")
	register_concmd("+grab","grab_on",ADMIN_LEVEL_Q," - Use: bind key +grab")
	register_concmd("-grab","grab_off")
	register_concmd("grab_toggle","grab_toggle",ADMIN_LEVEL_Q,"Toggles your grab on and off")
	
	grab_speed_cvar = register_cvar("grab_speed","5")
	
	register_srvcmd("item_pdrope","item_pdrope");

	maxplayers = get_maxplayers()

	set_task(1.0,"sql_init")
}


/**********************************
 Register beam sprite
 **********************************/

public plugin_precache()
{
	beamsprite = precache_model("sprites/dot.spr")
}


/*****************************
 Reset VARs on client connect
*****************************/

public client_putinserver(id)
{
	has_grab[id]=false
}

/****************************
 Item
 ***************************/
 
public item_pdrope()
{
	new arg[128]
	read_argv(1,arg,127)
	new id = str_to_num(arg);
	client_print(id,print_chat,"[RDRP] You can drag peoples now!");
	client_cmd(id,"say /me takes out a rope.");
	has_grab[id] = true;
	return PLUGIN_HANDLED;
}
/*****
 Grab
*****/

public grab_toggle(id,level,cid)
{
	if(grab[id]) grab_off(id)
	else grab_on(id,level,cid)
	return PLUGIN_HANDLED
}

public grab_on(id,level,cid)
{
	if(!has_grab[id])
	{
		return PLUGIN_HANDLED
	}
	if(grab[id])
	{
		return PLUGIN_HANDLED
	}
	grab[id]=-1
	static target, trash
	target=0
	get_user_aiming(id,target,trash,50)
	if(target && is_valid_ent2(target) && target!=id)
	{
		if(target<=maxplayers)
		{
			if(is_user_alive(target))
			{
				grabem(id,target)
			}
		}
		else if(get_solidity(target)!=4)
		{
			grabem(id,target)
		}
	}
	else
	{
		set_task(0.1,"grab_on2",id)
	}
	return PLUGIN_HANDLED
}

public grab_on2(id)
{
	if(is_user_connected(id))
	{
		static target, trash
		target=0
		get_user_aiming(id,target,trash,50)
		if(target && is_valid_ent2(target) && target!=id)
		{
			if(target<=maxplayers)
			{
				if(is_user_alive(target))
				{
					client_print(id,print_chat,"[AMXX] Found Target")
					grabem(id,target)
				}
			}
			else if(get_solidity(target)!=4)
			{
				client_print(id,print_chat,"[AMXX] Found Target")
				grabem(id,target)
			}
		}
		else
		{
			set_task(0.1,"grab_on2",id)
		}
	}
}

public grabem(id,target)
{
	grab[id]=target
	set_rendering2(target,kRenderFxGlowShell,255,0,0,kRenderTransAlpha,70)
	if(target<=maxplayers) set_user_gravity(target,0.0)
	grab_totaldis[id] = 0.0
	set_task(0.1,"grab_prethink",id+1000,"",0,"b")
	grab_prethink(id+1000)
}

public grab_off(id)
{
	if(is_user_connected(id))
	{
		if(grab[id]==-1)
		{
			client_print(id,print_chat,"[AMXX] No Target Found")
			grab[id]=0
		}
		else if(grab[id])
		{
			client_print(id,print_chat,"[AMXX] Target Released")
			set_rendering2(grab[id])
			if(grab[id]<=maxplayers && is_user_alive(grab[id])) set_user_gravity(grab[id],1.0)
			grab[id]=0
		}
	}
	return PLUGIN_HANDLED
}

public grab_prethink(id)
{
	id -= 1000
	if(!is_user_connected(id) && grab[id]>0)
	{
		set_rendering2(grab[id])
		if(grab[id]<=maxplayers && is_user_alive(grab[id])) set_user_gravity(grab[id],1.0)
		grab[id]=0
	}
	if(!grab[id] || grab[id]==-1)
	{
		remove_task(id+1000)
		return PLUGIN_HANDLED
	}

	//Get Id's, target's, and Where Id is looking's origins
	static origin1[3]
	get_user_origin(id,origin1)
	static Float:origin2_F[3], origin2[3]
	get_origin(grab[id],origin2_F)
	origin2[0] = floatround(origin2_F[0])
	origin2[1] = floatround(origin2_F[1])
	origin2[2] = floatround(origin2_F[2])
	static origin3[3]
	get_user_origin(id,origin3,3)

	//Create red beam
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(1)		//TE_BEAMENTPOINT
	write_short(id)		// start entity
	write_coord(origin2[0])
	write_coord(origin2[1])
	write_coord(origin2[2])
	write_short(beamsprite)
	write_byte(1)		// framestart
	write_byte(1)		// framerate
	write_byte(1)		// life in 0.1's
	write_byte(5)		// width
	write_byte(0)		// noise
	write_byte(255)		// red
	write_byte(0)		// green
	write_byte(0)		// blue
	write_byte(200)		// brightness
	write_byte(0)		// speed
	message_end()

	//Convert to floats for calculation
	static Float:origin1_F[3]
	static Float:origin3_F[3]
	origin1_F[0] = float(origin1[0])
	origin1_F[1] = float(origin1[1])
	origin1_F[2] = float(origin1[2])
	origin3_F[0] = float(origin3[0])
	origin3_F[1] = float(origin3[1])
	origin3_F[2] = float(origin3[2])

	//Calculate target's new velocity
	static Float:distance[3]

	if(!grab_totaldis[id])
	{
		distance[0] = floatabs(origin1_F[0] - origin2_F[0])
		distance[1] = floatabs(origin1_F[1] - origin2_F[1])
		distance[2] = floatabs(origin1_F[2] - origin2_F[2])
		grab_totaldis[id] = floatsqroot(distance[0]*distance[0] + distance[1]*distance[1] + distance[2]*distance[2])
	}
	distance[0] = origin3_F[0] - origin1_F[0]
	distance[1] = origin3_F[1] - origin1_F[1]
	distance[2] = origin3_F[2] - origin1_F[2]

	static Float:grab_totaldis2
	grab_totaldis2 = floatsqroot(distance[0]*distance[0] + distance[1]*distance[1] + distance[2]*distance[2])

	static Float:que
	que = grab_totaldis[id] / grab_totaldis2

	static Float:origin4[3]
	origin4[0] = ( distance[0] * que ) + origin1_F[0]
	origin4[1] = ( distance[1] * que ) + origin1_F[1]
	origin4[2] = ( distance[2] * que ) + origin1_F[2]

	static Float:velocity[3]
	velocity[0] = (origin4[0] - origin2_F[0]) * (get_pcvar_float(grab_speed_cvar) / 1.666667)
	velocity[1] = (origin4[1] - origin2_F[1]) * (get_pcvar_float(grab_speed_cvar) / 1.666667)
	velocity[2] = (origin4[2] - origin2_F[2]) * (get_pcvar_float(grab_speed_cvar) / 1.666667)

	set_velo(grab[id],velocity)

	return PLUGIN_CONTINUE
}
public get_origin(ent,Float:origin[3])
{
#if defined engine
	return entity_get_vector(id,EV_VEC_origin,origin)
#else
	return pev(ent,pev_origin,origin)
#endif
}

public set_velo(id,Float:velocity[3])
{
#if defined engine
	return set_user_velocity(id,velocity)
#else
	return set_pev(id,pev_velocity,velocity)
#endif
}

public get_velo(id,Float:velocity[3])
{
#if defined engine
	return get_user_velocity(id,velocity)
#else
	return pev(id,pev_velocity,velocity)
#endif
}

public is_valid_ent2(ent)
{
#if defined engine
	return is_valid_ent(ent)
#else
	return pev_valid(ent)
#endif
}

public get_solidity(ent)
{
#if defined engine
	return entity_get_int(ent,EV_INT_solid)
#else
	return pev(ent,pev_solid)
#endif
}

stock set_rendering2(index, fx=kRenderFxNone, r=255, g=255, b=255, render=kRenderNormal, amount=16)
{
#if defined engine
	return set_rendering(index,fx,r,g,b,render,amount)
#else
	set_pev(index, pev_renderfx, fx);
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);
	set_pev(index, pev_rendercolor, RenderColor);
	set_pev(index, pev_rendermode, render);
	set_pev(index, pev_renderamt, float(amount));
	return 1;
#endif
}
