////////////////////////////////////////////////////////////////
//	Harbu's Talkarea 1.5
//	Includes basic say, shout, ooc, cnn
//
//	Commands which require Harbu RP Main Pugin
//	amx_regnum, /call, com
//
///////////////////////////////////////////////////////////////

#pragma dynamic 32768

#include <amxmodx> 
#include <amxmisc> 
#include <engine>
#include <fun>
#include <dbi>
#include <tsx>

#define CELLPHONE_ONE_ID 13
#define CELLPHONE_TWO_ID 14
#define CALLERID 16
#define SUBSCRIPTION 18
#define PHONE_HACK_DEVICE 30

#define MAXIUMSTR 512
#define ITEMS 40

#define MCPDSTART 2
#define MCPDEND 11
#define MCMDSTART 41
#define MCMDEND 46

#define PAYPHONEBANK 132255
#define PAYPHONEBANKTWO 132256

#define PAYPHONESEVENELEVEN 151344
#define PAYPHONESEVENELEVENTWO 151345

#define PAYPHONEMCPD 181333

#define PRIVATEPHONEMCPD 911
#define PRIVATEPHONEHOTEL 111992


// SQL Handels
new Sql:dbc
new Result:result

new g_number[33][6]
new g_numfunc[33][32]

new g_cnntime[33] = 0
new g_adstatus[33]

// Global Phone Variables
new g_phone[33] = 0
new g_company[33] = 0
new g_caller[33] = 0
new g_phoneesta[33] = 0
new g_disable[33] = 0
new g_timer[33][2]
new g_paytimer[33]

/*/// Pay Phone Co-ordinates
new publicone[3] = { 79, -359, -411 }		// Payphone next to Bank Public Phone
new publictwo[3] = { 39, -359, -411 }		// Payphone next to Bank Public Phone #2
new publicthree[3] = { -1951, 1111, -411 }	// Payphone next to 7/11
new publicfour[3] = { -1951, 1152, -411 }	// Payphone #2 next to 7/11
new publicfive[3] = { 2328, 1833, -347 }	// Payphone in MCPD Jails

new privateone[3] = { -2096, 2304, -347 }	// MCPD Private Phone
new privatetwo[3] = { -718, 672, -395 }		// Hotel Private Phone

//new g_cityphone[7]				// Keeps callers for cityphones */

// Thanks for Ben 'Promethus' for this script
stock explode( output[][], input[], delimiter) 
{ 
	new nIdx = 0
	new iStringSize
	while ( input[iStringSize] ) 
		iStringSize++ 
	new nLen = (1 + copyc( output[nIdx], iStringSize-1, input, delimiter ))

	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], iStringSize-1, input[nLen], delimiter ))
	return nIdx + 1
}
public plugin_precache()
{
	precache_sound("phone/ring.wav")
	precache_sound("phone/busy.wav")
	precache_sound("phone/Error.wav")
	precache_sound("phone/beep.wav")
	precache_sound("phone/sms.wav")
	precache_sound("phone/1.wav")
	precache_sound("phone/2.wav")
	precache_sound("phone/3.wav")
	precache_sound("phone/4.wav")
	precache_sound("phone/5.wav")
	precache_sound("phone/6.wav")
	precache_sound("phone/7.wav")
	precache_sound("phone/8.wav")
	precache_sound("phone/9.wav")
	precache_sound("phone/0.wav")

	precache_model("models/mecklenburg/phone/v_cell.mdl")
	precache_model("models/mecklenburg/phone/p_cell.mdl")
}

public plugin_init()
{
	register_plugin("Harbu Talkarea","Alpha 1","Harbu")
	
	register_clcmd("say /adsoff","advertising_off")
	register_clcmd("say /adson","advertising_on")

	register_clcmd("say","handle_say")
	register_clcmd("say_team","handle_teamsay")
	register_cvar("sv_ooc","1")
	register_cvar("sv_cnn","1")
	register_cvar( "rp_printconsole", "1" )
	register_cvar( "rp_capscom", "1" )

	set_task(60.0,"cnnreset",0,"",0,"b")
	set_task(5.0,"sql_init")
	set_task(1.0,"timer",0,"",0,"b")

	// SQL Cvars
	register_cvar("talkarea_mysql_host","127.0.0.1",FCVAR_PROTECTED)
	register_cvar("talkarea_mysql_user","root",FCVAR_PROTECTED)
	register_cvar("talkarea_mysql_pass","",FCVAR_PROTECTED)
	register_cvar("talkarea_mysql_db","economy",FCVAR_PROTECTED)

	register_menucmd(register_menuid("Phone Mod:"),1023,"action_dialnumber")
	register_menucmd(register_menuid("Main "),1023,"Action_Phonemenu")
	register_menucmd(register_menuid("Phone Status "),1023,"action_phone_status")

	register_event("DeathMsg","death_msg","a")

	// Creating Phones
	/*create_ambient(privateone,"private_mcpd","10","100",8,"phone/call.wav")
	create_ambient(privatetwo,"private_hotel","10","100",8,"phone/call.wav")

	create_ambient(publicone,"public_bank1","10","80",8,"phone/call.wav")
	create_ambient(publictwo,"public_bank2","10","80",8,"phone/call.wav")
	create_ambient(publicthree,"public_seveneleven1","10","80",8,"phone/call.wav")
	create_ambient(publicfour,"public_seveneleven2","10","80",8,"phone/call.wav")
	create_ambient(publicfive,"public_mcpd","10","80",8,"phone/call.wav") */

}

