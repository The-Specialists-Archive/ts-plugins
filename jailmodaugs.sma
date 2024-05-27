// Shin´s Custom JailMod Plugin

#include <amxmodx>
#include <amxmisc>
#include <dbi>
#include <engine>
#include <fun>

new Sql:dbc
new Result:result

//Definitions
#define Keyscriminalt (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 1234
#define TELEDIST	200

//Jail Mod Positions
new jailone[3]={2762, 388, 147} 
new jailtwo[3]={2578, 209, 147} 
new jailthree[3]={2414, 359, 147} 
new introom[3]={-3521, -142, 36}


/////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////
public plugin_init()
{
	register_plugin("Jail Mod","Final-Ventura-Menu","Shin Lee")
	
	register_menucmd(register_menuid("criminalt"), Keyscriminalt, "Pressedcriminalt")
	
	register_clcmd("amx_jailmod","Showcriminalt",0,"- displays teleport menu")
	
	register_cvar("rp_police_start","1")
	register_cvar("rp_police_end","30")
	
	set_task(1.0,"sql_init")

	
}

// Initializing the MySQL database (Originally Developed by: Harbu)
public sql_init()
{
	new host[32], username[32], password[32], dbname[32], error[32]
	get_cvar_string("economy_mysql_host",host,32)
	get_cvar_string("economy_mysql_user",username,32) 
	get_cvar_string("economy_mysql_pass",password,32) 
	get_cvar_string("economy_mysql_db",dbname,32) 
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if (dbc == SQL_FAILED)
		{
		server_print("[JailMod] Could Not Connect To SQL Database^n")
	}
	else
		{
		server_print("[JailMod] Connected To SQL, Have A Nice Day!^n")
	}
}

/////////////////////////////////////////////
//Jail Mod (JOB ID Check - Originally Developed by Harbu)
/////////////////////////////////////////////
/////////////////////////////////////////////
// Show Menu (Admins Only) - Examples used from Harbu and Avalanches Code
/////////////////////////////////////////////
public Showcriminalt(id) {
	new buffer[64], authid[32], JobID, name[32]
	get_user_name( id, name, sizeof( name ) )
	get_user_authid( id, authid, sizeof( authid ) )
	select_string( id,"money","JobID","steamid",authid,buffer)
	JobID = str_to_num( buffer )
	if( JobID < get_cvar_num("rp_police_start") || JobID > get_cvar_num("rp_police_end") ){
		client_print(id,print_chat,"[JailMod] You have to work for the VCPD to teleport someone!^n")
		return PLUGIN_HANDLED
	}
	show_menu(id, Keyscriminalt, "-Criminal Teleport-^n--Teleport To:--^n^n1. Cell 1^n2. Cell 2^n3. Cell 3^n4. Interrogation Room^n^n0. Exit", -1, "criminalt") // Display menu
	return PLUGIN_HANDLED
}

// Select string (Originally Developed by: Harbu)
public select_string(id,table[],index[],condition[],equals[],output[])
{
	new query[256]
	format(query,255,"SELECT %s FROM %s WHERE %s='%s'",index,table,condition,equals)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0) dbi_field(result,1,output,64)
	dbi_free_result(result)
}

public Pressedcriminalt(id, key) {
	
	new player, body, Float:dist = get_user_aiming(id,player,body,9999);
	if(dist > TELEDIST) {
		client_print(id,print_chat,"* [JailMod] You are not close enough to the player^n");
		return PLUGIN_HANDLED
	}
	/* Jail-Menu:
	* -Criminal Options-
	* --Teleport To:--
	* 1. Cell 1
	* 2. Cell 2
	* 3. Cell 3
	* 4. Interrogation Room
	*
	* 0. Exit
	*/
	
	switch (key) {
		
		case 0: { // 1
			new entid, entbody
			get_user_aiming(id,entid,entbody,200)
			client_print(entid,print_chat,"* [JailMod] You have been sent to jail cell 1^n")
			set_user_origin(entid,jailone)
			client_print(id,print_chat,"* [JailMod] User has been sent to cell 1^n")
		}
		case 1: { // 2
			new entid, entbody
			get_user_aiming(id,entid,entbody,200)
			client_print(entid,print_chat,"* [JailMod] You have been sent to jail cell 2^n")
			set_user_origin(entid,jailtwo)
			client_print(id,print_chat,"* [JailMod] User has been sent to cell 2^n")

		}
		case 2: { // 3
			new entid, entbody
			get_user_aiming(id,entid,entbody,200)
			client_print(entid,print_chat,"* [JailMod] You have been sent to jail cell 3^n")
			set_user_origin(entid,jailthree)
			client_print(id,print_chat,"* [JailMod] User has been sent to cell 3^n")
		}
		case 3: { // 4
			new entid, entbody
			get_user_aiming(id,entid,entbody,200)
			client_print(entid,print_chat,"* [JailMod] You have been sent to the interrogation room^n")
			set_user_origin(entid,introom)
			client_print(id,print_chat,"* [JailMod] User has been sent to the interrogation room^n")
		}
		case 8: { // 0
		}
	}
	return PLUGIN_HANDLED
}