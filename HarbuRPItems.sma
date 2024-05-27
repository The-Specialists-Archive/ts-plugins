//////////////////////////////////////
// HarbuRP Plugins Items ADD-On Pack
//////////////////////////////////////


#pragma dynamic 32768

#include <amxmodx>
#include <amxmisc>
#include <dbi>
#include <tsfun>
#include <tsxaddon>
#include <engine>
#include <fun>

/*	THE LIST OF THE VALUES THAT CAN BE CHANGED

	Everything under here can/must be changed according to your
	needs and settings

*/

#define MAXIUMSTR 1024		// Length that SQL results can be
#define MAXDOORS 32		// Maxium amount of doors that can be blowed up at the same time


#define ITEMS 800		// Maxium amount of items user can have
#define MCMDPACK 7		// ItemID for First Aid Kit
#define MCMDPACKTWO 19		// Operation Kit
#define SPRAYPACK 6		// ItemID for Spraycan
#define MONEYTREE 500		// ItemID for Money Tree
#define PIZZA 44		// ItemID for Pizza

#define PIZZAJOB 268		// JobID for a 'Pizza Boy' Job
#define FOOD_SLOWDOWN 160	// How much speed to slowdown while eating

#define MARIJUANA_SEED_ITEM 700


/*	LIST ENDS HERE
	
	Only edit below if you know what you are doing
*/

// Variables
new fire, rope
new lightning
new smoke
new tazerd[33][2]			// Which color is the player glowing?, Speed?
new alcohol[33][3]			// Has user passed out?, Current Procent?
new smokevar[33][5]			// Used for storing if cig in mouth and if countdown of cig time
new foodmouth[33]			// Does user have food in his mouth?
new Float:nullorigin[3] = {0.0,0.0,0.0}	// Origin to where exploded door is temporarely keepen
new Float:g_door_explode[MAXDOORS][3]		// Storing Doors old origins
new Sql:dbc
new Result:result
new gmsgFade
new DOOR_GIBS				// For keeping the door piece model
new istaped[33]				// Is the player taped?
new istapedtry[33]			// So people can't spam there tape.
new roped[33]
new dragged[33]; // is the user already being dragged?
new dragging[33]; // is the user already roping someone?
new usedcar[33]; // Has the person already used the Car Item?
new onsteroids[33] // is the user on steroids?
// Timer Variables
new minute = 0
new hour = 20
new day = 1
new month = 1
new year = 2005

// Smokey Grenade
new smokeorigin[33][3]; // Origin of the smoke grenade?
new smoketimeout[33]; // Is the user timed out with the smoke grenade?

// LightBulb Mod
new numArguments[33][7]; // stuff for lightbulb Settings
new lightOrigin[33][3]; // origin for light to be spawned
new resetbulbs; // reset lightbulbs?

// The Sprites for the smoke grenades-- set to precache on all other maps then mecklenburg.
//new smoke2 // the precached smoke grenade sprite.

new monthname[13][33] = {"","January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
new monthday[13] = {0,31,28,31,30,31,30,31,31,30,31,30,31}

new marijuana_watering_timeout[33];
//new planting_area1[3] = { 809, 2882, -350 } // Where you plant marijuana seeds and others at.(Mecklenburg)

// Plant Global Variables
new g_plantingintegers[33][5]
new g_plantstring[33][64]
new g_wateringitemid;
new g_harvestingitemid[33];

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

// Precaching necessary sprites
public plugin_precache()
{
	smoke = precache_model("sprites/steam1.spr")		// Smoke sprite for smoking ciggs
	DOOR_GIBS = precache_model( "models/woodgibs.mdl" )	// Woodgibs when you break a door
	fire = precache_model("sprites/explode1.spr")		// Explosion of a door or kamikaze bombs
	lightning = precache_model("sprites/lgtning.spr")	// Lightning effect from Tazer
	//rope = precache_model("sprites/rope.spr")		// Rope Sprite for rope item
	precache_sound("phone/2.wav")
	precache_sound("harburp/tazer.wav")
	precache_sound("harburp/heart.wav")
	//precache_sound( "weapons/sfire-inslow.wav" )
//	precache_sound("nihilanth/nil_thieves.wav") // Precaches death sound
    precache_sound("debris/bustglass2.wav")
    precache_sound("weapons/sfire-inslow.wav")
//    SpriteExorcise = precache_model("sprites/redflare1.spr") // Precaches exorcise
//    SpriteFire = precache_model("sprites/fire.spr") // Fire sprite
//    SpriteBolt = precache_model("sprites/xbeam1.spr") // Bolt Sprite
//    bloodfrag = precache_model("sprites/bloodfrag.spr")
//	smoke2 = precache_model("sprites/xsmoke2.spr")
	precache_sound("zombiemod/sg_explode.wav") // smoke grenade explode sound
}

public plugin_init()
{
	register_plugin("Harbu RP Items Addon","Alpha 0.2a","Harbu")

	register_srvcmd("item_atm","item_atm")
	register_srvcmd("item_food","item_food")
	register_srvcmd("item_cigs","item_cigs")
	register_srvcmd("item_lighter","item_lighter")
	register_srvcmd("item_aid","item_aid")
	register_srvcmd("item_spray","item_spray")
	register_srvcmd("item_cellphone","item_cellphone")
	register_srvcmd("item_prepaid","item_prepaid")
	register_srvcmd("item_flashbang","item_flashbang")
	register_srvcmd("item_phonebook","item_phonebook")
	register_srvcmd("item_invisibility","item_invisibility")
	register_srvcmd("item_picklock","item_picklock")
	register_srvcmd("item_doorexplode","item_doorexplode")
	register_srvcmd("item_kamikaze","item_kamikaze")
	register_srvcmd("item_tazer","item_tazer")
	register_srvcmd("item_csyringe","item_csyringe")
	register_srvcmd("item_spill","item_spill")
	register_srvcmd("item_searcher","item_searcher")
	register_srvcmd("item_alcohol","item_alcohol")
	register_srvcmd("item_rope","item_rope")
	register_srvcmd("item_watch","item_watch")
	register_srvcmd("item_drugs","item_drugs")
        register_srvcmd("item_armor","item_armor")
        register_srvcmd("item_steroids","item_steroids")
        register_srvcmd("item_selfaid","item_selfaid")
        register_srvcmd("item_teargas","item_teargas")
	register_srvcmd("item_ducktape", "item_ducktape")
	register_srvcmd("item_weapon", "item_weapon")
	register_srvcmd("item_smokegrenade", "item_smokegrenade")
	register_srvcmd("item_car", "item_car")
	register_srvcmd("item_ring", "item_ring")
	register_srvcmd("item_ram","item_ram")
	register_srvcmd("item_cuff","item_cuff")
	register_srvcmd("item_drag", "item_drag")
	register_srvcmd("item_lightbulb", "item_lightbulb")
	register_srvcmd("item_magazine", "item_magazine")
	register_srvcmd("item_plant", "item_plant")
	register_srvcmd("item_water", "item_water")
	register_srvcmd("item_harvest", "item_harvest")
	register_clcmd("amx_resetbulbs", "reset_bulbs", -1)
	// Spraycan
	register_impulse(201,"sprayimpulse")
	register_clcmd("say /tazer","item_tazer",ADMIN_ALL," - Shortcut for tazer item")
	register_event("DeathMsg","death_msg","a")
	register_event("ResetHUD","spawn_msg", "be")
	register_event("WStatus","client_dropweapon","be")

	// Register Cvars
	register_cvar("itemmod_mysql_host","127.0.0.1", FCVAR_PROTECTED)
	register_cvar("itemmod_mysql_user","root", FCVAR_PROTECTED)
	register_cvar("itemmod_mysql_pass","", FCVAR_PROTECTED)
	register_cvar("itemmod_mysql_db","economy", FCVAR_PROTECTED)

	register_cvar("rp_item_tazer","26")
	register_cvar("rp_item_ducktape", "2524")
	// CLCmds
	register_clcmd("say /removetape", "removetapeplayer", -1)
	register_clcmd("say /untape", "removetape", -1)
//	register_clcmd("say /tape", "tapeplayer", -1)
	set_task(Float:8.0,"sql_item")
	set_task(300.0,"moneytree",0,"",0,"b")
	set_task(1.0,"time_advance",0,"",0,"b")

	gmsgFade = get_user_msgid("ScreenFade")

	register_menucmd(register_menuid("Attachments:"),1023,"use_attachmenu")
	register_menucmd(register_menuid("Planting Menu:"),1023,"action_planting_menu")
	hour = random_num(1,23)
	month = random_num(1,12)
	day = random_num(1,monthday[month])
	year = random_num(2000,2010)
}
public reset_bulbs()
{
	resetbulbs = 1;
}
public shortcut_tazer(id)
{
	callfunc_begin ("item_use","HarbuRPAlpha.amxx")
	callfunc_push_int(id)
	callfunc_push_int(get_cvar_num("rp_item_tazer"))
	callfunc_end()
	return PLUGIN_HANDLED
}

// Connecting to MySQL Database
public sql_item()
{
	new host[64], username[32], password[32], dbname[32], error[32]
 	get_cvar_string("itemmod_mysql_host",host,64) 
    	get_cvar_string("itemmod_mysql_user",username,32) 
    	get_cvar_string("itemmod_mysql_pass",password,32) 
    	get_cvar_string("itemmod_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if(dbc == SQL_FAILED)
	{
		server_print("^n[HarbuRP Items] Could Not Connect To SQL Database")
	}
	else
	{
	server_print("^n[HarbuRP Items] Connected To SQL, Have A Nice Day!")
	}
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
	dbi_query(dbc,"%s",query)
	return PLUGIN_HANDLED
}

public select_string(table[],index[],condition[],equals[],output[],size)
{
	new query[256]
	format(query,255,"SELECT %s FROM %s WHERE %s='%s'",index,table,condition,equals)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0) dbi_field(result,1,output,size)
	dbi_free_result(result)
}

stock get_item_amount(id,itemid,table[],customid[]="")
{
	new authid[32], amount, query[256]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
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
				amount = str_to_num(output2[1]
				)
				dbi_free_result(result)
				return amount
			}
		}
	}
	dbi_free_result(result)
	return amount
}

