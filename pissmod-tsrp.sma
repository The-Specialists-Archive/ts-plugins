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

new bool:aspissing[33]
new Sql:sql
new Result:sql_result
new piss_sprite


public plugin_init()
{
	register_plugin("Advanced Bathroom Mod","x.11","nihS")
	register_cvar("sql_host","")
	register_cvar("sql_user","")
	register_cvar("sql_pass","")
	register_cvar("sql_name","")
	register_clcmd("say /piss","bpiss")
	register_event("DeathMsg","deathmsg","a")
	
	set_task(2.0,"sql_init")
	set_task(60.0,"bathroom",0,"",0,"b")
}

public plugin_precache() // FINAL
{
          precache_sound("piss/pissing.wav")
          piss_sprite = precache_model("sprites/plasma.spr")
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
		server_print("[Bathroom] Cannot connect to SQL database.")
	}
	else
	{
		server_print("[Bathroom] Connected to SQL database.")
	}
	
	return PLUGIN_HANDLED
}

public client_connect(id) // FINAL
{
	aspissing[id]=false
}

public client_disconnect(id) // FINAL
{
	aspissing[id]=false
}

public client_putinserver(id) // FINAL
{
	set_task(8.0,"notify",id)
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
	
	edit_value(id,"money","bathroom","=",0)

	return PLUGIN_HANDLED
}

public bpiss(id)
{
	new authid[32],query[256]
	
	get_user_authid(id,authid,31)
	format(query,255,"SELECT bathroom FROM money WHERE steamid='%s'",authid)
	sql_result = dbi_query(sql,query)
	
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(dbi_nextrow(sql_result) > 0)
	{
		new currbathroom = dbi_field(sql_result,1)
		
		dbi_free_result(sql_result)
		
		if(!aspissing[id] && currbathroom <= 10)
		{
			client_print(id,print_chat,"[PissMod]You dont feel to piss!.")
		}
		else if(aspissing[id])
		{
			aspissing[id]=false
			set_task(0.1,"pissing",id)
			client_print(id,print_chat,"[PissMod]You are done and feel better.")
		}
		else if(!aspissing[id])
		{
			aspissing[id]=true
                        new ids[1]
		        ids[0]=id
			emit_sound(id,CHAN_VOICE,"piss/pissing.wav",0.1,ATTN_NORM,0,PITCH_NORM)
                        set_task(0.1,"make_pee",1481+id,ids,1,"a",106)
                        set_task(0.1,"cpiss",id)
			client_print(id,print_chat,"[PissMod]You begin to piss.^n")
			client_print(id,print_chat,"Type /piss again to stop pissing.")
		}
	}
	dbi_free_result(sql_result)

	return PLUGIN_HANDLED
}

public bathroom()
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
				format(query,255,"SELECT bathroom FROM money WHERE steamid='%s'",authid)
				sql_result = dbi_query(sql,query)
				if(dbi_nextrow(sql_result) > 0)
				{
					new currbathroom = dbi_field(sql_result,1)
					dbi_free_result(sql_result)
					if(currbathroom < 100)
					{
						edit_value(players[i],"money","bathroom","+",random_num(1,5))
					}
					if(currbathroom >= 60 && currbathroom <= 80)
					{
						client_print(players[i],print_chat,"[PissMod] You feel to piss.^n")
					}
					else if(currbathroom >= 81 && currbathroom <= 99)
					{
						client_print(players[i],print_chat,"[PissMod] you need to piss.^n")
					}
					else if(currbathroom >= 100)
					{
						client_print(players[i],print_chat,"[PissMod] You died because you didnt goed piss.^n")
						user_kill(players[i])
					}
				}
				dbi_free_result(sql_result)
			}
		}
	}

	return PLUGIN_HANDLED
}

public sqrt(num)
{
  new div = num
  new result = 1
  while (div > result) {
    div = (div + result) / 2
    result = num / div
  }
  return div
}

