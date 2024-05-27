/**************************************************************************************************

**** CVARS (FEATURES) ****
sv_adminhook         = Turn Plugin On/off
**** ADMIN COMMANDS ****
ADMIN_LEVEL_A (flag="m")
Granting Hook/Rope   = amx_granthook <authid, nick, @team, @all or #userid> <on/off>

ADMIN_LEVEL_E (flag="q") || Granted by admin
Ninja Rope by Spacedude (slightly modified) & Hook thingy
Attaching Rope			= +rope
Deattaching Rope		= -rope
Attaching Hook			= +hook
Deattaching Hook		= -hook

**************************************************************************************************/
#define USING_AMX 0 // 1 = Using AMX \ 0 = Useing AMXX

#if USING_AMX
	#include <amxmod>
	#include <amxmisc>
	#include <VexdUM>
	#include <fun>
	new gModName[32] = "AMX"
#else
	#include <amxmodx>
	#include <amxmisc>
	#include <fun>
	#include <engine>
	new gModName[32] = "AMXX"
#endif

#define TE_BEAMENTPOINT 1
#define TE_KILLBEAM 99
#define DELTA_T 0.1				// seconds
#define BEAMLIFE 100			// deciseconds
#define MOVEACCELERATION 150	// units per second^2
#define REELSPEED 300			// units per second

/* Hook Stuff */
new gHookLocation[33][3]
new gHookLenght[33]
new bool:gIsHooked[33]
new gAllowedHook[33]
new Float:gBeamIsCreated[33]
new global_gravity
new beam

/************************************************************************************************************************/
public plugin_init() //Called on plugin start
{
	// Plugin Info
	register_plugin("Admin Hook","1.0","AssKicR")
	
	//CVARS
	register_cvar("sv_adminhook", "1" )

	//ADMIN CMDS
	register_concmd("amx_granthook","AdminGrantHook",ADMIN_LEVEL_A,"<authid, nick, @team, @all or #userid> <on/off>")

	//USER COMMANDS
	register_clcmd("+rope", "hook_on",ADMIN_LEVEL_E)
	register_clcmd("-rope", "hook_off",ADMIN_LEVEL_E)
	register_clcmd("+hook", "hook_on",ADMIN_LEVEL_E)
	register_clcmd("-hook", "hook_off",ADMIN_LEVEL_E)

	//HOOKED EVENTS
	register_event("ResetHUD", "ResetHUD", "b")
}
/************************************************************************************************************************/
public plugin_precache()
{
	beam = precache_model("sprites/zbeam4.spr")
	precache_sound("weapons/xbow_hit2.wav")
}
/*************************************************************************************************************************/
/************************************************** USP/SCOUT REMOVE *****************************************************/
/*************************************************************************************************************************/

/*************************************************************************************************************************/
/**************************************************** HOOKED EVENTS ******************************************************/
/*************************************************************************************************************************/
public ResetHUD(id) {
	//Check if he is hooked to something
	if (gIsHooked[id]) RopeRelease(id)
}
/************************************************************************************************************************/
stock kz_velocity_set(id,vel[3]) {
	//Set Their Velocity to 0 so that they they fall straight down from
	new Float:Ivel[3]
	Ivel[0]=float(vel[0])
	Ivel[1]=float(vel[1])
	Ivel[2]=float(vel[2])
	entity_set_vector(id, EV_VEC_velocity, Ivel)
}

stock kz_velocity_get(id,vel[3]) {
	//Set Their Velocity to 0 so that they they fall straight down from
	new Float:Ivel[3]

	entity_get_vector(id, EV_VEC_velocity, Ivel)
	vel[0]=floatround(Ivel[0])
	vel[1]=floatround(Ivel[1])
	vel[2]=floatround(Ivel[2])
}

