#include <amxmodx>
#include <amxmisc>
#include <dbi>

#define RADIO_ID 1400

new p_Channels
new Sql:g_SqlHandle

new g_Query[512]

new g_Channel[33]

new g_Menu[] = "RpRadioMenu"

public plugin_init()
{
	register_plugin("Radio Mod","1.0","Hawk552")
	
	register_clcmd("say","CmdSay")
	register_srvcmd("item_radio","CmdRadio")
	
	p_Channels = register_cvar("amx_radio_channels","10")
	
	set_task(0.5,"SqlInit")
	
	register_menucmd(register_menuid(g_Menu),1023,"MenuHandle")
}

public plugin_end()
	dbi_close(g_SqlHandle)

public SqlInit()
{
	g_SqlHandle = SQL_MakeHarbuTuple()
	
	if(g_SqlHandle < SQL_OK)
		set_fail_state(g_Query)
}

public CmdRadio()
{
	new Args[10]
	read_args(Args,9)
	
	new id = str_to_num(Args)
	if(!id || !is_user_alive(id))
		return
	
	RadioMenu(id)
}

RadioMenu(id)
{
	new Channel[32]
	g_Channel[id] > -1 ? format(Channel,31,"%d",g_Channel[id] + 1) : format(Channel,31,"911")
	
	format(g_Query,511,"Radio Menu^n^n1. Channel: %s^n^n0. Exit",Channel)
	show_menu(id,MENU_KEY_1|MENU_KEY_0,g_Query,-1,g_Menu)
}

public MenuHandle(id,Key)
{
	if(Key)
		return
	
	new Channels = get_pcvar_num(p_Channels)
	Channels - 1 == g_Channel[id] ? (g_Channel[id] = IsEmergency(id) ? -1 : 0) : g_Channel[id]++
	RadioMenu(id)
}

public CmdSay(id)
{	
	static Args[256],Msg[512]
	read_args(Args,255)
	
	if(containi(Args,"/com") == -1)
		return PLUGIN_CONTINUE
	else if(!HasRadio(id))
	{
		client_print(id,print_chat,"[RADIO] You do not have a radio.")
		return PLUGIN_HANDLED
	}
	
	replace(Args,255,"/com","")
	remove_quotes(Args)
	trim(Args)
	
	new Players[32],Playersnum,Player,Name[33]
	get_players(Players,Playersnum)
	
	new Channel[32]
	g_Channel[id] > -1 ? format(Channel,31,"%d",g_Channel[id] + 1) : format(Channel,31,"911")
	
	get_user_name(id,Name,32)
	format(Msg,511,"(RADIO CHAN %s) %s : %s",Channel,Name,Args)
	
	for(new Count;Count < Playersnum;Count++)
	{
		Player = Players[Count]
		if(!is_user_alive(Player) || !HasRadio(Player))
			continue
		
		if(g_Channel[id] == -1)
		{
			if(IsEmergency(Player))
				client_print(Player,print_chat,"%s",Msg)
		}
		else if(g_Channel[id] == g_Channel[Player])
			client_print(Player,print_chat,"%s",Msg)
	}
	
	return PLUGIN_HANDLED
}

HasRadio(id)
{
	new Authid[36]
	get_user_authid(id,Authid,35)
	
	new Result:Query = dbi_query(g_SqlHandle,"SELECT * FROM money WHERE steamid='%s'",Authid)
	if(Query < RESULT_OK)
	{
		dbi_error(g_SqlHandle,g_Query,511)
		set_fail_state(g_Query)
	}
	
	if(!dbi_nextrow(Query))
		return 0
	
	dbi_result(Query,"items",g_Query,511)
	
	static Parser[100][16],Left[8],Right[8]
	new Num = ExplodeString(Parser,100,g_Query,15,' '),ItemId
	
	for(new Count;Count <= Num;Count++)
	{
		strtok(Parser[Count],Left,7,Right,7,'|',1)
		ItemId = str_to_num(Left)
		
		if(ItemId == RADIO_ID)
			return 1
	}
	
	dbi_free_result(Query)
	
	return 0
}

IsEmergency(id)
{
	new Authid[36]
	get_user_authid(id,Authid,35)
	
	new Result:Query = dbi_query(g_SqlHandle,"SELECT * FROM money WHERE steamid='%s'",Authid)
	if(Query < RESULT_OK)
	{
		dbi_error(g_SqlHandle,g_Query,511)
		set_fail_state(g_Query)
	}
	
	if(!dbi_nextrow(Query))
		return 0
	
	new JobId = dbi_result(Query,"JobID")
	if(!JobId)
		return 0
	
	dbi_free_result(Query)
	
	if(CheckJobId(JobId,"rp_jobid_mcpd") || CheckJobId(JobId,"rp_jobid_mcmd") || CheckJobId(JobId,"rp_jobid_mcfd"))
		return 1
		
	return 0
}

CheckJobId(jobid,cvar[])
{
	new Cache[20],Jobs[2][10],JobInts[2]
	get_cvar_string(cvar,Cache,19)
	
	parse(Cache,Jobs[0],9,Jobs[1],9)
	JobInts[0] = str_to_num(Jobs[0])
	JobInts[1] = str_to_num(Jobs[1])
	
	if(jobid <= JobInts[1] && jobid >= JobInts[0])
		return 1
	
	return 0
}

// Based on SQL_MakeStdTuple
Sql:SQL_MakeHarbuTuple()
{
	static host[64], user[32], pass[32], db[128], set_type[12]
	
	get_cvar_string("economy_mysql_host", host, 63)
	get_cvar_string("economy_mysql_user", user, 31)
	get_cvar_string("economy_mysql_pass", pass, 31)
	get_cvar_string("amx_sql_type", set_type, 11)
	get_cvar_string("economy_mysql_db", db, 127)
	
	return dbi_connect(host,user,pass,db,g_Query,511)
}

ExplodeString( p_szOutput[][], p_iMax, p_szInput[], p_iSize, p_szDelimiter )
{
	new iIdx = 0, l = strlen(p_szInput), iLen = (1 + copyc( p_szOutput[iIdx], p_iSize, p_szInput, p_szDelimiter ))
	
	while( (iLen < l) && (++iIdx < p_iMax) )
		iLen += (1 + copyc( p_szOutput[iIdx], p_iSize, p_szInput[iLen], p_szDelimiter ))
		
	return iIdx
}