// Initializing the MySQL database sc delete mysql 
public sql_init()
{
	new host[64], username[32], password[32], dbname[32], error[32]
 	get_cvar_string("economy_mysql_host",host,64) 
    	get_cvar_string("economy_mysql_user",username,32) 
    	get_cvar_string("economy_mysql_pass",password,32) 
    	get_cvar_string("economy_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if (dbc == SQL_FAILED)
	{
		server_print("[Harbu Talkarea] Could Not Connect To SQL Database^n")
	}
	else
	{
	server_print("[Harbu Talkarea] Connected To SQL, Have A Nice Day!^n")
	dbi_query(dbc,"CREATE TABLE IF NOT EXISTS `money` ( `steamid` VARCHAR(32) NOT NULL default '', `balance` INT NOT NULL default 1000, `salary` INT NOT NULL default 10, `timeleft` INT NOT NULL default 60, `job` VARCHAR(32) NOT NULL default 'Unemployed'")
	}
}
///////////////////////////////
// Harbus Common SQL Library
//////////////////////////////

// Check the amount of the specified item
public itemamount(id,itemid,table[])
{
	new authid[32], amount, query[256]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new field[MAXIUMSTR]
		new output[ITEMS][32]
		dbi_field(result,1,field,MAXIUMSTR-1)
		dbi_free_result(result)
		new total = explode(output,field,' ')
		for( new i = 0;  i < total; i++ )
		{
			new output2[2][32]
			explode(output2,output[i],'|')
			if(str_to_num(output2[0]) == itemid)
			{
				amount = str_to_num(output2[1])
				dbi_free_result(result)
				return amount
			}
		}
	}
	else dbi_free_result(result)
	return amount
}

// Function for adding/subtracting money from your wallet and Bank balance
public edit_value(id,table[],index[],func[],amount)
{
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
	dbi_query(dbc,query)
	return PLUGIN_HANDLED
}

// Selecting one string from the database
public select_string(id,table[],index[],condition[],equals[],output[])
{
	new query[256]
	format(query,255,"SELECT %s FROM %s WHERE %s='%s'",index,table,condition,equals)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0) dbi_field(result,1,output,64)
	dbi_free_result(result)
}



// Reset the anti-cnn time
public cnnreset()
{
	new players[32], num
	get_players(players,num,"")
	for(new i = 0 ;i < num ;++i) {
		g_cnntime[players[i]] = 0
	}
	return PLUGIN_HANDLED
}

public handle_teamsay(id)
{
	new Speech[300]
	read_args(Speech, 299)
	remove_quotes(Speech)
	if(equali(Speech,"")) return PLUGIN_HANDLED

	new name[33]
	get_user_name(id,name,sizeof(name))
	if(get_cvar_num("sv_ooc") <= 0) {
		client_print(id,print_chat,"[TalkArea] OOC is currently Disabled!^n")
		return PLUGIN_HANDLED
	}
	trim(Speech)
	format(Speech,299,"^n%s: (( %s ))^n",name,Speech)
	remove_quotes(Speech)
	client_print(id,print_chat,Speech)
	overhear(id,-1,Speech,0,1,0)
	return PLUGIN_HANDLED
}


