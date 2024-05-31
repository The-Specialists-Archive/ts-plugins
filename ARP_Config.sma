#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <sqlx>

#define MENU_OPTIONS 3
#define DB_MENU_OPTIONS 4

new g_MenuOptions[MENU_OPTIONS][] =
{
	"Add First ARP Admin",
	"Change Database Connection",
	"Load Map SQL Data"
}

// for some reason, these align perfectly. it's great for me ;]
new g_DbMenuOptions[DB_MENU_OPTIONS][] =
{
	"Host",
	"User",
	"Pass",
	"DB"
}

enum
{
	HOSTNAME = 1,
	USERNAME,
	PASSWORD,
	DATABASE
}

new g_LocalSqlFile[64] = "arp.ini"

new g_DbMenu[] = "mDatabaseMenu"
new g_MainMenu[] = "mConfigMenu"
new const g_Keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9

//new bool:g_FirstSet

new g_ModMode[33]
new g_Checker[33]

new g_Offline

new g_Queries
new g_Completed
new g_Errors

new g_Query[4096]

new Handle:g_SqlHandle

// the name of the users table
new g_DefaultUserTable[64] = "arp_users"
new g_UserTable[64] = "arp_users"
// the name of the jobs table
new g_DefaultJobsTable[64] = "arp_jobs"
new g_JobsTable[64] = "arp_jobs"
// the name of the property table
new g_DefaultPropertyTable[64] = "arp_property"
new g_PropertyTable[64] = "arp_property"
// name of the doors table
new g_DefaultDoorsTable[64] = "arp_doors"
new g_DoorsTable[64] = "arp_doors"
// door keys
new g_DefaultKeysTable[64] = "arp_keys"
new g_KeysTable[64] = "arp_keys"
// name of the items table
new g_DefaultItemsTable[64] = "arp_items"
new g_ItemsTable[64] = "arp_items"
// name of the orgs table
//new g_OrgsTable[] = "arp_orgs"
// name of the data table
new g_DefaultDataTable[64] = "arp_data"
new g_DataTable[64] = "arp_data"

public plugin_init()
{	
	register_clcmd("arp_config","CmdConfig")
	
	register_clcmd("say","CmdSay")
	register_clcmd("say_team","CmdSay")
	
	register_menucmd(register_menuid(g_MainMenu),g_Keys,"HandleCmdConfig")
	register_menucmd(register_menuid(g_DbMenu),g_Keys,"HandleDbMenu")
	
	new ConfigsDir[64]
	get_configsdir(ConfigsDir,63)

	format(g_LocalSqlFile,63,"%s/%s",ConfigsDir,g_LocalSqlFile)
}

public ARP_Init()
{
	g_Offline ? register_plugin("ARP - Config",ARP_VERSION,"The Apollo RP Team") : ARP_RegisterPlugin("Config",ARP_VERSION,"The Apollo RP Team","Helps admins with setting up the server")
	
	g_SqlHandle = ARP_SqlHandle()
	
	ARP_GetTable(USERS,g_UserTable,63)
	ARP_GetTable(JOBS,g_JobsTable,63)
	ARP_GetTable(PROPERTIES,g_PropertyTable,63)
	ARP_GetTable(DOORS,g_DoorsTable,63)
	ARP_GetTable(KEYS,g_KeysTable,63)
	ARP_GetTable(ITEMS,g_ItemsTable,63)
	ARP_GetTable(DATA,g_DataTable,63)
}	

public ARP_Error(const Reason[])
	g_Offline = 1

//public ARP_Init()
	//fnFirstSet()

public CmdConfig(id)
{	
	if(!IsOffline() && !ARP_AdminAccess(id) && !(get_user_flags(id) & ADMIN_BAN))
		return client_print(id,print_console,"You have no access to this command.")
		
	static Menu[MENU_OPTIONS * 64]
	new Pos
	
	Pos += format(Menu,MENU_OPTIONS * 64 - 1,"ARP Config Menu^n^n")
	for(new Count;Count < MENU_OPTIONS;Count++)
		Pos += format(Menu[Pos],MENU_OPTIONS * 64 - Pos - 1,"%i. %s^n",Count + 1,g_MenuOptions[Count])
	Pos += format(Menu[Pos],MENU_OPTIONS * 64 - Pos - 1,"^n0. Exit")
	
	show_menu(id,g_Keys,Menu,-1,g_MainMenu)
	
	return PLUGIN_HANDLED
}
		
