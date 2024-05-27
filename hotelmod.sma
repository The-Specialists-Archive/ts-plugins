#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <dbi>
#include <fun>

new const Plugin[] = "HotelMod"
new const Version[] = "1.0"
new const Author[] = "Wonsae"
new g_hotel[33]
new hotelorigin[3] = {512, 431, 44}

//dbi
new Sql:dbc
new Result:result
new query[256]

public plugin_init() {
	register_plugin(Plugin,Version,Author)
	
	register_cvar("rp_hotelmod_1day","86400")
	register_cvar("rp_hotelmod_2day","172800")
	register_cvar("rp_hotelmod_3day","259200")
	
	register_cvar("rp_hotelmod_price_1day","60")
	register_cvar("rp_hotelmod_price_2day","720")
	register_cvar("rp_hotelmod_price_3day","1440")
	
	register_menucmd(register_menuid("Welcome to the Hotel"),1023,"action_hotel")
	register_menucmd(register_menuid("Pick your choice of room"),1023,"action_room_menu")
	register_menucmd(register_menuid("Room availability:"),1023,"action_roomstatus")
	register_menucmd(register_menuid("Hotel A: How long will you be staying?"),1023,"action_hotel_a")
	register_menucmd(register_menuid("Hotel B: How long will you be staying?"),1023,"action_hotel_b")
	register_menucmd(register_menuid("Hotel C: How long will you be staying?"),1023,"action_hotel_c")
	register_menucmd(register_menuid("Hotel D: How long will you be staying?"),1023,"action_hotel_d")
	
	set_task(60.0,"remove_access_a",0,"",0,"b")
	set_task(60.0,"remove_access_b",0,"",0,"b")
	set_task(60.0,"remove_access_c",0,"",0,"b")
	set_task(60.0,"remove_access_d",0,"",0,"b")
	
	set_task(1.0,"sql_init")
}

// Connecting to SQL
public sql_init()
{
	new host[64], username[33], password[33], dbname[33], error[256]
	get_cvar_string("economy_mysql_host",host,63);
	get_cvar_string("economy_mysql_user",username,32); 
	get_cvar_string("economy_mysql_pass",password,32); 
	get_cvar_string("economy_mysql_db",dbname,32);
	dbc = dbi_connect(host,username,password,dbname,error,255);
	if (dbc == SQL_FAILED)
	{
		set_fail_state("[HotelMod] Couldn't connect to SQL Database.^n");
		server_print("[HotelMod] Couldn't connect to SQL Database.^n");
	}
	else
	{
		server_print("[HotelMod] Connected to SQL, have a nice day!^n");
		CheckTables()
	}
}

// Checking if tables exist or not.
CheckTables(){
	if(dbc == SQL_FAILED)
	{
		return PLUGIN_HANDLED;
	}
	
	format(query,255,"CREATE TABLE IF NOT EXISTS hotelmod (steamid varchar(64), room varchar(64), mins int(32), type varchar(64), name varchar(64))");
	dbi_query(dbc,"%s",query);
	return PLUGIN_CONTINUE;
}

public client_PreThink(id)
{
	new origin[3]
	get_user_origin(id,origin)
	if(entity_get_int(id,EV_INT_button) & IN_USE && !(entity_get_int(id,EV_INT_oldbuttons) & IN_USE))
	{
		if(get_distance(origin,hotelorigin) <= 150.0)
		{
			hotel(id)
		}
	}
	return PLUGIN_CONTINUE
}

public edit_value(id,table[],index[],func[],amount)
{
	if(dbc < SQL_OK) return PLUGIN_HANDLED
	new authid[32], query[256]
	get_user_authid(id,authid,31)
	if(equali(func,"="))
	{
		format(query,255,"UPDATE %s SET %s=%i WHERE steamid='%s'",table,index,amount,authid)
	}
	else
	{
		format(query,255,"UPDATE %s SET %s=%s%s%i WHERE steamid='%s'",table,index,index,func,amount,authid)
	}
	dbi_query(dbc,"%s",query)
	return PLUGIN_HANDLED
}