// Parses through and decides if the message is a say, shout etc..
public handle_say(id)
{
	new Speech[300], arg[32], arg2[32]

	read_args(Speech, 299)
	remove_quotes(Speech)
	if(equali(Speech,"")) return PLUGIN_HANDLED
	parse(Speech,arg,31,arg2,31) 

	new name[33]
	get_user_name(id,name,sizeof(name))

	if(equali(Speech,"ooc",3))	// Out of Character, Everyone will hear it!
	{
		if(get_cvar_num("sv_ooc") <= 0) {
			client_print(id,print_chat,"[TalkArea] OOC is currently Disabled!^n")
			return PLUGIN_HANDLED
		}
		replace(Speech,299,"ooc","")
		trim(Speech)
		format(Speech,299,"^n%s: (( %s ))^n",name,Speech)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,-1,Speech,0,1,0)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"/me",3))	// And ME Action similar to IRC (Harbu eats a carrot)
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		replace(Speech,299,"/me","")
		trim(Speech)
		format(Speech,299,"^n(Action) %s %s^n",name,Speech)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,400,Speech,0,0,0)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"cnn",3))	// Used for news flashes
	{
		if(g_cnntime[id] == 1) {
			client_print(id,print_chat,"[TalkArea] Wait a while before sending a new CNN message!^n")
			return PLUGIN_HANDLED
		}
		if(get_cvar_num("sv_cnn") <= 0) {
			client_print(id,print_chat,"[TalkArea] CNN is currently Disabled!^n")
			return PLUGIN_HANDLED
		}
		replace(Speech,299,"cnn","")
		trim(Speech)
		format(Speech,299,"^n<NEWSFLASH> - %s: (( %s ))^n",name,Speech)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,-1,Speech,1,1,0)
		client_cmd(id,"speak ^"fvox/alert^"")
		g_cnntime[id] = 1

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"shout",5))	// Shouting messages cover a large distance
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		replace(Speech,299,"shout","")
		trim(Speech)
		strtoupper(Speech)
		format(Speech,299,"^n(Shout) %s: %s^n",name,Speech)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,800,Speech,0,0,0)
		
		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"quiet",5))	// Quiet messages can only be heard by people next to you
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		replace(Speech,299,"quiet","")
		trim(Speech)
		strtolower(Speech)
		format(Speech,299,"^n(Whisper) %s: %s^n",name,Speech)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,80,Speech,0,0,0)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"steamid",7))	// Automaticly prints your steamid
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		new authid[32]
		get_user_authid(id,authid,31)
		format(Speech,299,"^n(SteamID) %s: %s^n",name,authid)
		remove_quotes(Speech)
		client_print(id,print_chat,Speech)
		overhear(id,300,Speech,0,0,0)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"/com",4))	// Intercom Radio for MCPD and MCMD
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		replace(Speech,299,"/com","")
		trim(Speech)
		if( get_cvar_num( "rp_capscom" ) == 1 ) strtoupper(Speech)
		format(Speech,299,"^n(Intercom) %s: <%s>^n",name,Speech)
		remove_quotes(Speech)
		com_message(id,Speech)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"sms",3))	// Text Messages for phone
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		replace(Speech,299,arg2,"")
		replace(Speech,299,"sms","")
		new target = cmd_target(id,arg2,0)
		if(!target) return PLUGIN_HANDLED
		format(Speech,299,"^n(SMS) %s:%s^n",name,Speech)
		remove_quotes(Speech)
		sms_message(id,Speech,target)

		if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

		return PLUGIN_HANDLED
	}
	if(equali(Speech,"/phone",6) || equali(Speech,"phone",5) || equali(Speech,"/call",5) || equali(Speech,"/answer",7) || equali(Speech,"/hangup",7))
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		set_weapon_kungfu(id)
		set_task(0.1,"Phonemenu",id)
		return PLUGIN_HANDLED
	}
	if(equali(Speech,"advert",6))
	{
		if(g_adstatus[id] == 1)
		{
			//Checks to make sure you have not used CNN in 5 seconds.
			if(g_cnntime[id] == 0)
			{
					//If you have not, format it, send it, and reset the array.
					g_cnntime[id]= 1
					replace(Speech,299,"advert","")
					trim(Speech)
					format(Speech,299,"(ADVERT) - %s: (( %s ))^n",name,Speech)
					remove_quotes(Speech)
					client_print(id,print_chat,Speech)
					overhear(id,-1,Speech,0,0,1)

					if( get_cvar_num( "rp_printconsole" ) == 1 ) server_print( Speech )

					return PLUGIN_HANDLED
			}
			client_print(id,print_chat,"[ADVERTISING] You can't send message now^n")
			return PLUGIN_HANDLED
		}
		else
		{
			client_print(id,print_chat,"* ADVERTISING IS DISABLED^n")
			return PLUGIN_HANDLED
		}
	}

	if(g_phone[id] > 0)
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED

		new name2[33], Speech2[300]
		get_user_name(g_phone[id],name2,sizeof(name2))

		format(Speech2,299,"^n(%s's Phone): %s^n",name2,Speech)
		client_print(g_phone[id],print_chat,Speech2)

		client_print(id,print_chat,"^n%s: %s^n",name,Speech)
		format(Speech,299,"^n%s: %s^n",name,Speech)

		remove_quotes(Speech)

		overhear(id,300,Speech,0,0,0)
		overhear(g_phone[id],200,Speech2,0,0,0)

		return PLUGIN_HANDLED
	}
	else
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED
		format(Speech,299,"^n%s: %s^n",name,Speech)
		client_print(id,print_chat,Speech)
		overhear(id,300,Speech,0,0,0)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

/////////////////////////////
// Phones
/////////////////////////////