public HandleCmdConfig(id,Key)
	switch(Key)
	{
		case 0 :
			FirstMember(id)
		case 1 :
			ChangeDatabase(id)
		case 2 :
			LoadSQLFile(id)
		default :
			if(Key != 9)
				CmdConfig(id)
	}
	
/*FirstSet()
{
	static Query[512],MemberTable[64]
	clan_get_membertable(MemberTable,63)
	
	format(Query,511,"SELECT * FROM %s",MemberTable)
	
	clan_sql_threaded_query(Query,"HandleFirstSet")
}

public HandleFirstSet(Handle:hQuery)
{
	if(!_:hQuery)
		return PLUGIN_CONTINUE
	
	new iNumRows = SQL_NumResults(hQuery)
	
	if(!iNumRows)
		g_bFirstSet = false
	else
		g_bFirstSet = true
		
	return PLUGIN_CONTINUE
}*/

FirstMember(id)
{			
	if(IsOffline())
	{
		client_print(id,print_chat,"[ARP] SQL connection is down - admin additions cannot be made.")
		
		return PLUGIN_CONTINUE
	}
	
	set_task(0.1,"FailedMessage",id)
	
	ARP_SetUserAccess(id,ARP_GetUserAccess(id) | ARP_AccessToInt("z"))
	
	g_Checker[id] = 1
	
	client_print(id,print_chat,"[ARP] You have been added as an admin.")
	
	return PLUGIN_CONTINUE
}

public FailedMessage(id)
	g_Checker[id] ? (g_Checker[id] = 0) : client_print(id,print_chat,"[ARP] Adding you as an admin has failed. Please check connection information.")

ChangeDatabase(id)
{
	new Offline = IsOffline()
	if(!Offline && !ARP_AdminAccess(id))
		return client_print(id,print_chat,"[ARP] You do not have access to this command.")
	
	if(Offline)
		client_print(id,print_chat,"[ARP] SQL connection failed - please change settings.")
	
	static Menu[DB_MENU_OPTIONS * 64],Setting[33]
	new Pos
	
	Pos += format(Menu,DB_MENU_OPTIONS * 64 - 1,"ARP Database Modification Menu^n^n")
	for(new Count;Count < DB_MENU_OPTIONS;Count++)
	{
		GetSetting(Count + 1,Setting,32)
		Pos += format(Menu[Pos],DB_MENU_OPTIONS * 64 - Pos - 1,"%i. %s: %s^n",Count + 1,g_DbMenuOptions[Count],Setting)
	}
	Pos += format(Menu[Pos],MENU_OPTIONS * 64 - Pos - 1,"^n0. Exit")
	
	show_menu(id,g_Keys,Menu,-1,g_DbMenu)
	
	return PLUGIN_CONTINUE
}

GetSetting(Setting,Format[],Len)
{
	if(!file_exists(g_LocalSqlFile))
		return
		
	new Line,Buffer[64],ByrefLen,Left[33],Right[33],Search[33]
	
	format(Search,32,"arp_sql_%s",g_DbMenuOptions[Setting - 1])
	while(read_file(g_LocalSqlFile,Line++,Buffer,63,ByrefLen))
	{
		if(containi(Buffer,Search) == -1)
			continue
		
		parse(Buffer,Left,32,Right,32)
		
		remove_quotes(Right)
		trim(Right)
		
		copy(Format,Len,Right)
		
		break
	}
}	

SetSetting(Setting,Format[])
{
	if(!file_exists(g_LocalSqlFile))
		return
		
	new Line,Buffer[64],ByrefLen,Left[33],Right[33],Search[33]
	
	format(Search,32,"arp_sql_%s",g_DbMenuOptions[Setting - 1])
	
	while(read_file(g_LocalSqlFile,Line++,Buffer,63,ByrefLen))
	{
		if(containi(Buffer,Search) == -1)
			continue
		
		parse(Buffer,Left,32,Right,32)
		
		format(Buffer,63,"%s ^"%s^"",Left,Format)
		
		write_file(g_LocalSqlFile,Buffer,Line - 1)
		
		break
	}
}
	