stock get_user_money(id)
{
	new authid[32], balance
	get_user_authid(id,authid,31)
	format( query, 255, "SELECT balance FROM money WHERE steamid='%s'", authid)
	result = dbi_query(dbc,"%s",query)
	if(result >= RESULT_OK)
	{
		dbi_nextrow(result)
		
		new buffer[32]
		dbi_field(result,1,buffer,31)
		balance = str_to_num(buffer)
		dbi_free_result(result)
	}
	return balance
}

public hotel(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	
	new menu[256]
	new key = (1<<0|1<<1|1<<9)
	
	new len = format(menu, sizeof(menu), "Welcome to the Hotel^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. Rent a room^n")
	len += format(menu[len],sizeof(menu)-len,"2. Room availability^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	
	return PLUGIN_HANDLED
}

public action_hotel(id,key)
{
	switch(key){
		case 0:{
			room_menu(id)
		}
		case 1:{
			roomstatus(id)
		}
		case 9:{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public room_menu(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Rent your room.^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. Hotel A^n")
	len += format(menu[len],sizeof(menu)-len,"2. Hotel B^n")
	len += format(menu[len],sizeof(menu)-len,"3. Hotel C^n")
	len += format(menu[len],sizeof(menu)-len,"4. Hotel D^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_room_menu(id,key)
{
	switch(key){
		case 0: hotel_a(id)
		
		case 1: hotel_b(id)
		
		case 2: hotel_c(id)
		
		case 3: hotel_d(id)
		
		case 8: hotel(id)
		
		case 9: return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public hotel_a(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Hotel A: How long will you be staying?^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. One Day ($%i)^n",get_cvar_num("rp_hotelmod_price_1day"))
	len += format(menu[len],sizeof(menu)-len,"2. Two Days ($%i)^n",get_cvar_num("rp_hotelmod_price_2day"))
	len += format(menu[len],sizeof(menu)-len,"3. Three Days ($%i)^n^n",get_cvar_num("rp_hotelmod_price_3day"))
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_hotel_a(id,key)
{
	new authid[32], name[33], cost, time, minutes
	
	get_user_authid(id,authid,31)
	get_user_name(id,name,32)
	
	switch(key){
		case 0:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel A'")
			result = dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,1)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_1day")
			time = get_cvar_num("rp_hotelmod_1day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_a'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_a",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel A'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel A'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel A'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='1 Day' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel1'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room A rented for 1 day. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 1:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel A'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			check_room(id,1)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_2day")
			time = get_cvar_num("rp_hotelmod_2day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_a'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_a'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel A'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel A'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel A'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='2 Days' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel1'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room A rented for 2 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 2:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel A'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			check_room(id,1)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			cost = get_cvar_num("rp_hotelmod_price_3day")
			time = get_cvar_num("rp_hotelmod_3day")
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_a'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_a'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel A'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel A'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel A'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='3 Days' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel1'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room A rented for 3 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 8:
		{
			room_menu(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public hotel_b(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Hotel B: How long will you be staying?^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. One Day ($%i)^n",get_cvar_num("rp_hotelmod_price_1day"))
	len += format(menu[len],sizeof(menu)-len,"2. Two Days ($%i)^n",get_cvar_num("rp_hotelmod_price_2day"))
	len += format(menu[len],sizeof(menu)-len,"3. Three Days ($%i)^n^n",get_cvar_num("rp_hotelmod_price_3day"))
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_hotel_b(id,key)
{
	new authid[32], name[33], cost, time, minutes
	
	get_user_authid(id,authid,31)
	get_user_name(id,name,32)
	
	switch(key){
		case 0:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel B'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_1day")
			time = get_cvar_num("rp_hotelmod_1day")
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_b'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_b'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel B'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel B'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel B'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='1 Day' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel2'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room B rented for 1 day. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 1:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel B'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			check_room(id,0)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_2day")
			time = get_cvar_num("rp_hotelmod_2day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_b'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_b'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel B'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel B'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel B'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='2 Days' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel2'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room B rented for 2 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 2:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel B'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			check_room(id,0)
			check_room(id,2)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_3day")
			time = get_cvar_num("rp_hotelmod_3day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_b'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_b'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel B'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel B'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel B'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='3 Days' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel2'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room B rented for 3 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 8:
		{
			room_menu(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public hotel_c(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Hotel C: How long will you be staying?^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. One Day ($%i)^n",get_cvar_num("rp_hotelmod_price_1day"))
	len += format(menu[len],sizeof(menu)-len,"2. Two Days ($%i)^n",get_cvar_num("rp_hotelmod_price_2day"))
	len += format(menu[len],sizeof(menu)-len,"3. Three Days ($%i)^n^n",get_cvar_num("rp_hotelmod_price_3day"))
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}


public action_hotel_c(id,key)
{
	
	new authid[32], name[33], cost, time, minutes
	
	get_user_authid(id,authid,31)
	get_user_name(id,name,32)
	
	switch(key){
		case 0:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel C'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			
			check_room(id,0)
			check_room(id,1)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_1day")
			time = get_cvar_num("rp_hotelmod_1day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_c'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_c'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel C'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel C'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel C'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='1 Day' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel3'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost)
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room C rented for 1 day. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 1:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel C'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0)
			check_room(id,1)
			check_room(id,3)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_2day")
			time = get_cvar_num("rp_hotelmod_2day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_c'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_c'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel C'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel C'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel C'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='2 Days' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel3'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			
			client_print(id,print_chat,"[HotelMod] Room C rented for 2 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 2:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel C'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0)
			check_room(id,1)
			check_room(id,3) 
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_3day")
			time = get_cvar_num("rp_hotelmod_3day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_c'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_c'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel C'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel C'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel C'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='3 Days' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel3'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room C rented for 3 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 8:
		{
			room_menu(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public hotel_d(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Hotel D: How long will you be staying?^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. One Day ($%i)^n",get_cvar_num("rp_hotelmod_price_1day"))
	len += format(menu[len],sizeof(menu)-len,"2. Two Days ($%i)^n",get_cvar_num("rp_hotelmod_price_2day"))
	len += format(menu[len],sizeof(menu)-len,"3. Three Days ($%i)^n^n",get_cvar_num("rp_hotelmod_price_3day"))
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_hotel_d(id,key)
{
	new authid[32], name[33], cost, time, minutes
	
	get_user_authid(id,authid,31)
	get_user_name(id,name,32)
	
	switch(key)
	{
		case 0:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel D'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0)
			check_room(id,1)
			check_room(id,2)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_1day")
			time = get_cvar_num("rp_hotelmod_1day")
			
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_d'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_d'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel D'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel D'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel D'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='1 Day' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel4'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) {
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room D rented for 1 day. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 1:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel D'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0) 
			check_room(id,1) 
			check_room(id,2)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_2day")
			time = get_cvar_num("rp_hotelmod_2day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_d'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_d'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel D'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel D'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel D'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='2 Days' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel4'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost)
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room D rented for 2 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 2:
		{
			format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel D'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				minutes = dbi_field(result,1)
				
				if(minutes > 0)
				{	
					client_print(id,print_chat,"[HotelMod] This room is already rented, come back later^n")
					return PLUGIN_HANDLED
				}
				dbi_free_result(result)
			}
			
			check_room(id,0)
			check_room(id,1)
			check_room(id,2)
			
			if(g_hotel[id] != 0)
			{
				client_print(id,print_chat,"[HotelMod] You can only have one room at a time sir.")
				g_hotel[id] = 0 //RESET, because the checks are executed.
				return PLUGIN_HANDLED
			}
			
			cost = get_cvar_num("rp_hotelmod_price_3day")
			time = get_cvar_num("rp_hotelmod_3day")
			
			format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='hotel_door_d'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='hotel_door_d'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET name='%s' WHERE room='Hotel D'",name)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET steamid='%s' WHERE room='Hotel D'",authid)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET minutes='%i' WHERE room='Hotel D'",time)
			dbi_query(dbc,"%s",query)
			format( query, 255, "UPDATE hotelmod SET type='3 Days' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET profit=profit+'%i' WHERE doorname='hotel4'",cost)
			dbi_query(dbc,"%s",query)
			if(get_user_money(id) < cost) 
			{
				client_print(id,print_chat,"[Bank] Not enough money in bank to rent this room^n")
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",cost)
			client_print(id,print_chat,"[HotelMod] Room D rented for 3 days. Enjoy your stay, sir")
			g_hotel[id] = 0
		}
		case 8:
		{
			room_menu(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public roomstatus(id)
{
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9)
	
	new len = format(menu, sizeof(menu), "Room availability:^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"1. Hotel A^n")
	len += format(menu[len],sizeof(menu)-len,"2. Hotel B^n")
	len += format(menu[len],sizeof(menu)-len,"3. Hotel C^n")
	len += format(menu[len],sizeof(menu)-len,"4. Hotel D^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"9. Go Back^n^n")
	
	len += format(menu[len],sizeof(menu)-len,"0. Close Menu")
	
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_roomstatus(id,key)
{
	new steamid[32], renter[33], time, kind[33]
	
	switch(key)
	{
		case 0:
		{
			format(query,255,"SELECT name,steamid,minutes,type FROM hotelmod WHERE room='Hotel A'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				dbi_field(result,1,renter,32) 
				dbi_field(result,2,steamid,31) //like above, but for the steamid
				time = dbi_field(result,3)  //just a normal variable, no need for a max
				dbi_field(result,4,kind,32)  //kind is a string or number ?			
			}
			new roommotd[2000]
			new len = format(roommotd,511,"Name: %s^n^n",renter)
			len += format(roommotd[len],511-len,"SteamID: %s^n^n",steamid)
			len += format(roommotd[len],511-len,"Minutes Left: %i^n^n",time)
			len += format(roommotd[len],511-len,"Type of rent: %s^n^n",kind)
			show_motd(id,roommotd,"Hotel A Status")
			dbi_free_result(result)	
		}
		case 1:
		{
			format(query,255,"SELECT name,steamid,minutes,type FROM hotelmod WHERE room='Hotel B'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				dbi_field(result,1,renter,32) 
				dbi_field(result,2,steamid,31) //like above, but for the steamid
				time = dbi_field(result,3)  //just a normal variable, no need for a max
				dbi_field(result,4,kind,32)  //kind is a string or number ?		
			}
			new roommotd[2000]
			new len = format(roommotd,511,"Name: %s^n^n",renter)
			len += format(roommotd[len],511-len,"SteamID: %s^n^n",steamid)
			len += format(roommotd[len],511-len,"Minutes Left: %i^n^n",time)
			len += format(roommotd[len],511-len,"Type of rent: %s^n^n",kind)
			show_motd(id,roommotd,"Hotel B Status")
			dbi_free_result(result)	
		}
		case 2:
		{
			format(query,255,"SELECT name,steamid,minutes,type FROM hotelmod WHERE room='Hotel C'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				dbi_field(result,1,renter,32) 
				dbi_field(result,2,steamid,31) //like above, but for the steamid
				time = dbi_field(result,3)  //just a normal variable, no need for a max
				dbi_field(result,4,kind,32)  //kind is a string or number ?		
			}
			new roommotd[2000]
			new len = format(roommotd,511,"Name: %s^n^n",renter)
			len += format(roommotd[len],511-len,"SteamID: %s^n^n",steamid)
			len += format(roommotd[len],511-len,"Minutes Left: %i^n^n",time)
			len += format(roommotd[len],511-len,"Type of rent: %s^n^n",kind)
			show_motd(id,roommotd,"Hotel C Status")
			dbi_free_result(result)	
		}
		case 3:
		{
			format(query,255,"SELECT name,steamid,minutes,type FROM hotelmod WHERE room='Hotel D'")
			result =  dbi_query(dbc,"%s",query)
			
			if(dbi_nextrow(result) > 0)
			{		
				dbi_field(result,1,renter,32) 
				dbi_field(result,2,steamid,31) //like above, but for the steamid
				time = dbi_field(result,3)  //just a normal variable, no need for a max
				dbi_field(result,4,kind,32)  //kind is a string or number ?			
			}
			new roommotd[2000]
			new len = format(roommotd,511,"Name: %s^n^n",renter)
			len += format(roommotd[len],511-len,"SteamID: %s^n^n",steamid)
			len += format(roommotd[len],511-len,"Minutes Left: %i^n^n",time)
			len += format(roommotd[len],511-len,"Type of rent: %s^n^n",kind)
			show_motd(id,roommotd,"Hotel D Status")
			dbi_free_result(result)	
		}
		case 8:
		{
			hotel(id)
		}
		case 9:
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public remove_access_a(id)
{
	new minutes
	
	format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel A'")
	result =  dbi_query(dbc,"%s",query)
	
	if(dbi_nextrow(result) > 0)
	{		
		minutes = dbi_field(result,1)		 
		if(minutes > 0)
		{
			format(query,255,"UPDATE hotelmod SET minutes=minutes-1 WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
		}
		if(minutes <= 0)
		{
			format(query,255,"UPDATE property SET ownername='' WHERE doorname='hotel_door_a'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET ownersteamid='' WHERE doorname='hotel_door_a'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET access='' WHERE doorname='hotel_door_a'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET name='' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET steamid='' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET type='' WHERE room='Hotel A'")
			dbi_query(dbc,"%s",query)
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public remove_access_b(id)
{
	new minutes
	
	format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel B'")
	result =  dbi_query(dbc,"%s",query)
	
	if(dbi_nextrow(result) > 0)
	{		
		minutes = dbi_field(result,1)		 
		if(minutes > 0)
		{
			format(query,255,"UPDATE hotelmod SET minutes=minutes-1 WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
		}
		if(minutes <= 0)
		{
			format(query,255,"UPDATE property SET ownername='' WHERE doorname='hotel_b'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET ownersteamid='' WHERE doorname='hotel_b'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET access='' WHERE doorname='hotel_b'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET name='' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET steamid='' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET type='' WHERE room='Hotel B'")
			dbi_query(dbc,"%s",query)
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public remove_access_c(id)
{
	new minutes
	
	format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel C'")
	result =  dbi_query(dbc,"%s",query)
	
	if(dbi_nextrow(result) > 0)
	{		
		minutes = dbi_field(result,1)	 
		if(minutes > 0)
		{
			format(query,255,"UPDATE hotelmod SET minutes=minutes-1 WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
		}
		if(minutes <= 0)
		{
			format(query,255,"UPDATE property SET ownername='' WHERE doorname='hotel_door_c'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET ownersteamid='' WHERE doorname='hotel_door_c'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET access='' WHERE doorname='hotel_door_c'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET name='' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET steamid='' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET type='' WHERE room='Hotel C'")
			dbi_query(dbc,"%s",query)
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public remove_access_d(id)
{
	new minutes
	
	format(query,255,"SELECT minutes FROM hotelmod WHERE room='Hotel D'")
	result =  dbi_query(dbc,"%s",query)
	
	if(dbi_nextrow(result) > 0)
	{		
		minutes = dbi_field(result,1)		 
		if(minutes > 0)
		{
			format(query,255,"UPDATE hotelmod SET minutes=minutes-1 WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
		}
		if(minutes <= 0)
		{
			format(query,255,"UPDATE property SET ownername='' WHERE doorname='hotel_door_d'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET ownersteamid='' WHERE doorname='hotel_door_d'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE property SET access='' WHERE doorname='hotel_door_d'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET name='' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET steamid='' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
			format(query,255,"UPDATE hotelmod SET type='' WHERE room='Hotel D'")
			dbi_query(dbc,"%s",query)
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public check_room(id,key)
{
	new authid[32], steamid[32]
	
	get_user_authid(id,authid,31)
	
	switch(key){
		case 0:{
			format(query,255,"SELECT steamid FROM hotelmod WHERE room='Hotel A'")
		}
		case 1:{
			format(query,255,"SELECT steamid FROM hotelmod WHERE room='Hotel B'")
		}
		case 2:{
			format(query,255,"SELECT steamid FROM hotelmod WHERE room='Hotel C'")
		}
		case 3:{
			format(query,255,"SELECT steamid FROM hotelmod WHERE room='Hotel D'")
		}
	}
	
	result =  dbi_query(dbc,"%s",query)
	
	if(dbi_nextrow(result) > 0)
	{		
		dbi_field(result,1,steamid,31)                 		
		if(equali(authid,steamid))
		{
			g_hotel[id] = 1
		}
		dbi_free_result(result)
	}
	return PLUGIN_HANDLED
}
