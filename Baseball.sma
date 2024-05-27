#include <amxmodx>
#include <amxmisc>
#include <engine>

new Float:g_MaxSpeed[33]
new g_Color[33][3]

public plugin_init()
{
	register_plugin("Arsenic Syringe","1.0","Hawk552")
	
	register_srvcmd("item_BaseballBat","Cmdbaseball")
}

public client_disconnect(id)
	g_MaxSpeed[id] = 0.0

public Cmdbaseball()
{
	new Args[10]
	read_args(Args,9)
	
	new id = str_to_num(Args)
	if(!id || !is_user_alive(id))
		return PLUGIN_CONTINUE
	
	new Index,Body
	get_user_aiming(id,Index,Body,100)
	
	if(!Index || !is_user_alive(Index))
		return client_print(id,print_chat,"[BaseBat] You are not looking at anyone.")
	
	if(g_MaxSpeed[Index])
		return client_print(id,print_chat,"[BaseBat] This user is already knocked out.")
	
	new Name[33]
	get_user_name(Index,Name,32)
	client_print(id,print_chat,"[BaseBat] You knocked %s with a Baseball Bat.",Name)
	
	get_user_name(id,Name,32)
	client_print(Index,print_chat,"[SYRINGE] You have been hit with a BaseBall Bat by %s.",Name)
	
	g_MaxSpeed[Index] = entity_get_float(Index,EV_FL_maxspeed)
	
	for(new Float:Count = 0.25;Count <= 30.0;Count += 0.25)
		set_task(Count,"sleep",Index)
	
	set_task(30.25,"Sleep",Index)
	
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
	if(g_MaxSpeed[id])
		entity_set_float(id,EV_FL_maxspeed,0.1)


public Sleep(id)
{
	g_Color[id][0] = 0
	g_Color[id][1] = 0
	g_Color[id][2] = 0
	
	client_cmd(id,"spk player/heartbeat1.wav")
	
	for(new Float:Count = 0.25;Count <= 30.0;Count += 0.25)
		set_task(Count,"SleepEffect",id)
	
	set_task(30.25,"SleepClear",id)
}

public SleepEffect(id)
{
	ScreenPulse(id)
	
	client_cmd(id,"+duck")
}	

public SleepClear(id)
{
	client_cmd(id,"-duck;stopsound")
	
	entity_set_float(id,EV_FL_maxspeed,g_MaxSpeed[id])
	g_MaxSpeed[id] = 0.0
}
	
public ScreenPulse(id)
{
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(1<<300)
	write_short(1<<300)
	write_short(1<<12)
	write_byte(g_Color[id][0])
	write_byte(g_Color[id][1]) 
	write_byte(g_Color[id][2])
	write_byte(255)
	message_end()
}

FindEmptyLoc(id,Origin[3],&Num)
{
	if(Num++ > 100)
		return client_print(id,print_chat,"You are in an invalid position to use this BaseBall Bat.")
	
	new Float:pOrigin[3]
	entity_get_vector(id,EV_VEC_origin,pOrigin)
	
	for(new Count;Count < 2;Count++)
		pOrigin[Count] += random_float(-100.0,100.0)
	
	if(PointContents(pOrigin) != CONTENTS_EMPTY && PointContents(pOrigin) != CONTENTS_SKY)
		return FindEmptyLoc(id,Origin,Num)
	
	Origin[0] = floatround(pOrigin[0])
	Origin[1] = floatround(pOrigin[1])
	Origin[2] = floatround(pOrigin[2])
	
	return PLUGIN_HANDLED
}