// Main Menu
public Phonemenu(id)
{
	new origin[3]
	get_user_origin(id,origin)
	if(itemamount(id,CELLPHONE_ONE_ID,"money") <= 0 && itemamount(id,CELLPHONE_TWO_ID,"money") <= 0) { //<= 0 && get_distance(origin,publicone) > 25.0 && get_distance(origin,publictwo) > 25.0 && get_distance(origin,publicthree) > 25.0 && get_distance(origin,publicfour) > 25.0 && get_distance(origin,publicfour) > 25.0  && get_distance(origin,publicfive) > 25.0 && get_distance(origin,privateone) > 25.0 && && get_distance(origin,privatetwo) > 25.0 ) {
		client_print(id,print_chat,"[ItemMod] You need a cellphone or go near a phone!^n")
		return PLUGIN_HANDLED
	}
	entity_set_string(id,EV_SZ_viewmodel,"models/mecklenburg/phone/v_cell.mdl")
	entity_set_string(id,EV_SZ_weaponmodel,"models/mecklenburg/phone/p_cell.mdl")

	new esta[32]

	if(g_phone[id] == 0 && g_company[id] == 0 && g_disable[id] == 0 && g_caller[id] == 0) format(esta,31,"Idle")		// If No Active Calls, No tries
	if(g_phone[id] != 0 && g_company[id] == 0 && g_disable[id] == 0) format(esta,31,"Phone Call")	// If Acitve Calls, No Tries
	if(g_phone[id] == 0 && g_company[id] != 0 && g_disable[id] == 0 && g_caller[id] == 0) format(esta,31,"Ringing")		// If No Active Call but tries
	if(g_phone[id] == 0 && g_company[id] == 0 && g_disable[id] == 1 && g_caller[id] == 0) format(esta,31,"Disabled")		// IF Phone is disabled
	if(g_phone[id] == 0 && g_company[id] != 0 && g_disable[id] == 0 && g_caller[id] == 1) format(esta,31,"Calling")		// IF Trie and from own phone

	new body[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9)

	for(new i = 0;i < 6;i++) {
		g_number[id][i] = 0
	}

	g_phoneesta[id] = 0
	new len = format(body,sizeof(body),"Main Phone Menu (esta: %s)^n",esta)
	if(equali(esta,"Idle"))
	{
		g_phoneesta[id] = 1
		add(body,sizeof(body),"^n1. Call^n")
		add(body,sizeof(body),"2. Register Number^n")
		add(body,sizeof(body),"3. Phone Status^n")
		add(body,sizeof(body),"4. Deactivate Phone^n")
	}
	if(equali(esta,"Ringing"))
	{
		new callerid = itemamount(id,CALLERID,"money")
		if(callerid > 0)
		{
			new name[33], query[256], authid[32]
			get_user_name(g_company[id],name,sizeof(name))
			get_user_authid(g_company[id],authid,31)
			format(query,255,"SELECT pnum FROM money WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new num[32]
				dbi_field(result,1,num,31)
				dbi_free_result(result)
				if(itemamount(g_company[id],PHONE_HACK_DEVICE,"money") > 0)
				{
					format(name,sizeof(name),"*PROTECTED*")
					format(num,sizeof(name),"******")
				}

				len += format(body[len],sizeof(body)-len,"^n-----------------------------------------^n")
				len += format(body[len],sizeof(body)-len,"Caller Name: %s^n",name)
				len += format(body[len],sizeof(body)-len,"Caller Number: %s^n",num)
				len += format(body[len],sizeof(body)-len,"-----------------------------------------^n")
			}
			else dbi_free_result(result)
		}
		g_phoneesta[id] = 2
		add(body,sizeof(body),"^n1. Answer Call^n")
		add(body,sizeof(body),"2. Cancel Call^n")
	}
	if(equali(esta,"Phone Call"))
	{
		new callerid = itemamount(id,CALLERID,"money")
		if(callerid > 0)
		{
			new name[33], query[256], authid[32]
			get_user_name(g_phone[id],name,sizeof(name))
			get_user_authid(g_phone[id],authid,31)
			format(query,255,"SELECT pnum FROM money WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new num[32]
				dbi_field(result,1,num,31)
				dbi_free_result(result)
				if(itemamount(g_phone[id],PHONE_HACK_DEVICE,"money") > 0)
				{
					format(name,sizeof(name),"*PROTECTED*")
					format(num,sizeof(name),"******")
				}

				len += format(body[len],sizeof(body)-len,"^n----------------------------------------^n")
				len += format(body[len],sizeof(body)-len,"Caller Name: %s^n",name)
				len += format(body[len],sizeof(body)-len,"Caller Number: %s^n",num)
				len += format(body[len],sizeof(body)-len,"----------------------------------------^n")
			}
			else dbi_free_result(result)
		}
		g_phoneesta[id] = 3
		add(body,sizeof(body),"^n1. Hangup Call^n")
		add(body,sizeof(body),"2. Call Status^n")
	}
	if(equali(esta,"Disabled"))
	{
		g_phoneesta[id] = 4
		add(body,sizeof(body),"^n1. Enable^n")
	}
	if(equali(esta,"Calling"))
	{
		g_phoneesta[id] = 5
		add(body,sizeof(body),"^n1. Cancel Call^n")
	}
	add(body,sizeof(body),"^n0. Exit Menu^n")
	show_menu(id,key,body)
	return PLUGIN_HANDLED
}