public HandleDbMenu(id,Key)
	if(Key < DB_MENU_OPTIONS && Key >= 0)
	{
		g_ModMode[id] = Key + 1
		client_print(id,print_chat,"[ARP] Please say (i.e. press y and type) what you would like to change this to, or say ^"cancel^" to stop.")
	}
	else if(Key == 9)
		return
	else
		ChangeDatabase(id)
			
LoadSQLFile(id)
{
	if(IsOffline())
	{
		client_print(id,print_chat,"[ARP] SQL connection failed - please check settings.")
		
		return
	}
	
	if(!ARP_AdminAccess(id))
	{
		client_print(id,print_chat,"[ARP] You do not have access to this command.")
		
		return
	}
	
	client_print(id,print_chat,"[ARP] Beginning SQL loading process.")
	
	new Line,ByrefLen,File[128],Mapname[33],Params[1]
	ARP_GetConfigsdir(File,127)
	get_mapname(Mapname,32)
	
	add(File,127,"/")
	add(File,127,Mapname)
	add(File,127,".sql")
	
	Params[0] = id
	
	g_Errors = 0
	g_Queries = 0
	g_Completed = 0
	
	if(!file_exists(File))
	{
		client_print(id,print_chat,"[ARP] No map configuration file found for this map.")
		
		return
	}
	
	while(read_file(File,Line++,g_Query,4095,ByrefLen))
	{
		if(g_Query[0] == ';' || g_Query[0] == '#' || g_Query[0] == '-' || strlen(g_Query) < 3)
			continue
		
		g_Queries++
		
		replace_all(g_Query,4095,g_DefaultUserTable,g_UserTable)
		replace_all(g_Query,4095,g_DefaultJobsTable,g_JobsTable)
		replace_all(g_Query,4095,g_DefaultPropertyTable,g_PropertyTable)
		replace_all(g_Query,4095,g_DefaultDoorsTable,g_DoorsTable)
		replace_all(g_Query,4095,g_DefaultKeysTable,g_KeysTable)
		replace_all(g_Query,4095,g_DefaultItemsTable,g_ItemsTable)
		replace_all(g_Query,4095,g_DefaultDataTable,g_DataTable)
		
		SQL_ThreadQuery(g_SqlHandle,"IgnoreHandle",g_Query,Params,1)
	}
}

public IgnoreHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) 
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if(FailState == TQUERY_QUERY_FAILED)
	{		
		SQL_QueryError(Query,g_Query,4095)
		
		server_print("Error: %s",g_Query)
	}	
	if(Errcode)
	{
		g_Errors++
		
		log_amx("Error on query: %s",Error)
	}
	
	// some bizarre error forces me to separate this
	g_Completed++
	
	client_print(Data[0],print_center,"%d/%d Completed - %d Errors",g_Completed,g_Queries,g_Errors)
	
	if(g_Completed == g_Queries)
	{
		client_print(Data[0],print_center,"Map SQL: Done!")
		client_print(Data[0],print_chat,"[ARP] Map SQL loading is complete. Please reload the map for settings to take effect.")
	}
	
	return PLUGIN_CONTINUE
}
	
public CmdSay(id)
{
	if(!g_ModMode[id])
		return PLUGIN_CONTINUE
		
	static Args[128]
	read_args(Args,127)
	
	remove_quotes(Args)
	trim(Args)
	
	if(equali(Args,"cancel"))
	{
		client_print(id,print_chat,"[ARP] %s modification cancelled.",g_DbMenuOptions[g_ModMode[id] - 1])
		
		g_ModMode[id] = 0
		
		return PLUGIN_HANDLED
	}
	
	replace_all(Args,127,"'","\'")
	
	SetSetting(g_ModMode[id],Args)
	
	client_print(id,print_chat,"[ARP] %s set, changes will take effect after map change.",g_DbMenuOptions[g_ModMode[id] - 1])
	
	g_ModMode[id] = 0
	
	return PLUGIN_HANDLED
}

IsOffline()
	return ARP_SqlHandle() == Empty_Handle || g_Offline