public make_pee(ids[])
{
  new id=ids[0]
  new vec[3]
  new aimvec[3]
  new velocityvec[3]
  new length
  get_user_origin(id,vec)
  get_user_origin(id,aimvec,3)
  new distance = get_distance(vec,aimvec)
  new speed = floatround(distance*1.9)

  velocityvec[0]=aimvec[0]-vec[0]
  velocityvec[1]=aimvec[1]-vec[1]
  velocityvec[2]=aimvec[2]-vec[2]

  length=sqrt(velocityvec[0]*velocityvec[0]+velocityvec[1]*velocityvec[1]+velocityvec[2]*velocityvec[2])

  velocityvec[0]=velocityvec[0]*speed/length
  velocityvec[1]=velocityvec[1]*speed/length
  velocityvec[2]=velocityvec[2]*speed/length

  switch(get_cvar_num("amx_piss_effect"))
  {
    case 0:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte(101)
      write_coord(vec[0])
      write_coord(vec[1])
      write_coord(vec[2])
      write_coord(velocityvec[0])
      write_coord(velocityvec[1])
      write_coord(velocityvec[2])
      write_byte(102) // color
      write_byte(160) // speed
      message_end()
    }
    case 1:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte (1)
      write_short (id)
      write_coord(aimvec[0])
      write_coord(aimvec[1])
      write_coord(aimvec[2])
      write_short(piss_sprite)
      write_byte( 1 ) // framestart
      write_byte( 6 ) // framerate
      write_byte( 1 ) // life
      write_byte( 8 ) // width
      write_byte( 0 ) // noise
      write_byte( 255 ) // r, g, b
      write_byte( 255 ) // r, g, b
      write_byte( 0 ) // r, g, b
      write_byte( 200 ) // brightness
      write_byte( 10 ) // speed
      message_end()
    }
    default:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte(101)
      write_coord(vec[0])
      write_coord(vec[1])
      write_coord(vec[2])
      write_coord(velocityvec[0])
      write_coord(velocityvec[1])
      write_coord(velocityvec[2])
      write_byte(102) // color
      write_byte(160) // speed
      message_end()
    }
  }   
}

public cpiss(id)
{
	new healfull[64],authid[32],query[256]
	new currhealth = get_user_health(id)
	new newhealth = currhealth + 1
	new maxhealth = get_cvar_num("sv_maxhealth")
	new minhealth = get_cvar_num("sv_minhealth")

	get_cvar_string("sv_healfull",healfull,63)
	get_user_authid(id,authid,31)
	format(query,255,"SELECT bathroom FROM money WHERE steamid='%s'",authid)
	sql_result = dbi_query(sql,query)

	if(!aspissing[id]) return PLUGIN_HANDLED
	if(dbi_nextrow(sql_result) > 0)
	{
		new currbathroom = dbi_field(sql_result,1)
		
		dbi_free_result(sql_result)
		if(equal(healfull,"0"))
		{
			if(currbathroom <= 0)
			{
				set_task(0.1,"bpiss",id)
			}
			else if(currbathroom > 0)
			{
				if(currhealth < maxhealth && currhealth > minhealth)
				{
					set_user_health(id,newhealth)
				}
				edit_value(id,"money","bathroom","-5",random_num(1,5))
				set_task(1.0,"health",id)
			}
		}
		else if(equal(healfull,"1"))
		{
			if(currbathroom <= 0)
			{
				set_task(0.1,"bpiss",id)
			}
			else if(currbathroom > 0)
			{
				if(currhealth < maxhealth)
				{
					set_user_health(id,newhealth)
				}
				edit_value(id,"money","bathroom","-5",random_num(1,5))
				set_task(1.0,"health",id)
			}
		}
		else
		{
			log_amx("[Pissmod] %s is not a valid value for sv_healfull",healfull)
		}
	}
	dbi_free_result(sql_result)
	
	return PLUGIN_HANDLED
}