public Action_Phonemenu(id,key)
{
	if(key == 9) {
		entity_set_string(id,EV_SZ_viewmodel,"")
		entity_set_string(id,EV_SZ_weaponmodel,"")
		entity_set_int(id,EV_INT_weaponanim,0)
		return PLUGIN_HANDLED
	}
	if(g_phoneesta[id] == 1)
	{
		if(key == 0)
		{
			new pnum[64], authid[32]
			get_user_authid(id,authid,31)
			select_string(id,"money","pnum","steamid",authid,pnum)
			if(equali(pnum,"")) {
				client_print(id,print_chat,"[PhoneMod] Register a phone number before calling someone^n")
				return PLUGIN_HANDLED
			}
			dialnumber(id,"Call")
		}
		if(key == 1) dialnumber(id,"Register")
		if(key == 2) phone_status(id)
		if(key == 3)
		{
			if(g_phone[id] != 0) hangup(id,1)
			if(g_company[id] != 0) cancel_call(id)
			g_disable[id] = 1
			entity_set_string(id,EV_SZ_viewmodel,"")
			entity_set_string(id,EV_SZ_weaponmodel,"")
			entity_set_int(id,EV_INT_weaponanim,0)
		}
		if(key >= 4) Phonemenu(id)
		return PLUGIN_HANDLED
	}
	if(g_phoneesta[id] == 2)
	{
		if(key == 0) {
			if((g_phone[id] != 0) || (g_company[id] == 0)) return PLUGIN_HANDLED
			answer(id)
		}
		if(key == 1) {
			entity_set_string(id,EV_SZ_viewmodel,"")
			entity_set_string(id,EV_SZ_weaponmodel,"")
			entity_set_int(id,EV_INT_weaponanim,0)
			cancel_call(id)
		}
		//else Phonemenu(id)
	}
	if(g_phoneesta[id] == 3)
	{
		if(key == 0) hangup(id,1)
		else if(key == 1) {

			new string[32], len

			if(g_timer[id][1] >= 10) len = format(string,31,"%i:",g_timer[id][1])
			else if(g_timer[id][1] < 10) len = format(string,31,"0%i:",g_timer[id][1])

			if(g_timer[id][0] >= 10) len += format(string[len],31-len,"%i",g_timer[id][0])
			else if(g_timer[id][0] < 10) len += format(string[len],31-len,"0%i",g_timer[id][0])

			client_print(id,print_center,"Phone Call Has Lasted %s^n",string)
		}
		else Phonemenu(id)
		return PLUGIN_HANDLED
	}
	if(g_phoneesta[id] == 4)
	{
		if(key == 0) {
			g_disable[id] = 0
			entity_set_string(id,EV_SZ_viewmodel,"models/mecklenburg/phone/v_cell.mdl")
			entity_set_string(id,EV_SZ_weaponmodel,"models/mecklenburg/phone/p_cell.mdl")
			Phonemenu(id)
		}
		else Phonemenu(id)
	}
	if(g_phoneesta[id] == 5)
	{
		if(key == 0) {
			if(g_caller[id] == 0) return PLUGIN_HANDLED
			entity_set_string(id,EV_SZ_viewmodel,"")
			entity_set_string(id,EV_SZ_weaponmodel,"")
			entity_set_int(id,EV_INT_weaponanim,0)
			cancel_call(id)
		}
		else Phonemenu(id)
	}

	return PLUGIN_HANDLED
}

// Registering Number - g_number
public dialnumber(id,func[])
{
	new body[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)

	new len = format(body,sizeof(body),"Phone Mod: %s Number^n",func)
	len += format(body[len],sizeof(body)-len,"---------------------------------------^n")
	len += format(body[len],sizeof(body)-len,"              %i%i%i-%i%i%i        ^n",g_number[id][0],g_number[id][1],g_number[id][2],g_number[id][3],g_number[id][4],g_number[id][5])
	len += format(body[len],sizeof(body)-len,"---------------------------------------^n")

	add(body,sizeof(body),"^n1. One^n")
	add(body,sizeof(body),"2. Two^n")
	add(body,sizeof(body),"3. Three^n")
	add(body,sizeof(body),"4. Four^n")
	add(body,sizeof(body),"5. Five^n")
	add(body,sizeof(body),"6. Six^n")
	add(body,sizeof(body),"7. Seven^n")
	add(body,sizeof(body),"8. Eight^n")
	add(body,sizeof(body),"9. Nine^n")
	add(body,sizeof(body),"^n0. Exit^n")

	format(g_numfunc[id],31,"%s",func)

	show_menu(id,key,body)
	return PLUGIN_HANDLED
}
	
public action_dialnumber(id,key)
{
	client_cmd(id,"speak ^"phone/%i^"",key+1)
	if(key != 9)
	{
		for(new i = 0;i < 6;i++) {
			if(g_number[id][i] == 0) {
				g_number[id][i] = key+1
				break
			}
		}
		if(g_number[id][5] != 0) {
			if(equali(g_numfunc[id],"Register")) regnumber(id,g_number[id][0],g_number[id][1],g_number[id][2],g_number[id][3],g_number[id][4],g_number[id][5])
			if(equali(g_numfunc[id],"Call")) resolve(id,g_number[id][0],g_number[id][1],g_number[id][2],g_number[id][3],g_number[id][4],g_number[id][5])
			format(g_numfunc[id],31,"")
		}
		else
		{
			dialnumber(id,g_numfunc[id])
		}
	}
	if(key == 9)
	{
		entity_set_string(id,EV_SZ_viewmodel,"")
		entity_set_string(id,EV_SZ_weaponmodel,"")
		entity_set_int(id,EV_INT_weaponanim,0)
		for(new i = 0;i < 6;i++) {
			g_number[id][i] = 0
		}
		format(g_numfunc[id],31,"")
	}
	return PLUGIN_HANDLED
}

// The actualy number registaration function
public regnumber(id,num1,num2,num3,num4,num5,num6)
{
	new authid[32], query[256], pnum[32]
	get_user_authid(id,authid,31)
	format(pnum,31,"%i%i%i%i%i%i",num1,num2,num3,num4,num5,num6)
	format(query,255,"SELECT * FROM money WHERE pnum='%s'",pnum)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		client_print(id,print_chat,"[Phone Mod] Number %i%i%i-%i%i%i has been already registered!^n",num1,num2,num3,num4,num5,num6)
		entity_set_string(id,EV_SZ_viewmodel,"")
		entity_set_string(id,EV_SZ_weaponmodel,"")
		entity_set_int(id,EV_INT_weaponanim,0)
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	format(query,255,"UPDATE money SET pnum='%s' WHERE steamid='%s'",pnum,authid)
	dbi_query(dbc,query)
	client_print(id,print_chat,"[Phone Mod] Number %i%i%i-%i%i%i successfully registered!^n",num1,num2,num3,num4,num5,num6)
	return PLUGIN_HANDLED
}

