#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <ApolloRP>
#include <tsfun>
#include <tsx>

new Handle:g_SqlHandle

new g_WeaponTable[] = "arp_weapons"

public plugin_init()
	ARP_RegisterCmd("arp_addgun","CmdAddGun","(ADMIN) <weaponid> <ammo> <extra> <save (0/1)> - adds gun to wall")

public ARP_Error(const Reason[])
	pause("d")

public CmdAddGun(id,level,cid)
{
	if(!ARP_CmdAccess(id,cid,5))
		return PLUGIN_HANDLED
	
	new WeaponId[33],Ammo[33],Flags[33],Save[33],Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	
	read_argv(1,WeaponId,32)
	read_argv(2,Ammo,32)
	read_argv(3,Flags,32)
	read_argv(4,Save,32)
	
	ts_weaponspawn(WeaponId,"15",Ammo,Flags,Origin)
	
	if(!str_to_num(Save))
		return PLUGIN_HANDLED
		
	new WeapId = str_to_num(WeaponId),Clip = str_to_num(Ammo),Spawnflags = str_to_num(Flags)
	
	new Query[256]
	format(Query,255,"INSERT INTO %s VALUES ('%d','%d','%d','%d','%d','%d')",g_WeaponTable,WeapId,Clip,Spawnflags,floatround(Origin[0]),floatround(Origin[1]),floatround(Origin[2]))
	
	SQL_ThreadQuery(g_SqlHandle,"IgnoreHandle",Query)
	
	new Name[33],Authid[36]
	get_user_name(id,Name,32)
	get_user_authid(id,Authid,35)
	
	ARP_Log("Cmd: ^"%s<%d><%s><>^" add gun spawn (origin ^"%f %f %f^") (weaponid ^"%s^") (ammo ^"%s^") (flags ^"%s^") (save ^"%d^")",Name,get_user_userid(id),Authid,Origin[0],Origin[1],Origin[2],WeaponId,Ammo,Flags,Save)
	
	show_activity(id,Name,"Add weapon spawn")
	
	return PLUGIN_HANDLED
}

public ARP_Init()
{
	ARP_RegisterPlugin("Gun Spawns",ARP_VERSION,"The Apollo RP Team","Allows gun spawns")
	
	g_SqlHandle = ARP_SqlHandle()
	
	new Query[256]
	
	format(Query,255,"CREATE TABLE IF NOT EXISTS %s (weaponid INT(11),clips INT(11),flags INT(11),x INT(11),y INT(11),z INT(11))",g_WeaponTable)
	SQL_ThreadQuery(g_SqlHandle,"IgnoreHandle",Query)
	
	format(Query,255,"SELECT * FROM %s",g_WeaponTable)
	SQL_ThreadQuery(g_SqlHandle,"FetchSpawns",Query)
}

public FetchSpawns(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Internal error: consult developer.")
	
	if(Errcode)
		return log_amx("Error on query: %s",Error)
	
	new WeaponId[33],Clips[33],Flags[33],Float:Origin[3]
	while(SQL_MoreResults(Query))
	{
		SQL_ReadResult(Query,0,WeaponId,32)
		SQL_ReadResult(Query,1,Clips,32)
		SQL_ReadResult(Query,2,Flags,32)
		Origin[0] = float(SQL_ReadResult(Query,3))
		Origin[1] = float(SQL_ReadResult(Query,4))
		Origin[2] = float(SQL_ReadResult(Query,5))
		
		ts_weaponspawn(WeaponId,"15",Clips,Flags,Origin)
		
		SQL_NextRow(Query)
	}
	
	return PLUGIN_CONTINUE
}

public IgnoreHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) 
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return log_amx("Could not connect to SQL database.")//set_fail_state("Could not connect to SQL database.")
	else if(FailState == TQUERY_QUERY_FAILED)
		return log_amx("Internal error: consult developer. Error: %s",Error)
	
	if(Errcode)
		return log_amx("Error on query: %s",Error)
	
	return PLUGIN_CONTINUE
}