/************************************************************************************************************************/
/**************************************************** ADMIN COMMANDS ****************************************************/
/************************************************************************************************************************/
public AdminGrantHook(id,level,cid) 
{ 
	if ( !cmd_access(id,level,cid,1) ) 
		return PLUGIN_HANDLED 

	new arg1[32],arg2[32]
	read_argv(1,arg1,31)
	read_argv(2,arg2,31)
	new onoff = str_to_num(arg2)

	if ( equali(arg1,"@all") ) 
	{ 
		new plist[32],pnum 
		get_players(plist,pnum,"a") 
		if (pnum==0) 
		{ 
		 console_print(id,"[%s] There are no clients",gModName) 
		 return PLUGIN_HANDLED 
		} 
		for (new i=0; i<pnum; i++) { 
			gAllowedHook[plist[i]]=onoff
			if (gIsHooked[plist[i]]==true && onoff==0)
			{
				RopeRelease(plist[i])
			}
		}

		console_print(id,"[%s] %s all players access to hook/rope",gModName,onoff ? "Gave":"Removed") 
	} 
	else if ( arg1[0]=='@' ) 
	{ 
		new plist[32],pnum 
		get_players(plist,pnum,"ae",arg1[1]) 
		if ( pnum==0 ) 
		{ 
		 console_print(id,"[%s] No clients in such team",gModName) 
		 return PLUGIN_HANDLED 
		} 
		for (new i=0; i<pnum; i++) {
			gAllowedHook[plist[i]]=onoff
			if (gIsHooked[plist[i]]==true && onoff==0)
			{
				RopeRelease(plist[i])
			}
		}
		console_print(id,"[%s] %s all %ss access to hook/rope",onoff ? "Gave":"Removed",arg1[1]) 
	} 
	else 
	{ 
		new pName[32] 
		new player = cmd_target(id,arg1,6) 
		if (!player) return PLUGIN_HANDLED 

		gAllowedHook[player]=onoff
		if (gAllowedHook[player]==0 && onoff==0)
		{
			RopeRelease(player)
		}

		
		get_user_name(player,pName,31) 
		console_print(id,"[%s] %s ^"%s^" access to hook/rope",onoff ? "Gave":"Removed",pName) 
	} 

	return PLUGIN_HANDLED 
}

/************************************************************************************************************************/
/****************************************************** NINJAROPE *******************************************************/
/************************************************************************************************************************/

public ropetask(parm[])
{
	new id = parm[0]
	new user_origin[3], user_look[3], user_direction[3], move_direction[3]
	new A[3], D[3], buttonadjust[3]
	new acceleration, velocity_towards_A, desired_velocity_towards_A
	new velocity[3], null[3]

	if (!is_user_alive(id))
	{
		RopeRelease(id)
		return
	}

	if (gBeamIsCreated[id] + BEAMLIFE/10 <= get_gametime())
	{
		beamentpoint(id)
	}

	null[0] = 0
	null[1] = 0
	null[2] = 0

	get_user_origin(id, user_origin)
	get_user_origin(id, user_look,2)
	kz_velocity_get(id, velocity)

	buttonadjust[0]=0
	buttonadjust[1]=0

	if (get_user_button(id)&IN_FORWARD)		buttonadjust[0]+=1
	if (get_user_button(id)&IN_BACK)		buttonadjust[0]-=1
	if (get_user_button(id)&IN_MOVERIGHT)	buttonadjust[1]+=1
	if (get_user_button(id)&IN_MOVELEFT)	buttonadjust[1]-=1
	if (get_user_button(id)&IN_JUMP)		buttonadjust[2]+=1
	if (get_user_button(id)&IN_DUCK)		buttonadjust[2]-=1

	if (buttonadjust[0] || buttonadjust[1])
	{
		user_direction[0] = user_look[0] - user_origin[0]
		user_direction[1] = user_look[1] - user_origin[1]

		move_direction[0] = buttonadjust[0]*user_direction[0] + user_direction[1]*buttonadjust[1]
		move_direction[1] = buttonadjust[0]*user_direction[1] - user_direction[0]*buttonadjust[1]
		move_direction[2] = 0

		velocity[0] += floatround(move_direction[0] * MOVEACCELERATION * DELTA_T / get_distance(null,move_direction))
		velocity[1] += floatround(move_direction[1] * MOVEACCELERATION * DELTA_T / get_distance(null,move_direction))
	}

	if (buttonadjust[2])	gHookLenght[id] -= floatround(buttonadjust[2] * REELSPEED * DELTA_T)
	if (gHookLenght[id] < 100) gHookLenght[id] = 100

	A[0] = gHookLocation[id][0] - user_origin[0]
	A[1] = gHookLocation[id][1] - user_origin[1]
	A[2] = gHookLocation[id][2] - user_origin[2]

	D[0] = A[0]*A[2] / get_distance(null,A)
	D[1] = A[1]*A[2] / get_distance(null,A)
	D[2] = -(A[1]*A[1] + A[0]*A[0]) / get_distance(null,A)

	acceleration = - global_gravity * D[2] / get_distance(null,D)

	velocity_towards_A = (velocity[0] * A[0] + velocity[1] * A[1] + velocity[2] * A[2]) / get_distance(null,A)
	desired_velocity_towards_A = (get_distance(user_origin,gHookLocation[id]) - gHookLenght[id] /*- 10*/) * 4

	if (get_distance(null,D)>10)
	{
		velocity[0] += floatround((acceleration * DELTA_T * D[0]) / get_distance(null,D))
		velocity[1] += floatround((acceleration * DELTA_T * D[1]) / get_distance(null,D))
		velocity[2] += floatround((acceleration * DELTA_T * D[2]) / get_distance(null,D))
	}

	velocity[0] += ((desired_velocity_towards_A - velocity_towards_A) * A[0]) / get_distance(null,A)
	velocity[1] += ((desired_velocity_towards_A - velocity_towards_A) * A[1]) / get_distance(null,A)
	velocity[2] += ((desired_velocity_towards_A - velocity_towards_A) * A[2]) / get_distance(null,A)

	kz_velocity_set(id, velocity)
}