// Resolve user from SQL Database and call
public resolve(id,num1,num2,num3,num4,num5,num6)
{
	new authid[32], tauthid[32], query[256], pnum[32], tid
	get_user_authid(id,authid,31)
	format(pnum,31,"%i%i%i%i%i%i",num1,num2,num3,num4,num5,num6)
	format(query,255,"SELECT steamid FROM money WHERE pnum='%s'",pnum)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,tauthid,31)
		dbi_free_result(result)
		if(g_phone[id] != 0 || g_company[id] != 0)
		{
			client_print(id,print_chat,"[PhoneMod] You are already in the middle of a conversation^n")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		if(equali(authid,tauthid,31)) {
			client_print(id,print_chat,"[PhoneMod] You can't call your self^n")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		tid = cmd_target(id,tauthid,4)
		if(!tid) {
			client_print(id,print_chat,"[PhoneMod] User is not in the city range or is dead^n")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		if(g_phone[tid] != 0 || g_company[tid] != 0) {
			client_print(id,print_chat,"[PhoneMod] The line is busy, try again later...^n")
			client_cmd(id,"speak ^"phone/busy^"")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		if(g_disable[tid] == 1) {
			client_print(id,print_chat,"[PhoneMod] User has disabled their phone^n")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		if(itemamount(tid,CELLPHONE_ONE_ID,"money") <= 0 && itemamount(tid,CELLPHONE_TWO_ID,"money") <= 0) {
			client_print(id,print_chat,"[PhoneMod] User has not got a cellphone with them^n")
			Phonemenu(id)
			return PLUGIN_HANDLED
		}
		if(itemamount(id,SUBSCRIPTION,"money") > 0)
		{
			format(query,255,"SELECT balance FROM money WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new balance
				balance = dbi_field(result,1)
				dbi_free_result(result)
				if(balance <= 0)
				{
					format(query,255,"SELECT ptime FROM money WHERE steamid='%s'",authid)
					result = dbi_query(dbc,query)
					if(dbi_nextrow(result) > 0)
					{
						new ptime
						ptime = dbi_field(result,1)
						dbi_free_result(result)
						if(ptime <= 0)
						{
							client_print(id,print_chat,"[PhoneMod] You don't have enough money nor prepaid time in your bank account^n")
							Phonemenu(id)
							return PLUGIN_HANDLED
						}
					}
					else dbi_free_result(result)
				}
			}
			else dbi_free_result(result)
		}
		else
		{
			format(query,255,"SELECT ptime FROM money WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new ptime
				ptime = dbi_field(result,1)
				dbi_free_result(result)
				if(ptime <= 0)
				{
					client_print(id,print_chat,"[PhoneMod] You don't have enough prepaid time^n")
					Phonemenu(id)
					return PLUGIN_HANDLED
				}
			}
			else dbi_free_result(result)
		}

		g_company[id] = tid
		g_company[tid] = id
		g_caller[id] = 1

		new sid[2]
		sid[0] = tid

		set_task(5.0,"ring",tid+5,sid,3,"a",20)
		client_print(id,print_chat,"[PhoneMod] Calling to %i%i%i-%i%i%i..^n",num1,num2,num3,num4,num5,num6)
		return PLUGIN_HANDLED
		}
	else
	{
		dbi_free_result(result)
		client_print(id,print_chat,"[PhoneMod] The dialed number is not in use^n")
		client_cmd(id,"speak ^"phone/Error^"")
		Phonemenu(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

// Making the ringing
public ring(sid[])
{
	new id = sid[0]
	new name[33], str[64]
	get_user_name(id,name,sizeof(name))
	format(str,63,"[PhoneMod] %s's phone is ringing...^n",name)
	client_print(id,print_chat,"[PhoneMod] Your phone is ringing...^n")
	client_cmd(g_company[id],"speak ^"phone/beep^"")
	overhear(id,350,str,0,0,0)
	emit_sound(id, CHAN_ITEM, "phone/ring.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED
}


// If user answers phone COMPANY[ID] Callers ID, Normal ID is answerers
public answer(id)
{
	g_phone[id] = g_company[id]
	g_phone[g_company[id]] = id
	g_company[g_phone[id]] = 0
	remove_task(g_company[id]+5)
	g_company[id] = 0
	client_print(g_phone[id],print_chat,"[Phone Mod] Player has answered the call!^n")
	client_print(id,print_chat,"[Phone Mod] You have answered the call!^n")
	emit_sound(id, CHAN_ITEM, "phone/ring.wav", 0.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(g_phone[id], CHAN_ITEM, "phone/ring.wav", 0.0, ATTN_NORM, 0, PITCH_NORM)
	remove_task(id+5)
	return PLUGIN_HANDLED
}

// If player hangs up
public hangup(id,msg)
{
	remove_task(id+5)
	remove_task(g_company[id]+5)
	if(g_phone[id] == 0) return PLUGIN_HANDLED
	if(msg == 1)client_print(id,print_chat,"[Phone Mod] You have hungup the call..^n")
	client_print(g_phone[id],print_chat,"[Phone Mod] Your call was hungup on..^n")
	g_caller[id] = 0
	g_caller[g_phone[id]] = 0
	g_phone[g_phone[id]] = 0
	g_phone[id] = 0
	g_company[g_company[id]] = 0
	g_company[id] = 0
	set_task(0.2,"Phonemenu",id)
	return PLUGIN_HANDLED
}

// If users cancels call	
public cancel_call(id)
{
	remove_task(id+5)
	remove_task(g_company[id]+5)
	g_caller[id] = 0
	g_caller[g_phone[id]] = 0
	g_caller[g_company[id]] = 0
	g_phone[g_phone[id]] = 0
	g_phone[id] = 0
	client_print(id,print_chat,"[Phone Mod] You cancelled the call!^n")
	client_print(g_company[id],print_chat,"[Phone Mod] The player canceled the call!^n")
	emit_sound(id, CHAN_ITEM, "phone/ring.wav", 0.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(g_company[id], CHAN_ITEM, "phone/ring.wav", 0.0, ATTN_NORM, 0, PITCH_NORM)
	g_company[g_company[id]] = 0
	g_company[id] = 0
	set_task(0.2,"Phonemenu",id)
	return PLUGIN_HANDLED
}

// When retrieveing the status
public phone_status(id)
{
	new authid[32], query[256], timeleft, model[32], pnum[32], mode[32]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT pnum,ptime FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,pnum,31)
		timeleft = dbi_field(result,2)
		dbi_free_result(result)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	new cellphoneone = itemamount(id,CELLPHONE_ONE_ID,"money")
	new cellphonetwo = itemamount(id,CELLPHONE_TWO_ID,"money")
	if(cellphoneone > 0) format(model,31,"Nokia 6310")
	else if(cellphonetwo > 0) format(model,31,"Nokia 3310")
	if(itemamount(id,SUBSCRIPTION,"money") > 0) format(mode,31,"Subscription Card")
	else format(mode,31,"Prepaid")
	
	new body[256]
	new key = (1<<9)
	new len = format(body,sizeof(body),"Phone Status ^n^n")
	len += format(body[len],sizeof(body)-len,"Phone Model: %s^n",model)
	len += format(body[len],sizeof(body)-len,"Phone Number: %s^n",pnum)
	len += format(body[len],sizeof(body)-len,"Phone Mode: %s^n",mode)
	len += format(body[len],sizeof(body)-len,"Prepaid Loaded: $%i^n",timeleft)
	len += format(body[len],sizeof(body)-len,"Prepaid Minutes: %i min^n^n",(timeleft/2))
	add(body,sizeof(body),"0. Go Back^n")
	show_menu(id,key,body)
	return PLUGIN_HANDLED
}

public action_phone_status(id,key)
{
	if(key == 9) Phonemenu(id)
	else phone_status(id)
	return PLUGIN_HANDLED
}

		
// Used for calcualting the are how far the speech goes
public overhear(a,distance,Speech[],sound,dead,is_ad)
{
	new OriginA[3], OriginB[3]
	get_user_origin(a,OriginA)
	new players[32], num
	get_players(players,num,"ac")
	for(new b = 0; b < num;b++)
	{
		if(dead == 0 && is_user_alive(players[b]) == 0) continue
		if(a!=players[b])
		{
			get_user_origin(players[b],OriginB)
			if(distance == -1) {
				if(is_ad == 1) {
					if(g_adstatus[a] == 0) return PLUGIN_HANDLED
				}
				is_ad = 0
				client_print(players[b],print_chat,Speech)
				if(sound == 1) client_cmd(players[b],"speak ^"fvox/alert^"")
			}
			else
			{
				if(get_distance(OriginA,OriginB) <= distance) {
					client_print(players[b],print_chat,Speech)
					if(sound == 1) client_cmd(players[b],"speak ^"fvox/alert^"")
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public death_msg()
{
	new id = read_data(2)
	if(g_phone[id] > 0) hangup(id,0)
	if(g_company[id] > 0) cancel_call(id)
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if(g_phone[id] > 0) hangup(id,0)
	if(g_company[id] > 0) cancel_call(id)
	return PLUGIN_CONTINUE
}

public timer()
{
	new players[32], num, query[256]
	get_players(players,num,"ac")
	for(new i = 0; i < num;i++)
	{
		if(g_phone[players[i]] > 0)
		{
			g_timer[players[i]][0]++
			g_paytimer[players[i]]++
			if(g_paytimer[players[i]] >= 60)
			{
				new authid[32]
				get_user_authid(players[i],authid,31)
				g_paytimer[players[i]] = 0
				if(itemamount(players[i],SUBSCRIPTION,"money") > 0 && g_caller[players[i]] > 0)
				{
					edit_value(players[i],"money","balance","-",2)
					format(query,255,"SELECT balance FROM money WHERE steamid='%s'",authid)
					result = dbi_query(dbc,query)
					if(dbi_nextrow(result) > 0)
					{
						new balance
						balance = dbi_field(result,1)
						dbi_free_result(result)
						if(balance <= 0) { 
							hangup(players[i],1)
							client_print(players[i],print_chat,"[PhoneMod] Your out of money in your bank account^n")
						}
					}
					dbi_free_result(result)
				}
				else if(itemamount(players[i],SUBSCRIPTION,"money") <= 0 && g_caller[players[i]] > 0)
				{
					edit_value(players[i],"money","ptime","-",2)
					format(query,255,"SELECT ptime FROM money WHERE steamid='%s'",authid)
					result = dbi_query(dbc,query)
					if(dbi_nextrow(result) > 0)
					{
						new ptime
						ptime = dbi_field(result,1)
						dbi_free_result(result)
						if(ptime <= 0) {
							hangup(players[i],1)
							client_print(players[i],print_chat,"[PhoneMod] Your out of prepaid phone time^n")
						}
					}
					else dbi_free_result(result)
				}
			}
			if(g_timer[players[i]][0] >= 60)
			{
				g_timer[players[i]][0] = 0
				g_timer[players[i]][1]++
			}
		}
		else
		{
			g_timer[players[i]][0] = 0
			g_timer[players[i]][1] = 0
		}
	}
	return PLUGIN_HANDLED
}

// If user has phone model can't pickup guns
public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	new string[64]
	entity_get_string(id,EV_SZ_viewmodel,string,63)
	if(equali(string,"models/mecklenburg/phone/v_cell.mdl"))
	{
		new bufferstop = entity_get_int(id,EV_INT_button)
		if(bufferstop != 0) {
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_USE)
			entity_set_int(id,EV_INT_weaponanim,0)
		}
	}
	return PLUGIN_CONTINUE
}


// Intercom Messaging
public com_message(id,Speech[])
{
	new JobID, buffer[64], authid[32]
	get_user_authid(id,authid,31)
	select_string(id,"money","JobID","steamid",authid,buffer)
	if(equali(buffer,"")) return PLUGIN_HANDLED
	JobID = str_to_num(buffer)
	if((JobID >= MCPDSTART && JobID <= MCPDEND) || (JobID >= MCMDSTART && JobID <= MCMDEND))
	{
		new players[32], num, authid2[32], buffer2[64], JobID2
		get_players(players,num,"ac")
		for(new i = 0; i < num;i++)
		{
			get_user_authid(players[i],authid2,31)
			select_string(players[i],"money","JobID","steamid",authid2,buffer2)
			JobID2 = str_to_num(buffer2)
			if((JobID2 >= MCPDSTART && JobID2 <= MCPDEND) || (JobID2 >= MCMDSTART && JobID2 <= MCMDEND)) client_print(players[i],print_chat,Speech)
		}
	}
	else client_print(id,print_chat,"[TalkArea] Need to work for MCPD/MCMD to use Intercom^n")
	return PLUGIN_HANDLED
}

// SMS Messaging
public sms_message(id,Speech[],target)
{
	new tname[33], query[256], authid[32]
	get_user_authid(id,authid,31)
	get_user_name(target,tname,sizeof(tname))
	if(!is_user_alive(target)) {
		client_print(id,print_chat,"[TalkArea] %s is not alive^n",tname)
		return PLUGIN_HANDLED
	}
	if(itemamount(id,CELLPHONE_ONE_ID,"money") <= 0 && itemamount(id,CELLPHONE_TWO_ID,"money") <= 0) {
		client_print(id,print_chat,"[TalkArea] You need a cellphone to send SMS messages^n")
		return PLUGIN_HANDLED
	}
	if(itemamount(target,CELLPHONE_ONE_ID,"money") <= 0 && itemamount(target,CELLPHONE_TWO_ID,"money") <= 0) {
		client_print(id,print_chat,"[TalkArea] %s has not got a cellphone with him^n",tname)
		return PLUGIN_HANDLED
	}
	if(g_disable[target] == 1) {
		client_print(id,print_chat,"[TalkArea] User has disabled their phone^n")
		return PLUGIN_HANDLED
	}
	if(itemamount(id,SUBSCRIPTION,"money") > 0)
	{
		format(query,255,"SELECT balance FROM money WHERE steamid='%s'",authid)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new balance
			balance = dbi_field(result,1)
			dbi_free_result(result)
			if(balance <= 0)
			{
				format(query,255,"SELECT ptime FROM money WHERE steamid='%s'",authid)
				result = dbi_query(dbc,query)
				if(dbi_nextrow(result) > 0)
				{
					new ptime
					ptime = dbi_field(result,1)
					dbi_free_result(result)
					if(ptime <= 0)
					{
						client_print(id,print_chat,"[PhoneMod] You don't have enough money nor prepaid time in your bank account^n")
						return PLUGIN_HANDLED
					}
				}
				else dbi_free_result(result)
			}
		}
		else dbi_free_result(result)
	}
	else
	{
		format(query,255,"SELECT ptime FROM money WHERE steamid='%s'",authid)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new ptime
			ptime = dbi_field(result,1)
			dbi_free_result(result)
			if(ptime <= 0)
			{
				client_print(id,print_chat,"[PhoneMod] You don't have enough prepaid time^n")
				return PLUGIN_HANDLED
			}
		}
		else dbi_free_result(result)
	}
	if(itemamount(id,SUBSCRIPTION,"money") > 0) edit_value(id,"money","balance","-",1)
	else edit_value(id,"money","ptime","-",1)

	client_print(id,print_chat,Speech)
	client_print(target,print_chat,Speech)
	emit_sound(target, CHAN_ITEM, "phone/sms.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED
}

public set_weapon_kungfu(id)
{
	client_cmd(id,"weapon_0")
	entity_set_int(id,EV_INT_weaponanim,0)
	return PLUGIN_HANDLED
}

// Advertising
public advertising_off(id)
{
	g_adstatus[id] = 0
	client_print(id,print_chat,"[Talkarea] You have turned advertising off.^n")
	return PLUGIN_HANDLED
}

public advertising_on(id)
{
	g_adstatus[id] = 1
	client_print(id,print_chat,"[Talkarea] You have turned advertising on.^n")
	return PLUGIN_HANDLED
}

public client_connect(id) g_adstatus[id] = 1
	