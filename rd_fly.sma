
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
//#include <tsxfun>

// Change this line to the access level you want and recompile if you wish to set it differently.


new bool: isflying[33]
new bool: flytoggle[33]
new bool: allowFly[33] = false;
new bool: tempfly[33] = false;
new Float: Velocity[33][3]
new fly_trail
new light

public plugin_precache()
{
	fly_trail = precache_model("sprites/zbeam4.spr")
	light = precache_model("sprites/lgtning.spr") 
	return PLUGIN_CONTINUE
}

public plugin_init() 
{
	register_plugin("Fly Power","1.0","Shin Lee");
	
	register_clcmd("+fly","make_fly",0,": Makes you change into fly mode")
	register_clcmd("-fly","stop_fly",0,": Makes you change back from fly mode to normal")
	register_clcmd("fly_toggle","make_fly",0,": Makes you change into flymode, no need to hold button")
	
	register_cvar("amx_flyspeed","500")
	register_cvar("amx_flytrailbrightness","40")
	register_cvar("amx_hover_grav","0.001")
	register_cvar("amx_flytime", "600");
	register_srvcmd("item_fly","item_fly");
	register_srvcmd("item_tempfly", "item_tempfly");
	
	register_event("SendAudio","ftime_up","b","2=%!MRAD_GO","2=%!MRAD_MOVEOUT","2=%!MRAD_LETSGO","2=%!MRAD_LOCKNLOAD")
	register_event("SendAudio","end_round","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw") 
	register_event("ResetHUD", "new_round", "b")
	register_event("DeathMsg", "stopFly", "a", "")
}

public stopFly()
{
	new victim = read_data(2);
	
	if(flytoggle[victim] || isflying[victim]) {
		stop_fly(victim);
	}
	
	allowFly[victim] = false;
	tempfly[victim] = false;
	client_print(victim, print_chat, "[RDRP] You are died!");
}

public client_putinserver(id)
{
	allowFly[id] = false;
	tempfly[id] = false;
}

public item_tempfly()
{
	new arg[128]
	read_argv(1,arg,127)
	new id = str_to_num(arg);
	client_print(id,print_chat,"[RDRP] You can now fly!");
	client_cmd(id,"say /me begins to float.");
	allowFly[id] = true;
	tempfly[id] = true;
	return PLUGIN_HANDLED;
}

public item_fly()
{
	new arg[128]
	read_argv(1,arg,127)
	new id = str_to_num(arg);
	client_print(id,print_chat,"[RDRP] You fly now!");
	client_cmd(id,"say /me begins to fly.");
	allowFly[id] = true;
	return PLUGIN_HANDLED;
}

public new_round(id)
{

	if(flytoggle[id] || isflying[id])
	{
		stop_fly(id)
	}
	
	return PLUGIN_HANDLED
}

public end_round()
{
	return PLUGIN_HANDLED
}

public ftime_up()
{
	return PLUGIN_HANDLED
}

public make_fly(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(!allowFly[id])
	{
		client_print(id, print_chat, "[RDRP] You must have a Dragon Ring.");
		return PLUGIN_HANDLED;
	}
	
	if(flytoggle[id])
	{
		stop_fly(id)
		return PLUGIN_HANDLED
	}
	
	new arg[20]
	read_argv(0,arg,19)
	
	if(equal(arg,"fly_toggle"))
	flytoggle[id] = true
	
	
	if(isflying[id]) 
	{
		client_print(id,print_chat,"[RDRP] You are already flying")
		stop_fly(id);
		return PLUGIN_HANDLED
	
	}
	
	
	
	new teamname[20]
	get_user_team(id,teamname,19)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(22)
	write_short(id)
	write_short(fly_trail)
	write_byte(50)
	write_byte(10)
	write_byte(255)
	write_byte(0)
	write_byte(0)
	write_byte(get_cvar_num("amx_flytrailbrightness"))
	message_end()
	
	new Origin[3]
	get_user_origin(id,Origin)
	
	message_begin(MSG_ALL,SVC_TEMPENTITY)
	write_byte(19)
	write_coord(Origin[0])
	write_coord(Origin[1])
	write_coord(Origin[2])
	write_coord(Origin[0] + 24)
	write_coord(Origin[1] + 45)
	write_coord(Origin[2] + -66)
	write_short(light)
	write_byte(0) // starting frame
	write_byte(15) // frame rate in 0.1s
	write_byte(10) // life in 0.1s
	write_byte(20) // line width in 0.1s
	write_byte(1) // noise amplitude in 0.01s
	write_byte(255)
	write_byte(0)
	write_byte(0)
	write_byte(400) // brightness
	write_byte(1) // scroll speed in 0.1s
	message_end()
	
	new parm[1]
	parm[0] = id
	
	set_user_gravity(id, get_cvar_float("amx_hover_grav"))
	
	set_task(0.1,"user_fly",5327+id, parm,1, "b")
	
	isflying[id] = true
	

	return PLUGIN_HANDLED
}

