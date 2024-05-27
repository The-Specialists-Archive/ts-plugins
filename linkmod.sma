#include <amxmodx>
#include <amxmisc>
#include <engine>

#define MAX_SERVERS 9
#define PROPERTIES_NUM 6

new g_File[] = "/servers.ini"

new g_Command[] = "say /buy"
new g_Server
new g_ClassName[] = "npc_linkmod"

enum SERVER
{
	NAME = 0,
	MAP,
	IP,
	// will be parsed later
	ORIGIN,
	ANGLE,
	MODEL
}

new g_Const[][] =
{
	"name",
	"map",
	"ip",
	"origin",
	"angle",
	"model"
}

new g_ServersNum = -1
new g_Servers[MAX_SERVERS][SERVER][64]

new g_Menu[] = "LinkModMenu"
new g_Keys

public plugin_init()
{
	register_plugin("Link Mod","1.0","Hawk552")
	
	register_clcmd(g_Command,"CmdLink")
	
	// add the keys
	for(new Count;Count < g_ServersNum;Count++)
		g_Keys += (1<<Count)

	// add the exit key
	g_Keys += (1<<9)
	
	register_menucmd(register_menuid(g_Menu),g_Keys,"LinkModMenuHandle")
	
	set_task(1.0,"IdentifyServer")
}

public plugin_precache()
{
	new ConfigsDir[64]
	get_configsdir(ConfigsDir,63)
	
	add(ConfigsDir,63,g_File)
	
	new File = fopen(ConfigsDir,"r")
	if(!File)
		return set_fail_state("Could not open file.")
	
	new Buffer[128],Temp[32]
	while(!feof(File) && g_ServersNum < MAX_SERVERS)
	{
		fgets(File,Buffer,127)
		if(containi(Buffer,"[") != -1 && containi(Buffer,"]") != -1)
			g_ServersNum++
		
		for(new Count;Count < PROPERTIES_NUM;Count++)
			if(containi(Buffer,g_Const[Count]) != -1)
			{
				
				parse(Buffer,Temp,31,g_Servers[g_ServersNum][SERVER:Count],63)
				remove_quotes(g_Servers[g_ServersNum][SERVER:Count])
				trim(g_Servers[g_ServersNum][SERVER:Count])
				
				break
			}
	}
	
	g_ServersNum++
	
	new ServerIP[20],HostName[32]
	get_cvar_string("net_address",ServerIP,19)
	get_cvar_string("hostname",HostName,31)
	
	for(new Count;Count < g_ServersNum;Count++)
		if(equali(ServerIP,g_Servers[Count][IP]) || equali(HostName,g_Servers[Count][NAME]))
		{
			g_Server = Count
			precache_model(g_Servers[g_Server][MODEL])
			break
		}
	
	return PLUGIN_CONTINUE
}

public IdentifyServer()
{	
	if(strlen(g_Servers[g_Server][NAME]) < 2)
		return set_fail_state("Current server not listed in file.")
	
	new Float:Origin[3],StringOrigins[3][10],Float:Angles[3]
	parse(g_Servers[g_Server][ORIGIN],StringOrigins[0],9,StringOrigins[1],9,StringOrigins[2],9)
	
	Angles[1] = str_to_float(g_Servers[g_Server][ANGLE])
	
	for(new Count;Count < 3;Count++)
		Origin[Count] = str_to_float(StringOrigins[Count])	
	
	new Ent = create_entity("info_target")
	if(!Ent)
		return set_fail_state("Could not create NPC entity.")
	
	new Float:Min[3] = {-16.0, -16.0, -36.0},Float:Max[3] = {16.0, 16.0, 36.0}
	
	entity_set_string(Ent,EV_SZ_classname,g_ClassName)
	entity_set_model(Ent,g_Servers[g_Server][MODEL])
	entity_set_origin(Ent,Origin)
	entity_set_int(Ent, EV_INT_solid,SOLID_BBOX)
	entity_set_int(Ent,EV_INT_movetype,MOVETYPE_FLY)
	entity_set_edict(Ent,EV_ENT_owner,33)
	entity_set_float(Ent,EV_FL_framerate,1.0)
	entity_set_int(Ent,EV_INT_sequence,1)
	entity_set_size(Ent,Min,Max) 
	entity_set_float(Ent,EV_FL_takedamage,1.0)
	entity_set_float(Ent,EV_FL_health,99999999999.0)
	entity_set_vector(Ent,EV_VEC_angles,Angles)
	Angles[1] -= 180
	entity_set_vector(Ent,EV_VEC_v_angle,Angles)
	
	return PLUGIN_CONTINUE
}

public CmdLink(id)
{
	new Ent,ClassName[33],Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	while((Ent = find_ent_in_sphere(Ent,Origin,75.0)) != 0)
	{
		entity_get_string(Ent,EV_SZ_classname,ClassName,32)
		
		if(!equali(ClassName,g_ClassName))
			continue
		
		ShowMenu(id)
		
		break
	}
	
	return PLUGIN_CONTINUE
}

ShowMenu(id)
{
	static Menu[MAX_SERVERS * 64]
	new Pos
	
	Pos += format(Menu[Pos],MAX_SERVERS * 64 - 1 - Pos,"Link Mod^n^n")
	for(new Count;Count < g_ServersNum;Count++)
		Pos += format(Menu[Pos],MAX_SERVERS * 64 - 1 - Pos,"%i. %s^n",Count + 1,g_Servers[Count][NAME])
	Pos += format(Menu[Pos],MAX_SERVERS * 64 - 1 - Pos,"^n0. Exit")
	
	show_menu(id,g_Keys,Menu,-1,g_Menu)
}

public LinkModMenuHandle(id,Key)
	if(Key != 9 && Key != g_Server)
		client_cmd(id,"connect %s",g_Servers[Key][IP])
	else if(Key == g_Server)
		client_print(id,print_chat,"[LinkMod] Sorry, the server you picked is this server.")