public hooktask(parm[])
{ 
	new id = parm[0]
	new velocity[3]

	if ( !gIsHooked[id] ) return 
	
	new user_origin[3],oldvelocity[3]
	parm[0] = id

	if (!is_user_alive(id))
	{
		RopeRelease(id)
		return
	}

	if (gBeamIsCreated[id] + BEAMLIFE/10 <= get_gametime())
	{
		beamentpoint(id)
	}

	get_user_origin(id, user_origin) 
	kz_velocity_get(id, oldvelocity) 
	new distance=get_distance( gHookLocation[id], user_origin )
	if ( distance > 10 ) 
	{ 
		velocity[0] = floatround( (gHookLocation[id][0] - user_origin[0]) * ( 2.0 * REELSPEED / distance ) )
		velocity[1] = floatround( (gHookLocation[id][1] - user_origin[1]) * ( 2.0 * REELSPEED / distance ) )
		velocity[2] = floatround( (gHookLocation[id][2] - user_origin[2]) * ( 2.0 * REELSPEED / distance ) )
	} 
	else
	{
		velocity[0]=0
		velocity[1]=0
		velocity[2]=0
	}

	kz_velocity_set(id, velocity) 
	
} 

public hook_on(id)
{
	if (get_cvar_num("sv_adminhook")==1)
		{
		if (gAllowedHook[id] || (get_user_flags(id)&ADMIN_LEVEL_E)) {
			if (!gIsHooked[id] && is_user_alive(id))
			{
				new cmd[32]
				read_argv(0,cmd,31)
				if(equal(cmd,"+rope")) RopeAttach(id,0)
				if(equal(cmd,"+hook")) RopeAttach(id,1)
			}
		}else{
			client_print(id,print_chat,"[%s] You have no access to that command",gModName)
			return PLUGIN_HANDLED
		}
	}else{
		client_print(id,print_chat,"[%s] This command is deativated",gModName)
	}
	return PLUGIN_HANDLED
}

public hook_off(id)
{
	if (gAllowedHook[id] || (get_user_flags(id)&ADMIN_LEVEL_E)) {
		if (gIsHooked[id])
		{
			RopeRelease(id)
		}
	}else{
		client_print(id,print_chat,"[%s] You have no access to that command",gModName)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public RopeAttach(id,hook)
{
	new parm[1], user_origin[3]
	parm[0] = id
	gIsHooked[id] = true
	get_user_origin(id,user_origin)
	get_user_origin(id,gHookLocation[id], 3)
	gHookLenght[id] = get_distance(gHookLocation[id],user_origin)
	global_gravity = get_cvar_num("sv_gravity")
	set_user_gravity(id,0.001)
	beamentpoint(id)
	emit_sound(id, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	if (hook) set_task(DELTA_T, "hooktask", 200+id, parm, 1, "b")
	else set_task(DELTA_T, "ropetask", 200+id, parm, 1, "b")
}

public RopeRelease(id)
{
	gIsHooked[id] = false
	killbeam(id)
	set_user_gravity(id)
	remove_task(200+id)
}

public beamentpoint(id)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMENTPOINT )
	write_short( id )
	write_coord( gHookLocation[id][0] )
	write_coord( gHookLocation[id][1] )
	write_coord( gHookLocation[id][2] )
	write_short( beam )	// sprite index
	write_byte( 0 )		// start frame
	write_byte( 0 )		// framerate
	write_byte( BEAMLIFE )	// life
	write_byte( 10 )	// width
	write_byte( 0 )		// noise
	if (get_user_team(id)==1)		// Terrorist
	{
		write_byte( 255 )	// r, g, b
		write_byte( 0 )	// r, g, b
		write_byte( 0 )	// r, g, b
	}
	else							// Counter-Terrorist
	{
		write_byte( 0 )	// r, g, b
		write_byte( 0 )	// r, g, b
		write_byte( 255 )	// r, g, b
	}
	write_byte( 150 )	// brightness
	write_byte( 0 )		// speed
	message_end( )
	gBeamIsCreated[id] = get_gametime()
}

public killbeam(id)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_KILLBEAM )
	write_short( id )
	message_end()
}

/************************************************************************************************************************/
/******************************************************* FORWARDS *******************************************************/
/************************************************************************************************************************/

public client_disconnect(id) {
	gAllowedHook[id]=0
}

/************************************************************************************************************************/
/************************************************** AMXX -> AMX funcs ***************************************************/
/************************************************************************************************************************/
#if USING_AMX
	stock get_user_button(id) return entity_get_int(id, EV_INT_button)
#endif