// For Adding/Subtracting Items Quickly
stock set_item_amount(id,func[],itemid,amount,table[],customid[]="")
{
	new authid[32], query[256], itemfield[MAXIUMSTR]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
	new currentamount = get_item_amount(id,itemid,table,customid)
	format(query,255,"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,itemfield,MAXIUMSTR-1)
		dbi_free_result(result)

		if(equali(func,"-"))
		{
			new string[32]
			format(string,31," %i|%i",itemid,currentamount)
			if(containi(itemfield,string) != -1)
			{
				if((currentamount - amount) <= 0)
				{
					replace(itemfield,MAXIUMSTR-1,string,"")
				}
				else
				{
					new newstring[32]
					format(newstring,31," %i|%i",itemid,currentamount-amount)
					replace(itemfield,MAXIUMSTR-1,string,newstring)
				}
				format(query,255,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,query)
			}
			else
			{
				client_print(id,print_chat,"[ItemMod] Error #150 LOOP. Please contact an administrator^n")
				dbi_free_result(result)
				return PLUGIN_HANDLED
			}
		}
		if(equali(func,"+"))
		{
			if(get_item_amount(id,itemid,table,authid) == 0)
			{
				new str[32]
				format(str,31," %i|%i",itemid,(currentamount +amount))
				add(itemfield,sizeof(itemfield),str)
				format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,query)
			}
			else
			{
				if(currentamount > 0)
				{
					new newstr[32], oldstr[32]
					format(oldstr,31," %i|%i",itemid,currentamount)
					format(newstr,31," %i|%i",itemid,(currentamount +amount))
					replace(itemfield,255,oldstr,newstr)
					format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
					dbi_query(dbc,query)
				}
				else
				{
					client_print(id,print_chat,"[ItemMod] Error #200. Please contact an administrator^n")
					dbi_free_result(result)
					return PLUGIN_HANDLED
				}
			}
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}
////////////////////////////////////
//		ITEMS
///////////////////////////////////

// Checking if user uses spray button
public sprayimpulse(id)
{
	if(get_item_amount(id,SPRAYPACK,"money") == 0)
	{
		client_print(id,print_chat,"[ItemMod] You need a spraycan to spray!^n")
		return PLUGIN_HANDLED
	}

	else
	{
		set_item_amount(id,"-",SPRAYPACK,1,"money")
		return PLUGIN_CONTINUE
	}
	return PLUGIN_HANDLED
	
}

// Spraycan
public item_spray()
{
	new id,arg[32]
	read_argv(1,arg,31)
	id = str_to_num(arg)
	client_cmd(id,"impulse 201")
	return PLUGIN_HANDLED
}

// ATM Card
public item_atm(id)
{
	new str[32], targetid
	read_argv(1,str,31)
	targetid = str_to_num(str)
	client_print(targetid,print_chat,"[ItemMod] Can't be used through menu. Go to an ATM Machine and write /use^n")
	return PLUGIN_HANDLED
}

// All kinds of food/medikits etc.
public item_food()
{
	new arg[32], arg2[32], arg3[32], arg4[32], arg5[32], id, query[256], authid[32], Float:addhunger, currenthunger, addhuntemp, itemid
	read_argv(1,arg,31)	// PlayerID
	read_argv(2,arg2,31)	// Item Name
	read_argv(3,arg3,31)	// Amount to recover of hunger
	read_argv(4,arg4,31)	// ItemID
	read_argv(5,arg5,31)	// Eating or Drinking
	addhuntemp = str_to_num(arg3)
	addhunger = float(addhuntemp)
	itemid = str_to_num(arg4)
	id = str_to_num(arg)

	if(foodmouth[id] == 1)
	{
		set_item_amount(id,"+",itemid,1,"money")

		client_print(id,print_chat,"[ItemMod] You are already eating/drinking something^n")
		return PLUGIN_HANDLED
	}

	get_user_authid(id,authid,31)
	format(query,255,"SELECT hunger FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		currenthunger = dbi_field(result,1)
		dbi_free_result(result)
		if(currenthunger <= 10) {
			set_item_amount(id,"+",itemid,1,"money")
			client_print(id,print_chat,"[ItemMod] Your feel too full to eat, wait a while^n")
			return PLUGIN_HANDLED
		}
		if(currenthunger >= 60) addhunger *= 1.5
		if(currenthunger <= 30 && addhuntemp >= 40) addhunger *= 0.5

		new Float:speed = get_user_maxspeed(id)
		speed -= float(FOOD_SLOWDOWN)
		set_user_maxspeed(id,speed)
	
		foodmouth[id] = 1
		set_task(0.5,"food_heal",id,"",0,"a",floatround(addhunger))
		set_task((addhunger/2),"food_speed",id)

		client_print(id,print_chat,"[ItemMod] You start %sing one %s^n",arg5,arg2)
	} else {
	dbi_free_result(result)
	}
	return PLUGIN_HANDLED
}

public food_heal(id)
{
	edit_value(id,"money","hunger","-",1)
	return PLUGIN_HANDLED
}

public food_speed(id)
{
	new Float:speed = get_user_maxspeed(id)
	speed += float(FOOD_SLOWDOWN)
	set_user_maxspeed(id,speed)
	foodmouth[id] = 0
	return PLUGIN_HANDLED
}

// Used for medikit package - item_aid <id> "<targetname>" Heal_Amount Minium_HP ItemID
public item_aid()
{
	new arg[32], arg2[32], arg3[32], id, targetid, amount, name[33], name2[33], arg4[32], minium, query[256], arg5[32], itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	read_argv(4,arg4,31)
	read_argv(5,arg5,31)

	id = str_to_num(arg)
	targetid = str_to_num(arg2)
	amount = str_to_num(arg3)
	minium = str_to_num(arg4)
	itemid = str_to_num(arg5)

	get_user_name(id,name,sizeof(name))
	get_user_name(targetid,name2,sizeof(name2))

	new currenthealth = get_user_health(targetid)
	if(currenthealth >= 100)
	{
		client_print(id,print_chat,"[HealMod] The person you are looking at has already full health^n")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	if(currenthealth <= minium)
	{
		client_print(id,print_chat,"[HealMod] Too much damage! The person you are looking at need's a more advanced procedure^n")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	if((currenthealth+amount) > 100)
	{
		new val = (currenthealth+amount) - 100
		amount -=val
	}
	set_user_health(targetid,currenthealth+amount)
	client_print(targetid,print_chat,"[HealMod] Received %i HP From Player %s!.^n",amount,name)
	client_print(id,print_chat,"[HealMod] Gave %i HP To Player %s!.^n",amount,name2)
	client_cmd(id,"speak ^"items/smallmedkit1^"")
	client_cmd(targetid,"speak ^"items/smallmedkit1^"")
	return PLUGIN_HANDLED

}
// Planting stuff

// item_plant <id> <itemid ( the one in SQL that you get after its harvested) > <plantname> <health> <minimum minutes till it fully grows> <itemid ( Actual Item's ID)
public item_plant()
{
	new arg[32],arg2[32],plant_name[32],default_health[32],arg5[32],start_timer,health,id,itemid,actual_item_id,arg6[32]
	read_argv(1,arg,31) // id variable
	read_argv(2,arg2,31) // itemid variable
	read_argv(3,plant_name,31)
	read_argv(4,default_health,31) // health variable
	read_argv(5,arg5,31) //start_timer
	read_argv(6,arg6,31)
	actual_item_id = str_to_num(arg6)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	health = str_to_num(default_health)
	start_timer = str_to_num(arg5)
	show_planting_menu(id,itemid,health,start_timer,plant_name,actual_item_id)
	return PLUGIN_HANDLED;
}
public show_planting_menu(id,itemid,health,start_timer,plant_name[],actual_item_id)
{
	new origin[3]
	get_user_origin(id,origin)
	/*
	if(get_distance(origin,planting_area1) >= 1000)
	{
		client_print(id,print_chat,"[PLANTS] You must be by the apartment complex shed to plant stuff!")
		return PLUGIN_HANDLED;
	}
	*/
	g_plantingintegers[id][0] = id
	g_plantingintegers[id][1] = itemid
	g_plantingintegers[id][2] = health
	g_plantingintegers[id][3] = start_timer
	g_plantingintegers[id][4] = actual_item_id
	format(g_plantstring[id],63,plant_name)
	new menu[1024],key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	format(menu,sizeof(menu),"Planting Menu:^n^n ")
	add(menu,sizeof(menu),"1. Plant 1^n ")
	add(menu,sizeof(menu),"2. Plant 5^n ")
	add(menu,sizeof(menu),"3. Plant 10^n ")
	add(menu,sizeof(menu),"4. Plant 25^n ")
	add(menu,sizeof(menu),"5. Plant 50^n ")
	add(menu,sizeof(menu),"6. Plant 100^n ")
	add(menu,sizeof(menu),"7. Plant 250^n ")
	add(menu,sizeof(menu),"8. Plant 500^n ")
	add(menu,sizeof(menu),"9. Plant All^n ")
	add(menu,sizeof(menu),"^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public action_planting_menu(id,key)
{
	client_print(id,print_console, "action_planting_menu")
	new origin[3]
	get_user_origin(id,origin)
	new plant_amount;
	switch(key)
	{
		case 0:
		{
			plant_amount = 1
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			client_print(id,print_console,"get_distance check!")
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 1:
		{
			plant_amount = 5
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 2:
		{
			plant_amount = 10
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 3:
		{
			plant_amount = 25
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 4: 
		{
			plant_amount = 50
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 5: 
		{
			plant_amount = 100
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 6:
		{
			plant_amount = 250
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 7:
		{
			plant_amount = 500
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 8: 
		{
			plant_amount = get_item_amount(id,g_plantingintegers[id][4],"money")
			if(plant_amount > get_item_amount(id,g_plantingintegers[id][4],"money"))
			{
				client_print(id,print_chat,"[PLANTS] You do not have the specified amount of plant seeds!")
				return PLUGIN_HANDLED;
			}
			//if(get_distance(origin,planting_area1) <= 1000)
			//{
			plant_insert(id,g_plantstring[id],125,plant_amount*2+g_plantingintegers[id][3],g_plantingintegers[id][2],plant_amount,origin[0],origin[1],origin[2],g_plantingintegers[id][1],g_plantingintegers[id][4])
			set_item_amount(id,"-",g_plantingintegers[id][4],plant_amount,"money")
			client_print(id,print_chat,"[PLANTS] You have planted %i plants here.", plant_amount)
			//}
		}
		case 9: client_print(id,print_chat,"[PLANTS] Menu closed.")
	}
	return PLUGIN_HANDLED;
}
// item_water <id> <itemid>
public item_water()
{
	new arg[32],arg2[32],id,itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	g_wateringitemid = itemid;
	water_plant(id)
	return PLUGIN_HANDLED;
}
//item_harvest <id> <itemid>
public item_harvest()
{
	new arg[32],arg2[32],id,itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	g_harvestingitemid[id] = itemid;
	plant_harvest(id)
	return PLUGIN_HANDLED;
}
public water_plant(id)
{
	new query[512],authid[32],origin[3]
	get_user_authid(id,authid,31)
	get_user_origin(id,origin)
	format(query,sizeof(query),"SELECT * FROM planting WHERE authid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		client_print(id,print_chat,"[PLANTS] You have not planted any seeds yet!")
		dbi_free_result(result)
		return PLUGIN_HANDLED;
	}
	//otherwise, just search for the closest plant.
	new rows = dbi_num_rows(result)
	for(new i = 0; i < rows; i++)
	{
		new authidsql[32],plantname[32],allowdistance,val,health,amount,x,y,z
		dbi_field(result,1,authidsql,31)
		dbi_field(result,2,plantname,31)
		allowdistance = dbi_field(result,3)
		val = dbi_field(result,4)
		health = dbi_field(result,5)
		amount = dbi_field(result,6)
		x = dbi_field(result,7)
		y = dbi_field(result,8)
		z = dbi_field(result,9)
		new origin2[3]
		origin2[0] = x
		origin2[1] = y
		origin2[2] = z
		if(get_distance(origin,origin2) <= allowdistance)
		{
			if(equali(authidsql,authid))
			{
				if(val > 0)
				{
					if(marijuana_watering_timeout[id] == 1)
					{
						client_print(id,print_chat,"[PLANTS] You have recently watered your plant, try later.")
						set_item_amount(id,"+",g_wateringitemid,1,"money")
						return PLUGIN_HANDLED;
					}
					new hpmark
					hpmark = plant_get_health(id,authid,x,y,z)
					if(hpmark <= 0)
					{
						client_print(id,print_chat,"[PLANTS] You discover that your plants have died.")
						new quarry[256]
						format(quarry,sizeof(quarry),"DELETE FROM planting WHERE authid='%s' AND x=%i AND y=%i AND z=%i",authid,x,y,z)
						dbi_query(dbc,query)
						set_item_amount(id,"+",g_wateringitemid,1,"money")
						return PLUGIN_HANDLED;
					}
					new rndupgrade = random_num(1,6)
					hpmark += rndupgrade
					client_print(id,print_chat,"[PLANTS] Your plant had %i health, now it has %i health!",hpmark-rndupgrade,hpmark)
					client_cmd(id,"say /me waters his plant")
					marijuana_watering_timeout[id] = 1;
					set_task(60.0, "allow_watering",id)
					new query2[256]
					format(query2,sizeof(query2),"UPDATE planting SET health=health+%i WHERE authid='%s' AND x=%i AND y=%i AND z=%i",rndupgrade,authid,x,y,z)
					dbi_query(dbc,query2)
				}
			}
		}
		dbi_nextrow(result)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED;
}
public plant_harvest(id)
{
	// Harvest plants nearest to you.
	new query[512],authid[32],origin[3]
	get_user_authid(id,authid,31)
	get_user_origin(id,origin)
	format(query,sizeof(query),"SELECT * FROM planting WHERE authid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		client_print(id,print_chat,"[PLANTS] You have not planted any seeds yet!")
		dbi_free_result(result)
		return PLUGIN_HANDLED;
	}
	new rows = dbi_num_rows(result)
	//otherwise, just search for the closest marijuana.
	for(new i = 0; i < rows; i++)
	{
		new authidsql[32],plantname[32],allowdistance,val,health,amount,x,y,z,itemid,seedid
		dbi_field(result,1,authidsql,31)
		dbi_field(result,2,plantname,31)
		allowdistance = dbi_field(result,3)
		val = dbi_field(result,4)
		health = dbi_field(result,5)
		amount = dbi_field(result,6)
		x = dbi_field(result,7)
		y = dbi_field(result,8)
		z = dbi_field(result,9)
		itemid = dbi_field(result,10)
		seedid = dbi_field(result,11)
		new origin2[3]
		origin2[0] = x
		origin2[1] = y
		origin2[2] = z
		if(get_distance(origin,origin2) <= allowdistance)
		{
			if(equali(authidsql,authid))
			{
				if(health > 0)
				{
					if(val < 1)
					{
						set_item_amount(id,"+",itemid,amount,"money")
						client_print(id,print_chat,"[PLANTS] %i %s has been harvested into your inventory, %i seeds taken from the plants.", amount,plantname,amount / 4)
						client_cmd(id,"say /me harvests his plants.")
						set_item_amount(id,"+",seedid,amount / 4,"money")
						new query2[256]
						format(query2,sizeof(query2),"DELETE FROM planting WHERE authid='%s' AND x=%i AND y=%i AND z=%i",authid,x,y,z)
						set_item_amount(id,"-",g_harvestingitemid[id],1,"money")
						dbi_query(dbc,query2)
					}
				}
			}
		} else {
			client_print(id,print_chat,"[PLANTS] No plants are found here.",amount)
		}
		dbi_nextrow(result)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED;
}
public allow_watering(id)
{
	client_print(id,print_chat,"[PLANTS] You can now water your plant.")
	marijuana_watering_timeout[id] = 0;
	return PLUGIN_HANDLED;
}
// Cigarettes item_cigs <id> <itemid> <hploose> <smoketime> <"mari" for marihuana>
public item_cigs()
{
	new arg[32], arg2[32], arg3[32], arg4[32], arg5[32], id, itemid, minushp, smoketime
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	read_argv(4,arg4,31)
	read_argv(5,arg5,31)

	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	minushp = str_to_num(arg3)
	smoketime = str_to_num(arg4)

	if(smokevar[id][0] == 1 && smokevar[id][4] == 0) {
		set_item_amount(id,"+",itemid,1,"money")
		set_item_amount(id,"+",smokevar[id][1],1,"money")

		smokevar[id][0] = 0
		smokevar[id][1] = 0
		smokevar[id][2] = 0
		smokevar[id][3] = 0

		client_print(id,print_chat,"[ItemMod] You take the smoke out of your mouth^n")
		return PLUGIN_HANDLED
	}
	if(smokevar[id][0] == 1 && smokevar[id][4] == 1)
	{
		smokevar[id][0] = 0
		smokevar[id][1] = 0
		smokevar[id][2] = 0
		smokevar[id][3] = 0
		smokevar[id][4] = 0

		set_item_amount(id,"+",itemid,1,"money")

		client_print(id,print_chat,"[ItemMod] You throw the burning smoke on the ground^n")
		return PLUGIN_HANDLED
	}


	smokevar[id][0] = 1
	if( equal( arg5, "mari" ) ) smokevar[id][0] = 2
	smokevar[id][1] = itemid
	smokevar[id][2] = smoketime * 2
	smokevar[id][3] = minushp
	client_print(id,print_chat,"[ItemMod] You put a smoke in your mouth^n")
	return PLUGIN_HANDLED
}

// Lighter Code
public item_lighter()
{
	new arg[32], id, health, str_id[32]
	read_argv(1,arg,31)
	id = str_to_num(arg)
	health = get_user_health(id)

	num_to_str( id, str_id, 31 )
	
	if(smokevar[id][0] == 0) {
		client_print(id,print_chat,"[ItemMod] You have nothing to light up^n")
		return PLUGIN_HANDLED
	}

	if( smokevar[id][0] == 2 ) {
		set_task( 2.0, "color_effect", 0, str_id, 31, "a",  smokevar[id][2] / 4 )
		set_task( float( smokevar[id][2] / 2 ), "unblind", id )
	}
	smokevar[id][4] = 1
	set_task(0.5,"smoke_effect",id,"",0,"a",smokevar[id][2])
	set_user_health(id,(health - smokevar[id][3]))
	return PLUGIN_HANDLED
}
new ammo_stuff[33],weaponid_stuff[33];
// Usage: item_weapon <id> weaponid ammo flags ( set flags to 50 for freechoose )
public item_weapon()
{
	new arg[32], weaponid[32], ammo[32], flags[32], id
	read_argv(1,arg, 31)
	id = str_to_num(arg)
	read_argv(2,weaponid,31)
	read_argv(3,ammo,31)
	read_argv(4,flags,31)
	ammo_stuff[id] = str_to_num(ammo)
	weaponid_stuff[id] = str_to_num(weaponid)
	if(str_to_num(flags) >= 50)
	{
		build_attachmenu(id)
		return PLUGIN_HANDLED;
	}
	ts_giveweapon(id,str_to_num(weaponid),str_to_num(ammo),str_to_num(flags))
	return PLUGIN_HANDLED;
}
new chose_laser[33], chose_scope[33], chose_silencer[33], chose_flashlight[33];
public build_attachmenu(id)
{
	new menu[1024],key
	format(menu,sizeof(menu),"Attachments: ^n")
	if(chose_silencer[id] == 0)
	{
		add(menu,sizeof(menu),"^n 1. ATTACH Silencer")
		key += (1<<0)
	}
	if(chose_laser[id] == 0)
	{
		add(menu,sizeof(menu),"^n 2. ATTACH Lasersight")
		key += (1<<1)
	}
	if(chose_flashlight[id] == 0)
	{
		add(menu,sizeof(menu),"^n 3. ATTACH Flashlight")
		key += (1<<2)
	}
	if(chose_scope[id] == 0)
	{
		add(menu,sizeof(menu),"^n 4. ATTACH Scope")
		key += (1<<3)
	}
	key += (1<<4)
	add(menu,sizeof(menu),"^n 5. Finish")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public use_attachmenu(id,key)
{
	switch(key)
	{
		case 0:
		{
			chose_silencer[id] = 1
			build_attachmenu(id)
		}
		case 1:
		{
			chose_laser[id] = 2
			build_attachmenu(id)
		}
		case 2:
		{
			chose_flashlight[id] = 4
			build_attachmenu(id)
		}
		case 3:
		{
			chose_scope[id] = 8
			build_attachmenu(id)
		}
		case 4:
		{
			new sumstuff;
			sumstuff = chose_laser[id] + chose_silencer[id] + chose_flashlight[id] + chose_scope[id]
			ts_giveweapon(id,weaponid_stuff[id],ammo_stuff[id],sumstuff)
			weaponid_stuff[id] = 0;
			ammo_stuff[id] = 0;
			chose_laser[id] = 0;
			chose_silencer[id] = 0;
			chose_flashlight[id] = 0;
			chose_scope[id] = 0;
			client_print(id,print_chat,"[ITEMS] Weapon flags chosen and given.")
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}
// USAGE: item_smokegrenade <id> <itemid>
// SMOKEY GRENADE ITEM
public item_smokegrenade()
{
	new arg[32], arg2[32],itemid,id
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	// use the smoke grenade
	if(smoketimeout[id] == 1)
	{
		client_print(id,print_chat,"[SMOKE] You cannot throw another smoke until your last one is done.")
		return PLUGIN_HANDLED;
	}
	new origin[3], origineyes[3]
	get_user_origin(id,origin)
	get_user_origin(id,origineyes,3)
	if(get_distance(origin,origineyes) <= 2000.0)
	{
		client_print(id,print_chat,"[SMOKE] You have thrown a smoke grenade!")
		smokeorigin[id] = origineyes
		smoketimeout[id] = 1
		set_task(1.0, "moresmoke", id, "", 0, "a", 60)
		set_task(60.0, "timeoutstop", id)
		emit_sound(id, CHAN_ITEM, "zombiemod/sg_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		return PLUGIN_HANDLED;
	} else {
		set_item_amount(id,"+",itemid,1,"money")
		client_print(id,print_chat,"[SMOKE] You cannot throw that far!")
	}
	return PLUGIN_HANDLED;
}
// USAGE: item_magazine <id> filename header type
// EXAMPLE: item_magazine <id> newsday.txt "Newsday Paper July 1st" newspaper
public item_magazine()
{
	new arg[32],filename[32],header[32],name[32],id
	read_argv(1,arg,31)
	read_argv(2,filename,31)
	read_argv(3,header,31)
	read_argv(4,name,31)
	id = str_to_num(arg)
	// Use the magazine!
	show_motd(id,filename,header)
	client_print(id,print_chat,"[%s] You are reading a %s!",strtoupper(name),name);
	return PLUGIN_HANDLED;
}
public moresmoke(id)
{
//	#define   TE_SMOKE         5      // alphablend sprite, move vertically 30 pps 
// coord coord coord (position) 
// short (sprite index) 
// byte (scale in 0.1's) 
// byte (framerate)
//
	#define TE_BEAMDISK         20      // disk that expands to max radius over lifetime 
// coord coord coord (center position) 
// coord coord coord (axis and radius) 
// short (sprite index) 
// byte (starting frame) 
// byte (frame rate in 0.1's) 
// byte (life in 0.1's) 
// byte (line width in 0.1's) 
// byte (noise amplitude in 0.01's) 
// byte,byte,byte (color) 
// byte (brightness) 
// byte (scroll speed in 0.1's) 

// #define TE_BEAMCYLINDER 21
// coord coord coord (center position) 
// coord coord coord (axis and radius) 
// short (sprite index) 
// byte (starting frame) 
// byte (frame rate in 0.1's) 
// byte (life in 0.1's) 
// byte (line width in 0.1's) 
// byte (noise amplitude in 0.01's) 
// byte,byte,byte (color) 
// byte (brightness) 
// byte (scroll speed in 0.1's) 
//#define TE_BOX            31 
// coord, coord, coord      boxmins 
// coord, coord, coord      boxmaxs 
// short life in 0.1 s 
// 3 bytes r, g, b 
// #define   TE_BEAMENTS         8       
// short (start entity) 
// short (end entity) 
// short (sprite index) 
// byte (starting frame) 
// byte (frame rate in 0.1's) 
// byte (life in 0.1's) 
// byte (line width in 0.1's) 
// byte (noise amplitude in 0.01's) 
// byte,byte,byte (color) 
// byte (brightness) 
// byte (scroll speed in 0.1's) 
// #define TE_PARTICLEBURST   122      // very similar to lavasplash. 
// coord (origin) 
// short (radius) 
// byte (particle color) 
// byte (duration * 10) (will be randomized a bit) 
//#define TE_LARGEFUNNEL      100 
// coord coord coord (funnel position) 
// short (sprite index) 
// short (flags) 
// #define TE_SPRAY         120      // Throws a shower of sprites or models 
// coord, coord, coord (position) 
// coord, coord, coord (direction) 
// short (modelindex) 
// byte (count) 
// byte (speed) 
// byte (noise) 
// byte (rendermode) 
//#define TE_SPRITETRAIL      15      // line of moving glow sprites with gravity, fadeout, and collisions 
// coord, coord, coord (start) 
// coord, coord, coord (end) 
// short (sprite index) 
// byte (count) 
// byte (life in 0.1's) 
// byte (scale in 0.1's) 
// byte (velocity along vector in 10's) 
// byte (randomness of velocity in 10's) 

//#define TE_BEAMTORUS      19      // screen aligned beam ring, expands to max radius over lifetime 
// coord coord coord (center position) 
// coord coord coord (axis and radius) 
// short (sprite index) 
// byte (starting frame) 
// byte (frame rate in 0.1's) 
// byte (life in 0.1's) 
// byte (line width in 0.1's) 
// byte (noise amplitude in 0.01's) 
// byte,byte,byte (color) 
// byte (brightness) 
// byte (scroll speed in 0.1's) 

// #define TE_FIREFIELD         123      // makes a field of fire. 
// coord (origin) 
// short (radius) (fire is made in a square around origin. -radius, -radius to radius, radius) 
// short (modelindex) 
// byte (count) 
// byte (flags) 
// byte (duration (in seconds) * 10) (will be randomized a bit) 
// #define TE_FIZZ            105      // create alpha sprites inside of entity, float upwards 
// short (entity) 
// short (sprite index) 
// byte (density) 

#define   TE_SMOKE         5      // alphablend sprite, move vertically 30 pps 
// coord coord coord (position) 
// short (sprite index) 
// byte (scale in 0.1's) 
// byte (framerate) 
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5)
	write_coord(smokeorigin[id][0])
	write_coord(smokeorigin[id][1])
	write_coord(smokeorigin[id][2])
	write_short( smoke )
	write_byte( 400 ) // scale/size
	write_byte(5)
	message_end()// end the tempentity message, so that it doesnt crash server.
	return PLUGIN_HANDLED;
}
public timeoutstop(id)
{
	smoketimeout[id] = 0
	return PLUGIN_HANDLED;
}		
// END OF SMOKEY GRENADE ITEM
// Cell Phone
public item_cellphone()
{
	new arg[32], id
	read_argv(1,arg,31)
	id = str_to_num(arg)
	client_cmd(id,"say /phone")
	return PLUGIN_HANDLED
}

// Item Prepaid
public item_prepaid()
{
	new arg[32], arg2[32], id, amount
	read_argv(1,arg,31)
	read_argv(2,arg2,31)

	id = str_to_num(arg)
	amount = str_to_num(arg2)
	edit_value(id,"money","ptime","+",amount)
	client_print(id,print_chat,"[PhoneMod] You loaded up $50 of prepaid phone time^n")
	return PLUGIN_HANDLED
}

// Item flashbang
public item_flashbang()
{
	new arg[32], origin[3], id
	read_argv(1,arg,31)
	id = str_to_num(arg)
	get_user_origin(id,origin)
	new players[32], num
	get_players(players,num,"ac")
	for(new i = 0; i < num;i++)
	{
		new p_origin[3]
		get_user_origin(players[i],p_origin)

		if(get_distance(origin,p_origin) <= 300.0)
		{
			message_begin(MSG_ONE,gmsgFade,{0,0,0},players[i]) 
			write_short( 1<<15 ) 
			write_short( 1<<12 )
			write_short( 1<<12 )
			write_byte( 255 ) 
			write_byte( 255 ) 
			write_byte( 255 ) 
			write_byte( 255 ) 
			message_end()
		}
	}
	emit_sound(id,CHAN_BODY, "weapons/sfire-inslow.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
	return PLUGIN_HANDLED
}

// Phonebook
public item_phonebook()
{
	new arg[32], id, phonebook[1024], players[32], num
	read_argv(1,arg,31)
	id = str_to_num(arg)

	new len = format(phonebook,sizeof(phonebook),"Phonebook listing of all players on server:^n^n^n")

	get_players(players,num,"c")
	for(new i = 0 ;i < num ;++i)
	{
		new szPhonenumber[32], name[32], authid[32]
		get_user_authid(players[i],authid,31)
		get_user_name(players[i],name,31)
		select_string("money","pnum","steamid",authid,szPhonenumber,31)
		if(!equali(szPhonenumber,"")) len += format(phonebook[len],sizeof(phonebook)-len,"%s: %s^n",name,szPhonenumber)
	}
	show_motd(id,phonebook,"Mecklenburg Phonebook")
	return PLUGIN_HANDLED
}

// Invisibility item item_invisibility <id> <transparent> <time>
public item_invisibility()
{
	new arg[32], arg2[32], arg3[32], id, arg4[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	read_argv(4,arg4,31)
	
	id = str_to_num(arg)

	if(task_exists(id)) {
		set_item_amount(id,"+",str_to_num(arg4),1,"money")
		client_print(id,print_chat,"[ItemMod] You are already using a invisibility device")
		return PLUGIN_HANDLED
	}

	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,str_to_num(arg2))
	set_task(float(str_to_num(arg3)),"normal_glow",id)
	client_print(id,print_chat,"[ItemMod] Invisibility Device activated!")
	return PLUGIN_HANDLED
}
// Usage: item_car <id> <name> - spawns car on player based by name.
public item_car()
{
	new arg[33], name[33], speed[33],item[33]
	read_argv(1, arg, 32)
	read_argv(2, name, 32)
	read_argv(3, speed, 32)
	read_argv(4, item, 32)
	new origin[3]
	new id = str_to_num(arg)
	new itemid = str_to_num(item)
	if(usedcar[id] & itemid)
	{
		client_print(id,print_chat,"[CarMod] You already have a car parked somewhere!")
		return PLUGIN_HANDLED;
	}
	get_user_origin(id,origin)
	new message[64]
	format(message, 63, "amx_makecar %s %i %i %i %i 0", name, origin[0], origin[1], origin[2], str_to_num(speed))
	callfunc_begin ("edit_speed","carmod.amxx")
	callfunc_push_int(id)
	callfunc_push_int(str_to_num(speed))
	callfunc_end()
	usedcar[id] += itemid;
	server_cmd(message)
	client_print(id,print_chat,"[CarMod] You take out your car!")
	return PLUGIN_HANDLED;
}
// Usage: item_ring <id>
public item_ring()
{
	new arg[33]
	read_argv(1,arg,32)
	new id = str_to_num(arg)
	client_cmd(id,"say /me uses diamond ring")
	set_task(0.5,"ring_shine_stuff",id)
	return PLUGIN_HANDLED;
}
public ring_shine_stuff(id)
{
	new origin[3]
	get_user_origin(id,origin)
	ring_shine(origin)
	return PLUGIN_HANDLED;
}
public ring_shine(origin[])
{
//	#define TE_DLIGHT         27      // dynamic light, effect world, minor entity effect 
// coord, coord, coord (pos) 
// byte (radius in 10's) 
// byte byte byte (color) 
// byte (brightness) 
// byte (life in 10's) 
// byte (decay rate in 10's) 

	// TEMPENTITY SHIT
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(27) // TE_DLIGHT( Dynamic Light)
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(100) // radius in 10's
	write_byte(100) // red
	write_byte(100) // green
	write_byte(100) // blue
	write_byte(10) //brightness
	write_byte(100) // life in 10's
	write_byte(20) // decay rate in 10's
	message_end()
	return PLUGIN_HANDLED;
}
// item_lightbulb <id> <r> <g> <b> <brightness> <radius> <decay rate>
public item_lightbulb()
{

	new strArguments[7][32];
	
	read_argv(1,strArguments[0],31); // id
	read_argv(2,strArguments[1],31); // r
	read_argv(3,strArguments[2],31); // g
	read_argv(4,strArguments[3],31); // b
	read_argv(5,strArguments[4],31); // brightness
	read_argv(6,strArguments[5],31); // radius
	read_argv(7,strArguments[6],31); // decay rate
	
	new id = str_to_num(strArguments[0]);
	
	numArguments[id][0] = str_to_num(strArguments[0]);
	numArguments[id][1] = str_to_num(strArguments[1]);
	numArguments[id][2] = str_to_num(strArguments[2]);
	numArguments[id][3] = str_to_num(strArguments[3]);
	numArguments[id][4] = str_to_num(strArguments[4]);
	numArguments[id][5] = str_to_num(strArguments[5]);
	numArguments[id][6] = str_to_num(strArguments[6]);
	
	if( !(is_user_connected(id) && is_user_alive(id)) ) return PLUGIN_HANDLED;

	get_user_origin(id,lightOrigin[id]);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,lightOrigin[id]) 
	write_byte(27);
	write_coord(lightOrigin[id][0]);
	write_coord(lightOrigin[id][1]); 
	write_coord(lightOrigin[id][2]); 
	write_byte(numArguments[id][5]);
	write_byte(numArguments[id][1]);
	write_byte(numArguments[id][2]);
	write_byte(numArguments[id][3]);
	write_byte(numArguments[id][4]);
	write_byte(numArguments[id][6]);
	//write_byte(1);
	message_end();
	set_task(2.0, "lightbulb_update", id+1337, "", 0, "b")
	return PLUGIN_HANDLED;

}
public lightbulb_update(id)
{
	id -= 1337
	if(!is_user_connected(id))
	{
		remove_task(id+1337)
	}
	if(resetbulbs == 1)
	{
		remove_task(id+1337)
		resetbulbs = 0;
	}
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,lightOrigin[id]) 
	write_byte(27);
	write_coord(lightOrigin[id][0]);
	write_coord(lightOrigin[id][1]); 
	write_coord(lightOrigin[id][2]); 
	write_byte(numArguments[id][5]);
	write_byte(numArguments[id][1]);
	write_byte(numArguments[id][2]);
	write_byte(numArguments[id][3]);
	write_byte(numArguments[id][4]);
	write_byte(numArguments[id][6]);
	message_end();
	return PLUGIN_HANDLED;
}
// Picklocking Doors
public item_picklock()
{
	new arg[32], arg2[32], id, entid, entbody, classname[32], origin[3], name[33]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)
	get_user_name(id,name,sizeof(name))
	get_user_aiming(id,entid,entbody,200)
	if(!is_valid_ent(entid)) {
		client_print(id,print_chat,"[DoorMod] You must be facing a door!^n")
		return PLUGIN_HANDLED
	}
	entity_get_string(entid,EV_SZ_classname,classname,31)
	if(equali(classname,"func_door") || equali(classname,"func_door_toggle"))
	{
		client_print(id,print_chat,"[DoorMod] You can only picklock normal rotating doors^n")
		return PLUGIN_HANDLED
	}
	if(!equali(classname,"func_door_rotating")) {
		client_print(id,print_chat,"[DoorMod] You must be facing a door!^n")
		return PLUGIN_HANDLED
	}
	if(task_exists(id+32)) {
		client_print(id,print_chat,"[DoorMod] You are already picking a lock^n")
		return PLUGIN_HANDLED
	}
	if(random_num(0,80) == 40) {
		set_item_amount(id,"-",str_to_num(arg2),1,"money")
		client_print(id,print_chat,"[DoorMod] The picklock snapped in half^n")
	}

	new players[32], num
	get_user_origin(id,origin)
	get_players(players,num,"ac")
	for(new i=0;i<num;i++)
	{
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= get_cvar_num("rp_msgdistance"))
		{
			client_print(players[i],print_chat,"* [DoorMod] %s is picklocking the door..^n",name)
		}
	}
	set_task(5.0,"picklock_action",id+32)
	return PLUGIN_HANDLED
}

// Exploding Doors
public item_doorexplode()
{
	new arg[32], arg2[32], id, entid, entbody, classname[32], origin[3], Float:dmg, Float:takedmg, Float:check_origin[3]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)


	get_user_origin(id,origin)
	get_user_aiming(id,entid,entbody,200)
	if(!is_valid_ent(entid)) {
		client_print(id,print_chat,"[DoorMod] You must be facing a door!^n")
		return PLUGIN_HANDLED
	}


	entity_get_string(entid,EV_SZ_classname,classname,31)
	if(!equali(classname,"func_door") && !equali(classname,"func_door_rotating") && !equali(classname,"func_door_toggle"))
	{
		set_item_amount(id,"+",str_to_num(arg2),1,"money")
		client_print(id,print_chat,"[DoorMod] You must be facing a door!^n")
		return PLUGIN_HANDLED
	}


	dmg = entity_get_float(entid,EV_FL_dmg)
	takedmg = entity_get_float(entid,EV_FL_takedamage)
	entity_get_vector(entid,EV_VEC_origin,check_origin)
	if(takedmg == 0.0 && dmg == 0.0) {
		entity_set_float(entid,EV_FL_dmg,1.0)
		entity_set_float(entid,EV_FL_takedamage,1.0)
	}
	if(check_origin[0] == 0.0 && check_origin[1] == 0.0 && check_origin[2] == 0.0) {
		check_origin[0] = float(origin[0])
		check_origin[1] = float(origin[1])
		check_origin[2] = float(origin[2])
		entity_set_vector(entid,EV_VEC_origin,check_origin)
	}


	new players[32], num
	get_players(players,num,"ac")
	for(new i=0;i<num;i++)
	{
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= (get_cvar_num("rp_msgdistance")*2))
		{
			client_print(players[i],print_chat," ** [DoorMod] EVERYONE CLEAR OUT THIS DOOR WILL BE BLOWN UP! **^n")
		}
	}
	set_task(1.0,"time_explode",entid+29,"3",5)
	return PLUGIN_HANDLED
}


// KamiKaze Bomb item_kamikaze <id>
public item_kamikaze()
{
	new arg[32], id, name[32]
	read_argv(1,arg,31)
	id = str_to_num(arg)
	get_user_name(id,name,31)
	client_print(0,print_chat," ** [ItemMod] WARNING: Watchout for player %s he has a kamikaze bomb armed! **",name)
	set_task(1.0,"kamikaze_timer",id+55,"3",5)
	set_task(4.0,"kamikaze_blow",id+54)
	return PLUGIN_HANDLED
}

// item_tazer <id> <targetid>
public item_tazer()
{
	new arg[32], arg2[32], id, origin[3], origin2[3], targetid, entbody, itemid
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)

	get_user_aiming(id,targetid,entbody,400)
	if(!is_user_connected(targetid))
	{
		client_print(id,print_chat,"[ItemMod] You must be looking at another player^n")
		return PLUGIN_HANDLED
	}
	if(!is_user_alive(targetid)) return PLUGIN_HANDLED

	if(random_num(1,100) == 100) {
		client_print(id,print_chat,"[ItemMod] Your tazer had a short-circuit!^n")
		set_item_amount(id,"-",itemid,get_cvar_num("rp_item_tazer"),"money")
		kamikaze_blow(id)
		return PLUGIN_HANDLED
	}
	if(task_exists(id+128)) {
		client_print(id,print_chat,"[ItemMod] Your tazer is currently recharging^n")
		return PLUGIN_HANDLED
	}
	if(task_exists(targetid+96)) {
		client_print(id,print_chat,"[ItemMod] Targetted person is already being tazered!^n")
		return PLUGIN_HANDLED
	}

	get_user_origin(id,origin)
	get_user_origin(targetid,origin2)
	basic_lightning(origin,origin2,10)
	basic_shake(targetid,8,12)

	emit_sound(id, CHAN_ITEM, "harburp/tazer.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	if(get_user_health(targetid) <= 5)
	{
		user_silentkill(targetid)
		make_deathmsg (id,targetid,0,"Tazer")
	}
	else set_user_health(targetid,get_user_health(targetid)-5)
	

	for(new i=1;i<=35;i++)
	{
		client_cmd(targetid,"weapon_%d; drop",i)
	}

	set_task(0.5,"slowdown",targetid)

	new buf[5]
	num_to_str(targetid,buf,4)
	set_task(0.5,"glow_flash",targetid,buf,4,"a",19)
	set_task(5.0,"darken_effect",targetid+64)

	set_task(10.0,"remove_tazer_effect",targetid+96)
	set_task(30.0,"recharge_func",id+128)
	return PLUGIN_HANDLED
}

public slowdown(id)
{
	set_user_maxspeed(id,get_user_maxspeed(id)-319)
	return PLUGIN_HANDLED
}

// Cyanide Syringe - item_csyringe <id> <targetid> - by Promethus
// Cyanide Syringe - item_csyringe <id> <targetid> - by Promethus
public item_csyringe()
{
	new id,targetid,itemid,arg[31],arg2[32],arg3[32],blah1,blah2

	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)

	id = str_to_num(arg)
	targetid = str_to_num(arg2)
	itemid = str_to_num(arg3)

	if(get_user_aiming(id,blah1,blah2,50)) {
		make_deathmsg(id,targetid,0,"Cyanide Syringe")
		user_silentkill(targetid)

		new Frags = get_user_frags(id)

		client_print(id,print_chat,"[ItemMod] Frag count: %d^n",Frags)

		set_user_frags(id,get_user_frags(id)+1)

		Frags = get_user_frags(id)

		client_print(id,print_chat,"[ItemMod] New Frag count: %d^n",Frags)

		client_print(id,print_chat,"[ItemMod] You used a Cyanide Syringe^n")
		return PLUGIN_HANDLED
	} else {
		client_print(id,print_chat,"[ItemMod] You need to be close to and looking at a player^n")
		set_item_amount(id,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED 
}
public item_ducktape() // ducktape item
{
	new id,targetid,itemid,arg[31],arg2[32],arg3[32],blah1,blah2

	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	id = str_to_num(arg)
	targetid = str_to_num(arg2)
	itemid = str_to_num(arg3)
	new tname[33]
	new idname[33]
	get_user_name(id, idname, 32)
	get_user_name(targetid, tname, 32)
	if(get_user_aiming(id,blah1, blah2,80)) {
		
		if(istapedtry[targetid] == 3)
		{
			istapedtry[targetid] = 0
			client_print(id,print_chat, "[TAPE] %s is now taped!", tname)
			client_print(targetid, print_chat, "[TAPE] %s has taped you!", idname)
			istaped[targetid] = 1
			return PLUGIN_HANDLED;
		}
		istapedtry[targetid]++
		client_print(id, print_chat, "[TAPE] You are taping %s! Keep using tape on him!", tname)
		client_print(targetid, print_chat, "[TAPE] You are being taped by %s!", idname)
		if(istapedtry[targetid] == 3)
		{
			istapedtry[targetid] = 0
			client_print(id,print_chat, "[TAPE] %s is now taped!", tname)
			client_print(targetid, print_chat, "[TAPE] %s has taped you!", idname)
			istaped[targetid] = 1
		}
		return PLUGIN_HANDLED
	} else {
		client_print(id,print_chat,"[TAPE] You must be close to the player and looking at him to tape him!^n")
		set_item_amount(id, "+", itemid,1, "money")
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public tapeplayer(id)
{
	callfunc_begin ("item_use","HarbuRPAlpha.amxx")
	callfunc_push_int(id)
	callfunc_push_int(get_cvar_num("rp_item_ducktape"))
	callfunc_end()
	return PLUGIN_HANDLED
}
public removetapeplayer(id) // have the player himself remove the ducktape
{
	if(istaped[id] == 1)
	{
		client_print(id,print_chat, "[TAPE] You cannot remove the tape yourself! Someone else must untape you!")
		return PLUGIN_HANDLED;
	}
	istapedtry[id] = 0
	client_print(id, print_chat, "[TAPE] You removed the tape off of you!")
	return PLUGIN_HANDLED;
}
public removetape(id)
{
	new target,blah2
	if(get_user_aiming(id, target, blah2, 80))
	{
		new tname[33], name[33]
		get_user_name(target, tname, 32) // targets name
		get_user_name(id, name, 32)
		if(istaped[target] == 0)
		{
			client_print(id,print_chat, "[TAPE] %s is not taped!", tname)
			return PLUGIN_HANDLED;
		}
		// else
		istaped[target] = 0
		istapedtry[target] = 0
		client_print(target, print_chat, "[TAPE] %s has un-taped you!", name)
		client_print(id, print_chat, "[TAPE] You have un-taped %s!", tname)
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
// Suicide Pill - item_spill <id> - by Promethus
public item_spill()
{
	new arg[32],id
	read_argv(1,arg,31)

	id = str_to_num(arg)

	new will_kill = random_num(1,4)

	if(will_kill == 4) {
		client_print(id,print_chat,"[ItemMod] The suicide pill failed and did 25 damage")
		set_user_health(id,get_user_health(id)-25)
	} else {
		user_kill(id)
	}

	item_spill_kill(id)

	return PLUGIN_HANDLED
}

public item_spill_kill(id_arg)
{

	client_cmd(id_arg,"say /me takes a suicide pill")

	return PLUGIN_HANDLED
}

// Searcher Item - item_searcher <id> <targetid> <itemid> - By Ben Prometheus
public item_searcher()
{
	new id,targetid,itemid,arg[31],arg2[32],arg3[32],target_name[64]

	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)

	id = str_to_num(arg)
	targetid = str_to_num(arg2)
	itemid = str_to_num(arg3)

	get_user_name(targetid,target_name,63)

	set_item_amount(id,"+",itemid,1,"money")

	client_cmd(id,"say /me searches %s",target_name)

	new info[512],info_header[128]

	format(info_header,127,"Info for player ^"%s^"",target_name)

	show_motd(id,info,info_header)

	return PLUGIN_HANDLED 
}

// Alchohol - item_alcohol <id>
public item_alcohol()
{
	new arg[32], arg2[32], arg4[32], arg5[32], itemname[32], id, itemid, drunk, origin[3]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,itemname,31)
	read_argv(4,arg4,31)
	read_argv(5,arg5,31)
	id = str_to_num(arg)
	itemid = str_to_num(arg2)
	drunk = str_to_num(arg5)

	new Float:task_time = float(str_to_num(arg4))
	if(alcohol[id][0] == 1) {
		set_item_amount(id,"+",itemid,1,"money")
		client_print(id,print_chat,"[Alcohol Mod] Can't drink while passed out!^n")
		return PLUGIN_HANDLED
	}

	alcohol[id][1] += drunk

	if(alcohol[id][1] > 10) {
		alcohol[id][0] = 1
		client_print(id,print_center," * You Pass out! * ^n")
		remove_task(id+224)
		remove_task(id+256)
		remove_task(id+288)
		set_user_maxspeed(id,get_user_maxspeed(id)-319)
		alcohol_dark_passout(arg)

		message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
		write_short(1<<0)
		write_short(1<<0) 
		write_short(1<<2) 
		write_byte(0) 
		write_byte(0)  
		write_byte(0)   
		write_byte(220)   
		message_end()
		client_cmd(id,"+duck")
		set_task(4.0,"alcohol_dark_passout",id+160,arg,31,"a",30)
		set_task(60.0,"alcohol_remove_passout",id+192,arg,31)
		return PLUGIN_HANDLED
	}
	set_user_rendering(id,kRenderFxGlowShell,255,128,255,kRenderNormal,16)	
	new repeat = 60 / floatround(task_time)
	set_task(task_time,"alcohol_move",id+224,arg,31,"a",repeat)
	if(random_num(1,2) == 2) set_task(20.0,"alcohol_shake",id+256,arg,31,"a",2)
	else set_task(25.0,"alcohol_spin",id+288,arg,31,"a",2)
	for(new i = 0; i <= drunk; i++) {
		set_task(60.0,"alcohol_die",id,arg,31)
	}
	client_print(id,print_chat,"[Alcohol Mod] You enjoy some %s^n",itemname)

	get_user_origin(id,origin)

	new players[32], num, name[32]
	get_players(players,num,"ac")
	get_user_name(id,name,31)

	for(new i=0;i<num;i++)
	{
		if(players[i] == id) continue
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= (get_cvar_num("rp_msgdistance")))
		{
			client_print(players[i],print_chat,"[Alcohol Mod] %s enjoys some %s^n",name,itemname)
		}
	}
	return PLUGIN_HANDLED
}

// Item Rope - item_rope <id> <targetid> <itemid>
public item_rope()
{
	new arg[32], arg2[32], arg3[32], id, targetid, itemid

	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)

	id = str_to_num(arg)
	targetid = str_to_num(arg2)
	itemid = str_to_num(arg3)

	if(roped[targetid] > 0) {
		client_print(id,print_chat,"[ItemMod] This player has already been roped by someone else!")
		set_item_amount(targetid,"+",itemid,1,"money")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
// Item Ram - item_ram <id> <itemname> <dist> <rotating doors only>
public item_ram()
{
	new arg[32], arg2[32], arg3[32], arg4[32], id, flag, dist
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	read_argv(4,arg4,31)
	id = str_to_num(arg)
	dist = str_to_num(arg3)
	flag = str_to_num(arg4)

	new ent, body;
	get_user_aiming(id,ent,body,dist);

	if(!is_valid_ent(ent)) {
		client_print(id,print_chat,"[ItemMod] You must be looking at a door to use this!^n");
		return PLUGIN_HANDLED;
	}

	new classname[32];
	entity_get_string(ent,EV_SZ_classname,classname,31);

	if(!equali(classname,"func_door_rotating") && !equali(classname,"func_door")) {
		client_print(id,print_chat,"[ItemMod] You must be looking at a door to use this!^n");
		return PLUGIN_HANDLED;
	}

	if(get_entity_distance(id,ent) > dist) {
		client_print(id,print_chat,"[ItemMod] You are too far away from the door to use this!^n",arg2);
		return PLUGIN_HANDLED;
	}

	if(flag && equali(classname,"func_door")) {
		client_print(id,print_chat,"[ItemMod] This door cannot be opened with a %s!^n",arg2);
		return PLUGIN_HANDLED;
	}

	//client_print(id,print_chat,"[ItemMod] Your %s busts open the door!^n",arg2);

	client_cmd(id,"say ^"/me launches his %s into the door, causing it to bust open!^"",arg2);
	force_use(id,ent);
	fake_touch(ent,id);
	
	return PLUGIN_HANDLED
}
// Usage: item_batram <id>
public item_batram()
{
	new arg[32],id
	read_argv(1,arg,31)
	id = str_to_num(arg)
	new entid,hitbox;
	get_user_aiming(id,entid,hitbox,9999);
	if(!is_valid_ent(entid))
	{
		client_print(id,print_chat,"[ItemMod] You must be looking at a door to use this!^n");
		return PLUGIN_HANDLED;
	}
	new classname[32]
	entity_get_string(entid,EV_SZ_classname,classname,31);
	if(equali(classname,"func_door_rotating"))
	{
		force_use(id,entid)
		fake_touch(entid,id)
		client_cmd(id,"say ^"/me launches his battering ram into the door, causing it to bust open!^"");
	} else {
		client_print(id,print_chat,"[ItemMod] You can only use the battering ram on rotating doors.")
	}
	return PLUGIN_HANDLED;
}
// Item Handcuffs - item_cuff <id>
public item_cuff()
{
	new arg[32]
	read_argv(1,arg,31)
	callfunc_begin("cuff","HarbuRPAlpha.amxx")
	callfunc_push_int(str_to_num(arg))
	callfunc_push_int(1)
	callfunc_end()
	return PLUGIN_HANDLED
}
// Item drag - item_drag <id> // drag someone with a rope
public item_drag()
{
	new arg[32]
	read_argv(1,arg,31)
	new id = str_to_num(arg)
	new tid,body,Float:distance
	distance = get_user_aiming(id,tid,body,9999)
	if(tid < 1 && tid > get_maxplayers())
	{
		client_print(id,print_chat,"[ROPE] Invalid player.")
		return PLUGIN_HANDLED;
	}
	new o1[3], o2[3],name[32],tname[32]
	get_user_origin(id,o1)
	get_user_origin(tid,o2)
	get_user_name(id,name,31)
	get_user_name(tid,tname,31)
	if(dragged[tid] >= 1)
	{
		remove_task(id+126)
		remove_task(id+127)
		dragged[tid] = 0
		client_print(id,print_chat,"[ROPE] You are no longer roping %s.", tname)
		client_print(tid,print_chat,"[ROPE] You are no longer being roped by %s.", name)
		return PLUGIN_HANDLED;
	}
	if(dragging[id] == 1)
	{
		client_print(id,print_chat,"[ROPE] You are already roping someone!")
		return PLUGIN_HANDLED;
	}
	if(get_distance(o1,o2) >= 200.0)
	{
		client_print(id,print_chat,"[ROPE] Target is too far away... ")
		return PLUGIN_HANDLED;
	}
	dragging[id] = 1
	client_print(id,print_chat,"[ROPE] You are roping %s!", tname)
	client_print(tid,print_chat,"[ROPE] You are being roped by %s!", name)
	// Else, connect rope sprites, etc.
	set_task(0.5, "rope_string", id+126,"",0,"b") // rope_string, yep.
	set_task(0.1, "rope_teleport", id+127,"",0,"b") // roping teleport.
	return PLUGIN_HANDLED;
}
public rope_teleport(id,tid)
{
	new origin[3],torigin[3],top_origin[3]
	get_user_origin(id,origin)
	get_user_origin(tid,torigin)
	top_origin = origin
	top_origin[2] += 80
	set_user_origin(tid,top_origin)
	return PLUGIN_HANDLED;
}
public rope_string(id,tid)
{
	id -= 126
	new origin[3],torigin[3]
	get_user_origin(id,origin)
	get_user_origin(tid,torigin)
	// MESSAGE_BEGIN
// coord coord coord (start position) 
// coord coord coord (end position) 
// short (sprite index) 
// byte (starting frame) 
// byte (frame rate in 0.1's) 
// byte (life in 0.1's) 
// byte (line width in 0.1's) 
// byte (noise amplitude in 0.01's) 
// byte,byte,byte (color) 
// byte (brightness) 
// byte (scroll speed in 0.1's) 
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(0) // TE_BEAMPOINTS
	for(new i = 0; i < 3; i++)
	{
		write_coord(origin[i])
	}
	for(new i = 0; i < 3; i++)
	{
		write_coord(torigin[i])
	}
	write_short(rope) // rope sprite
	write_byte(1) // starting frame
	write_byte(5) // frame rate
	write_byte(10) // life
	write_byte(10) // rope width(sprite width)
	write_byte(30) // noise
	write_byte(100) // red
	write_byte(100) // green
	write_byte(100) // blue
	write_byte(200) // brightness
	write_byte(100) // scroll speed??
	message_end()
	return PLUGIN_HANDLED;
}
// Item Watch - item_watch <id> <flag>
public item_watch()
{
	new arg[32], arg2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	new id = str_to_num(arg)
	new flag = str_to_num(arg2)

	set_hudmessage(175,175,175,-1.0,-0.02,0,0.0,999.0,0.0,0.0,4)
	new str_min[32], str_hour[32], final[32]
	
	if(minute <= 9) format(str_min,sizeof(str_min),"0%i",minute)
	else if(minute > 9) format(str_min,sizeof(str_min),"%i",minute)

	if(hour <= 9) format(str_hour,sizeof(str_hour),"0%i",hour)
	else if(hour > 9) format(str_hour,sizeof(str_hour),"%i",hour)

	format(final,sizeof(final),"%s:%s %s %i, %i",str_hour,str_min,monthname[month],day,year)
	show_hudmessage(id,final)
	if(flag > 0) {
	
		new speak_min[32], speak_hour[32]
		num_to_word(minute,speak_min,31)
		num_to_word(hour,speak_hour,31)
		client_cmd(id,"speak ^"the time is %s %s^"",speak_hour,speak_min)
	}
	set_task(1.0,"tick_tock",id,arg,31,"a",10)
	set_task(10.0,"stop_clock",id,arg,31)
	return PLUGIN_HANDLED
}

public tick_tock(param[])
{
	new id = str_to_num(param)

	set_hudmessage(175,175,175,-1.0,-0.02,0,0.0,999.0,0.0,0.0,4)
	new str_min[32], str_hour[32], final[32]
	
	if(minute <= 9) format(str_min,sizeof(str_min),"0%i",minute)
	else if(minute > 9) format(str_min,sizeof(str_min),"%i",minute)

	if(hour <= 9) format(str_hour,sizeof(str_hour),"0%i",hour)
	else if(hour > 9) format(str_hour,sizeof(str_hour),"%i",hour)

	format(final,sizeof(final),"%s:%s %s %i, %i",str_hour,str_min,monthname[month],day,year)
	show_hudmessage(id,final)
}

public stop_clock(param[])
{
	new id = str_to_num(param)
	set_hudmessage(175,175,175,-1.0,-0.02,0,0.0,1.0,0.0,0.0,4)
	show_hudmessage(id,"")
}


		
//////////////////////////////////
//		SET TASKS
//////////////////////////////////
public darken_effect(id)
{
	id -= 64
	client_cmd(id,"speak ^"harburp/heart^"")
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<2)
	write_short(1<<14) 
	write_short(1<<0) 
	write_byte(0) 
	write_byte(0)  
	write_byte(0)   
	write_byte(255)   
	message_end()
	return PLUGIN_HANDLED
}


public glow_flash(param[],shitid)
{
	new id = str_to_num(param)
	new origin[3], end_origin[3]
	get_user_origin(id,origin)

	end_origin[0] = origin[0] + random_num(-30,30)
	end_origin[1] = origin[1] + random_num(-30,30)
	end_origin[2] = origin[2] + random_num(0,30)

	basic_lightning(origin,end_origin,6)

	if(tazerd[id][0] == 0) {
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
		tazerd[id][0] = 1
		return PLUGIN_CONTINUE
	}
	else if(tazerd[id][0] == 1) {
		set_user_rendering(id,kRenderFxGlowShell,0,0,225,kRenderNormal,32)
		tazerd[id][0] = 0
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public remove_tazer_effect(id)
{
	set_user_maxspeed(id-96,get_user_maxspeed(id-96)+319)
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
	remove_task(id)
	return PLUGIN_HANDLED
}

public recharge_func(id)
{
	remove_task(id)
	return PLUGIN_HANDLED
}

public kamikaze_timer(sZtimer[],id)
{
	id -= 55
	new timer = str_to_num(sZtimer)
	set_user_rendering(id,kRenderFxGlowShell,random_num(1,255),random_num(1,255),random_num(1,255),kRenderNormal,16)
	if(timer == 3) client_cmd(id,"speak ^"fvox/three^"")
	if(timer == 2) client_cmd(id,"speak ^"fvox/two^"")
	if(timer == 1) client_cmd(id,"speak ^"fvox/one^"")
	timer--
	if(timer > 0) {
		new str[5]
		num_to_str(timer,str,4)
		set_task(1.0,"kamikaze_timer",id+55,str,5)
	}
	return PLUGIN_CONTINUE
}

// When the Kamikaze Allah Guy Blows Up
public kamikaze_blow(id)
{
	id -= 54
	new origin[3], Float:forigin[3]

	get_user_origin(id,origin,0)
	IVecFVec(origin,forigin)
	basic_explosion(origin)
	make_deathmsg(id,id,0,"Kamikaze")
	user_silentkill(id)
	radius_damage(forigin,100,50)
	return PLUGIN_HANDLED
}

// Block all the use and shit from a tazered, or if hes taped(smokeys addon)
public client_PreThink(id)
{
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED;
	}
	new button = entity_get_int(id,EV_INT_button); // get buttons
	if(istaped[id] == 1)
	{
		entity_set_int(id,EV_INT_button,button & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_JUMP & ~IN_ALT1 & ~IN_USE & ~FL_ONGROUND);
	}
	if(task_exists(id+88) || alcohol[id][0] == 1)
	{
		new bufferstop = entity_get_int(id,EV_INT_button)
		if(bufferstop != 0) {
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_USE & ~IN_FORWARD & ~IN_BACK & ~IN_MOVELEFT & ~IN_MOVERIGHT)
		}
		if((bufferstop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND)) {
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

// Making the smoke effects
public smoke_effect(id)
{
	smokevar[id][2]--
	if(smokevar[id][0] == 0) {
		remove_task(id)
		return PLUGIN_HANDLED
	}
	if(smokevar[id][2] <= 0)
	{
		smokevar[id][0] = 0
		smokevar[id][1] = 0
		smokevar[id][2] = 0
		smokevar[id][3] = 0
		smokevar[id][4] = 0
		client_print(id,print_chat,"[ItemMod] You finish the smoke and toss it on the ground^n")
		client_cmd(id,"default_fov 90")
		remove_task(id)
		return PLUGIN_HANDLED
	}
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new vec[3]
	get_user_origin(id,vec)
	new y1,x1
	x1 = random_num(-10,10)
	y1 = random_num(-10,10)
	
	//Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( 5 ) // 5
	write_coord(vec[0]+x1) 
	write_coord(vec[1]+y1) 
	write_coord(vec[2]+30)
	write_short( smoke )
	write_byte( 10 )  // 10
	write_byte( 15 )  // 10
	message_end()
	client_cmd(id,"default_fov 90")
	return PLUGIN_CONTINUE
}

// Unblind a blinded player
public unblind(id)
{
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<12)
	write_short(1<<8) 
	write_short(1<<0) 
	write_byte(0)
	write_byte(0) 
	write_byte(0)   
	write_byte(100)  
	message_end()
	return PLUGIN_HANDLED
}

public time_explode(string[],entid)
{
	entid -= 29
	new point = str_to_num(string)
	new Float:forigin[3], origin[3], players[32], num
	entity_get_vector(entid,EV_VEC_origin,forigin)

	origin[0] = floatround(forigin[0])
	origin[1] = floatround(forigin[1])
	origin[2] = floatround(forigin[2])

	get_players(players,num,"ac")
	for(new i=0;i<num;i++)
	{
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= (get_cvar_num("rp_msgdistance")*2))
		{
			client_print(players[i],print_chat," **[DoorMod] %i!!! **^n",point)
		}
	}

	if(point == 3)
	{
		new str[32], fpara[5]
		format(str,sizeof(str),"Explode_%i",entid)
		create_ambient(origin,str,"10","80",8,"phone/2.wav")
		set_rendering(entid,kRenderFxGlowShell,0,225,0,kRenderNormal,16)
		force_use(entid,find_ent_by_tname(-1,str))
		force_use(entid,find_ent_by_tname(-1,str))
		point -= 1
		num_to_str(point,fpara,sizeof(fpara))
		set_task(1.0,"time_explode",entid+29,fpara,sizeof(fpara))
		return PLUGIN_CONTINUE
	}
	if(point == 2)
	{
		new str[32], fpara[5]
		format(str,sizeof(str),"Explode_%i",entid)
		set_rendering(entid,kRenderFxGlowShell,225,225,0,kRenderNormal,16)
		force_use(entid,find_ent_by_tname(-1,str))
		force_use(entid,find_ent_by_tname(-1,str))
		point -= 1
		num_to_str(point,fpara,sizeof(fpara))
		set_task(1.0,"time_explode",entid+29,fpara,sizeof(fpara))
		return PLUGIN_CONTINUE
	}
	if(point == 1)
	{
		new str[32]
		format(str,sizeof(str),"Explode_%i",entid)
		set_rendering(entid,kRenderFxGlowShell,225,0,0,kRenderNormal,16)
		force_use(entid,find_ent_by_tname(-1,str))
		force_use(entid,find_ent_by_tname(-1,str))
		remove_entity(find_ent_by_tname(-1,str))
		set_task(1.0,"door_explode",entid+30)
		remove_task(entid+29)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_HANDLED
}

// The Explosion of door and setting the recovery task
public door_explode(entid)
{
	new Float:Origin[3]
	entid -= 30
	set_rendering(entid)
	entity_get_vector(entid,EV_VEC_origin,Origin)

	new intorigin[3]
	FVecIVec(Origin,intorigin)

	basic_explosion(intorigin)

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, intorigin )
	write_byte( 108 )		// TE_BREAKMODEL (108)
	write_coord( floatround(Origin[0]) )
	write_coord( floatround(Origin[1]) )
	write_coord( floatround(Origin[2]) )
	write_coord( 0 )
	write_coord( 0 )
	write_coord( 0 )
	write_coord( 5 )
	write_coord( 5 )
	write_coord( 5 )
	write_byte( 15 )
	write_short( DOOR_GIBS )
	write_byte( 50 )
	write_byte( 50 )
	write_byte( 0 )

	message_end()
	
	new entstore
	for(new i = 0; i < MAXDOORS; i++)
	{
		if(g_door_explode[i][0] == 0.0 && g_door_explode[i][1] == 0.0 && g_door_explode[i][2] == 0.0)
		{
			g_door_explode[i][0] = Origin[0]
			g_door_explode[i][1] = Origin[1]
			g_door_explode[i][2] = Origin[2]
			entstore = i
			break
		}
	}

	entity_set_origin(entid,nullorigin)
	set_entity_visibility(entid,0)

	radius_damage(Origin,75,35)
	new buffer[32]
	num_to_str(entstore,buffer,sizeof(buffer))
	set_task(25.0,"store_door",entid,buffer,sizeof(buffer))
	
	return PLUGIN_HANDLED
}

// Recovering the door
public store_door(param[],entid)
{
	new storeid = str_to_num(param)

	entity_set_vector(entid,EV_VEC_origin,g_door_explode[storeid])
	set_entity_visibility(entid,1)

	g_door_explode[storeid][0] = 0.0
	g_door_explode[storeid][1] = 0.0
	g_door_explode[storeid][2] = 0.0
	
	return PLUGIN_HANDLED
}

public normal_glow(id)
{
	set_user_rendering(id)
	return PLUGIN_HANDLED
}

// Picklocking door
public picklock_action(id)
{
	id -= 32

	new curid, curbody, classname[32]
	get_user_aiming(id,curid,curbody,200)
	if(curid) entity_get_string(curid,EV_SZ_classname,classname,31)
	if(equali(classname,"func_door_rotating"))
	{
		if(random_num(0,20) == 10)
		{
			force_use(id,curid)
			fake_touch(curid,id)
			client_print(id,print_chat,"[DoorMod] Door picklocked!")
			remove_task(id+32)
			return PLUGIN_HANDLED
		}
		client_print(id,print_chat,"[DoorMod] Failed to picklock the door")
	}
	remove_task(id+32)
	return PLUGIN_HANDLED
}

public moneytree()
{
	new players[32], inum
  	get_players(players,inum,"ac")
	for(new i = 0 ;i < inum ;++i)
	{
		// Money Trees money spawning
		if(get_item_amount(players[i],MONEYTREE,"money") > 0)
		{
			new currentamount = get_item_amount(players[i],MONEYTREE,"money")
			edit_value(players[i],"money","wallet","+",random_num(1,5) * currentamount)
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////
// EFFECTS LIBRARY ///
//////////////////////

// A Basic Explosion
stock basic_explosion(origin[3])
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( 12 ) 
	write_coord(origin[0]) //coord, coord, coord (start)
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte( 200 ) // byte (scale in 0.1's) 188 
	write_byte( 10 ) // byte (framerate) 
	message_end()

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 3 )
	write_coord(origin[0]) //coord, coord, coord (start)
	write_coord(origin[1])
	write_coord(origin[2])
	write_short( fire )
	write_byte( 60 )
	write_byte( 10 )
	write_byte( 0 )
	message_end()
	return PLUGIN_HANDLED
}

// A Lightning Effect
stock basic_lightning(s_origin[3],e_origin[3],life = 8)
{

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 0 )
	write_coord(s_origin[0])
	write_coord(s_origin[1])
	write_coord(s_origin[2])
	write_coord(e_origin[0])
	write_coord(e_origin[1])
	write_coord(e_origin[2])
	write_short( lightning )
	write_byte( 1 ) // framestart
	write_byte( 5 ) // framerate
	write_byte( life ) // life
	write_byte( 20 ) // width
	write_byte( 30 ) // noise
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // brightness
	write_byte( 200 ) // speed
	message_end()

	message_begin( MSG_PVS, SVC_TEMPENTITY,e_origin)
	write_byte( 9 )
	write_coord( e_origin[0] )
	write_coord( e_origin[1] )
	write_coord( e_origin[2] )
	message_end()
	return PLUGIN_HANDLED
}

// Shaking a users screen
stock basic_shake(id,amount = 14, length = 14)
{
      message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, id)
      write_short(255<< amount ) //ammount 
      write_short(10 << length) //lasts this long 
      write_short(255<< 14) //frequency 
      message_end()
}

//////////////////////////////////////////
//	A l c o h o l  C o d e
/////////////////////////////////////////

// Walking strange alcohol effect
public alcohol_move(sZid[],task_id)
{
	new id = str_to_num(sZid)
	client_cmd(id,"-moveleft;-moveright;-forward;-back")
	new ran = random_num(1,4)
	if(ran == 1) client_cmd(id,"+forward")
	if(ran == 2) client_cmd(id,"+back")
	if(ran == 3) client_cmd(id,"+moveleft")
	if(ran == 4) client_cmd(id,"+moveright")

	set_task(0.5,"alcohol_stop_move",0,sZid,32)
		
	return PLUGIN_HANDLED
}

// Stop movement
public alcohol_stop_move(sZid[])
{
	new id = str_to_num(sZid)
	client_cmd(id,"-moveleft;-moveright;-forward;-back")
	return PLUGIN_HANDLED
}

// Shaking effect for alcohol
public alcohol_shake(sZid[],task_id)
{
	basic_shake(str_to_num(sZid))
	return PLUGIN_HANDLED
}

// Spinning effect for spinning
public alcohol_spin(sZid[],task_id)
{
	client_cmd(str_to_num(sZid),"+left")
	set_task(3.0,"alcohol_remove_spin",0,sZid,31)
	return PLUGIN_HANDLED
}

// Removing the alcohol Spinning effect
public alcohol_remove_spin(sZid[])
{
	client_cmd(str_to_num(sZid),"-left")
	return PLUGIN_HANDLED
}

// When 1 alcohol dies in your body!
public alcohol_die(sZid[])
{
	new id = str_to_num(sZid)
	client_cmd(id,"-moveleft;-moveright;-forward;-back")
	alcohol[id][1] -= 1
	if(alcohol[id][1] <= 0) set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
}

// The passing out dark screen effect & breathing
public alcohol_dark_passout(sZid[])
{
	new id = str_to_num(sZid)
	client_cmd(id,"speak ^"harburp/heart^"")
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<0)
	write_short(1<<0) 
	write_short(1<<2) 
	write_byte(0) 
	write_byte(0)  
	write_byte(0)   
	write_byte(220)   
	message_end()
	client_cmd(id,"+duck")
	return PLUGIN_HANDLED
}

public alcohol_remove_passout(sZid[])
{
	new id = str_to_num(sZid)
	alcohol[id][0] = 0
	remove_task(id+160)
	alcohol[id][1] = 0
	set_user_maxspeed(id,get_user_maxspeed(id)+319)
	unblind(id)
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
	client_cmd(id,"-duck")
	client_cmd(id,"speak NULL")
	client_print(id,print_center," * You Wake Up! * ^n")
	return PLUGIN_HANDLED
}
public item_drugs()
{
   new arg[32], arg2[32], arg4[32], arg5[32], itemname[32], id, itemid, high, origin[3]
   read_argv(1,arg,31)
   read_argv(2,arg2,31)
   read_argv(3,itemname,31)
   read_argv(4,arg4,31)
   read_argv(5,arg5,31)
   id = str_to_num(arg)
   itemid = str_to_num(arg2)
   high = str_to_num(arg5)

   new Float:task_time = float(str_to_num(arg4))
   if(alcohol[id][0] == 1) {
      set_item_amount(id,"+",itemid,1,"money")
      client_print(id,print_chat,"[Drug Mod] Can't do drugs while passed out!^n")
      return PLUGIN_HANDLED
   }

   alcohol[id][1] += high

   if(alcohol[id][1] > 10) {
      alcohol[id][0] = 1
      client_print(id,print_center," * You Pass out! * ^n")
      remove_task(id+224)
      remove_task(id+256)
      remove_task(id+288)
      set_user_maxspeed(id,get_user_maxspeed(id)-319)
      alcohol_dark_passout(arg)

      message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
      write_short(1<<0)
      write_short(1<<0)
      write_short(1<<2)
      write_byte(0)
      write_byte(0)
      write_byte(0) 
      write_byte(220) 
      message_end()
      client_cmd(id,"+alt1;wait;-alt1")
      set_task(4.0,"alcohol_dark_passout",id+160,arg,31,"a",30)
      set_task(60.0,"alcohol_remove_passout",id+192,arg,31)
      return PLUGIN_HANDLED
   }
   set_user_rendering(id,kRenderFxGlowShell,255,128,255,kRenderNormal,16)   
   new repeat = 60 / floatround(task_time)
//   set_task(task_time,"drug_move",id+224,arg,31,"a",repeat)
   set_task(5.0,"alcohol_shake",id+256,arg,31,"a",10)
   set_task(10.0,"alcohol_spin",id+288,arg,31,"a",4)
//   set_task(5.0, "randcolors", id+256, arg, 31, "a", 20)
//   set_task(5.0, "drug_illusion1", id+256, arg, 31, "a", 20)
//   set_task(10.0, "sound_illusion1", id+256, arg, 31, "a", 20)
   client_print(id,print_chat,"[Drug Mod] You enjoy some %s^n",itemname)
   for(new i = 0; i <= high; i++) {
      set_task(60.0,"alcohol_die",id,arg,31)
   }
   get_user_origin(id,origin)

   new players[32], num, name[32]
   get_players(players,num,"ac")
   get_user_name(id,name,31)

   for(new i=0;i<num;i++)
   {
      if(players[i] == id) continue
      new porigin[3]
      get_user_origin(players[i],porigin)
      if(get_distance(origin,porigin) <= (get_cvar_num("rp_msgdistance")))
      {
         client_print(players[i],print_chat,"[Drug Mod] %s enjoys some %s^n",name,itemname)
      }
   }
   return PLUGIN_HANDLED
}
/*
public high_effect(id)
{
   id -= 64
   new origin[3]
   message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
   write_short(1<<2)
   write_short(1<<14)
   write_short(1<<0)
   write_byte(random_num(0,255))
   write_byte(random_num(0,255)) 
   write_byte(random_num(0,255))   
   write_byte(random_num(100,250))   
   message_end()

   
   get_user_origin(id,origin)
   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( fire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteBolt )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteFire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteExorcise )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( bloodfrag )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()


   if(random_num(0,4)==2)
   {
      emit_sound(id,CHAN_AUTO, "debris/bustglass2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH) // plays the death sound
   }
   if(random_num(0,4)==2)
   {
      emit_sound(id,CHAN_AUTO, "weapons/sfire-inslow.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH) // plays the death sound
   }
   set_task(0.7,"illusion",id)
   return PLUGIN_HANDLED
}
*/
/*

public illusion(id)
{
   new origin[3]
   get_user_origin(id,origin)
   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( fire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteBolt )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteFire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteExorcise )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( bloodfrag )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()
   set_task(0.7,"illusion2",id)
   return PLUGIN_HANDLED
}
public illusion2(id)
{
   new origin[3]

   get_user_origin(id,origin)
   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( fire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteBolt )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteFire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteExorcise )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( bloodfrag )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()
   set_task(0.7,"illusion3",id)
   return PLUGIN_HANDLED
}
public illusion3(id)
{
   new origin[3]

   get_user_origin(id,origin)
   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( fire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteBolt )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,600)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteFire )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( SpriteExorcise )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()

   message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
   write_byte( 17 )
   write_coord(origin[0]+(random_num(0,100)-300)) //coord, coord, coord (start)
   write_coord(origin[1]+(random_num(0,100)-300))
   write_coord(origin[2]+(random_num(0,50)))
   write_short( bloodfrag )
   write_byte( random_num(0,60) )
   write_byte( 255 )
   message_end()
   return PLUGIN_HANDLED
}
*/
/*
public drug_illusion1(id)
{
	new origin[3]
	get_user_origin(id,origin)
	new randillusion = random(2)
	if(randillusion == 0)
	{
		message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
		write_byte( 17 )
		write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
		write_coord(origin[1]+(random_num(0,600)-300))
		write_coord(origin[2]+(random_num(0,50)))
		write_short ( bloodfrag )
		write_byte( 200 )
		message_end()
	}
	if(randillusion == 1)
	{
		message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
		write_byte( 17 )
		write_coord(origin[0]+(random_num(0,600)-300)) //coord, coord, coord (start)
		write_coord(origin[1]+(random_num(0,600)-300))
		write_coord(origin[2]+(random_num(0,50)))
		write_short ( SpriteExorcise )
		write_byte( 200 )
		message_end()
	}
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<14)
	write_short(1<<14) 
	write_short(1<<0) 
	write_byte(random_num(1, 255)) //red
	write_byte(random_num(1, 255)) //green
	write_byte(random_num(1, 255))   //blue
	write_byte(random_num(1, 200))   //alpha
	message_end()
	// else, there is no illusion, k? k
	return PLUGIN_HANDLED;
}
*/
/*
public randcolors(id)
{
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<0) 
	write_byte(random_num(1, 255)) //red
	write_byte(random_num(1,255)) //green
	write_byte(random_num(1,255))   //blue
	write_byte(random_num(1,255))   //alpha
	message_end()
}
*/
/*
public sound_illusion1(id)
{
	new origin[3]
	get_user_origin(id,origin)
	new randomsound = random(2)
	if(randomsound == 0)
	{
		emit_sound(id,CHAN_AUTO, "debris/bustglass2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH) // plays the death sound
	}
	if(randomsound == 1)
	{
		emit_sound(id,CHAN_AUTO, "weapons/sfire-inslow.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH) // plays the death sound
	}
	return PLUGIN_HANDLED;
}
*/
public item_armor()
{
   new id, arg[31], arg2[31], armoramount

   read_argv(1,arg,31)
   read_argv(2,arg2,31)

   id = str_to_num(arg)
   armoramount = str_to_num(arg2)
   
   set_user_armor(id, get_user_armor(id)+armoramount)
   client_cmd(id,"say /me puts on kevlar armor.")

   return PLUGIN_HANDLED
}
public item_teargas()
{
   new arg[32], origin[3], id
   read_argv(1,arg,31)
   id = str_to_num(arg)
   get_user_origin(id,origin)
   new players[32], num
   get_players(players,num,"ac")
   for(new i = 0; i < num;i++)
   {
      new p_origin[3]
      get_user_origin(players[i],p_origin)

      message_begin(  MSG_BROADCAST,SVC_TEMPENTITY,{0,0,0})
      write_byte( 5 )
      write_coord(origin[0]) //coord, coord, coord (start)
      write_coord(origin[1])
      write_coord(origin[2])
      write_short( smoke )
      write_byte( 200 )
      write_byte( 3 )
      message_end()
   

      if(get_distance(origin,p_origin) <= 300.0)
      {
         if(players[i]!=id)
         {
            message_begin(MSG_ONE, gmsgFade, {0,0,0}, players[i])
            write_short(1<<2)
            write_short(1<<14)
            write_short(1<<0)
            write_byte( 122 )
            write_byte( 177 )
            write_byte( 7 )
            write_byte( 250 )
            message_end()

            for(new w=1;w<=35;w++)
            {
               client_cmd(players[i],"weapon_%d; drop",w)
            }
            if(get_user_health(players[i]) <= 5)
            {
               user_silentkill(players[i])
               make_deathmsg (id,players[i],0,"Tear Gas")
            }
            else set_user_health(players[i],get_user_health(players[i])-10)
            set_task(10.0,"remove_tazer_effect",players[i]+96)
         }
      }
   }
   emit_sound(id,CHAN_BODY, "weapons/sfire-inslow.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
   return PLUGIN_HANDLED
}
public item_steroids()
{
   new id, arg[31]

   read_argv(1,arg,31)

   id = str_to_num(arg)
   if(onsteroids[id] == 1)
   {
		client_print(id,print_chat, "Your already using steroids!")
		return PLUGIN_HANDLED;
   }
   client_cmd(id,"say /me takes steroids.")
   set_task(0.5, "steroid_effect", id, "", 0, "a", 50)
   set_task(26.0, "steroid_effectmsg", id)
   onsteroids[id] = 1
   return PLUGIN_HANDLED
}
public steroid_effect(id)
{	
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	if(get_user_health(id) > 200)
	{
		return PLUGIN_HANDLED;
	}
	if(onsteroids[id] == 0)
	{
		return PLUGIN_HANDLED;
	}
	set_user_health(id, get_user_health(id)+1) // get users health and add to it by 1
	return PLUGIN_HANDLED;
}
public steroid_effectmsg(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED;
	}
	if(onsteroids[id] == 0)
	{
		return PLUGIN_HANDLED;
	}
	client_print(id,print_chat, "[STEROIDS] You feel much stronger now! However you feel much desire to work out and fight alot.")
	steroid_redeffect(id)
	set_task(15.0, "steroid_redeffect", id, "", 0, "a", 10)
	set_task(155.0, "steroid_finish", id) // the end of the steroids finally, YAY HURRAY! LAWL!!11
	return PLUGIN_HANDLED;
}
public steroid_redeffect(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED;
	}
	if(onsteroids[id] == 0)
	{
		return PLUGIN_HANDLED;
	}
	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<14)
	write_short(1<<14) 
	write_short(1<<0) 
	write_byte(221) //red
	write_byte(85) //green
	write_byte(96)   //blue
	write_byte(100)   //alpha
	message_end()
	return PLUGIN_HANDLED;
}
public steroid_finish(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED;
	}
	onsteroids[id] = 0
	client_print(id,print_chat, "Your steroids are starting to wear off... your mind tells you to buy more!")
	return PLUGIN_HANDLED;
}
public item_selfaid()
{
   new arg[32], arg2[32], arg3[32], id, amount, minium, arg4[32], itemid
   read_argv(1,arg,31)
   read_argv(2,arg2,31)
   read_argv(3,arg3,31)
   read_argv(4,arg4,31)

   id = str_to_num(arg)
   amount = str_to_num(arg2)
   minium = str_to_num(arg3)
   itemid = str_to_num(arg4)

   new currenthealth = get_user_health(id)
   if(currenthealth >= 100)
   {
      client_print(id,print_chat,"[HealMod] The person you are looking at has already full health^n")
      set_item_amount(id,"+",itemid,1,"money")
      return PLUGIN_HANDLED
   }
   if(currenthealth <= minium)
   {
      client_print(id,print_chat,"[HealMod] Too much damage! You need a much more advanced procedure!^n")
      set_item_amount(id,"+",itemid,1,"money")
      return PLUGIN_HANDLED
   }
   if((currenthealth+amount) > 100)
   {
      new val = (currenthealth+amount) - 100
      amount -=val
   }
   set_user_health(id,currenthealth+amount)
   client_print(id,print_chat,"[HealMod] Gave %i HP To Player %s!.^n",amount,id)
   client_cmd(id,"speak ^"items/smallmedkit1^"")
   return PLUGIN_HANDLED
}
// When player dies
public death_msg()
{
	new id = read_data(2)
	if(alcohol[id][0] > 0)
	{
		alcohol[id][0] = 0
		remove_task(id+160)
		set_user_maxspeed(id,get_user_maxspeed(id)+319)
		unblind(id)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
		client_cmd(id,"-duck")
		client_cmd(id,"speak NULL")
		return PLUGIN_CONTINUE
	}
	
	if(alcohol[id][1] > 1)
	{
		alcohol[id][1] = 0
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
		remove_task(id+224)
		remove_task(id+256)
		remove_task(id+288)
		return PLUGIN_CONTINUE
	}
	onsteroids[id] = 0
	istaped[id] = 0
	istapedtry[id] = 0
	roped[id] = 0
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	if(task_exists(id)) remove_task(id)
	if(task_exists(id+32)) remove_task(id+32)
	if(task_exists(id+29)) remove_task(id+29)
	if(task_exists(id+55)) remove_task(id+55)
	if(task_exists(id+54)) remove_task(id+54)
	if(task_exists(id+64)) remove_task(id+64)
	if(task_exists(id+96)) remove_task(id+96)
	if(task_exists(id+128)) remove_task(id+128)
	if(task_exists(id+160)) remove_task(id+160)
	if(task_exists(id+192)) remove_task(id+192)
	if(task_exists(id+224)) remove_task(id+224)
	if(task_exists(id+256)) remove_task(id+256)
	if(task_exists(id+288)) remove_task(id+288)
	if(task_exists(id+126)) remove_task(id+126)
	if(task_exists(id+127)) remove_task(id+127)
	smoketimeout[id] = 0
	onsteroids[id] = 0
	istaped[id] = 0
	istapedtry[id] = 0
	roped[id] = 0
	dragging[id] = 0
	dragged[id] = 0
	usedcar[id] = 0
	weaponid_stuff[id] = 0;
	ammo_stuff[id] = 0;
	chose_laser[id] = 0;
	chose_silencer[id] = 0;
	chose_flashlight[id] = 0;
	chose_scope[id] = 0;
	return PLUGIN_CONTINUE
}

public spawn_msg(id)
{
	client_print(id,print_console,"Tell me the reason")
	new authid[32], JobID, str[32], query[256]
	get_user_authid(id,authid,31)
	select_string("money","JobID","steamid",authid,str,31)
	JobID = str_to_num(str)

	format(query,255,"SELECT * FROM itemspawns")
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		new rows = dbi_num_rows(result)
		for(new i=0;i < rows;i++)
		{
			new itemid, amount, authid2[32], edittable[32], JobID2[32]
			itemid = dbi_field(result,1)
			amount = dbi_field(result,2)
			dbi_field(result,3,authid2,31)
			dbi_field(result,4,edittable,31)
			dbi_field(result,5,JobID2,31)

			if(equali(authid,authid2)) set_item_amount(id,"+",itemid,amount,edittable)

			new output[2][32]
			explode(output,JobID2,'-')
			if(str_to_num(output[0]) >= JobID && str_to_num(output[1]) <= JobID) set_item_amount(id,"+",itemid,amount,edittable)
		}
	} else {
		dbi_free_result(result)
	}
	return PLUGIN_HANDLED
}

// When player drops weapon maintain speed
public client_dropweapon(id)
{
	if(alcohol[id][0] == 1) slowdown(id)
	return PLUGIN_HANDLED
}

// Time Mod
public time_advance()
{
	minute++
	if(minute == 60)
	{
		hour++
		minute = 0
	}
	if(hour == 24)
	{
		day++
		hour = 0
	}
	if(day == monthday[month])
	{
		month++
		day = 1
	}
	if(month == 12)
	{
		year++
		month = 1
	}
	return PLUGIN_CONTINUE
}

/// Einen Druggen //

public color_effect( str[] )
{
	new id = str_to_num( str )

	if( smokevar[id][0] != 2 ) remove_task()

	message_begin(MSG_ONE, gmsgFade, {0,0,0}, id)
	write_short(1<<0)
	write_short(1<<0) 
	write_short(1<<2) 
	write_byte(0) 
	write_byte(random_num( 80, 200 ))  
	write_byte(0)   
	write_byte(random_num( 50, 200 ))   
	message_end()

	return PLUGIN_CONTINUE
}

stock plant_insert(id,plantname[],allowdistance,grow_time,health,amount,x,y,z,itemid,seedid=700)
{
	new authid[32]
	get_user_authid(id,authid,31)
	new query[512]
	format(query,sizeof(query),"INSERT INTO planting(authid,plantname,allowdistance,val,health,amount,x,y,z,itemid,seedid) VALUES('%s','%s','%i','%i','%i','%i','%i','%i','%i','%i','%i')",authid,plantname,allowdistance,grow_time,health,amount,x,y,z,itemid,seedid)
	dbi_query(dbc,query)
	//plant_insert_timeout[id] = 1;
	return PLUGIN_HANDLED;
}
stock plant_get_health(id,authid[],x,y,z)
{
	new query[256],health
	format(query,sizeof(query),"SELECT health FROM planting WHERE authid='%s' AND x='%i' AND y='%i' AND z='%i'",authid,x,y,z)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		health = dbi_field(result,1)
		dbi_free_result(result)
	} else {
		client_print(id,print_chat,"[PLANTS] Error getting health of your plant.")
		dbi_free_result(result)
		return 0;
	}
	return health;
}