public user_fly(parm[])
{
	new Float: xAngles[3]
	new Float: xOrigin[3]
	
	new xEnt
	
	new id
	id = parm[0]
	
	if(!is_user_alive(id)) stop_fly(id)
	
	if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_JUMP)  // FORWARD + MOVERIGHT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] -= 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK)  // FORWARD + MOVERIGHT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] -= 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_JUMP)  // FORWARD + MOVELEFT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] += 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK)  // FORWARD + MOVELEFT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] += 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_JUMP && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_BACK)  // BACK + MOVERIGHT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] -= 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK)  // BACK + MOVERIGHT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] -= 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_JUMP && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_BACK)  // BACK + MOVELEFT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] += 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK)  // BACK + MOVELEFT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] += 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_FORWARD) //  MOVERIGHT  + FORWARD
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] -= 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_BACK) // MOVERIGHT + BACK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] -= 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_FORWARD) // MOVELEFT + FORWARD
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] += 45
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_BACK) // MOVELEFT + BACK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] += 135
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_JUMP)  // FORWARD + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0

	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD && get_user_button(id)&IN_DUCK)  // FORWARD + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_JUMP)  // BACK + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] += 180
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_BACK && get_user_button(id)&IN_DUCK)  // BACK + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] += 180
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}	
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_JUMP)  // MOVERIGHT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] -= 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVERIGHT && get_user_button(id)&IN_DUCK)  // MOVERIGHT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] -= 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_JUMP)  // MOVELEFT + JUMP
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = -45.0
	xAngles[1] += 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVELEFT && get_user_button(id)&IN_DUCK)  // MOVELEFT + DUCK
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 45.0
	xAngles[1] += 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_FORWARD) // FORWARD
	VelocityByAim(id, get_cvar_num("amx_flyspeed") , Velocity[id])
	else if(get_user_button(id)&IN_BACK) // BACK
	VelocityByAim(id, -get_cvar_num("amx_flyspeed") , Velocity[id])
	else if(get_user_button(id)&IN_DUCK) // DUCK
	{
	Velocity[id][0] = 0.0
	Velocity[id][1] = 0.0
	Velocity[id][2] = -get_cvar_num("amx_flyspeed") * 1.0
	}
	else if(get_user_button(id)&IN_JUMP) // JUMP
	{
	Velocity[id][0] = 0.0
	Velocity[id][1] = 0.0
	Velocity[id][2] = get_cvar_num("amx_flyspeed") * 1.0
	}
	else if(get_user_button(id)&IN_MOVERIGHT) // MOVERIGHT
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] -= 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else if(get_user_button(id)&IN_MOVELEFT) // MOVELEFT
	{
	entity_get_vector(id, EV_VEC_v_angle, xAngles)
	entity_get_vector(id, EV_VEC_origin, xOrigin)
	
	xEnt = create_entity("info_target")
	if(xEnt == 0) { 
	return PLUGIN_HANDLED_MAIN 
	}
	
	xAngles[0] = 0.0
	xAngles[1] += 90
	
	entity_set_origin(xEnt, xOrigin)
	entity_set_vector(xEnt, EV_VEC_v_angle, xAngles)
	
	VelocityByAim(xEnt, get_cvar_num("amx_flyspeed"), Velocity[id])
	
	remove_entity(xEnt)
	}
	else
	{
	Velocity[id][0] = 0.0
	Velocity[id][1] = 0.0
	Velocity[id][2] = 0.0
	}
	
	
	entity_set_vector(id, EV_VEC_velocity, Velocity[id])
	
	new Float: pOrigin[3]
	new Float: zOrigin[3]
	new Float: zResult[3]
	
	entity_get_vector(id, EV_VEC_origin, pOrigin)
	
	zOrigin[0] = pOrigin[0]
	zOrigin[1] = pOrigin[1]
	zOrigin[2] = pOrigin[2] - 1000
	
	trace_line(id,pOrigin, zOrigin, zResult)
	
	if(entity_get_int(id, EV_INT_sequence) != 8 && (zResult[2] + 100) < pOrigin[2] && is_user_alive(id) && (Velocity[id][0] > 0.0 && Velocity[id][1] > 0.0 && Velocity[id][2] > 0.0)) 
	entity_set_int(id, EV_INT_sequence, 8)
	
	return PLUGIN_HANDLED
}

public stop_fly(id)
{
	if(!isflying[id]) return PLUGIN_HANDLED
	

	message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id )
	write_byte(99)
	write_short(id)
	message_end()

	
	set_user_gravity(id)
	
	isflying[id] = false
	flytoggle[id] = false
	remove_task(5327+id)
	
	return PLUGIN_HANDLED
}
