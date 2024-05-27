/*

Advanced SleepMod v1.02 for TSRP
Programmed by DataMatrix

Original idea by GHW_Chronic

NOTE: Functions noted by "// FINAL"
are possible final revisions.

*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <dbi>

new bool:asleep[33]
new Sql:sql
new Result:sql_result

public plugin_init()
{
	register_plugin("Advanced SleepMod for TSRP","1.02","DataMatrix")
	register_cvar("sv_healfull","0")
	register_cvar("sv_maxhealth","100")
	register_cvar("sv_minhealth","50")
	register_cvar("rp_servername","")
	register_cvar("rp_serverurl","")
	register_cvar("sql_host","")
	register_cvar("sql_user","")
	register_cvar("sql_pass","")
	register_cvar("sql_name","")
	register_clcmd("say /sleep","bsleep")
	register_event("DeathMsg","deathmsg","a")
	
	set_task(2.0,"sql_init")
	set_task(20.0,"tiredness",0,"",0,"b")
}

public plugin_precache() // FINAL
{
	precache_sound("misc/snore.wav")
	precache_sound("misc/yawn.wav")
}

public sql_init() // FINAL
{
	new host[64],user[32],pass[32],name[32],error[32]
	
	get_cvar_string("sql_host",host,63)
	get_cvar_string("sql_user",user,31)
	get_cvar_string("sql_pass",pass,31)
	get_cvar_string("sql_name",name,31)
	sql = dbi_connect(host,user,pass,name,error,31)
	
	if(sql == SQL_FAILED)
	{
		server_print("[SleepMod] Cannot connect to SQL database.")
	}
	else
	{
		server_print("[SleepMod] Connected to SQL database.")
	}
	
	return PLUGIN_HANDLED
}

public client_connect(id) // FINAL
{
	asleep[id]=false
}

public client_disconnect(id) // FINAL
{
	asleep[id]=false
}

public client_putinserver(id) // FINAL
{
	set_task(8.0,"notify",id)
}

public notify(id) // FINAL
{
	client_print(id,print_console,"This server is running Advanced SleepMod v1.0 for TSRP by DataMatrix!^n")
	client_print(id,print_console,"Commands: /sleep^n")
	
	return PLUGIN_HANDLED
}

public is_user_database(id) // FINAL
{
	if(sql < SQL_OK) return PLUGIN_HANDLED
	new authid[32],query[256]
	
	get_user_authid(id,authid,31)
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	sql_result = dbi_query(sql,query)
	
	if(dbi_nextrow(sql_result) > 0)
	{
		dbi_free_result(sql_result)
		return PLUGIN_HANDLED
	}
	dbi_free_result(sql_result)

	return PLUGIN_HANDLED
}

public edit_value(id,table[],index[],func[],amount) // FINAL
{
	if(sql < SQL_OK) return PLUGIN_HANDLED
	new authid[32],query[256]
	
	get_user_authid(id,authid,31)
	
	if(equali(func,"="))
	{
		format(query,255,"UPDATE %s SET %s=%i WHERE steamid='%s'",table,index,amount,authid)
	}
	else
	{
		format(query,255,"UPDATE %s SET %s=%s%s%i WHERE steamid='%s'",table,index,index,func,amount,authid)
	}
	dbi_query(sql,query)

	return PLUGIN_HANDLED
}

public deathmsg() // FINAL
{
	new id = read_data(2)
	
	edit_value(id,"money","tiredness","=",0)

	return PLUGIN_HANDLED
}

public bsleep(id)
{
	new authid[32],query[256]
	
	get_user_authid(id,authid,31)
	format(query,255,"SELECT tiredness FROM money WHERE steamid='%s'",authid)
	sql_result = dbi_query(sql,query)
	
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(dbi_nextrow(sql_result) > 0)
	{
		new currtiredness = dbi_field(sql_result,1)
		
		dbi_free_result(sql_result)
		
		if(!asleep[id] && currtiredness <= 10)
		{
			client_print(id,print_chat,"[SleepMod]You are not tired enough to sleep.")
		}
		else if(asleep[id])
		{
			asleep[id]=false
			client_cmd(id,"-duck")
			set_user_maxspeed(id,320.0)
			set_task(0.1,"fadeout",id)
			set_task(0.1,"snore",id)
			client_print(id,print_chat,"[SleepMod]You wake up feeling refreshed.")
		}
		else if(!asleep[id])
		{
			asleep[id]=true
			client_cmd(id,"+duck")
			set_user_maxspeed(id,1.0)
			set_task(0.1,"fadeout",id)
			set_task(0.1,"snore",id)
			set_task(0.1,"health",id)
			client_print(id,print_chat,"[SleepMod]You begin to fall asleep.^n")
			client_print(id,print_chat,"Type /sleep again to wake up.")
		}
	}
	dbi_free_result(sql_result)

	return PLUGIN_HANDLED
}

public snore(id) // FINAL
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(asleep[id])
	{
		emit_sound(id,CHAN_VOICE,"misc/snore.wav",0.1,ATTN_NORM,0,PITCH_NORM)
		set_task(5.0,"snore",0,"",0,"b")
	}
	else if(!asleep[id])
	{
		emit_sound(id,CHAN_VOICE,"misc/yawn.wav",0.1,ATTN_NORM,0,PITCH_NORM)
	}

	return PLUGIN_HANDLED
}

public health(id)
{
	new healfull[64],authid[32],query[256]
	new currhealth = get_user_health(id)
	new newhealth = currhealth + 1
	new maxhealth = get_cvar_num("sv_maxhealth")
	new minhealth = get_cvar_num("sv_minhealth")

	get_cvar_string("sv_healfull",healfull,63)
	get_user_authid(id,authid,31)
	format(query,255,"SELECT tiredness FROM money WHERE steamid='%s'",authid)
	sql_result = dbi_query(sql,query)

	if(!asleep[id]) return PLUGIN_HANDLED
	if(dbi_nextrow(sql_result) > 0)
	{
		new currtiredness = dbi_field(sql_result,1)
		
		dbi_free_result(sql_result)
		if(equal(healfull,"0"))
		{
			if(currtiredness <= 0)
			{
				set_task(0.1,"bsleep",id)
			}
			else if(currtiredness > 0)
			{
				if(currhealth < maxhealth && currhealth > minhealth)
				{
					set_user_health(id,newhealth)
				}
				edit_value(id,"money","tiredness","-",random_num(1,5))
				set_task(1.0,"health",id)
			}
		}
		else if(equal(healfull,"1"))
		{
			if(currtiredness <= 0)
			{
				set_task(0.1,"bsleep",id)
			}
			else if(currtiredness > 0)
			{
				if(currhealth < maxhealth)
				{
					set_user_health(id,newhealth)
				}
				edit_value(id,"money","tiredness","-",random_num(1,5))
				set_task(1.0,"health",id)
			}
		}
		else
		{
			log_amx("[SleepMod] %s is not a valid value for sv_healfull",healfull)
		}
	}
	dbi_free_result(sql_result)
	
	return PLUGIN_HANDLED
}

public tiredness()
{
	new players[32],num
	get_players(players,num,"ac")
	for(new i = 0;i < num;i++)
	{
		new ran = random_num(1,5)
		if(ran == 1)
		{
			if(is_user_database(players[i]) == 1)
			{
				new authid[32],query[256]
				get_user_authid(players[i],authid,31)
				format(query,255,"SELECT tiredness FROM money WHERE steamid='%s'",authid)
				sql_result = dbi_query(sql,query)
				if(dbi_nextrow(sql_result) > 0)
				{
					new currtiredness = dbi_field(sql_result,1)
					dbi_free_result(sql_result)
					if(currtiredness < 100)
					{
						edit_value(players[i],"money","tiredness","+",random_num(1,5))
					}
					if(currtiredness >= 60 && currtiredness <= 80)
					{
						client_print(players[i],print_chat,"[SleepMod] You yawn and feel tired.^n")
					}
					else if(currtiredness >= 81 && currtiredness <= 99)
					{
						client_print(players[i],print_chat,"[SleepMod] You yawn and feel very tired.^n")
					}
					else if(currtiredness >= 100)
					{
						client_print(players[i],print_chat,"[SleepMod] You feel too exhausted to run.^n")
						set_user_maxspeed(players[i],160.0)
					}
				}
				dbi_free_result(sql_result)
			}
		}
	}

	return PLUGIN_HANDLED
}

public fadeout(id) // FINAL
{
	if(asleep[id])
	{
		set_user_rendering(id,kRenderFxGlowShell,0,255,0,kRenderTransAlpha,25)
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(~0);
		write_short(~0);
		write_short(1<<12);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
	else if(!asleep[id])
	{
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,0)
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(~0);
		write_short(~0);
		write_short(1<<12);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		message_end();
	}

	return PLUGIN_HANDLED
}
