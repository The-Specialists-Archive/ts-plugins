
/*




------------------------------------------------------------------------------------------------------------
			RD TSRP Plugins ( Beta x.3 ) ( RDRP VERSION ) ( All Maps Supportet )
------------------------------------------------------------------------------------------------------------

	Made By: 	Eric Andrews AKA. Harbu 'Vladimir' Kerensky
			StevenAFL

        Highly Modified by: Shin Lee




	Thanks to: Ben Promethus (Giving Some Codes)
	Thanks to: Avalanche (For ammo buying script)
        Thanks to: me (Shin Lee) (for make it so much better)



	Beta x.7        amxx 1.7x
	25.4.2007	- Fixed loads of bugs relating to variables containing wallet, jobid's etc.
			- Fixed cuffbug after dying not loosing cuffs
			- Left out that suspicous admin thing for Steven?
			- Added in ATM5
			- Leet Laptop disabled by default.. ( well actually just coordinates 0,0,0 )
                        //things added by Shin Lee (Red Dragon RP)//
                        - Sleepmod, Hungermod,Bathroommod
                        - Dinerrob fixed (YAY, robdoors for Augsburg_b3)
                        - 7/11 rob fixed (YAY, robdoors for Augsburg_b3)
                        - dropmoney fixed (YAY, thats awesome)
                        - include Weaponspawnprice MOTD (ts/wprices.txt,say /wprices)
                        - fined money goes into the Bankaccount of Police Officers
                        - amx_gangname added (look at a door and type that)
                        - Police Shout script added
 
 
*/


#pragma dynamic 32768

#include <amxmodx>
#include <amxmisc>
#include <dbi>
#include <engine>
#include <tsx>
#include <engine_stocks>
#include <fun>
#include <tsxaddon>

#define HP_VERSION "x.7"	// Version displayed on Starting message console etc.

#define ITEMS 35
#define MAXKEYS 32
#define MAXIUMSTR 2048		// String maxium byte size for property acesses, items, items storage

new gunshop[3]			// Value to store gunshop position
new addons[33][5]		// Stores information of currently selected addons
new chosenweapon[33][3]

// Bank ATM #1 and #2 Position
new atmone[3]
new atmtwo[3]
new atmthree[3]
new atmfour[3]
new atmfive[3]

// Jail Cell Positions
new jailone[3]
new jailtwo[3]
new jailthree[3]
new jailfour[3]

// Uncuff Positions - Default for Mecklenburg_b5
new uncuffareaone[3]
new uncuffareatwo[3]

new hasclosedoors = 0 // Close MCPD, Gunshop doors at beginng ( 0 = ON, 1 =OFF)

// JobIDS replace with the ones you have in your MySQL database
new mafiajobs[2]
new mcpdjobs[2]
new mcmdjobs[2]
new jobs711[2]

// 711 Robbing
new whorob711						// Who is Robbing the 711
new robgain711 = 0					// How much has the robber gained
new rob711currentcash = 0				// Amount of cash currently in the Register
new temptime711rob = 0					// After robbing the 7/11 a time thingy to stop the metal bars from going messed up..

// Diner Robbing
new whorobdiner						// Who is Robbing the Diner
new robgaindiner = 0					// How much has the robber gained
new robdinercurrentcash = 0				// Amount of cash currently in the diner cash register
new temptimedinerrob = 0				// After robbing the Diner a time thingy to stop the metal bars from going messed up..

// Bank Robbing
new nrobags						// How many bags have been taken to bank
new whorobbank						// Who the fuck is robbing the bank
new Float:positionrob[3] = {1839.0, 1265.0, -59.0}		// Position of target where the moneybags has to be taken
new finishtime = 0
new moneybag					// Moneybag entity numbers (Set Later)
new moneybag2
new mdone[2]						// Which moneybags have been already taken?
new Float:borigin[3]					// Moneybag entity origins (Later)
new Float:borigin2[3]

// Item Mod Variables
new g_itemholder[33][10][3]		// ID Numbers of the items in players menu
new g_page[33]				// Current Page
new g_isnextpage[33]			// is next page?
new g_selecteditem[33][2]		// Selected Item and its Quantity
new g_delay_item[33]			// Delay when dropping an item

// Shops for ItemMod
new g_shopid[33]			// Stores the current shop name
new g_shopfunc[33]			// Stores function

// Prodigy Store
new g_prodigy_time[33]			// Stores the time left in prodigy store
new g_prodigy_func[33]			// Stores the function of the prodigy
new g_prodigy_sel[33]			// Stores the selected item

new Storageone[3]			// MCPD Store-o-Matic
new Storagetwo[3]			// Appartment A
new Storagethree[3]			// Appartment B
new Storagefour[3]			// Appartment C
new Storagefive[3]			// MCMD

// Accept job? Menu
new g_jobid[33]				// Store temporarly the JobID the employer has offered
new g_employer[33]			// Store temporarly the Job Employeer name

new leet_laptop[3] = { 2011, 225, 192 }	// Coordinates for 1337 Computer
new leet_rightpass[5] = {1,4,9,2,7}		// Right Code
new leet_guesscode[33][5]

new timer_salary[33] = 60

new g_fine[33][2]	// [0] = ID of issuer, [1] = Amount

new cuffed[33]

new JobID3[33]
new wallet3[33]
new balance3[33]
new hudtog[33]

// picking up money
new picktimeout[33]; // pickup timeout

// Registering the database
new Sql:dbc
new Result:result

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
 ////////////////////////////////////////////////////////////////////
 // PLUGIN PRECACHE
 //////////////////////////////////////////////////////////////////
 public plugin_precache()
 {
	precache_model("models/hwrp/w_backpack.mdl")	// CS Backpack Model
	precache_model("models/money.mdl")		// Money Model
	precache_sound("items/gunpickup2.wav")	// Picking up item
	precache_sound("items/ammopickup1.wav")	// Droping item
        precache_sound("rdrp/police1.wav") // sound for police shout
}
public plugin_init()
{
	register_plugin("Harbu TSRP",HP_VERSION,"RDRP Coders")

	server_cmd("slowmatch 0") // Disable Slowmotion, Use 1 instead if you want to enable it



	// Register Cvars
	register_cvar("HarbuRP_Version",HP_VERSION,FCVAR_SERVER)

	register_cvar("economy_mysql_host","127.0.0.1",FCVAR_PROTECTED)
	register_cvar("economy_mysql_user","root",FCVAR_PROTECTED)
	register_cvar("economy_mysql_pass","",FCVAR_PROTECTED)
	register_cvar("economy_mysql_db","economy",FCVAR_PROTECTED)

	register_cvar("rp_startmoney","200")		// How much money a person gets when he registers his account
	register_cvar("rp_gunrefillprice","15")		// Price for refilling Weapons
	register_cvar("rp_loose_items","0")		// Loose items when you die
	register_cvar("rp_item_limit","15")		// Limit the amount of items you can carry

	register_cvar("rp_economyhud_pos_x","-1.9")	// X Position of EconomyHud on players screen
	register_cvar("rp_economyhud_pos_y","0.55")	// Y Position of EconomyHud on players screen
	register_cvar("rp_economyhud_red","0")		// Hud Colors
	register_cvar("rp_economyhud_green","175")
	register_cvar("rp_economyhud_blue","0")

	register_cvar("rp_prodigy_price_bronze","250")	// Prices for different storages
	register_cvar("rp_prodigy_price_silver","500")
	register_cvar("rp_prodigy_price_gold","1000")
	register_cvar("rp_prodigy_price_platinum","5000")

	register_cvar("rp_prodigy_min_bronze","720")	// Minutes of storage for each account type
	register_cvar("rp_prodigy_min_silver","1440")
	register_cvar("rp_prodigy_min_gold","2880")
	register_cvar("rp_prodigy_min_platinum","14400")

	register_cvar("rp_prodigy_limit_bronze","60")	// Item limit for different prodigy accounts
	register_cvar("rp_prodigy_limit_silver","100")
	register_cvar("rp_prodigy_limit_gold","160")
	register_cvar("rp_prodigy_limit_platinum","200")

	register_cvar("rp_walletlimit","5000")		// Limit of how much cash can be carried in your wallet
	register_cvar("rp_salary_to_wallet","0")	// Should salary be paied to wallet or bank balance
	register_cvar("rp_loose_cash","1")		// Should you loose cash from your wallet when you die

	register_cvar("rp_position_gunshop","-2407 144 -411") // Gunshop Position (Mecklenburg_B8v6 Default)

	register_cvar("rp_itemid_atmcard","2")		// Itemid for ATMcard
	register_cvar("rp_itemid_insurance","150")	// Itemid for Insurance

	register_cvar("rp_msgdistance","350")		// The radius robbing messages should be shown

	register_cvar("rp_position_atmone","691 -425 -347")	// ATM #1 (Default for mecklenburg_b8v6 Bank)
	register_cvar("rp_position_atmtwo","268 -439 -347")	// ATM #2 (Default for mecklenburg_b8v6 Bank)
	register_cvar("rp_position_atmthree","-2503 1071 -411")	// ATM #3 (Default for mecklenburg_b8v6 7/11)
	register_cvar("rp_position_atmfour","0 0 0")		// ATM #4 (Extra one)
	register_cvar("rp_position_atmfive","0 0 0")		// ATM #5 ( Extra Extra One) "Jesus Christ" :/

	register_cvar("rp_position_jailone","-2710 2214 -314")	// Coordinates for Jails
	register_cvar("rp_position_jailtwo","-2710 2082 -314")
	register_cvar("rp_position_jailthree","-2710 1949 -314")
	register_cvar("rp_position_jailfour","-2710 1839 -314")

								// Storage coordinates
	register_cvar( "rp_position_storageone", "-2135 2622-347" )	// MCPD Store-o-Matic
	register_cvar( "rp_position_storagetwo", "-120 2464 -27" )	// Appartment A
	register_cvar( "rp_position_storagethree", "-1159 2463 -29" )	// App. B
	register_cvar( "rp_position_storagefour", "607 -778 292" )	// App. C
	register_cvar( "rp_position_storagefive", "1533 1231 -379" )	// MCMD

	register_cvar("rp_position_uncuffzone_one","89 725 -200")	// UNCUFF Areas
	register_cvar("rp_position_uncuffzone_two","626 -969 310")

	register_cvar("rp_jobid_mafia","51 57")				// JobID's
	register_cvar("rp_jobid_mcpd","2 11")
	register_cvar("rp_jobid_mcmd","41 46")
	register_cvar("rp_jobid_711","71 73")

	register_cvar("rp_moneybag_value","1000")			// Value of each moneybag when robbing the bank

	register_cvar("rp_cuffed_speedloose","220")			// How much speed is taken from player while cuffed
	register_cvar("rp_delete_vehicle","1")				// Remove veichles on map start
	register_cvar("rp_delete_button", "1")				// Remove buttons at map start

	register_cvar("rp_npcid_market","1")				// NpcID for Market (7/11) NPC
	register_cvar("rp_npcid_diner","2")				// NpcID for Diner NPC
	register_cvar("rp_npcid_prodigy","21")
	register_cvar("rp_npcid_bank_one","19")
	register_cvar("rp_npcid_bank_two","20")

	register_cvar("rp_license_pistol","2500")
	register_cvar("rp_license_sub","4000")
	register_cvar("rp_license_shotgun","6000")
	register_cvar("rp_license_rifle","8000")
	register_cvar("rp_license_heavy","12000")

	register_cvar("rp_license_pistol_id","180")
	register_cvar("rp_license_sub_id","181")
	register_cvar("rp_license_shotgun_id","182")
	register_cvar("rp_license_rifle_id","183")
	register_cvar("rp_license_heavy_id","184")
	
	register_cvar( "rp_fine_forced", "0" );		// Force the player to pay the fine
	
	register_cvar( "rp_god_doors", "0" );		// Make doors unbrekable
	register_cvar( "rp_god_windows", "0" );		// Make windows unbrekable

	// Seven Eleven Robbing

	register_cvar( "rp_711_amount", "20" )		// While robbing how much money got from register per second 
	register_cvar( "rp_711_minium", "100" )		// Minium amount the register has to have so it can be robbed
	register_cvar( "rp_711_maxium", "200" )		// The maxium amount that can spawn into the register
	register_cvar( "rp_711_users", "6" )		// Amount of users on server to be able to rob
	register_cvar( "rp_711_spawn", "50" )		// How much money spawns per minute to the register

	// Diner Robbing

	register_cvar( "rp_diner_amount", "20" )	// While robbing how much money got from register per second
	register_cvar( "rp_diner_minium", "200" )	// Minium amount the register has to have so it can be robbed
	register_cvar( "rp_diner_maxium", "400" )	// The maxium amount that can spawn into the register
	register_cvar( "rp_diner_users", "6" )		// Amount of users on server to be able to rob
	register_cvar( "rp_diner_spawn", "50" )		// How much money spawns per minute to the register

	// Bank Robbing

	register_cvar( "rp_bank_mission_time", "300" )		// How many seconds to complete the mission (Seconds )
	register_cvar( "rp_bank_users", "8" )			// Amount of users on server to be able to rob
	register_cvar( "rp_bank_cops", "2" )			// Amount of cops on server to be able to rob
	register_cvar( "rp_bank_interval", "180" )		// Amount of minutes between robbing

	register_cvar( "rp_show_robber", "1" )			// Show who is robbing the 7/11, Diner or Bank


	// Register Touches
	register_touch("func_door_rotating","player","lockeddoortouch")
	register_touch("func_door","player","lockeddoortouch")
	register_touch("item_dropped","player","item_pickup")
	register_touch("money_pile","player","money_pickup")
	register_touch("bankrob","func_pushable","bankmoney")

	// Register Events
	register_event("DeathMsg","death_msg","a")
	register_event("TSMessage","msg_ts","b")


	// Registering Concmds
	register_concmd("amx_createmoney","admin_economy",ADMIN_IMMUNITY,"<name or #userid> <amount> - creates money for a player")
	register_concmd("amx_setmoney","admin_economy",ADMIN_IMMUNITY,"<name or #userid> <amount> - sets player balance")
	register_concmd("amx_destroymoney","admin_economy",ADMIN_IMMUNITY,"<name or #userid> <amount> - removes money from a player")
	register_concmd("amx_setjob","admin_economy",ADMIN_ALL,"<name or #userid> <job> - Set a job for a player")
	register_concmd("amx_employ","admin_economy",ADMIN_ALL,"<name or #userid> <job> - offer a player a job")

	register_concmd("amx_weaponspawn","spawn_command",ADMIN_IMMUNITY,"<weaponid> <clips> <flags> <Save 0 or 1> - creates weaponspawn underneath player")
	register_concmd("amx_removespawn","spawn_remove",ADMIN_IMMUNITY," - used for removing weaponspawns")
	
	register_concmd("amx_setcash711","set711cash",ADMIN_IMMUNITY,"<amount> - set the amount of money in the 711 cash register")
	register_concmd("amx_setcashdiner","setdinercash",ADMIN_IMMUNITY,"<amount> - set the amount of money in the Diner cash register")

	register_concmd("amx_regname","registername",ADMIN_ALL,"<name or #userid> <password> - register an account to use plugins")

	register_concmd("amx_addaccess","access_handle",ADMIN_ALL,"<name, steamid or regname> <NAME,STEAMID or REG> - add access to door")
	register_concmd("amx_removeaccess","access_handle",ADMIN_ALL,"<name, steamid or regname> <NAME,STEAMID or REG> - remove access to door")
	register_concmd("amx_ownername","access_edit",ADMIN_ALL,"<newtext> - change the owner text")
        register_concmd("amx_gangname","access_edit",ADMIN_ALL,"<newtext> - change the gangname text")
	register_concmd("amx_sell","access_edit",ADMIN_ALL,"<price> - sell a property you own")
	register_concmd("amx_cancel","access_edit",ADMIN_ALL,"- cancel the property you are selling")
	register_concmd("amx_profit","access_edit",ADMIN_ALL,"- take out profits from a commerical property")
	register_concmd("amx_lock","access_lock",ADMIN_ALL,"- set door to lock status")

	register_concmd("amx_setright","set_jobright",ADMIN_IMMUNITY,"<name or #userid> <JobFlag> - set a player's Job Right privileges")

	register_concmd("amx_additems","admin_items",ADMIN_IMMUNITY,"<name or #userid> <ItemID> <amount> - create an item for a player")
	register_concmd("amx_delitems","admin_items",ADMIN_IMMUNITY,"<name or #userid> <ItemID> <amount> - destroys an item from a player")

	register_concmd("amx_addjob","admin_addjob",ADMIN_BAN,"<JobID> <title> <salary> <JobRight> - Add job to database")
	register_concmd("amx_removejob","admin_removejob",ADMIN_BAN,"<JobID> - Remove a job from the database")
	register_concmd("amx_joblist","admin_listjobs",ADMIN_ALL,"- List all the jobs in the database")
	register_concmd("amx_itemlist","admin_listitems",ADMIN_ALL,"_ List all the items in the database")

	// Client Commands
	register_clcmd("say","say_handle")
	register_clcmd("say /help","help",0,"Opens up the help message for Harbus RP plugins")
	register_clcmd("say /buy","buystuff",-1,"Buys Stuff")
	register_clcmd("say /cuff","cuff",-1," - Cuff the person in your aim")
	register_clcmd("say /origin", "origin_bag")
	register_clcmd("say /hud", "hudonoff")
        register_clcmd("say /handsup","pshout_action")



	//Menu Registergs

	register_menucmd(register_menuid("Employment Offer"),1023,"action_employmentoffer")

	register_menucmd(register_menuid("Gunshop Main Menu"),1023,"Gunshop_Main_Action")
	register_menucmd(register_menuid("Gunshop - "),1023,"Gunshop_Weapon_Action")
	register_menucmd(register_menuid("Weapon Addons - "),1023,"Addons_Action")
	register_menucmd(register_menuid("Weapon Licenses"),1023,"Gunshop_License_Action")

	register_menucmd(register_menuid("ATM Menu"),1023,"actionMenuatm")
	register_menucmd(register_menuid("ATM Deposit"),1023,"actionMenudep")
	register_menucmd(register_menuid("ATM Withdraw"),1023,"actionMenuwit")


	register_menucmd(register_menuid("Inventory Menu"),1023,"action_itemmenu")
	register_menucmd(register_menuid("Item: "),1023,"action_item_use_menu")
	register_menucmd(register_menuid("NPC: "),1023,"shop_options_actions")
	register_menucmd(register_menuid("Items for Sale "),1023,"shop_show_action")
	register_menucmd(register_menuid("Nations Bank Employee"),1023,"bank_npc_action")
	register_menucmd(register_menuid("Prodigy Employee"),1023,"action_prodigy")
	register_menucmd(register_menuid("Prodigy Store"),1023,"Prodigy_Show_Action")

	register_menucmd(register_menuid("Deposit -"),1023,"Action_Amount_Menu")
	register_menucmd(register_menuid("Withdraw -"),1023,"Action_Amount_Menu")
	register_menucmd(register_menuid("Transfer -"),1023,"action_item_amount")
	register_menucmd(register_menuid("Drop -"),1023,"action_item_amount")

	register_menucmd(register_menuid("1337 Laptop"),1023,"action_leet_guess")
	register_menucmd(register_menuid("Ze Menu"),1023,"action_leet_menu")
	register_menucmd(register_menuid("MCPD Door Control"),1023,"leet_control_mcpd")

	register_menucmd( register_menuid( "Fine Order" ), 1023, "action_fine" );



	// Tasks
	set_task(600.0,"prodigytime",0,"",0,"b")
	set_task(120.0,"registerremind",0,"",0,"b")
	set_task(60.0,"fillregisters",0,"",0,"b")
        set_task(60.0,"hunger",0,"",0,"b")
	set_task(1.0,"sql_init")
	set_task(2.0,"salary",0,"",0,"b")
	set_task(5.0, "mcmdhealth",0,"",0,"b")
	set_task(2.0,"activehud",0,"",0,"b")
	set_task(1.0,"timer",0,"",0,"b")
	set_task(2.0,"playerlook",0,"",0,"b")

	server_cmd("exec addons/amxmodx/configs/HarbuRP/harbu_rp_config.cfg")
}

public hudonoff(id) {
	if(hudtog[id] == 0) {
		hudtog[id] = 1
		client_print(id,print_chat,"[AMXX] Economy HUD toggled OFF")
		set_hudmessage(get_cvar_num("rp_economyhud_red"),get_cvar_num("rp_economyhud_green"),get_cvar_num("rp_economyhud_blue"),get_cvar_float("rp_economyhud_pos_x"),get_cvar_float("rp_economyhud_pos_y"),0,0.0,99.9,0.0,0.0,1)
		show_hudmessage(id, "")
	}
	else {
		hudtog[id] = 0
		client_print(id,print_chat,"[AMXX] Economy HUD toggled ON")

	}
	return PLUGIN_HANDLED
}

public is_mcpd_job( id )
{
	new ret = 0;

	if((JobID3[id] >= mcpdjobs[0]) && (JobID3[id] <= mcpdjobs[1]))
	{
		ret = 1;
	}
	return ret;
}
	

public origin_bag( id )
{
	new Float:origin[3], Float:origin2[3]
	entity_get_vector(moneybag,EV_VEC_origin,origin)
	entity_get_vector(moneybag2,EV_VEC_origin,origin2)

	client_print( id, print_chat, "[ Test Mod ] %f %f %f - %f %f %f", origin[0], origin[1], origin[2], origin2[0], origin2[1], origin2[2] )

	origin[0] = 0.0
	origin[1] = 0.0
	origin[2] = 0.0

	origin2[0] = 0.0
	origin2[1] = 0.0
	origin2[2] = 0.0

	get_brush_entity_origin( moneybag, origin )
	get_brush_entity_origin( moneybag2, origin2 )

	client_print( id, print_chat, "[ Test Mod ] %f %f %f - %f %f %f", origin[0], origin[1], origin[2], origin2[0], origin2[1], origin2[2] )

	return PLUGIN_HANDLED
}

// Setting a origin variable ([3]) values from a cvar formated "x y z"
stock cvar_to_array(SzCvar[],length,origin[],dimension = 3)
{
	new output[6][32]
	get_cvar_string(SzCvar,SzCvar,length)
	explode(output,SzCvar,' ')
	for(new i=0;i < dimension;i++) {
	origin[i] = str_to_num(output[i])
	}
	return PLUGIN_HANDLED
}

// Close door when level starts (Specific for Mecklenburg_b8v6)
public closedoors(id)
{
	if(hasclosedoors == 1)
	{
		return PLUGIN_HANDLED
	}

	hasclosedoors = 1

	///////////////////////////////////
	// SETTING VALUES FOR ROB ENTITYS
	///////////////////////////////////

	new doorentbuf = get_maxplayers()
	new dinerdoor = 191 + doorentbuf
	moneybag = 58 + doorentbuf
	moneybag2 = 57 + doorentbuf

	//////////////////////////////////
	// REMOVING OBJECTS
	/////////////////////////////////


	////////////////////////////////////
	// SETTING SPEEDS AND MISC.
	///////////////////////////////////



	//////////////////////////////////////////////////
	// Setting Doors and other entites indistructuble
	//////////////////////////////////////////////////


	/////////////////////////////////////
	//	SETTING BANKROB ITEM
	/////////////////////////////////////


	get_brush_entity_origin( moneybag, borigin )
	get_brush_entity_origin( moneybag2, borigin2 )
	new bank = create_entity("info_target")

	if(!bank) {
		server_print("BANK ROB WAS not created. Error.^n")
		return PLUGIN_HANDLED
	}

	new Float:minbox[3] = { -50.0, -50.0, -50.0 }
	new Float:maxbox[3] = { 50.0, 50.0, 50.0 }

	entity_set_vector(bank,EV_VEC_mins,minbox)
	entity_set_vector(bank,EV_VEC_maxs,maxbox)

	entity_set_float(bank,EV_FL_dmg,0.0)
	entity_set_float(bank,EV_FL_dmg_take,0.0)
	entity_set_float(bank,EV_FL_max_health,99999.0)
	entity_set_float(bank,EV_FL_health,99999.0)

	entity_set_int(bank,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(bank,EV_INT_movetype,MOVETYPE_NONE)

	entity_set_string(bank,EV_SZ_classname,"bankrob")

	entity_set_origin(bank,positionrob)

	/////////////////////////////////////
	//	SETTING CVAR POSITIONS
	/////////////////////////////////////

	cvar_to_array("rp_position_gunshop",31,gunshop,3)

	cvar_to_array("rp_position_atmone",31,atmone,3)
	cvar_to_array("rp_position_atmtwo",31,atmtwo,3)
	cvar_to_array("rp_position_atmthree",31,atmthree,3)
	cvar_to_array("rp_position_atmfour",31,atmfour,3)
	cvar_to_array("rp_position_atmfive",31,atmfive,3)

	cvar_to_array("rp_position_jailone",31,jailone,3)
	cvar_to_array("rp_position_jailtwo",31,jailtwo,3)
	cvar_to_array("rp_position_jailthree",31,jailthree,3)
	cvar_to_array("rp_position_jailfour",31,jailfour,3)

	cvar_to_array("rp_position_uncuffzone_one",31,uncuffareaone,3)
	cvar_to_array("rp_position_uncuffzone_two",31,uncuffareatwo,3)

	cvar_to_array( "rp_position_storageone", 31, Storageone, 3 );
	cvar_to_array( "rp_position_storagetwo", 31, Storagetwo, 3 );
	cvar_to_array( "rp_position_storagethree", 31, Storagethree, 3 );
	cvar_to_array( "rp_position_storagefour", 31, Storagefour, 3 );
	cvar_to_array( "rp_position_storagefive", 31, Storagefive, 3 );

	cvar_to_array("rp_jobid_mafia",31,mafiajobs,2)
	cvar_to_array("rp_jobid_mcpd",31,mcpdjobs,2)
	cvar_to_array("rp_jobid_mcmd",31,mcmdjobs,2)
	cvar_to_array("rp_jobid_711",31,jobs711,2)
	
	///////////////////////////////////
	// Remove Veichles & Buttons on Map Start
	///////////////////////////////////
	if(get_cvar_num("rp_delete_vehicle") > 0)
	{
		for(new i = 0; i < entity_count() ; i++)
		{
			if(!is_valid_ent(i)) continue
			new text[32]
			entity_get_string(i,EV_SZ_classname,text,31)
			if(equali(text,"func_tracktrain")) remove_entity(i)
		}
	}

	if(get_cvar_num("rp_delete_button") > 0)
	{
		for(new i = 0; i < entity_count() ; i++)
		{
			if(!is_valid_ent(i)) continue
			new text[32]
			entity_get_string(i,EV_SZ_classname,text,31)
			if(equali(text,"func_button"))
			{
				new target[32], classname[32]
				entity_get_string(i,EV_SZ_target,target,31)
				new ent = find_ent_by_tname( -1, target )
				if(ent) entity_get_string(ent, EV_SZ_classname, classname, 31 );
				if( containi( classname, "door" ) != -1 ) {
					new omg[32]
					entity_get_string(ent,EV_SZ_targetname,omg,31)
					if(containi(omg,"ele") == -1) remove_entity(i)
				}
			}
		}
	}

	if( get_cvar_num("rp_god_doors") > 0 || get_cvar_num("rp_god_windows") > 0 )
	{
		new iEnts = entity_count()
		for(new i = 0; i < iEnts ; i++)
		{
			if(!is_valid_ent(i)) continue
			new text[32]
			entity_get_string(i,EV_SZ_classname,text,31)
			if( get_cvar_num("rp_god_doors") > 0 )
			{
				if( equali(text,"func_door" ) || equali(text,"func_door_rotating") ) set_entity_health(i,-1.0)
			}

			if( get_cvar_num("rp_god_windows") > 0 )
			{
				if(equali(text,"func_breakable") ) set_entity_health(i,-1.0)
			}
		}
	}



	////////////////////////////////////
	// Loading Weapons Spawns
	////////////////////////////////////
	if(dbc < SQL_OK) return PLUGIN_HANDLED
	new query[256]
	format(query,255,"SELECT * FROM weapons")
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new rows = dbi_num_rows(result)
		for(new i=0;i < rows;i++)
		{
			new WeaponID[32], ExtraClips[32], SpawnFlags[32], Float:Origin[3]

			dbi_field(result,1,WeaponID,31)
			dbi_field(result,2,ExtraClips,31)
			dbi_field(result,3,SpawnFlags,31)

			Origin[0] = float(dbi_field(result,4))
			Origin[1] = float(dbi_field(result,5))
			Origin[2] = float(dbi_field(result,6))

			ts_weaponspawn(WeaponID,"15",ExtraClips,SpawnFlags,Origin)	// Call Weaponspawn Creation Function
			dbi_nextrow(result)
		}
	}
	else dbi_free_result(result)

	return PLUGIN_HANDLED
}

// Check if origin and NPC are enough close
stock allowed_npc_distance(id,npcid)
{
	new origin[3], n_origin[3], query[256]
	get_user_origin(id,origin)
	format(query,255,"SELECT x,y,z FROM npc WHERE npcid=%i",npcid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		n_origin[0] = dbi_field(result,1)
		n_origin[1] = dbi_field(result,2)
		n_origin[2] = dbi_field(result,3)

		if(get_distance(origin,n_origin) <= 25.0) return 1

	}
	dbi_free_result(result)
	return 0
}

// Initializing the MySQL database sc delete mysql 
public sql_init()
{
	new host[64], username[33], password[32], dbname[32], error[32]
 	get_cvar_string("economy_mysql_host",host,64) 
    	get_cvar_string("economy_mysql_user",username,32) 
    	get_cvar_string("economy_mysql_pass",password,32) 
    	get_cvar_string("economy_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if (dbc == SQL_FAILED)
	{
		server_print("[HarbuRP] Could Not Connect To SQL Database^n")
	}
	else
	{
	server_print("[HarbuRP] Connected To SQL, Have A Nice Day!^n")
	}
}

// Buffer for checking the say commands
public say_handle(id)
{
	new buffer[256], buffer1[33], buffer2[33], buffer3[33], origin[3]
	get_user_origin(id,origin)
	read_argv(1,buffer,255)
	parse(buffer, buffer1, 32, buffer2, 32, buffer3, 32)
	if(equali(buffer1,"givemoney") || equali(buffer1,"/givemoney"))
	{
		user_givemoney(id,str_to_num(buffer2))
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/usedoor") || equali(buffer1,"/trigger"))
	{
		targetdoor(id)
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/transfer") || equali(buffer1,"transfer"))
	{
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two"))) user_transfer(id,buffer2,str_to_num(buffer3))
		else client_print(id,print_chat,"[EconomyMod] You need to be facing a Bank Employee^n")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/uncuff"))
	{
		cuff(id)
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/ent"))
	{
		checkenitynumber(id)
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/showcommands"))
	{
		motd_show(id,"rp_commands")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/laws"))
	{
		motd_show(id,"rp_laws")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/rules"))
	{
		motd_show(id,"rp_rules")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/deposit"))
	{
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two"))) bankfunction(id,str_to_num(buffer2),1)
		else client_print(id,print_chat,"[EconomyMod] You need to be facing a Bank Employee^n")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/withdraw"))
	{
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two"))) bankfunction(id,str_to_num(buffer2),2)
		else client_print(id,print_chat,"[EconomyMod] You need to be facing a Bank Employee^n")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/items") || equali(buffer1,"/inventory"))
	{
		build_itemmenu(id,0)
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/unemployme"))
	{
		edit_value(id,"money","jobid","=",0)
		JobID3[id] = 0
		client_print(id,print_chat,"[EconomyMod] You have quit your job, you are now unemployed again^n")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/motd"))
	{
		show_motd(id,"motd.txt","Welcome to Red Dragon RP")
		return PLUGIN_HANDLED
	}
	if( equali( buffer1, "/fine" ) )
	{
		func_fine( id, str_to_num( buffer2 ) )
		return PLUGIN_HANDLED
	}
        if(equali(buffer1,"/wprices"))
	{
		show_motd(id,"wprices.txt","Weaponspawn Pricelist")
		return PLUGIN_HANDLED
	}
	if(equali(buffer1,"/drop"))
	{
		user_drop_money(id,str_to_num(buffer2))
	}
	        return PLUGIN_CONTINUE 
}
	

// Function for adding/subtracting money from your wallet and Bank balance
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

// Find user from database, must be registerd a playername
public is_user_database(id)
{
	if(dbc < SQL_OK) return 0
	new authid[32], query[256]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_free_result(result)
		return 1
	}
	else dbi_free_result(result)
	return 0
}

// Check the amount of the specified item
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
				amount = str_to_num(output2[1])
				return amount
			}
		}
	}
	else dbi_free_result(result)
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
					return PLUGIN_HANDLED
				}
			}
		}
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}



// Used for Creating/Deleting/Setting players balances and setting jobs
public admin_economy(id)
{
	new authid[32], command[32], arg[32], arg2[32], name[33], value
	read_argv(0,command,31)
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	if(!equali(command,"amx_setjob") && !equali(command,"amx_employ"))
	{
		if(!(get_user_flags(id) & ADMIN_IMMUNITY))
		{
			client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
			return PLUGIN_HANDLED
		}
	}
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	get_user_authid(targetid,authid,31)
	get_user_name(targetid,name,sizeof(name))
	value = str_to_num(arg2)
	if(is_user_database(targetid) == 0)
	{
		client_print(id,print_console,"Players registaration information does not exist in database^n")
		return PLUGIN_HANDLED
	}
	if(equali(arg,"") || equali(arg2,""))
	{
		if(equali(command,"amx_setjob") || equali(command,"amx_employ"))
		{
			client_print(id,print_console,"Usage:  %s <name or #userid> <jobID>^n",command)
			return PLUGIN_HANDLED
		}
		client_print(id,print_console,"Usage:  %s <name or #userid> <amount>^n",command)
		return PLUGIN_HANDLED
	}
	if(value <= -1 && !equali(command,"amx_setjob") && !equali(command,"amx_employ"))
	{
		client_print(id,print_console,"Amount can not be a negative value^n")
		return PLUGIN_HANDLED
	}
	if(equali(command,"amx_createmoney"))
	{
		edit_value(targetid,"money","balance","+",value)
		balance3[id] += value;
		client_print(id,print_console,"[AMXX] Created $%i for %s^n",value,name)
		client_print(targetid,print_chat,"[EconomyMod] You have received $%i from an admin^n",value)
	}
	if(equali(command,"amx_destroymoney"))
	{
		edit_value(targetid,"money","balance","-",value)
		balance3[id] -= value;
		client_print(id,print_console,"[AMXX] Removed $%i from player %s balance^n",value,name)
		client_print(targetid,print_chat,"[EconomyMod] An admin has removed $%i from your balance^n",value)
	}
	if(equali(command,"amx_setmoney"))
	{
		edit_value(targetid,"money","balance","=",value)
		balance3[id] = value;
		client_print(id,print_console,"[AMXX] Set player %s balance to $%i^n",name,value)
		client_print(targetid,print_chat,"[EconomyMod] Your balance has been set to $%i by a admin^n",value)
	}
	if(equali(command,"amx_setjob") || equali(command,"amx_employ"))
	{
		if(is_user_database(id) == 0)
		{
			print_text(id)
			client_print(id,print_console,"Your registaration information was not found in database^n")
			return PLUGIN_HANDLED
		}
		new query[256], myauthid[32], myname[33]
		get_user_authid(id,myauthid,31)
		get_user_name(id,myname,sizeof(myname))
		new JobName[32], Acess[32]
		format(query,255,"SELECT JobName,access FROM jobs WHERE JobID=%i",value)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			dbi_field(result,1,JobName,31)
			dbi_field(result,2,Acess,31)
			dbi_free_result(result)
		}
		else {
			dbi_free_result(result)
			client_print(id,print_console,"[AMXX] That jobid is not registered with a job^n")
			return PLUGIN_HANDLED
		}
		format(query,255,"SELECT JobRight FROM money WHERE steamid='%s'",myauthid)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new JobRight[32]
			dbi_field(result,1,JobRight,31)
			dbi_free_result(result)
			if(value == 0)
			{
				format(query,255,"SELECT Access FROM jobs WHERE JobID=%i",JobID3[id])
				result = dbi_query(dbc,query)
				if(dbi_nextrow(result) > 0)
				{
					new Currentaccess[32]
					dbi_field(result,1,Currentaccess,31)
					dbi_free_result(result)
					if(equali(JobRight,"")) {
						client_print(id,print_console,"[AMXX] You don't have access to unemploy this player^n")
						return PLUGIN_HANDLED
					}
					if(equali(Currentaccess,JobRight) || equali(JobRight,"Z"))
					{
						edit_value(targetid,"money","jobid","=",value)
						client_print(id,print_console,"[AMXX] You set %s job to Unemployed! (JobID = %i)^n",name,value)
						client_print(targetid,print_chat,"[EconomyMod] Player %s fired you!^n",myname)
						JobID3[targetid] = value;
						log_amx("[Harbu RP Log] Player's %s Job was changed to unemployed (JobID = 0), by %s (SteamID: %s)",name,myname,myauthid)
						return PLUGIN_HANDLED
					}
					else
					{
						client_print(id,print_console,"[AMXX] You don't have access to unemploy this player^n")
						return PLUGIN_HANDLED
					}
				}
				else dbi_free_result(result)
			}
			else
			{
				if(equali(command,"amx_setjob"))
				{
					if(equali(JobRight,"Z"))
					{
						edit_value(targetid,"money","jobid","=",value)
						JobID3[targetid] = value
						client_print(id,print_console,"[AMXX] You set %s job to %s! (JobID = %i)^n",name,JobName,value)
						client_print(targetid,print_chat,"[EconomyMod] Player %s changed your job to %s!^n",myname,JobName)
						log_amx("[Harbu RP Log] Player's %s Job was changed to %s (JobID = %i), by %s (SteamID: %s)",name,JobName,value,myname,myauthid)
						return PLUGIN_HANDLED
					}
					else
					{
						client_print(id,print_console,"[AMXX] You don't have access to set that job^n")
						return PLUGIN_HANDLED
					}
				}
				if(equali(command,"amx_employ"))
				{
					if(equali(Acess,JobRight) || equali(JobRight,"Z"))
					{
						employmentoffer(id,targetid,value)
						client_print(id,print_console,"[AMXX] Sent employment offer to player %s ...^n",name)
						return PLUGIN_HANDLED
					}
					else
					{
						client_print(id,print_console,"[AMXX] You don't have access to offer that job^n")
						return PLUGIN_HANDLED
					}
				}
			}
		}
		else dbi_free_result(result)
	}	
	return PLUGIN_HANDLED
}

// Setting a players JobRights
public set_jobright(id)
{
	new arg[32], arg2[32], query[256], authid[32], name[33], tname[33]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	new authlol[32]
	get_user_authid(id,authlol,31)
	if((get_user_flags(id) & ADMIN_IMMUNITY))
	{
		if(equali(arg,"") || equali(arg2,""))
		{
			client_print(id,print_console,"Usage:  amx_setright <name or #userid> <JobFlag>^n")
			return PLUGIN_HANDLED
		}
		new tid = cmd_target(id,arg,0)
		if(!tid) return PLUGIN_HANDLED
		get_user_authid(tid,authid,31)
		get_user_name(id,name,sizeof(name))
		get_user_name(tid,tname,sizeof(tname))
		format(query,255,"UPDATE money SET JobRight='%s' WHERE steamid='%s'",arg2,authid)
		dbi_query(dbc,query)

		client_print(id,print_console,"[AMXX] Set %s JobRight to Flag %s^n",tname,arg2)
		client_print(tid,print_chat,"[EconomyMod] Your JobRight was set to %s by %s^n",arg2,name)
	}
	else {
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

new page[33]
public admin_listjobs(id)
{
	new query[256]
	format(query,255,"SELECT * FROM jobs ORDER BY JobID LIMIT 0,100")
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		dbi_free_result(result)
		client_print(id,print_console,"[AMXX] Error querying info from the MySQL Database^n")
		return PLUGIN_HANDLED
	}

	new rows = dbi_num_rows(result)
	client_print(id,print_console,"JobID	Title		Salary	Access - PAGE 1^n")
	for(new i = 0; i < rows; i++)
	{
		new JobID, title[32], p_salary, sz_access[32]
		JobID = dbi_field(result,1)
		dbi_field(result,2,title,31)
		p_salary = dbi_field(result,3)
		dbi_field(result,4,sz_access,31)

		client_print(id,print_console,"%i	%s		%i	%s^n",JobID,title,p_salary,sz_access)
		dbi_nextrow(result)
	}
	client_print(id,print_console,"ROWS SHOWN: %i^n",rows)
	if(rows >= 100) {
		page[id]++
		set_task(0.5,"nextjobpage",id)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public nextjobpage(id) {
	new query[256]
	if(page[id] == 1) format(query,255,"SELECT * FROM jobs ORDER BY JobID LIMIT 100,200")
	else if(page[id] == 2) format(query,255,"SELECT * FROM jobs ORDER BY JobID LIMIT 200,300")
	else if(page[id] == 3) format(query,255,"SELECT * FROM jobs ORDER BY JobID LIMIT 300,400")
	else return PLUGIN_HANDLED
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		dbi_free_result(result)
		client_print(id,print_console,"[AMXX] Error querying info from the MySQL Database^n")
		return PLUGIN_HANDLED
	}

	new rows = dbi_num_rows(result)
	client_print(id,print_console,"^nJobID	Title		Salary	Access - PAGE %i^n",page[id]+1)
	for(new i = 0; i < rows; i++)
	{
		new JobID, title[32], p_salary, sz_access[32]
		JobID = dbi_field(result,1)
		dbi_field(result,2,title,31)
		p_salary = dbi_field(result,3)
		dbi_field(result,4,sz_access,31)

		client_print(id,print_console,"%i	%s		%i	%s^n",JobID,title,p_salary,sz_access)
		dbi_nextrow(result)
	}
	client_print(id,print_console,"ROWS SHOWN: %i^n",rows)
	if(rows >= 100) {
		page[id]++
		set_task(0.5,"nextjobpage",id)
	}
	else page[id] = 0
	dbi_free_result(result)
	return PLUGIN_HANDLED
}

public admin_removejob(id)
{

	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}

	new arg[32], JobID, query[256]
	read_argv(1,arg,31)
	JobID = str_to_num(arg)

	if(JobID == 0) {
		client_print(id,print_console,"Usage:  amx_removejob <JobID>^n")
		return PLUGIN_HANDLED
	}
	
	format(query,255,"SELECT JobName FROM jobs WHERE JobID=%i",JobID)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		dbi_free_result(result)
		client_print(id,print_console,"[AMXX] No job registered with JobID %i^n",JobID)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	format(query,255,"DELETE FROM jobs WHERE JobID=%i",JobID)
	dbi_query(dbc,query)
	client_print(id,print_console,"[AMXX] Removed Job with JobID %i^n",JobID)
	return PLUGIN_HANDLED
}

public admin_addjob(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}

	new arg[32], title[32], arg3[32], JobRight[32], JobID, p_salary, query[256]

	read_argv(1,arg,31)
	read_argv(2,title,31)
	read_argv(3,arg3,31)
	read_argv(4,JobRight,31)

	JobID = str_to_num(arg)
	p_salary = str_to_num(arg3)

	if(JobID == 0 || p_salary == 0 || equali(JobRight,"") || equali(title,""))
	{
		client_print(id,print_console,"Usage:  amx_addjob <JobID> <title> <salary> <JobRight>^n")
		return PLUGIN_HANDLED
	}

	format(query,255,"SELECT JobName FROM jobs WHERE JobID=%i",JobID)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		client_print(id,print_console,"[AMXX] This JobID is already in use by another job^n")
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	format(query,255,"INSERT INTO jobs (JobID,JobName,Salary,Access) VALUES('%i','%s','%i','%s')",JobID,title,p_salary,JobRight)
	dbi_query(dbc,query)
	client_print(id,print_console,"[AMXX] Job was added to the database^n")
	return PLUGIN_HANDLED
}

	

// Showing the Job Ask menu
public employmentoffer(id,targetid,JobID)
{
	new name[33], query[256], JobName[32], offer_salary
	get_user_name(id,name,sizeof(name))
	format(query,255,"SELECT JobName,Salary FROM jobs WHERE JobID=%i",JobID)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,JobName,31)
		offer_salary = dbi_field(result,2)
		dbi_free_result(result)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	new employbody[256]
	new key = (1<<0|1<<1)

	new len = format(employbody,255,"Employment Offer^n^n")
	len += format(employbody[len],255-len,"Offerer: %s^n",name)
	len += format(employbody[len],255-len,"Title: %s^n",JobName)
	len += format(employbody[len],255-len,"Salary: $%i^n^n",offer_salary)

	add(employbody,sizeof(employbody),"1. Accept^n")
	add(employbody,sizeof(employbody),"2. Decline^n")

	g_jobid[targetid] = JobID
	g_employer[targetid] = id
	show_menu(targetid,key,employbody)
	return PLUGIN_HANDLED
}

public action_employmentoffer(id,key)
{
	new name[33], employername[33], employerauthid[32], offer_salary
	get_user_name(g_employer[id],employername,sizeof(employername))
	get_user_name(id,name,sizeof(name))
	get_user_authid(g_employer[id],employerauthid,31)
	if(key == 0)
	{
		new query[256], JobName[32]
		edit_value(id,"money","jobid","=",g_jobid[id])
		JobID3[id] = g_jobid[id]
		format(query,255,"SELECT JobName,Salary FROM jobs WHERE JobID=%i",g_jobid[id])
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			dbi_field(result,1,JobName,31)
			offer_salary = dbi_field(result,2)
			dbi_free_result(result)
		}
		else {
			dbi_free_result(result)
			return PLUGIN_HANDLED
		}

		client_print(id,print_chat,"[EconomyMod] You are now employed as %s with a salary of $%i/Hour^n",JobName,offer_salary)
		client_print(g_employer[id],print_console,"[AMXX] Player %s accepted your employment offer^n",name)
		log_amx("[Harbu RP Log] Player's %s Job was changed to %s (JobID = %i), by %s (SteamID: %s) via a employment offer!",name,JobName,g_jobid[id],employername,employerauthid)
	}
	else
	{
		client_print(id,print_chat,"[EconomyMod] You declined the employment offer^n")
		client_print(g_employer[id],print_console,"[AMXX] Player %s declined your employment offer^n",name)
	}
	return PLUGIN_HANDLED
}




// Giving money to another player via looking at other person
public user_givemoney(id,amount)
{
	new name[33], entid, entbody, name2[33]
	get_user_aiming(id,entid,entbody,100)
	if(!is_user_connected(entid)) {
		client_print(id,print_chat,"[EconomyMod] You are not looking at another player^n")
		return PLUGIN_HANDLED
	}
	get_user_name(id,name,sizeof(name))
	get_user_name(entid,name2,sizeof(name2))
	if(!amount || amount <= 0) {
		client_print(id,print_chat,"[EconomyMod] Usage:  /givemoney <amount>^n")
		return PLUGIN_HANDLED
	}
	if(wallet3[id] < amount) {
		client_print(id,print_chat,"[EconomyMod] You don't have that much in your wallet^n")
		return PLUGIN_HANDLED
	}
	if((wallet3[entid] + amount) > get_cvar_num("rp_walletlimit")) {
		client_print(id,print_chat,"[EconomyMod] Cant send because player will have over the maxium %i in his wallet^n",get_cvar_num("rp_walletlimit"))
		return PLUGIN_HANDLED
	}

	edit_value(id,"money","wallet","-",amount)
	wallet3[id] -= amount
	edit_value(entid,"money","wallet","+",amount)
	wallet3[entid] += amount

	client_print( entid, print_notify, "[EconomyMod] You have received $%i from %s.^n", amount, name)
	client_print( id, print_notify,"[EconomyMod] You have given $%i to %s.^n", amount, name2)
	client_print( entid, print_chat, "[EconomyMod] You have received $%i from %s.^n", amount, name)
	client_print( id, print_chat,"[EconomyMod] You have given $%i to %s.^n", amount, name2)
	return PLUGIN_HANDLED
}

// Transfering cash through bank
public user_transfer(id,targname[],amount)
{
	if(cuffed[id] == 1) {
		client_print(id,print_chat,"[EconomyMod] You can't transfer when cuffed^n")
		return PLUGIN_HANDLED
	}
	new targetid, name[33], name2[33], authid[32], authid2[32], query[256], origin[3]
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two")))
	{
		targetid = cmd_target(id,targname,0)
		if(!targetid || targetid == id) return PLUGIN_HANDLED

		get_user_name(id,name,sizeof(name))
		get_user_name(targetid,name2,sizeof(name2))
		get_user_authid(id,authid,31)
		get_user_authid(targetid,authid2,31)

		new balance
		format( query, 255, "SELECT balance FROM money WHERE steamid='%s'", authid)
		result = dbi_query( dbc, query)
		if( dbi_nextrow( result ) > 0 )
		{
			balance = dbi_field(result,1)
			dbi_free_result(result)
		}
		else {
			dbi_free_result(result)
			return PLUGIN_HANDLED
		}

		if(!amount || amount <= 0) {
			client_print(id,print_chat,"[EconomyMod] Usage:  /transfer <name> <amount>^n")
			return PLUGIN_HANDLED
		}
		if(balance < amount) {
			client_print(id,print_chat,"[EconomyMod] You don't have that much in your balance^n")
			return PLUGIN_HANDLED
		}

		edit_value(id,"money","balance","-",amount)
		edit_value(targetid,"money","balance","+",amount)

		client_print( targetid, print_notify, "[EconomyMod] Player %s transferred you $%i^n", name, amount)
		client_print( id, print_notify,"[EconomyMod] You have transferred %i for %s^n", amount, name2)
		client_print( targetid, print_chat, "[EconomyMod] Player %s transferred you $%i^n", name, amount)
		client_print( id, print_chat,"[EconomyMod] You have transferred %i for %s^n", amount, name2)
		return PLUGIN_HANDLED
	}
	else
	{
		client_print(id,print_chat,"[EconomyMod] You have to be facing a Bank Employee to transfer money^n")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

// When player drops money on the ground
public user_drop_money(id,amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(is_user_database(id) == 0) {
		print_text(id)
		return PLUGIN_HANDLED
	}
	if(amount <= 0) {
		client_print(id,print_chat,"[EconomyMod] Usage:  /drop <amount>^n")
		return PLUGIN_HANDLED
	}

	new origin[3], authid[32], query[256], wallet, Float:forigin[3]
	get_user_origin(id,origin)
	get_user_authid(id,authid,31)

	format(query,255,"SELECT wallet FROM money WHERE steamid='%s'",authid)
	result = dbi_query( dbc, "%s",query)
	if( dbi_nextrow( result ) <= 0 ) {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	wallet = dbi_field(result,1)
	dbi_free_result(result)
	if(amount > wallet) {
		client_print(id,print_chat,"[EconomyMod] You don't have enough money in your wallet!")
		return PLUGIN_HANDLED
	}
	new ent = create_entity("info_target")
	if(!ent) return PLUGIN_HANDLED

	IVecFVec(origin,forigin)

	new Float:minbox[3] = { -2.5, -2.5, -2.5 }
	new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
	new Float:angles[3] = { 0.0, 0.0, 0.0 }

	angles[1] = float(random_num(0,270))

	entity_set_vector(ent,EV_VEC_mins,minbox)
	entity_set_vector(ent,EV_VEC_maxs,maxbox)
	entity_set_vector(ent,EV_VEC_angles,angles)

	entity_set_float(ent,EV_FL_dmg,0.0)
	entity_set_float(ent,EV_FL_dmg_take,0.0)
	entity_set_float(ent,EV_FL_max_health,99999.0)
	entity_set_float(ent,EV_FL_health,99999.0)

	entity_set_int(ent,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(ent,EV_INT_movetype,MOVETYPE_TOSS)

	
	new moneystr[32]
	num_to_str(amount,moneystr,31)
	entity_set_string(ent,EV_SZ_targetname,moneystr)
	entity_set_string(ent,EV_SZ_classname,"money_pile")

	entity_set_model(ent,"models/money.mdl")
	entity_set_origin(ent,forigin)
	picktimeout[id] = 1
	edit_value(id,"money","wallet","-",amount)
	set_task(5.0, "untimeout", id)
	client_print(id,print_chat,"[EconomyMod] You dropped $%i on the ground",amount)
	return PLUGIN_HANDLED
}
public untimeout(id)
{
	picktimeout[id] = 0
	return PLUGIN_HANDLED;
}
// When a user pickups a money pile
public money_pickup(ent,id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(is_user_database(id) == 0) {
		print_text(id)
		return PLUGIN_HANDLED
	}
	if(picktimeout[id] == 1)
	{
		return PLUGIN_HANDLED;
	}
	new str[32], amount
	entity_get_string(ent,EV_SZ_targetname,str,31)
	amount = str_to_num(str)
	edit_value(id,"money","wallet","+",amount)
	remove_entity(ent)
	client_print(id,print_chat,"[EconomyMod] Picked up $%i",amount)
	return PLUGIN_HANDLED
}
	
//////////////////////////////////////////
//		SQL Gunshop
/////////////////////////////////////////

// Gunshop Main Menu
public Gunshop_Main(id)
{
	if(is_user_database(id) == 0) {
		print_text(id)
		return PLUGIN_HANDLED
	}
	new menu[256], origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<9)
	new len = format(menu,sizeof(menu),"Gunshop Main Menu^n^n")

	len += format(menu[len],sizeof(menu)-len,"1. Pistols^n")
	len += format(menu[len],sizeof(menu)-len,"2. Sub-Machine Guns^n")
	len += format(menu[len],sizeof(menu)-len,"3. Shotguns^n")
	len += format(menu[len],sizeof(menu)-len,"4. Rifles^n")
	len += format(menu[len],sizeof(menu)-len,"5. Heavy Weapons^n")
	len += format(menu[len],sizeof(menu)-len,"6. Special Weapons^n^n")

	len += format(menu[len],sizeof(menu)-len,"7. Refill Ammo ($%i)^n",get_cvar_num("rp_gunrefillprice"))
	len += format(menu[len],sizeof(menu)-len,"8. Licenses^n^n")

	len += format(menu[len],sizeof(menu)-len,"0. Close Menu^n")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public Gunshop_Main_Action(id,key)
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	if(key == 0) {
		if(get_item_amount(id,get_cvar_num("rp_license_pistol_id"),"money")) Gunshop_Weapon(id,"Pistol")
		else client_print(id,print_chat,"[GunShop] You need a pistol license to buy pistols")
	}
	if(key == 1) {
		if(get_item_amount(id,get_cvar_num("rp_license_sub_id"),"money")) Gunshop_Weapon(id,"Sub-Machinegun")
		else client_print(id,print_chat,"[GunShop] You need a sub-machine license to buy sub-machine guns")
	}
	if(key == 2) {
		if(get_item_amount(id,get_cvar_num("rp_license_shotgun_id"),"money")) Gunshop_Weapon(id,"Shotgun")
		else client_print(id,print_chat,"[GunShop] You need a shotgun license to buy shotguns")
	}
	if(key == 3) {
		if(get_item_amount(id,get_cvar_num("rp_license_rifle_id"),"money")) Gunshop_Weapon(id,"Rifle")
		else client_print(id,print_chat,"[GunShop] You need a rifle license to buy rifles")
	}
	if(key == 4) {
		if(get_item_amount(id,get_cvar_num("rp_license_heavy_id"),"money")) Gunshop_Weapon(id,"Heavy")
		else client_print(id,print_chat,"[GunShop] You need a heavy weapon license to buy heavy weapons")
	}
	if(key == 5) Gunshop_Weapon(id,"Special")
	if(key == 6) Gunshop_Ammo(id)
	if(key == 7) Gunshop_License(id)
	return PLUGIN_HANDLED
}

// A Specific Weapon Menu, Building and Showing
public Gunshop_Weapon(id,type[])
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	for(new i=0;i < 10;i++)
	{
		g_itemholder[id][i][0] = 0
		g_itemholder[id][i][1] = 0
		g_itemholder[id][i][2] = 0
	}
	new body[256], query[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new len = format(body,sizeof(body),"Gunshop - %ss ^n^n",type)
	format(query,255,"SELECT weaponid,name,price,banned FROM gunshop WHERE type='%s'",type)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new rows = dbi_num_rows(result)
		for(new i=0;i < rows;i++)
		{
			new name[33]
			g_itemholder[id][i][0] = dbi_field(result,1)
			dbi_field(result,2,name,sizeof(name))
			g_itemholder[id][i][1] = dbi_field(result,3)
			g_itemholder[id][i][2] = dbi_field(result,4)
			len += format(body[len],sizeof(body)-len,"%i. %s ($%i)^n",i+1,name,g_itemholder[id][i][1])
			dbi_nextrow(result)
		}
		dbi_free_result(result)
		add(body,sizeof(body),"^n0.Previous Menu")
		show_menu(id,key,body)
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

public Gunshop_Weapon_Action(id,key)
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	if(key > 8) {
		Gunshop_Main(id)
		return PLUGIN_HANDLED
	}
	Purchase_Weapon(id,g_itemholder[id][key][0],g_itemholder[id][key][1],g_itemholder[id][key][2],1)
	return PLUGIN_HANDLED
}

// The actual buying of a Weapon or showing the addons menu
public Purchase_Weapon(id,weaponid,price,banned,scene)
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	chosenweapon[id][0] = weaponid
	chosenweapon[id][1] = price
	chosenweapon[id][2] = banned
	
	if(banned == 1) {
		client_print(id,print_chat,"[GunShop] The weapon is currently banned^n")
		return PLUGIN_HANDLED
	}
	new buffer[64], wallet, authid[32], query[256], bullets, silencer, laser, flash, scope
	get_user_authid(id,authid,31)
	select_string(id,"money","wallet","steamid",authid,buffer)
	wallet = str_to_num(buffer)
	if(wallet < price) {
		client_print(id,print_chat,"[GunShop] You can't afford the selected weapon^n")
		return PLUGIN_HANDLED
	}
	format(query,255,"SELECT bullets,silencer,laser,flash,scope FROM gunshop WHERE weaponid=%i",weaponid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		bullets = dbi_field(result,1)
		silencer = dbi_field(result,2)
		laser = dbi_field(result,3)
		flash = dbi_field(result,4)
		scope = dbi_field(result,5)
		dbi_free_result(result)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	if(scene == 1)
	{
		if(silencer == 1 || laser == 1 || flash == 1 || scope == 1)
		{
			for(new i=0;i < 5;i++) addons[id][i] = 0
			new body[256], name[33]
			new key = (1<<0|1<<1|1<<2|1<<3|1<<9)
			xmod_get_wpnname(weaponid,name,sizeof(name)) 
			new len = format(body,sizeof(body),"Weapon Addons - %s ^n^n",name)

			if(silencer == 1) {
				len += format(body[len],sizeof(body)-len,"1. Silencer ($2)^n")
				addons[id][1] = 1
			}
			if(laser == 1) {
				len += format(body[len],sizeof(body)-len,"2. Laser ($2)^n")
				addons[id][2] = 2
			}
			if(flash == 1) {
				len += format(body[len],sizeof(body)-len,"3. Flashlight ($2)^n")
				addons[id][3] = 4
			}
			if(scope == 1) {		
				len += format(body[len],sizeof(body)-len,"4. Scope ($3)^n")
				addons[id][4] = 8
			}
			add(body,sizeof(body),"^n0. Finish^n")
			show_menu(id,key,body)
			return PLUGIN_HANDLED
		}
		else
		{
			new name[33]
			xmod_get_wpnname(weaponid,name,sizeof(name))
			edit_value(id,"money","wallet","-",price)
			wallet3[id] -= price;
			ts_giveweapon(id,weaponid,bullets,0)
			client_print(id,print_chat,"[GunShop] Purchased %s for $%i^n",name,price)
			return PLUGIN_HANDLED
		}
	}
	if(scene == 2)
	{
		if(!addons[id][1] && !addons[id][2] && !addons[id][3] && !addons[id][4]) {
			Purchase_Weapon(id,chosenweapon[id][0],chosenweapon[id][1],chosenweapon[id][2],3)
			return PLUGIN_HANDLED
		}
		new body[256], name[32]
		new key = (1<<0|1<<1|1<<2|1<<3|1<<9)
		xmod_get_wpnname(weaponid,name,sizeof(name)) 
		new len = format(body,sizeof(body),"Weapon Addons - %s^n^n",name)
		if(addons[id][1]) {
			len += format(body[len],sizeof(body)-len,"1. Silencer ($2)^n")
		}
		if(addons[id][2]) {
			len += format(body[len],sizeof(body)-len,"2. Laser ($2)^n")
		}
		if(addons[id][3]) {
			len += format(body[len],sizeof(body)-len,"3. Flashlight ($2)^n")
		}
		if(addons[id][4]) {			
			len += format(body[len],sizeof(body)-len,"4. Scope ($3)^n")
		}
		add(body,sizeof(body),"^n0. Finish^n")
		show_menu(id,key,body)
		return PLUGIN_HANDLED
	}
	if(scene == 3)
	{
		new name[33]
		xmod_get_wpnname(weaponid,name,sizeof(name))
		edit_value(id,"money","wallet","-",price)
		wallet3[id] -= price;
		ts_giveweapon(id,weaponid,bullets,addons[id][0])
		client_print(id,print_chat,"[GunShop] Purchased %s for $%i^n",name,price)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
		
}

// Addons Action
public Addons_Action(id,key)
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	if(key == 9) Purchase_Weapon(id,chosenweapon[id][0],chosenweapon[id][1],chosenweapon[id][2],3)
	else
	{
		if(addons[id][key+1] > 0) {
			if(key+1 == 4) chosenweapon[id][2] += 3
			else chosenweapon[id][2] +=2
			addons[id][0] += addons[id][key+1]
			addons[id][key+1] = 0
			Purchase_Weapon(id,chosenweapon[id][0],chosenweapon[id][1],chosenweapon[id][2],2)
		}
		else Purchase_Weapon(id,chosenweapon[id][0],chosenweapon[id][1],chosenweapon[id][2],2)
	}
	return PLUGIN_HANDLED
}

// Buying weapon ammunation
public Gunshop_Ammo(id)
{
	new weaponid, ammo, clip, mode, extra
	weaponid = ts_getuserwpn(id,clip,ammo,mode,extra)
	if(weaponid == 0 || weaponid == 36)
	{
		client_print(id,print_chat,"[GunShop] You need to be wieliding a weapon to buy ammo for it^n")
		Gunshop_Main(id)
		return PLUGIN_HANDLED
	}
	new check, buffer[64], maxammo, wallet, authid[32], weaponame[64]
	if(weaponid == 24 || weaponid == 25 || weaponid == 35) check = clip
	else check = ammo

	num_to_str(weaponid,buffer,63)
	select_string(id,"gunshop","maxium","weaponid",buffer,buffer)
	select_string(id,"gunshop","name","weaponid",buffer,weaponame)
	maxammo = str_to_num(buffer)

	if(check >= maxammo)
	{
		client_print(id,print_chat,"[GunShop] You have already full ammo for this gun^n")
		Gunshop_Main(id)
		return PLUGIN_HANDLED
	}

	get_user_authid(id,authid,31)
	select_string(id,"money","wallet","steamid",authid,buffer)
	wallet = str_to_num(buffer)
	if(wallet < get_cvar_num("rp_gunrefillprice"))
	{
		client_print(id,print_chat,"[GunShop] You don't have enough money in your wallet^n")
		return PLUGIN_HANDLED
	}
	edit_value(id,"money","wallet","-",get_cvar_num("rp_gunrefillprice"))
	wallet3[id] -= get_cvar_num("rp_gunrefillprice");
	client_print(id,print_chat,"[GunShop] Your weapon has been refilled!^n")

	ts_setuserammo(id,weaponid,maxammo)
	return PLUGIN_HANDLED
}

public Gunshop_License(id)
{
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED
	new menu[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9)
	new len = format(menu,sizeof(menu),"Weapon Licenses^n^n")

	len += format(menu[len],sizeof(menu)-len,"1. Pistol License ($%i)^n",get_cvar_num("rp_license_pistol"))
	len += format(menu[len],sizeof(menu)-len,"2. Sub-Machine License ($%i)^n",get_cvar_num("rp_license_sub"))
	len += format(menu[len],sizeof(menu)-len,"3. Shotgun License ($%i)^n",get_cvar_num("rp_license_shotgun"))
	len += format(menu[len],sizeof(menu)-len,"4. Rifle License ($%i)^n",get_cvar_num("rp_license_rifle"))
	len += format(menu[len],sizeof(menu)-len,"5. Heavy Weapon License ($%i)^n",get_cvar_num("rp_license_heavy"))
	len += format(menu[len],sizeof(menu)-len,"^n0. Close Menu^n")

	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public Gunshop_License_Action(id,key)
{
	if(key == 9) return PLUGIN_HANDLED
	new origin[3], price, itemid, authid[32]
	get_user_origin(id,origin)
	get_user_authid(id,authid,31)
	if(get_distance(origin,gunshop) > 35.0) return PLUGIN_HANDLED

	if(key == 0) {
		price = get_cvar_num("rp_license_pistol")
		itemid = get_cvar_num("rp_license_pistol_id")
	}
	if(key == 1) {
		price = get_cvar_num("rp_license_sub")
		itemid = get_cvar_num("rp_license_sub_id")
	}
	if(key == 2) {
		price = get_cvar_num("rp_license_shotgun")
		itemid = get_cvar_num("rp_license_shotgun_id")
	}
	if(key == 3) {
		price = get_cvar_num("rp_license_rifle")
		itemid = get_cvar_num("rp_license_rifle_id")
	}
	if(key == 4) {
		price = get_cvar_num("rp_license_heavy")
		itemid = get_cvar_num("rp_license_heavy_id")
	}

	new buffer[64], balance
	select_string(id,"money","balance","steamid",authid,buffer)
	balance = str_to_num(buffer)
	if(balance < price) {
		client_print(id,print_chat,"[GunShop] You don't have enough money in your bank balance!")
		return PLUGIN_HANDLED
	}
	edit_value(id,"money","balance","-",price)
	wallet3[id] -= price;
	set_item_amount(id,"+",itemid,1,"money")
	client_print(id,print_chat,"[GunShop] License #%i issued!",random_num(1000,8000))
	return PLUGIN_HANDLED

}

public msg_ts(id)
{
	 set_task(1.0,"autopress",id)
	 return PLUGIN_HANDLED
}

public autopress(id)
{
	new output[64], jail, authid[32]
	get_user_authid(id,authid,31)
	select_string(id,"money","jail","steamid",authid,output)
	jail = str_to_num(output)
	if(jail > 0)
	{
		client_cmd(id,"+attack; wait; -attack")
		set_task(5.0,"spawnjail",id)
	}
	return PLUGIN_HANDLED
}

public spawnjail(id)
{
	new output[64], jail, authid[32]
	get_user_authid(id,authid,31)

	select_string(id,"money","jail","steamid",authid,output)
	jail = str_to_num(output)

	if(jail == 1) {
		set_user_origin(id,jailone)
		edit_value(id,"money","jail","=",0)
	}
	if(jail == 2) {
		set_user_origin(id,jailtwo)
		edit_value(id,"money","jail","=",0)
	}
	if(jail == 3) {
		set_user_origin(id,jailthree)
		edit_value(id,"money","jail","=",0)
	}
	if(jail == 4) {
		set_user_origin(id,jailfour)
		edit_value(id,"money","jail","=",0)
	}
	return PLUGIN_HANDLED
}
public client_putinserver(id)
{
	timer_salary[id] = 60
	new authid[32]
	get_user_authid(id,authid,31)

	uncuffaction(id)
	set_task(8.0,"print_commercial",id)

	new name[64], query[256]
	get_user_name(id,name,63)
	remove_quotes(name) 
	if(equali(name,"Pub: ",5))
	{
		replace(name,63,"Pub: ","")
		set_user_info(id,"name",name)
	}
	closedoors(id)
	format(query,255,"SELECT name,JobID,balance,wallet FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new regname[64]
		dbi_field(result,1,regname,63)
		JobID3[id] = dbi_field(result,2)
		balance3[id] = dbi_field(result,3)
		wallet3[id] = dbi_field(result,4)

		dbi_free_result(result)
		if(equal(regname,""))
		{
			new newname[64]
			format(newname,63,"Pub: %s",name)
			set_user_info(id,"name",newname)
			set_task(8.0,"print_text",id)
			return PLUGIN_HANDLED
		}
		if(!equal(regname,""))
		{
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)
	new newname[64]
	format(newname,63,"Pub: %s",name)
	set_user_info(id,"name",newname)
	set_task(11.0,"print_text",id)
	//set_lights(lights)
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	if(!is_user_alive(id))
	{
		new done
		if(get_cvar_num("rp_loose_cash") == 0)
		{
		done = 1
		}
		if(done != 1) {
			new query[256]
			new authid[32]
			get_user_authid(id,authid,31)
			if(get_cvar_num("rp_loose_cash") == 1)
			{
				format(query,255,"UPDATE money SET wallet=0 WHERE steamid='%s'",authid)
				dbi_query(dbc,query)
				wallet3[id] = 0
			}
			else
			{
				format(query,255,"UPDATE money SET wallet=wallet-%i WHERE steamid='%s'",get_cvar_num("rp_loose_cash"),authid)
				dbi_query(dbc,query)
				wallet3[id] -= get_cvar_num("rp_loose_cash")
			}
		}
	}
	uncuffaction(id)
	hudtog[id] = 0

	JobID3[id] = 0

	new origin[3]
	get_user_origin(id,origin)

	// Jail Save Mod
	if(get_distance(origin,jailone) <= 100.0) edit_value(id,"money","jail","=",1)
	if(get_distance(origin,jailtwo) <= 100.0) edit_value(id,"money","jail","=",2)
	if(get_distance(origin,jailthree) <= 100.0)  edit_value(id,"money","jail","=",3)
	if(get_distance(origin,jailfour) <= 100.0)   edit_value(id,"money","jail","=",4)
	else if(get_distance(origin,jailone) > 100.0 && get_distance(origin,jailtwo) > 100.0 && get_distance(origin,jailthree) > 100.0 && get_distance(origin,jailfour) > 100.0) edit_value(id,"money","jail","=",0)

	if(whorob711 == id) {
		whorob711 = 0
	}
	if(whorobdiner == id) {
		whorobdiner = 0
	}
	if(whorobbank == id) {
		whorobbank = 0
		new faak = find_ent_by_tname(-1,"bankdr")
		force_use(id,faak)
		fake_touch(faak,id)
		new faak2 = find_ent_by_tname(-1,"bankvault")
		force_use(id,faak2)
		fake_touch(faak2,id)
		nrobags = 0
		mdone[0] = 0
		mdone[1] = 0
		entity_set_origin(moneybag,borigin)
		entity_set_origin(moneybag2,borigin2)
	}
	
	return PLUGIN_CONTINUE
}
public salary(id)
{
	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ )
	{
		if( timer_salary[players[i]] > 0)
		{
			// Is Player in Jail??!?!?
			new origin[3]
			get_user_origin(players[i],origin)
			if(get_distance(origin,jailone) <= 100.0 || get_distance(origin,jailtwo) <= 100.0 || get_distance(origin,jailthree) <= 100.0 || get_distance(origin,jailfour) <= 100.0)
			{
			}
			else
			{
				timer_salary[players[i]] -= 1
			}
		}
		else if ( timer_salary[players[i]] <= 0 )
		{
			new query[256], authid[32]
			get_user_authid(players[i],authid,31)

			format( query, 255, "SELECT Salary FROM jobs WHERE JobID=%i", JobID3[players[i]])
			result = dbi_query( dbc, query)
			if( dbi_nextrow( result ) > 0 )
			{
				new salaryf
				salaryf = dbi_field(result,1)
				dbi_free_result(result)
				if(get_cvar_num("rp_salary_to_wallet") == 0)
				{
					format( query, 255, "UPDATE money SET balance=balance+%i WHERE steamid='%s'",salaryf,authid)
					balance3[players[i]] += salaryf
				}
				if(get_cvar_num("rp_salary_to_wallet") == 1)
				{
					format( query, 255, "UPDATE money SET wallet=wallet+%i WHERE steamid='%s'",salaryf,authid)
					wallet3[players[i]] += salaryf
				}
				timer_salary[players[i]] = 60
				dbi_query(dbc,query)
			}
			else dbi_free_result(result)

		}
	}
	return PLUGIN_CONTINUE
}


// Active Hud Code (on right)
public activehud(id)
{
	new query[256],playername[33],authid[32],num,players[32],servername[64],serverurl[64],hud[256],strJob[32]
	get_players(players,num,"ac")
	for(new i=0; i<num; i++)
	{
		get_user_authid(players[i],authid,31)
		get_user_name(players[i],playername,sizeof(playername))
		format(query,255,"SELECT balance,wallet,JobID,hunger,tiredness,bathroom FROM money WHERE steamid='%s'",authid)
		result = dbi_query(dbc,query)
		new Balance,Salary,JobID,Wallet,Hunger,Tiredness,bathroom
		if(dbi_nextrow(result) > 0)
		{
			Balance = dbi_field(result,1)
			Wallet = dbi_field(result,2)
			JobID = dbi_field(result,3)
			Hunger = dbi_field(result,4)
			Tiredness = dbi_field(result,5)
                        bathroom = dbi_field(result,6)
			robaction(players[i],Wallet)
			dbi_free_result(result)
			if(g_delay_item[players[i]] > 0) g_delay_item[players[i]]--
			new model[32]
			get_user_info(players[i],"model",model,31)
			get_cvar_string("sv_servername",servername,63)
			get_cvar_string("sv_serverurl",serverurl,63)
			
			format(query,255,"SELECT JobName,Salary FROM jobs WHERE JobID=%i",JobID)
			result = dbi_query(dbc,query)
			
			if(dbi_nextrow(result) > 0)
			{
				dbi_field(result,1,strJob,31)
				Salary = dbi_field(result,2)
				dbi_free_result(result)
				
				if(equali(servername,"") && equali(serverurl,""))
				{
					format(hud,255,"-|Red Dragon RP|- ^n --------------------- ^n Wallet: $%i ^n Bank: $%i ^n Salary: $%i ^n Job: %s ^n Payday: %i min ^n Hunger: %i% ^n Tiredness: %i% ^n Bathroom: %i% ^n --------------------- ^n red-dragon-rp.de.vu",Wallet,Balance,Salary,strJob,timer_salary[players[i]],Hunger,Tiredness,bathroom)
				}
				else if(equali(servername,""))
				{
					format(hud,255," %s ^n ------------------- ^n Wallet: $%i ^n Account: $%i ^n Salary: $%i ^n Job: %s ^n Payday: %i min ^n Hunger: %i% ^n Tiredness: %i%",serverurl,Wallet,Balance,Salary,strJob,timer_salary[players[i]],Hunger,Tiredness)
				}
				else if(equali(serverurl,""))
				{
					format(hud,255," %s ^n ------------------- ^n Wallet: $%i ^n Account: $%i ^n Salary: $%i ^n Job: %s ^n Payday: %i min ^n Hunger: %i% ^n Tiredness: %i%",servername,Wallet,Balance,Salary,strJob,timer_salary[players[i]],Hunger,Tiredness)
				}
				else
				{
					format(hud,255," %s ^n %s ^n ------------------- ^n Wallet: $%i ^n Account: $%i ^n Salary: $%i ^n Job: %s ^n Payday: %i min ^n Hunger: %i% ^n Tiredness: %i%",servername,serverurl,Wallet,Balance,Salary,strJob,timer_salary[players[i]],Hunger,Tiredness)
				}
				
				format(serverurl,63,"http://%s",serverurl)
				set_hudmessage(get_cvar_num("rp_economyhud_red"),get_cvar_num("rp_economyhud_green"),get_cvar_num("rp_economyhud_blue"),get_cvar_float("rp_economyhud_pos_x"),get_cvar_float("rp_economyhud_pos_y"),0,0.0,99.9,0.0,0.0,1)
				show_hudmessage(players[i]," %s",hud)
			}
			else
			{
				dbi_free_result(result)
				set_hudmessage(get_cvar_num("rp_economyhud_red"),get_cvar_num("rp_economyhud_green"),get_cvar_num("rp_economyhud_blue"),get_cvar_float("rp_economyhud_pos_x"),get_cvar_float("rp_economyhud_pos_y"),0,0.0,99.9,0.0,0.0,1)
				show_hudmessage(players[i]," [EconomyMod] JobID Error!^n Please notify an admin.")
			}
		}
		else
		{
			dbi_free_result(result)
			set_hudmessage(get_cvar_num("rp_economyhud_red"),get_cvar_num("rp_economyhud_green"),get_cvar_num("rp_economyhud_blue"),get_cvar_float("rp_economyhud_pos_x"),get_cvar_float("rp_economyhud_pos_y"),0,0.0,99.9,0.0,0.0,1)
			show_hudmessage(players[i]," [Not Registered]^n Write amx_regname <nickname> <password> ^n in console to register!")
		}

	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}


// When player looks at another player retrieve job
// Also Propertymod
public playerlook(id) 
{ 
	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ )
	{
		new tid, body 
		get_user_aiming( players[i], tid, body, 50)
		new origin[3]
		get_user_origin(players[i],origin)
		if(is_user_connected(tid))
		{
			new job[32],query[256]
			format( query, 255, "SELECT JobName FROM jobs WHERE JobID=%i", JobID3[tid])
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 )
			{
				dbi_field(result,1,job,31)
				dbi_free_result(result)
				set_hudmessage(200,0,0,-1.0,0.4,0,0.0,20.9,0.0,0.0,2) 
				show_hudmessage(players[i],"Job: %s",job)
			}
			else dbi_free_result(result)
		}
		///////////////////////////////////////////////////////////////////////////////
		// Looking at doors and seeing information
		///////////////////////////////////////////////////////////////////////////////
		if(is_valid_ent(tid) == 1)
		{
			new classname[256], targetname[32]
			entity_get_string(tid,EV_SZ_classname,classname,255)
			entity_get_string(tid,EV_SZ_targetname,targetname,31)
			if(equali(targetname,"")) {
				new buf = get_maxplayers()
				num_to_str(tid-buf,targetname,31)
			}
			if(!equali(targetname,"")) {
				new str[32], query[256]
				new buf = get_maxplayers()
				num_to_str(tid-buf,str,31)
				format(query,255,"SELECT * FROM property WHERE doorname='%s'",str)
				result = dbi_query(dbc,query)
				if( dbi_nextrow( result ) > 0 ) format(targetname,31,str)
				dbi_free_result(result)
			}
				
			if(equal(classname,"func_door") || equal(classname,"func_door_rotating") || equal(classname,"func_door_toggle") || equal(classname,"func_tracktrain"))
			{
				new query[256]
		
				// Fakemessage allows us to fake that the door would be actually another door!
				format( query, 255, "SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
				result = dbi_query(dbc,query)
				if( dbi_nextrow( result ) > 0 )
				{
					new fakestr[32]
					dbi_field(result,1,fakestr,31)
					dbi_free_result(result)
					if(!equali(fakestr,"")) format(targetname,31,fakestr)
					format( query, 255, "SELECT building,ownername,price,organi FROM property WHERE doorname='%s'",targetname)
					result = dbi_query(dbc,query)
					if( dbi_nextrow( result ) > 0 )
					{
						new ownername[32], price, building[32], organi[32]
						dbi_field(result,1,building,31)
						dbi_field(result,2,ownername,31)
						price = dbi_field(result,3)
                                                dbi_field(result,4,organi,31)
						dbi_free_result(result)

						// Ownername(TRUE) && Price(FALSE) && Buildingname(TRUE) && organi(TRUE)
						if(!equali( ownername,"")  && price == 0 && !equali(building,"") && !equali(organi,""))	
						{
							set_hudmessage(200,0,0,-1.0,0.35,0,0.0,99.9,0.0,0.0,2)
							show_hudmessage(players[i],"Building: %s ^n Owned by: %s ^n Organization: %s ^n",building,ownername,organi)
						}

						// Ownername(TRUE) && Price(TRUE) && Buildingname(TRUE) && organi(TRUE)
						if(!equali( ownername,"") && price > 0 && !equali(building,"") && !equali(organi,""))
						{
							set_hudmessage(200,0,0,-1.0,0.35,0,0.0,99.9,0.0,0.0,2)
							show_hudmessage(players[i],"Building: %s ^n Owned by: %s ^n Organization: %s ^n For Sell: $%i ^n Say /buy to purchase",building,ownername,organi,price)
						}
                                                
                                                // Ownername(TRUE) && Price(TRUE) && Buildingname(TRUE) && organi(FALSE)
                                                if(!equali( ownername,"") && price > 0 && !equali(building,"") && !equali(organi,""))
						{
							set_hudmessage(200,0,0,-1.0,0.35,0,0.0,99.9,0.0,0.0,2)
							show_hudmessage(players[i],"Building: %s ^n Owned by: %s ^n For Sell: $%i ^n Say /buy to purchase",building,ownername,price)
						}

						// Ownername(FALSE) && Price(TRUE) && Buildingname(TRUE) && organi(FALSE) 
						if(equali( ownername,"") && price > 0 && !equali(building,"") && !equali(organi,""))
						{
							set_hudmessage(200,0,0,-1.0,0.35,0,0.0,99.9,0.0,0.0,2)
							show_hudmessage(players[i],"Building: %s ^n For Sell: $%i ^n Say /buy to purchase",building,price)
						}

						// Ownername(FALSE) && Price(FALSE) && Buildingname(TRUE) && organi(FALSE)
						if(equali( ownername,"") && price == 0 && !equali(building,"") && !equali(organi,""))
						{
							set_hudmessage(200,0,0,-1.0,0.35,0,0.0,99.9,0.0,0.0,2)
							show_hudmessage(players[i],"Building: %s",building)
						}

					}
					else dbi_free_result(result)
				}
				else dbi_free_result(result)
			}
		}
		


		if(!is_valid_ent(tid))
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,0.1,0.0,0.0,2)
			show_hudmessage(players[i],"")
		}
		if(get_distance(origin,atmone) <= 30.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the ATM to access your bank account!")
		}
		if(get_distance(origin,atmtwo) <= 30.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the ATM to access your bank account!")
		}
		if(get_distance(origin,atmthree) <= 30.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the ATM to access your bank account!")
		}
		if(get_distance(origin,atmfour) <= 30.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the ATM to access your bank account!")
		}
		if(get_distance(origin,atmfive) <= 30.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the ATM to access your bank account!")
		}
		if(get_distance(origin,jailone) <= 100.0 || get_distance(origin,jailtwo) <= 100.0 || get_distance(origin,jailthree) <= 100.0 || get_distance(origin,jailfour) <= 100.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"You are now in Jail. You dont get payed while in Jail!")
		}
		if(get_distance(origin,gunshop) <= 35.0)
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to buy weapons from gunshop!")
		}
		if(get_distance(origin,Storageone) <= 20.0 || get_distance(origin,Storagetwo) <= 20.0 || get_distance(origin,Storagethree) <= 20.0 || get_distance(origin,Storagefour) <= 20.0 || get_distance(origin,Storagefive) <= 20.0 )
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"Say /buy to use the Store-O-Matic!")
		}
		if(get_distance(origin,uncuffareaone) <= 100.0 || get_distance(origin,uncuffareatwo) <= 50.0) // Uncuffing Areas
		{
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],"You are in an uncuff area. Come here if you want your cuff's removed")
			if(cuffed[players[i]] == 1)
			{
				uncuffaction(players[i])
				client_print(players[i],print_chat,"[CuffMod] You have been uncuffed!^n")
			}
		}
		if(allowed_npc_distance(players[i],get_cvar_num("rp_npcid_market")))
		{
			if(whorob711 == players[i])
			{
				new status[256]
				format(status,255,"You are robbing Edeka. Cash in Register: $%i, Cash stolen: $%i.",rob711currentcash,robgain711)
				set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
				show_hudmessage(players[i],status)
			}
		}
		if(allowed_npc_distance(players[i],get_cvar_num("rp_npcid_diner")))
		{
			if(whorobdiner == players[i])
			{
				new statuss[256]
				format(statuss,255,"You are robbing Phoenix Restaurant. Cash in Register: $%i, Cash stolen: $%i.",robdinercurrentcash,robgaindiner)
				set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
				show_hudmessage(players[i],statuss)
			}
		}
		if(whorobbank == players[i])
		{
			new status2[256]
			format(status2,255,"Robbing bank. Get the bags to the end of the sewers! Timeleft: %i secs",finishtime)
			set_hudmessage(200,0,0,-1.5,0.95,2,0.0,99.9,0.0,0.0,2)
			show_hudmessage(players[i],status2)
		}
	}
	return PLUGIN_HANDLED
}

// Code for Help Commands menu
public help(id)
{
	new helpmotd[2000], len = sizeof(helpmotd) - 1
	format(helpmotd,len,"Please type in you chat the category your help belongs to^n^n^n")
	add(helpmotd,len,"/showcommands - To view all the commands the server has^n")
	add(helpmotd,len,"/rules - To view the server rules, obey them or get banned from our server^n")
	add(helpmotd,len,"/laws - Server laws if Police catch you breaking these you will get a fine and jailtime^n")
	show_motd(id,helpmotd,"Red Dragon RP - Help Index")
}

public motd_show(id,file[])
{
	new dir[256], addon[32]
	get_configsdir(dir,255)
	format(addon,31,"/HarbuRP/%s.txt",file)
	add(dir,255,addon)
	show_motd(id,dir,"Red Dragon RP")
}




/////////////////////////////////////////////////
//		DoorMod & Property Mod
////////////////////////////////////////////////

// Using command to open locked doors
public targetdoor(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(cuffed[id] == 1) {
		client_print(id,print_chat,"[EconomyMod] You can't open a door while cuffed^n")
		return PLUGIN_HANDLED
	}
	new entid, doorbody, query[MAXIUMSTR+20], authid[32]
	get_user_authid(id,authid,31)
	get_user_aiming(id,entid,doorbody,200)
	if(is_valid_ent(entid))
	{
		new targetname[32]
		entity_get_string(entid,EV_SZ_targetname,targetname,31)
		if(equali(targetname,"")) {
			new buf = get_maxplayers()
			num_to_str(entid-buf,targetname,31)
		}
		if(!equali(targetname,"")) {
			new str[32]
			new buf = get_maxplayers()
			num_to_str(entid-buf,str,31)
			format(query,sizeof(query)+19,"SELECT * FROM property WHERE doorname='%s'",str)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 ) format(targetname,31,str)
			dbi_free_result(result)
		}
		format( query, sizeof(query)+19, "SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new fakemsg[32], rfakedoor[32]
			dbi_field(result,1,fakemsg,31)
			dbi_free_result(result)
			if(!equali(fakemsg,"")) {
				format(rfakedoor,31,targetname)
				format(targetname,31,fakemsg)
			}

			format( query, sizeof(query)+19, "SELECT ownersteamid,access,JobIDKey FROM property WHERE doorname='%s'",targetname)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 )
			{
				new ownersteamid[32], keys[MAXIUMSTR], JobIDKey[32]
				dbi_field(result,1,ownersteamid,31)
				dbi_field(result,2,keys,MAXIUMSTR-1)
				dbi_field(result,3,JobIDKey,31)
				dbi_free_result(result)
				if(equali(ownersteamid,authid))
				{
					force_use(id,entid)
					fake_touch(entid,id)
					return PLUGIN_HANDLED
				}
				new output[MAXKEYS][32]
				new var = explode( output, keys, '|')
				for( new i = 0;  i < var; i++ )
				{
					if(equali(output[i],authid))
					{
						force_use(id,entid)
						fake_touch(entid,id)
						return PLUGIN_HANDLED
					}
					if(equali(output[i],"MCPD"))
					{
						if((JobID3[id] >= mcpdjobs[0]) && (JobID3[id] <= mcpdjobs[1]))
						{
							force_use(id,entid)
							fake_touch(entid,id)
							return PLUGIN_HANDLED
						}
					}		
					if(equali(output[i],"Mafia"))
					{
						if((JobID3[id] >= mafiajobs[0]) && (JobID3[id] <= mafiajobs[1]))
						{
							force_use(id,entid)
							fake_touch(entid,id)
							return PLUGIN_HANDLED
						}
					}
					if(equali(output[i],"MCMD"))
					{
						if((JobID3[id] >= mcmdjobs[0]) && (JobID3[id] <= mcmdjobs[1]))
						{
							force_use(id,entid)
							fake_touch(entid,id)
							return PLUGIN_HANDLED
						}
					}	
				}
				new Jobids[2][32]
				if(equali(JobIDKey,""))
				{
					client_print(id,print_chat,"[DoorMod] You don't have a key to this door^n")
					return PLUGIN_HANDLED
				}
				explode( Jobids, JobIDKey, '-')
				if((JobID3[id] >= str_to_num(Jobids[0])) && (JobID3[id] <= str_to_num(Jobids[1])))
				{
					force_use(id,entid)
					fake_touch(entid,id)
					return PLUGIN_HANDLED
				}
				else
				{
					client_print(id,print_chat,"[DoorMod] You don't have a key to this door^n")
					return PLUGIN_HANDLED
				}
			}
			else dbi_free_result(result)
		}
		else dbi_free_result(result)
	} 
	return PLUGIN_HANDLED
}

// Adding/Removing access for player
public access_handle(id)
{
	if(is_user_database(id) == 0){
		print_text(id)
		return PLUGIN_HANDLED
	}
	new query[MAXIUMSTR+20], authid[32], authid2[32], entid, entbody, fakemsg[32], ownersteamid[32], acess[MAXIUMSTR], str[64], command[32], targetname[32]
	read_argv(0,command,31)
	get_user_aiming(id,entid,entbody,200)
	if(!is_valid_ent(entid)) {
		client_print(id,print_console,"[AMXX] You must be looking at the door of your property^n")
		return PLUGIN_HANDLED
	}
	entity_get_string(entid,EV_SZ_targetname,targetname,31)

	if(equali(targetname,"")) {
		new buf = get_maxplayers()
		num_to_str(entid-buf,targetname,31)
	}
	if(!equali(targetname,"")) {
		new str2[32]
		new buf = get_maxplayers()
		num_to_str(entid-buf,str2,31)
		format(query,sizeof(query)+19,"SELECT * FROM property WHERE doorname='%s'",str2)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 ) format(targetname,31,str2)
		dbi_free_result(result)
	}

	get_user_authid(id,authid,31)
	format(query,sizeof(query)+19,"SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		dbi_field(result,1,fakemsg,31)
		dbi_free_result(result)
		if(!equali(fakemsg,"")) format(targetname,31,fakemsg)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	format(query,sizeof(query)+19,"SELECT ownersteamid,access FROM property WHERE doorname='%s'",targetname)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		dbi_field(result,1,ownersteamid,31)
		dbi_field(result,2,acess,MAXIUMSTR-1)
		dbi_free_result(result)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	if(!equali(ownersteamid,authid)) {
		client_print(id,print_console,"[AMXX] Your not the owner of this building^n")
		return PLUGIN_HANDLED
	}
	new arg[32], arg2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	if(equali(arg,"") || equali(arg2,"")) {
		client_print(id,print_console,"Usage:  %s <name,steamid or regname> <NAME,STEAMID or REG>^n",command)
		return PLUGIN_HANDLED
	}
	if(!equali(arg2,"NAME") && !equali(arg2,"STEAMID") && !equali(arg2,"REG"))
	{
		client_print(id,print_console,"Usage:  %s <name,steamid or regname> <NAME,STEAMID or REG>^n",command)
		return PLUGIN_HANDLED
	}
	if(equali(arg2,"NAME"))
	{
		new targetid
		targetid = cmd_target(id,arg,0)
		if(!targetid) return PLUGIN_HANDLED
		if(is_user_database(targetid) == 0) {
			client_print(id,print_console,"[AMXX] Target player has not registered yet^n")
			return PLUGIN_HANDLED
		}
		get_user_authid(targetid,authid2,31)
	}
	if(equali(arg2,"STEAMID"))
	{
		format(authid2,31,arg)
		format(query,sizeof(query)+19,"SELECT name FROM money WHERE steamid='%s'",authid2)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new str_name[64]
			dbi_field(result,1,str_name,63)
			dbi_free_result(result)
			if(equali(str_name,"")) {
				client_print(id,print_console,"[AMXX] Invalid SteamID or player has not registered^n")
				return PLUGIN_HANDLED
			}
		}
		else {
			dbi_free_result(result)
			client_print(id,print_console,"[AMXX] Invalid SteamID or player has not registered^n")
			return PLUGIN_HANDLED
		}
	}
	if(equali(arg2,"REG"))
	{
		format(query,sizeof(query)+19,"SELECT steamid FROM money WHERE name='%s'",arg)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			dbi_field(result,1,authid2,31)
			dbi_free_result(result)
		}
		else
		{
			dbi_free_result(result)
			client_print(id,print_console,"[AMXX] No one has registered with the specified regname^n")
			return PLUGIN_HANDLED
		}
	}
	if(equali(command,"amx_addaccess"))
	{
		if(containi(acess,authid2) != -1) {
			client_print(id,print_console,"[AMXX] Player has access to your property already^n")
			return PLUGIN_HANDLED
		}
		new output[MAXKEYS][32]
		new var = explode( output, acess, '|')
		if(var == MAXKEYS) {
			client_print(id,print_console,"[AMXX] Can't add more access's because of %i limit^n",MAXKEYS)
			return PLUGIN_HANDLED
		}
		format(str,63,"|%s",authid2)
		add(acess,sizeof(acess),str)
		format(query,sizeof(query)+19,"UPDATE property SET access='%s' WHERE doorname='%s'",acess,targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Added access for SteamID: %s^n",authid2)
		return PLUGIN_HANDLED
	}
	if(equali(command,"amx_removeaccess"))
	{
		if(containi(acess,authid2) == -1) {
			client_print(id,print_console,"[AMXX] The specified player dosen't have access to your building^n")
			return PLUGIN_HANDLED
		}
		format(str,63,"|%s",authid2)
		replace(acess,sizeof(acess),str,"")
		format(query,sizeof(query)+19,"UPDATE property SET access='%s' WHERE doorname='%s'",acess,targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Removed access from SteamID: %s^n",authid2)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public lock_action( id, entid, buf )
{
	new temp_targetname[32], query[256]
	entity_get_string( entid, EV_SZ_targetname, temp_targetname, 31 )
	format( temp_targetname, 31, "%i", entid-buf )

	format( query, 255, "SELECT locked FROM property WHERE doorname='%s'", temp_targetname )
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		new status = dbi_field( result, 1 )
		dbi_free_result( result )

		if( !status )
		{
			format( query, 255, "UPDATE property SET locked=1 WHERE doorname='%s'", temp_targetname )
			dbi_query( dbc, query )
			client_print(id,print_chat,"[EconomyMod] You locked the door^n")
			return PLUGIN_HANDLED
		}
					
		else if( status )
		{
			format( query, 255, "UPDATE property SET locked=0 WHERE doorname='%s'", temp_targetname )
			dbi_query( dbc, query )
			client_print(id,print_chat,"[EconomyMod] You unlocked the door^n")
			return PLUGIN_HANDLED
		}

	}
	return PLUGIN_HANDLED
}

// Locking doors
public access_lock( id )
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(cuffed[id] == 1) {
		client_print(id,print_chat,"[EconomyMod] You can't lock a door while cuffed^n")
		return PLUGIN_HANDLED
	}
	new entid, doorbody, query[MAXIUMSTR+20], authid[32]
	get_user_authid(id,authid,31)
	get_user_aiming(id,entid,doorbody,200)
	new buf = get_maxplayers()

	if(is_valid_ent(entid))
	{
		new targetname[32], classname[32]
		entity_get_string( entid, EV_SZ_classname, classname, 31 )
		if( equali( "func_door", classname ) )
		{
			client_print(id,print_chat,"[EconomyMod] You can only lock rotating doors^n")
			return PLUGIN_HANDLED
		}
		entity_get_string(entid,EV_SZ_targetname,targetname,31)
		if(equali(targetname,"")) {
			num_to_str(entid-buf,targetname,31)
		}
		if(!equali(targetname,"")) {
			new str[32]
			num_to_str(entid-buf,str,31)
			format(query,sizeof(query)+19,"SELECT * FROM property WHERE doorname='%s'",str)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 ) format(targetname,31,str)
			dbi_free_result(result)
		}
		format( query, sizeof(query)+19, "SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new fakemsg[32], rfakedoor[32]
			dbi_field(result,1,fakemsg,31)
			dbi_free_result(result)
			if(!equali(fakemsg,"")) {
				format(rfakedoor,31,targetname)
				format(targetname,31,fakemsg)
			}

			format( query, sizeof(query)+19, "SELECT ownersteamid,access,JobIDKey FROM property WHERE doorname='%s'",targetname)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 )
			{
				new ownersteamid[32], keys[MAXIUMSTR], JobIDKey[32]
				dbi_field(result,1,ownersteamid,31)
				dbi_field(result,2,keys,MAXIUMSTR-1)
				dbi_field(result,3,JobIDKey,31)
				dbi_free_result(result)
				if(equali(ownersteamid,authid))
				{
					lock_action( id, entid, buf )
					return PLUGIN_HANDLED
				}
				new output[MAXKEYS][32]
				new var = explode( output, keys, '|')
				for( new i = 0;  i < var; i++ )
				{
					if(equali(output[i],authid))
					{
						lock_action( id, entid, buf )
						return PLUGIN_HANDLED
					}
					if(equali(output[i],"MCPD"))
					{
						if((JobID3[id] >= mcpdjobs[0]) && (JobID3[id] <= mcpdjobs[1]))
						{
							lock_action( id, entid, buf )
							return PLUGIN_HANDLED
						}
					}		
					if(equali(output[i],"Mafia"))
					{
						if((JobID3[id] >= mafiajobs[0]) && (JobID3[id] <= mafiajobs[1]))
						{
							lock_action( id, entid, buf )
							return PLUGIN_HANDLED
						}
					}
					if(equali(output[i],"MCMD"))
					{
						if((JobID3[id] >= mcmdjobs[0]) && (JobID3[id] <= mcmdjobs[1]))
						{
							lock_action( id, entid, buf )
							return PLUGIN_HANDLED
						}
					}	
				}
				new Jobids[2][32]
				if(equali(JobIDKey,""))
				{
					client_print(id,print_chat,"[DoorMod] You don't have a key to this door^n")
					return PLUGIN_HANDLED
				}
				explode( Jobids, JobIDKey, '-')
				if((JobID3[id] >= str_to_num(Jobids[0])) && (JobID3[id] <= str_to_num(Jobids[1])))
				{
					lock_action( id, entid, buf )
					return PLUGIN_HANDLED
				}
				else
				{
					client_print(id,print_chat,"[DoorMod] You don't have a key to this door^n")
					return PLUGIN_HANDLED
				}
			}
			else dbi_free_result(result)
		}
		else dbi_free_result(result)
	} 
	return PLUGIN_HANDLED
}

// Selling property or changing owner name
public access_edit(id)
{
	new authid[32], entid, entbody, command[32], arg[32], ownersteamid[32], query[256], fakemsg[32], targetname[32]
	get_user_aiming(id,entid,entbody,200)
	get_user_authid(id,authid,31)
	read_argv(0,command,31)
	read_argv(1,arg,31)

	if(!is_valid_ent(entid)) {
		client_print(id,print_console,"[AMXX] You must be looking at the door of your property^n")
		return PLUGIN_HANDLED
	}

	entity_get_string(entid,EV_SZ_targetname,targetname,31)

	if(equali(targetname,"")) {
		new buf = get_maxplayers()
		num_to_str(entid-buf,targetname,31)
	}
	if(!equali(targetname,"")) {
		new str[32]
		new buf = get_maxplayers()
		num_to_str(entid-buf,str,31)
		format(query,255,"SELECT * FROM property WHERE doorname='%s'",str)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 ) format(targetname,31,str)
		dbi_free_result(result)
	}

	format(query,255,"SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		dbi_field(result,1,fakemsg,31)
		dbi_free_result(result)
		if(!equali(fakemsg,"")) format(targetname,31,fakemsg)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	format(query,255,"SELECT ownersteamid FROM property WHERE doorname='%s'",targetname)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		dbi_field(result,1,ownersteamid,31)
		dbi_free_result(result)
	}
	else {
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	if(!equali(ownersteamid,authid)) {
		client_print(id,print_console,"[AMXX] Your not the owner of this building^n")
		return PLUGIN_HANDLED
	}
	if(equali(arg,"") && !equali(command,"amx_cancel") && !equali(command,"amx_profit")) {
		if(equali(command,"amx_ownername")) client_print(id,print_console,"Usage:  %s <text>^n",command)
                if(equali(command,"amx_gangname")) client_print(id,print_console,"Usage:  %s <text>^n",command)
		if(equali(command,"amx_sell")) client_print(id,print_console,"Usage:  %s <price>^n",command)
		return PLUGIN_HANDLED
	}
	// If command is amx_ownername <text>
	if(equali(command,"amx_ownername"))
	{
		format(query,255,"UPDATE property SET ownername='%s' WHERE doorname='%s'",arg,targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Properties owername set to %s^n",arg)
		return PLUGIN_HANDLED
	}
        // If command is amx_gangname <text>
	if(equali(command,"amx_gangname"))
	{
		format(query,255,"UPDATE property SET organi='%s' WHERE doorname='%s'",arg,targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Properties gangname set to %s^n",arg)
		return PLUGIN_HANDLED
	}
	// If command is amx_sell <price>
	if(equali(command,"amx_sell"))
	{
		format(query,255,"UPDATE property SET price=%i WHERE doorname='%s'",str_to_num(arg),targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Your property is now for sell for $%i^n",str_to_num(arg))
		return PLUGIN_HANDLED
	}
	// if you want to cancel the cell amx_cancel
	if(equali(command,"amx_cancel"))
	{
		format(query,255,"UPDATE property SET price=0 WHERE doorname='%s'",targetname)
		dbi_query(dbc,query)
		client_print(id,print_console,"[AMXX] Your property is not for sale anymore^n")
		return PLUGIN_HANDLED
	}
	// if you want to take profits out of your property (Only on commercial ones)
	if(equali(command,"amx_profit"))
	{
		new output[64], profit
		select_string(id,"property","profit","doorname",targetname,output)
		profit = str_to_num(output)
		if(profit <= 0) {
			client_print(id,print_console,"[AMXX] This property hasn't made any profit or is not commercial^n")
			return PLUGIN_HANDLED
		}
		else
		{
			new with = get_cvar_num("rp_walletlimit")
			if(profit < 5000) with = profit
			if(wallet3[id] > 0) with -= wallet3[id]
			if(with <= 0) {
				client_print(id,print_console,"[AMXX] Your wallet is already full^n")
				return PLUGIN_HANDLED
			}
			format(query,255,"UPDATE property SET profit=profit-%i WHERE doorname='%s'",with,targetname)
			dbi_query(dbc,query)
			edit_value(id,"money","wallet","+",with)
			wallet3[id] += with
			client_print(id,print_console,"[AMXX] Took $%i of the properties profits, $%i profit left^n",with,profit-with)
			return PLUGIN_HANDLED
		}
	}

	return PLUGIN_HANDLED
}

// Code to make sure players cant pass locked doors
public lockeddoortouch(entid,id)
{
	if(is_user_alive(id) == 1)
	{
		new query[256], targetname[32]
		entity_get_string(entid,EV_SZ_targetname,targetname,31)

		if(equali(targetname,"")) {
			new buf = get_maxplayers()
			num_to_str(entid-buf,targetname,31)
		}
		if(!equali(targetname,"")) {
			new str[32]
			new buf = get_maxplayers()
			num_to_str(entid-buf,str,31)
			format(query,255,"SELECT * FROM property WHERE doorname='%s'",str)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 ) {
				format(targetname,31,str)
				dbi_free_result(result)
			}
			else dbi_free_result(result)
		}
		format( query, 255, "SELECT locked FROM property WHERE doorname='%s'",targetname)
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new locked, str[6]
			dbi_field(result,1,str,5)
			locked = str_to_num(str)
			dbi_free_result(result)
			if(locked == 1) return PLUGIN_HANDLED
			else return PLUGIN_CONTINUE
		}
		else dbi_free_result(result)
	}
	return PLUGIN_CONTINUE
}

// SHITZ DELETE AFTER SOME TIME

public checkenitynumber(id)
{
	new entid, entbody
	get_user_aiming(id,entid,entbody,9999)
	if(entid == 0) return PLUGIN_HANDLED

	new classname[32], target[32], targetname[32], Float:HP, Float:angles[3], Float:angles2[3]
	entity_get_string(entid,EV_SZ_classname,classname,31)
	entity_get_string(entid,EV_SZ_target,target,31)
	entity_get_string(entid,EV_SZ_targetname,targetname,31)
	entity_get_vector(entid,EV_VEC_angles,angles)
	entity_get_vector(id,EV_VEC_angles,angles2)
	HP = entity_get_float(entid,EV_FL_max_health)
	

	new entitydata[256]
	entid -= get_maxplayers()
	new len= format(entitydata,sizeof(entitydata),"Classname: %s^n",classname)
	len += format(entitydata[len],sizeof(entitydata)-len,"Target: %s^n",target)
	len += format(entitydata[len],sizeof(entitydata)-len,"Targetname: %s^n",targetname)
	len += format(entitydata[len],sizeof(entitydata)-len,"Health: %f^n",HP)
	len += format(entitydata[len],sizeof(entitydata)-len,"EntID: %i^n",entid)
	len += format(entitydata[len],sizeof(entitydata)-len,"Angles: %f %f %f^n",angles[0],angles[1],angles[2])
	len += format(entitydata[len],sizeof(entitydata)-len,"^nYour current Angles: %f %f %f^n",angles2[0],angles2[1],angles2[2])
	client_print(id,print_console,entitydata)
	return PLUGIN_HANDLED
}

///////////////////////////////////
// Weapon Spawn Plugin (Beta x1)
///////////////////////////////////

// Handeling a command
public spawn_command(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}

	new WeaponID[32]
	new ExtraClip[32]
	new SpawnFlag[32]
	new query[256]
	new SaveSpawn[32]

	read_argv(1,WeaponID,31)
	read_argv(2,ExtraClip,31)
	read_argv(3,SpawnFlag,31)
	read_argv(4,SaveSpawn,31)

	if(equali(WeaponID,"") || equali(ExtraClip,"") || equali(SpawnFlag,"") || equali(SaveSpawn,"")) {
		client_print(id,print_console,"Usage:  amx_weaponspawn <WeaponID> <ExtaClips> <SpawnFlags> <Save 0 or 1>^n")
		return PLUGIN_HANDLED
	}

	new Val_ID = str_to_num(WeaponID)
	if(Val_ID == 2 || Val_ID == 10 || Val_ID == 16 || Val_ID == 30 || Val_ID > 35)
	{
		client_print(id,print_console,"[AMXX] Invalid WeaponID^n")
		return PLUGIN_HANDLED
	}

	new Float:fNewOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fNewOrigin)

	ts_weaponspawn(WeaponID,"15",ExtraClip,SpawnFlag,fNewOrigin)	// Call to function to create weapon spawn

	if(equali(SaveSpawn,"0"))
	{
		client_print(id,print_chat,"[AMXX] Non-Savable Weaponspawn Created^n")
		return PLUGIN_HANDLED
	}
	if(equali(SaveSpawn,"1") )
	{
		format( query, 255, "INSERT INTO weapons (weaponid, clips, flags, X, Y, Z) VALUES(%s,%s,%s,%f,%f,%f)", WeaponID, ExtraClip, SpawnFlag, fNewOrigin[0], fNewOrigin[1], fNewOrigin[2])
		dbi_query(dbc,query)
		client_print(id,print_notify,"[WeaponSpawn] Weaponspawn Created! Co-ordinates saved in SQL Database^n")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

// Buying Property, Weapons etc.
public buystuff(id)
{
	new entid, entbody
	get_user_aiming(id,entid,entbody,50)
	new origin[3]
	get_user_origin(id,origin)
	if(is_valid_ent(entid))
	{
		new classname[256], targetname[32]
		entity_get_string(entid,EV_SZ_classname,classname,255)
		entity_get_string(entid,EV_SZ_targetname,targetname,31)

		if(equali(targetname,"")) {
			new buf = get_maxplayers()
			num_to_str(entid-buf,targetname,31)
		}
		if(!equali(targetname,"")) {
			new str[32], query[256]
			new buf = get_maxplayers()
			num_to_str(entid-buf,str,31)
			format(query,255,"SELECT * FROM property WHERE doorname='%s'",str)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 ) format(targetname,31,str)
			dbi_free_result(result)
		}
		if(equal(classname,"func_door") || equal(classname,"func_door_rotating") || equal(classname,"func_door_toggle"))
		{
	
			new authid[32], query[256], name[33]
			get_user_authid(id,authid,31)
			get_user_name(id,name,sizeof(name))
			format( query, 255, "SELECT balance FROM money WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if( dbi_nextrow( result ) > 0 )
			{
				new strf[32]
				dbi_field(result,1,strf,31)
				dbi_free_result(result)

				format( query, 255, "SELECT fakemsg FROM property WHERE doorname='%s'",targetname)
				result = dbi_query(dbc,query)
				if( dbi_nextrow( result ) > 0 )
				{
					new fakemsg[32]
					dbi_field(result,1,fakemsg,31)
					dbi_free_result(result)
					if(!equali(fakemsg,"")) format(targetname,31,fakemsg)

					format( query, 255, "SELECT building,ownername,ownersteamid,price,organi FROM property WHERE doorname='%s'",targetname)
					result = dbi_query(dbc,query)
					if( dbi_nextrow( result ) > 0 )
					{
						new building[32],ownername[32],price,targetid[32],organi[32]
						dbi_field(result,1,building,31)
						dbi_field(result,2,ownername,31)
						dbi_field(result,3,targetid,31)
                                                dbi_field(result,5,organi,31)
						price = dbi_field(result,4)
						dbi_free_result(result)
						if(price > balance3[id])
						{
							client_print(id,print_chat,"[EconomyMod] You don't have enough money in your bank account to buy this property^n") // SOMEONE OWNS ALREADY
							return PLUGIN_HANDLED
						}
						if(!equali( targetid,"")  && price == 0)
						{
							client_print(id,print_chat,"[EconomyMod] This property is already owned by: %s^n",ownername)
							return PLUGIN_HANDLED
						}
						if(!equali( targetid,"") && price > 0) // SOEMONE OWNS BUT SELLING
						{	
							format( query, 255, "UPDATE money SET balance=balance-%i WHERE steamid='%s'", price, authid)
							dbi_query( dbc, query)
							balance3[id] -= price
							format( query, 255, "UPDATE money SET balance=balance+%i WHERE steamid='%s'", price, targetid)
							dbi_query( dbc, query)
							new tid = cmd_target(id,targetid,0)
							if(tid) balance3[tid] += price
							format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='%s'",name,targetname)
							dbi_query( dbc, query)
                                                        format( query, 255, "UPDATE property SET organi='%s' WHERE doorname='%s'",name,targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='%s'",authid,targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET access='' WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET price=0 WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET JobIDKey='' WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							client_print(id,print_chat,"[EconomyMod] Building successfully bought for $%i^n",price)
						}
						if(equali( targetid,"") && price > 0) // NO ONE OWNS BUT SELLING
						{
							format( query, 255, "UPDATE money SET balance=balance-%i WHERE steamid='%s'", price, authid)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET ownername='%s' WHERE doorname='%s'",name,targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET ownersteamid='%s' WHERE doorname='%s'",authid,targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET access='' WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET price=0 WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							format( query, 255, "UPDATE property SET JobIDKey='' WHERE doorname='%s'",targetname)
							dbi_query( dbc, query)
							balance3[id] -= price
							client_print(id,print_chat,"[EconomyMod] Building successfully bought for $%i^n",price)
						}
					}
					else dbi_free_result(result)
				}
				else dbi_free_result(result)
			}
			else dbi_free_result(result)
		}
	}
	if(get_distance(origin,gunshop) <= 35.0)
	{
		Gunshop_Main(id)
	}
	if(get_distance(origin,atmone) <= 25.0)
	{
		Menu_Atm(id)
	}
	if(get_distance(origin,atmtwo) <= 25.0)
	{
		Menu_Atm(id)
	}
	if(get_distance(origin,atmthree) <= 25.0)
	{
		Menu_Atm(id)
	}
	if(get_distance(origin,atmfour) <= 25.0)
	{
		Menu_Atm(id)
	}
	if(get_distance(origin,atmfive) <= 25.0)
	{
		Menu_Atm(id)
	}
	if(get_distance(origin,leet_laptop) <= 25.0)
	{
		laptop_leet_guess(id)
	}
	if(get_distance(origin,Storageone) <= 20.0 || get_distance(origin,Storagetwo) <= 20.0 || get_distance(origin,Storagethree) <= 20.0 || get_distance(origin,Storagefour) <= 20.0 || get_distance(origin,Storagefive) <= 20.0 )
	{
		prodigy(id)
	}
	else
	{
		new query[256], npc_origin[3], npcid, hardcode
		format(query,255,"SELECT npcid,x,y,z,hardcode FROM npc")
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new rows = dbi_num_rows(result)
			for( new i = 0; i < rows; i++)
			{
				npcid = dbi_field(result,1)
				npc_origin[0] = dbi_field(result,2)
				npc_origin[1] = dbi_field(result,3)
				npc_origin[2] = dbi_field(result,4)
				hardcode = dbi_field(result,5)
				if(get_distance(origin,npc_origin) <= 25.0)
				{
					if(hardcode == 1) Bank_Npc(id)
					else if(hardcode == 2) prodigy(id)
					else if(hardcode == 3)
					{
						new authid[32]
						get_user_authid( id, authid, 31 );
						if( equali( authid, "STEAM_0:1:2117582" ) ) shop_options(id,npcid);
						else break;
					}	
					else if(hardcode == 0) shop_options(id,npcid)
					break
				}
				dbi_nextrow(result)
			}
		}
		else dbi_free_result(result)
	}
				
	return PLUGIN_HANDLED
}


// Disable Kill Command
public client_kill(id)
{
	console_print(id,"[AMXX] Sorry, the kill command is disabled.")
	return PLUGIN_HANDLED
}



/////////////////////////////
/// CUFF MOD ///////////////
////////////////////////////
public cuff(id)
{
	new entid, entbody
	get_user_aiming(id,entid,entbody,100)
	if(!is_user_connected(entid))
	{
		return PLUGIN_HANDLED
	}
	if(is_user_connected(entid) && is_user_alive(id))
	{
		new name[33], name2[33]
		get_user_name(id, name, sizeof(name))
		get_user_name(entid, name2, sizeof(name2))
		if((JobID3[id] >= mcpdjobs[0] && JobID3[id] <= mcpdjobs[1]))
		{
			if(cuffed[entid] == 0)
			{
				if((JobID3[entid] >= mcpdjobs[0] && JobID3[entid] <= mcpdjobs[1]) || (JobID3[entid] == 1))
				{
					client_print(id,print_chat,"[CuffMod] You cannot cuff another MCPD officer!^n")
				}
				else
				{
					// If cuffed person was robbing the 7/11 make a cool annoucment that you ended it!
					if(whorob711 == entid)
					{
						robbing711deathend(entid,id)
					}
					if(whorobdiner == entid)
					{
						robbingdinerdeathend(entid,id)
					}
					if(whorobbank == entid)
					{
						robbingbankdeathend(entid,id)
					}
					cuffaction(entid)
					client_print(entid,print_chat,"[CuffMod] You have been cuffed!^n")
					client_print(id,print_chat,"[CuffMod] You have cuffed the player!^n")
					return PLUGIN_HANDLED
				}
			}
			if(cuffed[entid] == 1)
			{
				uncuffaction(entid)
				client_print(entid,print_chat,"[Cuff Mod] You have been uncuffed!^n")
				client_print(id,print_chat,"[Cuff Mod] You have uncuffed the player!^n")
				return PLUGIN_HANDLED
			}
		}
		else
		{
			client_print(id,print_chat,"[Cuff Mod] You have to work for the MCPD to (un)cuff someone!^n")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public uncuffaction(entid)
{
	cuffed[entid] = 0
	set_user_maxspeed(entid,get_user_maxspeed(entid)+get_cvar_num("rp_cuffed_speedloose"))
	set_user_rendering(entid,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
}

public cuffaction(id)
{
	cuffed[id] = 1
	for(new i=1;i<=35;i++)
	{
		client_cmd(id,"weapon_%d; drop",i)
	}
	set_task(0.5,"slowdown",id)
	set_user_rendering(id,kRenderFxGlowShell,255,0,0,kRenderNormal,16)
	return PLUGIN_HANDLED
}

public slowdown(id)
{
	set_user_maxspeed(id,get_user_maxspeed(id)-get_cvar_num("rp_cuffed_speedloose"))
	return PLUGIN_HANDLED
}

// To stop user Jump/Kick/Hit/Press buttons etc...
public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(cuffed[id] == 1)
	{
		new bufferstop = entity_get_int(id,EV_INT_button)

		if(bufferstop != 0) {
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE)
		}

		if((bufferstop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) {
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}


// Give health automaticly to MCMD players every 5 secs
public mcmdhealth()
{
	new players[32], inum
  	get_players(players,inum,"c")
	for(new i = 0 ;i < inum ;++i)
	{
		if((JobID3[players[i]] >= mcmdjobs[0] && JobID3[players[i]] <= mcmdjobs[1]))
		{
			new currenthealth
			currenthealth = get_user_health(players[i])
			if(currenthealth < 100)
			{
				currenthealth = currenthealth + 1
				set_user_health(players[i],currenthealth)
			}
		}
	}
	return PLUGIN_HANDLED
}

///////////////////////////////
//
// ATM CODE
//
///////////////////////////////



// ATM Menu 1. Deposit, 2. Withdraw
public actionMenuatm(id,key)
{
 switch(key){
 case 0:{
 showMenudep(id)
 }
 case 1:{
 showMenuwit(id)
 }
 }

 return PLUGIN_HANDLED
}

public Menu_Atm(id)
{
	if(get_item_amount(id,get_cvar_num("rp_itemid_atmcard"),"money") == 0)
	{
		client_print(id,print_chat,"[Bank] You need an ATM Card to use this^n")
		return PLUGIN_HANDLED
	}
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[Bank] Can't deposit or withdraw money when cuffed^n")
		return PLUGIN_HANDLED
	}
	new menuBodyp[512]
	new len = format(menuBodyp,511,"ATM Menu^n^n")
	len += format(menuBodyp[len],511-len,"1. Deposit^n2. Withdraw^n^n0. Exit")
	show_menu(id,((1<<0)|(1<<1)|(1<<9)),menuBodyp)
	return PLUGIN_HANDLED
}


// Deposit Menu
public actionMenudep(id,key)
{
 switch(key){
 case 0:{
 bankfunction(id,50,1)
 }
 case 1:{
 bankfunction(id,100,1)
 }
 case 2:{
 bankfunction(id,200,1)
 }
 case 3:{
 bankfunction(id,500,1)
 }
 case 4:{
 bankfunction(id,1000,1)
 }
 case 5:{
 bankfunction(id,1500,1)
 }
 case 6:{
 bankfunction(id,2500,1)
 }
 case 7:{
 bankfunction(id,5000,1)
 }
 }

 return PLUGIN_HANDLED
}

public showMenudep(id)
{
	
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[Bank] Can't deposit or withdraw money when cuffed^n")
		return PLUGIN_HANDLED
	}
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,atmone) <= 25.0 || get_distance(origin,atmtwo) <= 25.0 || get_distance(origin,atmthree) <= 25.0 || get_distance(origin,atmfour) <= 25.0 || get_distance(origin,atmfive) <= 25.0 )
	{
		new menuBodyp[512]
		new len = format(menuBodyp,511,"ATM Deposit^n^n")
		len += format(menuBodyp[len],511-len,"1. $50^n2. $100^n3. $200^n4. $500^n5. $1000^n6. $1500^n7. $2500^n8. $5000^n^n0. Exit")
		show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)),menuBodyp)
	}
	return PLUGIN_HANDLED
}

// Withdraw Menu
public actionMenuwit(id,key)
{
 switch(key){
 case 0:{
 bankfunction(id,50,2)
 }
 case 1:{
 bankfunction(id,100,2)
 }
 case 2:{
 bankfunction(id,200,2)
 }
 case 3:{
 bankfunction(id,500,2)
 }
 case 4:{
 bankfunction(id,1000,2)
 }
 case 5:{
 bankfunction(id,2000,2)
 }
 case 6:{
 bankfunction(id,5000,2)
 }
 case 7:{
 bankfunction(id,10000,2)
 }
 }

 return PLUGIN_HANDLED
}

public showMenuwit(id)
{
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[Bank] Can't deposit or withdraw money when cuffed^n")
		return PLUGIN_HANDLED
	}
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,atmone) <= 25.0 || get_distance(origin,atmtwo) <= 25.0 || get_distance(origin,atmthree) <= 25.0 || get_distance(origin,atmfour) <= 25.0 || get_distance(origin,atmfive) <= 25.0)
	{
		new menuBodyp[512]
		new len = format(menuBodyp,511,"ATM Withdraw^n^n")
		len += format(menuBodyp[len],511-len,"1. $50^n2. $100^n3. $200^n4. $500^n5. $1000^n6. $2000^n7. $5000^n8. $10000^n^n0. Exit")
		show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)),menuBodyp)
	}
	return PLUGIN_HANDLED
}

///////////////////////////////////////////////////////////////////////////////
// Doing the actual Depositing/Withdrawing actions from the ATM and bankers///
/////////////////////////////////////////////////////////////////////////////

public bankfunction(id,amount,func)
{
	new origin[3]
	get_user_origin(id,origin)
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[Bank] Can't deposit or withdraw money when cuffed^n")
		return PLUGIN_HANDLED
	}
	if(get_distance(origin,atmone) <= 25.0 || get_distance(origin,atmtwo) <= 25.0 || get_distance(origin,atmthree) <= 25.0 || get_distance(origin,atmfour) <= 25.0 || get_distance(origin,atmfive) <= 25.0 || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two")))
	{
		if(func == 1) // Deposit
		{
			if(amount <= 0)
			{
				client_print(id,print_chat,"[Bank] Sorry, amount to deposit has to be more than zero!^n")
				return PLUGIN_HANDLED
			}
			else
			{
				new authid[32], query[256]
				get_user_authid(id,authid,31)
				if(wallet3[id] < amount || amount == 0)
				{
					client_print(id,print_chat,"[Bank] You dont have enough money in your wallet!^n")
					return PLUGIN_HANDLED
				}
				else
				{
					format( query, 255, "UPDATE money SET wallet=wallet-%i WHERE steamid='%s'", amount, authid)
					dbi_query( dbc, query)
					wallet3[id] -= amount
					format( query, 255, "UPDATE money SET balance=balance+%i WHERE steamid='%s'", amount, authid)
					dbi_query( dbc, query)
					balance3[id] += amount
					client_print( id, print_chat,"[Bank] You have deposited $%i in your bank balance^n", amount)
					return PLUGIN_HANDLED
				}
			}
		}
		if(func == 2) // Withdraw
		{
			if(amount <= 0)
			{
				client_print(id,print_chat,"[Bank] Sorry, amount to withdraw has to be more than zero!^n")
				return PLUGIN_HANDLED
			}
			else
			{
				new authid[32], query[256]
				get_user_authid(id,authid,31)
				if(balance3[id] < amount || amount == 0)
				{
					client_print(id,print_chat,"[Bank] You dont have enough money in your bank account!^n")
					return PLUGIN_HANDLED
				}
				else
				{
					new sumlimit
					sumlimit = wallet3[id] + amount
					if(sumlimit > get_cvar_num("rp_walletlimit") || wallet3[id] == get_cvar_num("rp_walletlimit"))
					{
						client_print(id,print_chat,"[Bank] Sorry, you can only have %i in your wallet!^n",get_cvar_num("rp_walletlimit"))
						return PLUGIN_HANDLED
					}
					format( query, 255, "UPDATE money SET wallet=wallet+%i WHERE steamid='%s'", amount, authid)
					dbi_query( dbc, query)
					wallet3[id] += amount
					format( query, 255, "UPDATE money SET balance=balance-%i WHERE steamid='%s'", amount, authid)
					dbi_query( dbc, query)
					balance3[id] -= amount
					client_print( id, print_chat,"[Bank] You have withdrawn $%i from your bank balance^n", amount)
					return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//			Robmod
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

public rob(id)
{
	new origin[3], authid[32], query[256]
	get_user_origin(id,origin)
	get_user_authid(id,authid,31)
	format( query, 255, "SELECT wallet,JobID FROM money WHERE steamid='%s'", authid)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		new buffer[32], JobID, wallet
		dbi_field(result,1,buffer,31)
		wallet = str_to_num(buffer)
		dbi_field(result,2,buffer,31)
		JobID = str_to_num(buffer)
		dbi_free_result(result)
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_market")))
		{
			rob711(id,wallet,JobID)
			return PLUGIN_HANDLED
		}
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_diner")))
		{
			robdiner(id,wallet,JobID)
			return PLUGIN_HANDLED
		}
		if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two")))
		{
			robbank(id,wallet,JobID)
			return PLUGIN_HANDLED
		}
		else
		{
			client_print(id,print_chat,"[RobMOD] Nothing to rob here. Go behind a cash register^n")
			return PLUGIN_HANDLED
		}
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED
}


/////////////////////////////////////////////////////////////////////////////////////////////
// Robbing The 7/11
/////////////////////////////////////////////////////////////////////////////////////////////

// Try to find reasons why cannot start the robbing
public rob711(id,wallet,JobID)
{
	if((JobID >= mcpdjobs[0] && JobID <= mcpdjobs[1]) || (JobID >= jobs711[0] && JobID <= jobs711[1]))
	{
		client_print(id,print_chat,"[RobMOD] SMPD's and Edeka workers cannot rob the Edeka^n")
		return PLUGIN_HANDLED
	}
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[RobMOD] Can not rob the Edeka while cuffed^n")
		return PLUGIN_HANDLED
	}
	if(whorob711 == id)
	{
		client_print(id,print_chat,"[RobMOD] You are already robbing the Edeka^n")
		return PLUGIN_HANDLED
	}
	if(whorob711 > 0 && whorob711 != id)
	{
		client_print(id,print_chat,"[RobMOD] Someone else is already robbing the Edeka^n")
		return PLUGIN_HANDLED
	}
	if(wallet >= get_cvar_num("rp_walletlimit") || (wallet + get_cvar_num( "rp_711_amount" )) >= get_cvar_num("rp_walletlimit"))
	{
		client_print(id,print_chat,"[RobMOD] Your wallet dosen't have space for more money^n")
		return PLUGIN_HANDLED
	}
	new players[32], num
	get_players(players,num)
	if(num < get_cvar_num( "rp_711_users" ))
	{
		client_print(id,print_chat,"[RobMOD] Not enoguh players on server to rob Edeka^n")
		return PLUGIN_HANDLED
	}
	if(temptime711rob == 1)
	{
		client_print(id,print_chat,"[RobMOD] The Edeka was just robbed, come back later!^n")
		return PLUGIN_HANDLED
	}

	// Finding if there are MCPD officers on the server
	new foundofficers = 0
	get_players(players,num)
	for( new i = 0;  i < num; i++ )
	{
		new authid[32], query[256]
		get_user_authid( players[i], authid, 31) 
		format( query, 255, "SELECT JobID FROM money WHERE steamid='%s'", authid) 
		result = dbi_query(dbc,query) 
		if( dbi_nextrow( result ) > 0 )
		{ 
			new job[32], UJobID
			dbi_field( result, 1, job, 31) 
			dbi_free_result(result)
			UJobID = str_to_num(job)
			if(UJobID >= mcpdjobs[0] && UJobID <= mcpdjobs[1])
			{
				foundofficers = foundofficers + 1
			}
		}
		dbi_free_result(result)
	}
	if(foundofficers == 0)
	{
		client_print(id,print_chat,"[RobMOD] No SMPD officers on server to try and stop you!^n")
		return PLUGIN_HANDLED
	}

	// Cash too low in register
	if(rob711currentcash < get_cvar_num( "rp_711_minium" ) && temptime711rob == 0 )
	{
	new origin[3], name[33]
	get_user_origin(id,origin)
	get_user_name(id,name,sizeof(name))
	for(new i=0;i<num;i++)
	{
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= get_cvar_num("rp_msgdistance"))
		{
			client_print(players[i],print_chat,"* [RobMOD] %s opens and checks the cash register!^n",name)
		}
	}
	client_print(id,print_chat,"[RobMOD] The cash register is out of money, try again later!^n")
	return PLUGIN_HANDLED
	}

	// Starting the robbing command
	robbing711start(id)
	client_print(id,print_chat,"[RobMOD] You are robbing the Edeka. Stay close to the cash register or robber will be aborted^n")
	return PLUGIN_HANDLED
}


// When starting the robbery, the MCPD will be informed :)
public robbing711start(id)
{
	new hudstring[256], name[33]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"Attention All SMPD Units!^n %s is robbing the Edeka",name)
	else format(hudstring,255,"Attention All SMPD Units!^n The Edeka is being robbed")
	set_hudmessage(217,217,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

	//new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_711 = find_ent_by_tname(-1,"711_Alarm_Door")
	//force_use(tempdoor,alarm_711)
	//fake_touch(alarm_711,tempdoor)
	whorob711 = id
	robgain711 = 0
	set_user_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16)
}

// When player has emptied the register or moved away
public robbing711naturalend(id)
{
	new hudstring[256], name[33]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"%s is getting away from the Edeka!^n Stop him by anymeans necessary!",name)
	else format(hudstring,255,"The robber is getting away from the Edeka!^n Stop him by anymeans necessary!" )
	set_hudmessage(217,217,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

        //new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_711 = find_ent_by_tname(-1,"711_Alarm_Door")
	//force_use(tempdoor,alarm_711)
	//fake_touch(alarm_711,tempdoor)
	whorob711 = 0
	temptime711rob = 1
	robgain711 = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	set_task(30.0,"Temporary_Time_711")
}

// Robber was either killed or cuffed
public robbing711deathend(id,killer)
{
	new hudstring[256], name[33], killername[33]
	get_user_name(id,name,sizeof(name))
	get_user_name(killer,killername,sizeof(killername))
	format(hudstring,255,"Thanks to %s for stopping^n %s who was robbing the Edeka!",killername,name)
	set_hudmessage(217,217,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

        //new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_711 = find_ent_by_tname(-1,"711_Alarm_Door")
	//force_use(tempdoor,alarm_711)
	//fake_touch(alarm_711,tempdoor)
	whorob711 = 0
	temptime711rob = 1
	robgain711 = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	set_task(30.0,"Temporary_Time_711")
}

// The Temporary time thing to not make the Door bars inverted
public Temporary_Time_711()
{
	if(whorob711 == 0)
	{
		temptime711rob = 0
	}
}

public set711cash(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}
	new amount, buffer[256]
	read_argv(1,buffer,255)
	amount = str_to_num(buffer)
	rob711currentcash = amount
	client_print(id,print_notify,"[RobMOD] Edeka cash register set to $%i^n",amount)
	return PLUGIN_HANDLED
}

/////////////////////////////////////////////////////////////////////////////////////////////
// Robbing The Diner
/////////////////////////////////////////////////////////////////////////////////////////////

// Try to find reasons why cannot start the robbing
public robdiner(id,wallet,JobID)
{
	if((JobID >= mcpdjobs[0] && JobID <= mcpdjobs[1]))
	{
		client_print(id,print_chat,"[RobMOD] SMPD's and Phoenix Restaurant workers cannot rob the Phoenix Restaurant^n")
		return PLUGIN_HANDLED
	}
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[RobMOD] Can not rob the Phoenix Restaurant while cuffed^n")
		return PLUGIN_HANDLED
	}
	if(whorobdiner == id)
	{
		client_print(id,print_chat,"[RobMOD] You are already robbing the Phoenix Restaurant^n")
		return PLUGIN_HANDLED
	}
	if(whorobdiner > 0 && whorobdiner != id)
	{
		client_print(id,print_chat,"[RobMOD] Someone else is already robbing the Phoenix Restaurant^n")
		return PLUGIN_HANDLED
	}
	if(wallet >= get_cvar_num("rp_walletlimit") || (wallet + get_cvar_num( "rp_diner_amount" )) >= get_cvar_num("rp_walletlimit"))
	{
		client_print(id,print_chat,"[RobMOD] Your wallet dosen't have space for more money^n")
		return PLUGIN_HANDLED
	}
	new players[32], num
	get_players(players,num)
	if(num < get_cvar_num( "rp_diner_users" ))
	{
		client_print(id,print_chat,"[RobMOD] Not enough players on server to rob the Phoenix Restaurant^n")
		return PLUGIN_HANDLED
	}
	if(temptimedinerrob == 1)
	{
		client_print(id,print_chat,"[RobMOD] The Phoenix Restaurant was just robbed, come back later!^n")
		return PLUGIN_HANDLED
	}

	// Finding if there are MCPD officers on the server
	new foundofficers = 0
	get_players(players,num)
	for( new i = 0;  i < num; i++ )
	{
		new authid[32], query[256]
		get_user_authid( players[i], authid, 31) 
		format( query, 255, "SELECT JobID FROM money WHERE steamid='%s'", authid) 
		result = dbi_query(dbc,query) 
		if( dbi_nextrow( result ) > 0 )
		{ 
			new job[32], UJobID
			dbi_field( result, 1, job, 31) 
			dbi_free_result(result)
			UJobID = str_to_num(job)
			if(UJobID >= mcpdjobs[0] && UJobID <= mcpdjobs[1])
			{
				foundofficers = foundofficers + 1
			}
		}
		dbi_free_result(result)
	}
	if(foundofficers == 0)
	{
		client_print(id,print_chat,"[RobMOD] No SMPD officers on server to try and stop you!^n")
		return PLUGIN_HANDLED
	}

	// Cash too low in register
	if(robdinercurrentcash < get_cvar_num( "rp_diner_minium" ) && temptimedinerrob == 0 )
	{
	new origin[3], name[33]
	get_user_origin(id,origin)
	get_user_name(id,name,sizeof(name))
	for(new i=0;i<num;i++)
	{
		new porigin[3]
		get_user_origin(players[i],porigin)
		if(get_distance(origin,porigin) <= get_cvar_num("rp_msgdistance"))
		{
			client_print(players[i],print_chat,"* [RobMOD] %s opens and checks the cash register!^n",name)
		}
	}
	client_print(id,print_chat,"[RobMOD] The cash register is out of money, try again later!^n")
	return PLUGIN_HANDLED
	}

	// Starting the robbing command
	robbingdinerstart(id)
	client_print(id,print_chat,"[RobMOD] You are robbing the Phoenix Restaurant. Stay close to the cash register or robber will be aborted^n")
	return PLUGIN_HANDLED
}


// When starting the robbery, the MCPD will be informed :)
public robbingdinerstart(id)
{
	new hudstring[256], name[33]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"Attention All SMPD Units!^n %s is emptying the Phoenix Restaurant",name)
	else format(hudstring,255,"Attention All SMPD Units!^n The Phoenix Restaurant is being emptied")
	set_hudmessage(250,176,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

	//new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_diner = find_ent_by_tname(-1,"Pizza_Alarm_Door")
	//force_use(tempdoor,alarm_diner)
	//fake_touch(alarm_diner,tempdoor)
	whorobdiner = id
	robgaindiner = 0
	set_user_rendering(id,kRenderFxGlowShell,255,128,0,kRenderNormal,16)
}

// When player has emptied the register or moved away
public robbingdinernaturalend(id)
{
	new hudstring[256], name[33]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"%s is leaving the Phoenix Restaurant!^n Get him dead or alive!",name)
	else format(hudstring,255,"The robber is leaving the Phoenix Restaurant!^n Get him dead or alive!" )
	set_hudmessage(250,176,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

        //new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_diner = find_ent_by_tname(-1,"Pizza_Alarm_Door")
	//force_use(tempdoor,alarm_diner)
	//fake_touch(alarm_diner,tempdoor)
	whorobdiner = 0
	temptimedinerrob = 1
	robgaindiner = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	set_task(30.0,"Temporary_Time_diner")
}

// Robber was either killed or cuffed
public robbingdinerdeathend(id,killer)
{
	new hudstring[256], name[33], killername[33]
	get_user_name(id,name,sizeof(name))
	get_user_name(killer,killername,sizeof(killername))
	format(hudstring,255,"Good Work %s!^n He stopped %s who was robbing the Phoenix Restaurant!",killername,name)
	set_hudmessage(250,176,0,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

        //new tempdoor = find_ent_by_class(-1,"func_door")
	//new alarm_diner = find_ent_by_tname(-1,"Pizza_Alarm_Door")
	//force_use(tempdoor,alarm_diner)
	//fake_touch(alarm_diner,tempdoor)
	whorobdiner = 0
	temptimedinerrob = 1
	robgaindiner = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	set_task(30.0,"Temporary_Time_diner")
}

// The Temporary time thing to not make the Door bars inverted
public Temporary_Time_diner()
{
	if(whorobdiner == 0)
	{
		temptimedinerrob = 0
	}
}

// The actual money transfer code (From Cash Register -> To Player)


public setdinercash(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}
	new amount, buffer[256]
	read_argv(1,buffer,255)
	amount = str_to_num(buffer)
	robdinercurrentcash = amount
	client_print(id,print_notify,"[RobMOD] Phoenix Restaurant cash register set to $%i^n",amount)
	return PLUGIN_HANDLED
}



////////////////////////////////////
//	Robbing the Bank
///////////////////////////////////

public bankmoney(entid,pushable) {
	if(whorobbank == 0) return PLUGIN_HANDLED

	if(pushable == moneybag && mdone[0] == 0) mdone[0] = 1
	else if(pushable == moneybag2 && mdone[1] == 0) mdone[1] = 1
	else return PLUGIN_HANDLED

	if(whorobbank > 0) {
		nrobags++
		client_print(whorobbank,print_chat,"[AMXX] Thats it! You have %i/4 bags!",nrobags)
		edit_value(whorobbank,"money","wallet","+",get_cvar_num("rp_moneybag_value"))
		wallet3[whorobbank] += get_cvar_num("rp_moneybag_value")
	}
	if(nrobags == 4) 
	{
		robbingbanknaturalend(whorobbank)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public robbank(id,wallet,JobID)
{
	if((JobID >= mcpdjobs[0] && JobID <= mcpdjobs[1]))
	{
		client_print(id,print_chat,"[RobMOD] Police and bank workers cannot rob the bank^n")
		return PLUGIN_HANDLED
	}
	if(cuffed[id] == 1)
	{
		client_print(id,print_chat,"[RobMOD] Can not rob the bank while cuffed^n")
		return PLUGIN_HANDLED
	}
	if(whorobbank == id)
	{
		client_print(id,print_chat,"[RobMOD] You are already robbing the bank^n")
		return PLUGIN_HANDLED
	}
	if(whorobbank > 0 && whorobbank != id)
	{
		client_print(id,print_chat,"[RobMOD] Someone else is already robbing the bank^n")
		return PLUGIN_HANDLED
	}
	new players[32], num
	get_players(players,num)
	if(num < get_cvar_num( "rp_bank_users" ))
	{
		client_print(id,print_chat,"[RobMOD] Not enough players on server to rob the bank^n")
		return PLUGIN_HANDLED
	}
	new query[256]
	format(query,255,"SELECT val FROM misc WHERE title='BankRob'")
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		new str[32], robtime
		dbi_field(result,1,str,31)
		dbi_free_result(result)
		robtime = str_to_num(str)
		if(robtime >= 1)
		{
			client_print(id,print_chat,"[RobMOD] Unfortunately the bank has been robbed. Come back in %i minutes.^n",robtime)
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)

	// Finding if there are MCPD officers on the server
	new foundofficers = 0
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ )
	{
		if(JobID3[players[i]] >= mcpdjobs[0] && JobID3[players[i]] <= mcpdjobs[1])
		{
			foundofficers = foundofficers + 1
		}
	}
	if(foundofficers < get_cvar_num( "rp_bank_cops" ))
	{
		client_print(id,print_chat,"[RobMOD] Not enough Police officers on server to try and stop you!^n")
		return PLUGIN_HANDLED
	}

	// Starting the robbing command
	finishtime = get_cvar_num( "rp_bank_mission_time" )
	robbingbankstart(id)

	client_print(id,print_chat,"[RobMOD] You are robbing the bank. Take these bags to the end of the sewers before the timer runs out!^n")
	return PLUGIN_HANDLED
}

// When starting the BANK robbery, the MCPD will be informed :)
public robbingbankstart(id)
{
	new hudstring[256], name[33]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"Attention ALL Police, SWAT and Army Units!^n %s has broken into the banks vault!",name)
	else format(hudstring,255,"Attention ALL Police, SWAT and Army Units!^n The bank vaults have been broken into!")
	set_hudmessage(255,0,255,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

	// ROB MOD CODE HERE!!
	new faak = find_ent_by_tname(-1,"bankdr")
	force_use(id,faak)
	fake_touch(faak,id)
	new faak2 = find_ent_by_tname(-1,"bankvault")
	force_use(id,faak2)
	fake_touch(faak2,id)

	whorobbank = id
	set_user_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,16)
}

// When player has got all moneybags or some or time is out
public robbingbanknaturalend(id)
{
	new hudstring[256], name[33], query[256]
	get_user_name(id,name,sizeof(name))
	if( get_cvar_num( "rp_show_robber" ) ) format(hudstring,255,"%s who robbed the vault is hiding! Find him and eliminate him!",name)
	else format(hudstring,255,"The robber who robbed the vault is hiding! Find him and eliminate him!",name)
	set_hudmessage(255,0,255,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)

	// INSERT ROBSTOP CODE HERE!!!
	new faak = find_ent_by_tname(-1,"bankdr")
	force_use(id,faak)
	fake_touch(faak,id)
	new faak2 = find_ent_by_tname(-1,"bankvault")
	force_use(id,faak2)
	fake_touch(faak2,id)
	nrobags = 0
	mdone[0] = 0
	mdone[1] = 0
	entity_set_origin(moneybag,borigin)
	entity_set_origin(moneybag2,borigin2)

	format(query,255,"UPDATE misc SET val=%i WHERE title='BankRob'",get_cvar_num( "rp_bank_interval" ))
	dbi_query(dbc,query)
	whorobbank = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
}

// Robber was either killed or cuffed
public robbingbankdeathend(id,killer)
{
	new hudstring[256], name[33], killername[33], query[256]
	get_user_name(id,name,sizeof(name))
	get_user_name(killer,killername,sizeof(killername))
	format(hudstring,255,"Well.. Well.. it seems %s made a stop to %s's bank rob attempt!",killername,name)
	set_hudmessage(255,0,255,-1.0,0.35,0,0.0,8.0,0.0,0.0,1+2)
	show_hudmessage(0,hudstring)
	
	// LAWL ROB CODE HERE AGAIN
	new faak = find_ent_by_tname(-1,"bankdr")
	force_use(id,faak)
	fake_touch(faak,id)
	new faak2 = find_ent_by_tname(-1,"bankvault")
	force_use(id,faak2)
	fake_touch(faak2,id)
	nrobags = 0
	mdone[0] = 0
	mdone[1] = 0
	entity_set_origin(moneybag,borigin)
	entity_set_origin(moneybag2,borigin2)

	format(query,255,"UPDATE misc SET val=%i WHERE title='BankRob'",get_cvar_num( "rp_bank_interval" ))
	dbi_query(dbc,query)
	whorobbank = 0
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
}

public timer()
{
	if(whorobbank == 0)
	{
		return PLUGIN_HANDLED
	}
	if(whorobbank > 0)
	{
		finishtime -= 1
		if(finishtime <= 0)
		{
			robbingbanknaturalend(whorobbank)
			finishtime = 0
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}


/////////////////////////////////////////////////
// Transferring Money from robberies to player
////////////////////////////////////////////////

public robaction(id,wallet)
{
	new origin[3], authid[32], query[256]
	get_user_origin(id,origin)
	get_user_authid(id,authid,31)
	if(whorob711 == id && is_user_alive(id) == 1)
	{

		// If robber moves too far from register
		if(!allowed_npc_distance(id,get_cvar_num("rp_npcid_market")))
		{
			robbing711naturalend(id)
			client_print(id,print_chat,"[RobMOD] You've moved too far from the register, now RUN!^n")
		}

		// If wallet is full
		if((wallet + get_cvar_num( "rp_711_amount" )) > get_cvar_num("rp_walletlimit"))
		{
			robbing711naturalend(id)
			client_print(id,print_chat,"[RobMOD] Your wallet has no more room for more money, now hurry to an atm machine!^n")
		}

		// Pay the rob
		else
		{
			format( query, 255, "UPDATE money SET wallet=wallet+%i WHERE steamid='%s'", get_cvar_num( "rp_711_amount" ), authid)
			dbi_query( dbc, query)
			wallet3[id] += get_cvar_num( "rp_711_amount" )
			rob711currentcash -= get_cvar_num( "rp_711_amount" )
			robgain711 += get_cvar_num( "rp_711_amount" )
		}
		if(rob711currentcash <= 0)
		{
			robbing711naturalend(id)
			client_print(id,print_chat,"[RobMOD] You have cleared the register. Now run like hell!^n")
		}
	}
	if(whorobdiner == id && is_user_alive(id) == 1)
	{

		// If robber moves too far from register
		if(!allowed_npc_distance(id,get_cvar_num("rp_npcid_diner")))
		{
			robbingdinernaturalend(id)
			client_print(id,print_chat,"[RobMOD] You've moved too far from the register, now RUN!^n")
		}

		// If wallet is full
		if((wallet + get_cvar_num( "rp_diner_amount" )) > get_cvar_num("rp_walletlimit"))
		{
			robbingdinernaturalend(id)
			client_print(id,print_chat,"[RobMOD] Your wallet has no more room for more money, now hurry to an atm machine!^n")
		}

		// Pay the rob
		else
		{
			format( query, 255, "UPDATE money SET wallet=wallet+%i WHERE steamid='%s'", get_cvar_num( "rp_diner_amount" ), authid)
			dbi_query( dbc, query)
			wallet3[id] += get_cvar_num( "rp_diner_amount" )
			robdinercurrentcash -= get_cvar_num( "rp_diner_amount" )
			robgaindiner += get_cvar_num( "rp_diner_amount" )
		}
		if(robdinercurrentcash <= 0)
		{
			robbingdinernaturalend(id)
			client_print(id,print_chat,"[RobMOD] You have cleared the register. Now run like hell!^n")
		}
	}
	return PLUGIN_HANDLED
}


////////////////////////////////////
// Filling MCPD/Diner Cash Registers
///////////////////////////////////

public fillregisters()
{
	if(whorob711 == 0)
	{
		if(rob711currentcash <= get_cvar_num( "rp_711_maxium" ))
		{
			rob711currentcash += get_cvar_num( "rp_711_spawn" )
		}
	}
	if(whorobdiner == 0)
	{
		if(robdinercurrentcash <= get_cvar_num( "rp_diner_maxium" ))
		{
			robdinercurrentcash += get_cvar_num( "rp_diner_spawn" )
		}
	}
	if(whorobbank == 0)
	{
		new query[256]
		format(query,255,"SELECT val FROM misc WHERE title='BankRob'")
		result = dbi_query(dbc,query)
		if( dbi_nextrow( result ) > 0 )
		{
			new str[32], robtime
			dbi_field(result,1,str,31)
			dbi_free_result(result)
			robtime = str_to_num(str)
			if(robtime > 0)
			{
				format(query,255,"UPDATE misc SET val=val-1 WHERE title='BankRob'")
				dbi_query(dbc,query)
			}
		}
		else dbi_free_result(result)
	}		
	return PLUGIN_HANDLED	
}

// When a player gets killed, this is called!
public death_msg()
{
	new killer2 = read_data(1)
	new id = read_data(2)
	if(get_cvar_num("rp_nodeathmsg") == 1)
	{
		client_cmd(0, "clear")
		log_message("%s killed %s", killer2, id)
	}

	new authid[32], query[256]
	get_user_authid(id,authid,31)

	edit_value(id,"money","jail","=",0)
	edit_value(id,"money","hunger","=",0)

	cuffed[id] = 0 					
	client_cmd(id,"-speed")
	client_cmd(id,"-attack")
	client_cmd(id,"-attack2")
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)

	// If player was robbing the 7/11 make annoucment
	if(whorob711 == id)
	{
		new killer = read_data(1)
		robbing711deathend(id,killer)
	}
	if(whorobdiner == id)
	{
		new killer = read_data(1)
		robbingdinerdeathend(id,killer)
	}
	if(whorobbank == id)
	{
		new killer = read_data(1)
		robbingbankdeathend(id,killer)
	}

	// For removing money from wallet when dead!
	if( get_cvar_num( "rp_loose_cash") != 0 )
	{
		if(get_cvar_num("rp_loose_cash") == 1)
		{
			format(query,255,"UPDATE money SET wallet=0 WHERE steamid='%s'",authid)
			dbi_query(dbc,query)
			wallet3[id] = 0
		}
		else
		{
			format(query,255,"UPDATE money SET wallet=wallet-%i WHERE steamid='%s'",get_cvar_num("rp_loose_cash"),authid)
			dbi_query(dbc,query)
			wallet3[id] -= get_cvar_num("rp_loose_cash")
		}
	}


	/////////////////////
	// Removing Items
	////////////////////
	if(get_cvar_num("rp_loose_items") > 0)
	{
		if(is_user_database(id) == 0) return PLUGIN_HANDLED
		new itemfield[MAXIUMSTR]
		new currentamount = get_item_amount(id,get_cvar_num("rp_itemid_insurance"),"money")
		if(currentamount > 0)
		{
			set_item_amount(id,"-",get_cvar_num("rp_itemid_insurance"),1,"money")
			client_print(id,print_chat,"[ItemMod] Your insurance recovered your items^n")
			return PLUGIN_HANDLED
		}
			
		format(query,255,"SELECT items FROM money WHERE steamid='%s'",authid)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			dbi_field(result,1,itemfield,MAXIUMSTR-1)
			dbi_free_result(result)
		}
		else {
			dbi_free_result(result)
			return PLUGIN_HANDLED
		}
		new output[ITEMS][10]
		new total = explode(output,itemfield,' ')
		for(new i = 1;i < total; i++)
		{
			new output2[2][10]
			explode(output2,output[i],'|')
			format(query,255,"SELECT diedrop FROM items WHERE itemid=%i",str_to_num(output2[0]))
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new diedrop
				diedrop = dbi_field(result,1)
				dbi_free_result(result)
				if(diedrop > 0) item_drop(id,str_to_num(output2[0]),str_to_num(output2[1]),"Die")
			}
			else dbi_free_result(result)
		}
	}
	return PLUGIN_HANDLED
}

////////////////////////////////////
// Registeration Process
///////////////////////////////////
public registername(id)
{
	new name[64], password[64], query[256], authid[32]
	get_user_authid(id,authid,31)
	read_argv(1,name,63)
	read_argv(2,password,63)

	remove_quotes(name)
	trim(name)

	if(equali(name,"") || equali(password,""))
	{
		client_print(id,print_console,"Usage:  amx_regname <registername> <password>^n")
		return PLUGIN_HANDLED
	}
	if(containi(name,"'") != -1 || containi(password,"'") != -1)
	{
		client_print(id,print_console,"^n[AMXX] Registername and password may not contain character ' ^n")
		return PLUGIN_HANDLED
	}
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new oldname[64]
		dbi_field(result,1,oldname,63)
		dbi_free_result(result)
		if(!equali(oldname,""))
		{
			client_print(id,print_console,"[AMXX] You have already registered a username^n")
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)
	format(query,255,"SELECT * FROM money WHERE name='%s'",name)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		client_print(id,print_console,"[AMXX] Someone has already registered with the specified username^n")
		dbi_free_result(result)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)

	format(query,255,"SELECT * FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	new var = dbi_nextrow(result)
	dbi_free_result(result)
	if( var > 0 )
	{
	}
	else
	{
		format( query, 255, "INSERT INTO money (steamid,balance) VALUES('%s','%i')", authid,get_cvar_num("rp_startmoney"))
		dbi_query(dbc,query)
		balance3[id] = get_cvar_num("rp_startmoney")
		server_print( "[HarbuRP] %s was added to MySQL database!^n", authid)
	}

	format(query,255,"UPDATE money SET name='%s', password='%s' WHERE steamid='%s'",name,password,authid)
	dbi_query(dbc,query)
	client_print(id,print_console,"[AMXX] Registaration Sucsessful! Username: %s Password: %s^n",name,password)
	new currentname[64]
	get_user_name(id,currentname,63)
	remove_quotes(currentname) 
	if(equali(currentname,"Pub: ",5))
	{
		replace (currentname,63,"Pub: ","")
		set_user_info(id,"name",currentname)
	}
	return PLUGIN_HANDLED
}

public print_text(id)
{
	client_print(id,print_chat,"[AMXX] Write amx_regname <name> <password> in console to register and use plugins!^n")
	return PLUGIN_HANDLED
}

public print_commercial(id)
{
	engclient_print(id,engprint_console,"--------------------------------------------------------------------------------^n")
	engclient_print(id,engprint_console,"  Welcome to Red Dragon RP ^n")
	engclient_print(id,engprint_console,"  please Visit www.red-dragon-rp.de.vu ^n")
	engclient_print(id,engprint_console,"--------------------------------------------------------------------------------^n")
	return PLUGIN_HANDLED
}

public registerremind()
{
	new players[32],num
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ )
	{
		new var = is_user_database(players[i])
		if(var == 0)
		{
			print_text(players[i])
		}
	}
	return PLUGIN_HANDLED
}
		
		
	
public client_infochanged(id)
{
	new newname[33], oldname[33], authid[32], query[256]
	get_user_info(id, "name", newname,sizeof(newname)) 
	get_user_name(id,oldname,sizeof(oldname))
	get_user_authid(id,authid,31)
	set_task(3.0,"no_harbu",id)	
	if(equali(newname,"Pub: ",5)) return PLUGIN_HANDLED
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new regname[32]
		dbi_field(result,1,regname,31)
		dbi_free_result(result)
		if(equal(regname,""))
		{
			new changename[32]
			format(changename,31,"Pub: %s",newname)
			set_user_info(id,"name",changename)
			return PLUGIN_HANDLED
		}
		if(!equal(regname,""))
		{
			if(equali(newname,"Pub: ",5))
			{
				replace(newname,63,"Pub: ","")
				set_user_info(id,"name",newname)
				return PLUGIN_HANDLED
			}
				
			return PLUGIN_HANDLED
		}
	}
	else
	{
		dbi_free_result(result)
		new changename[32]
		format(changename,31,"Pub: %s",newname)
		set_user_info(id,"name",changename)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public no_shin(id)
{
	new newname[32], authid[32]
	get_user_info(id, "name", newname,sizeof(newname))
	get_user_authid(id,authid,31)
	if(containi(newname,"Shin") != -1 && !equali(authid,"STEAM_0:0:3062636"))
	{
		client_print(0,print_chat,"*** The name Shin is restricted. ***")
		set_user_info(id,"name","Player")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
	

//////////////////////////////////////////////////
// Item Mod 1.2
//
// Made by: Eric Andrews 'Harbu'
//
// Commands:
// --------------------------------
//  /items - open up the items menu
//
//  amx_additems - <player> <itemid> <amount>
//  amx_delitems - <player> <itemid> <amount>
//
/////////////////////////////////////////////////

// List items in console
public admin_listitems(id)
{
	new query[256]
	format(query,255,"SELECT itemid,title FROM items ORDER BY itemid")
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		client_print(id,print_console,"[AMXX] Error querying info from the MySQL Database^n")
		return PLUGIN_HANDLED
	}

	new rows = dbi_num_rows(result)
	client_print(id,print_console,"ItemID	Name^n")
	for(new i = 0; i < rows; i++)
	{
		new ItemID, title[32]
		ItemID = dbi_field(result,1)
		dbi_field(result,2,title,31)

		client_print(id,print_console,"%i	%s^n",ItemID,title)
		dbi_nextrow(result)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED

}

// Items Admin Commands
public admin_items(id)
{
	new authid[33]
	get_user_authid(id,authid,32)
	if(!(get_user_flags(id) & ADMIN_IMMUNITY) )
	{
		client_print(id, print_console, "[AMXX] You do not have access to this command!^n")
		return PLUGIN_HANDLED
	}
	new arg[32], arg2[32], arg3[32], command[32], name[33], tname[33], amount, itemid
	read_argv(0,command,31)
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	itemid = str_to_num(arg2)
	amount = str_to_num(arg3)

	if(equali(arg,"") || equali(arg2,"") || equali(arg3,"") || itemid == 0 || amount == 0) {
		client_print(id,print_console,"Usage:  %s <name or #userid> <ItemID> <amount>^n",command)
		return PLUGIN_HANDLED
	}
	new tid = cmd_target(id,arg,0)
	if(!tid) return PLUGIN_HANDLED

	get_user_name(tid,tname,sizeof(tname))
	get_user_name(id,name,sizeof(name))
	new output[64]
	select_string(id,"items","title","itemid",arg2,output)
	if(equali(output,"")) {
		client_print(id,print_console,"[AMXX] Invalid ItemID^n")
		return PLUGIN_HANDLED
	}
	if(equali(command,"amx_additems"))
	{
		set_item_amount(tid,"+",itemid,amount,"money")
		client_print(id,print_console,"[AMXX] Created %i x %s for player %s (ItemID %i)^n",amount,output,tname,itemid)
		client_print(tid,print_chat,"[ItemMod] Admin %s created %i x %s to your inventory^n",name,amount,output)
	}
	if(equal(command,"amx_delitems"))
	{
		new currentamount = get_item_amount(tid,itemid,"money")
		if(currentamount == 0) {
			client_print(id,print_console,"[AMXX] %s has none of the specified item^n",tname)
			return PLUGIN_HANDLED
		}
		if((currentamount-amount) < 0) {
			new hold = amount - currentamount
			amount -= hold
		}
		set_item_amount(tid,"-",itemid,amount,"money")

		client_print(id,print_console,"[AMXX] Destroyed %i x %s from player %s (ItemID %i)^n",amount,output,tname,itemid)
		client_print(tid,print_chat,"[ItemMod] Admin %s destroyed %i x %s from your inventory^n",name,amount,output)
	}
	return PLUGIN_HANDLED
}

// Count the amount of items
stock count_total_items( id )
{
	new query[256], authid[32]
	get_user_authid( id, authid, 31 );
	format(query,255,"SELECT items FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new field[MAXIUMSTR]
		new output[ITEMS][32]
		
		dbi_field(result,1,field,MAXIUMSTR-1)
		dbi_free_result(result)
		
		new total = explode(output,field,' ')
		return total;
	}
	
	return 0;
}
	



// Building up the menu
public build_itemmenu(id,currentpage)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	for(new i = 0; i < 10; i++)
	{
		g_itemholder[id][i][0] = 0
		g_itemholder[id][i][1] = 0
		g_itemholder[id][i][2] = 0
	}
	g_page[id] = currentpage
	new authid[32], query[256]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT items FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new field[MAXIUMSTR], beginid, endid, nextpage, numofitems
		new output[ITEMS][32]
		dbi_field(result,1,field,MAXIUMSTR-1)
		dbi_free_result(result)
		if(equal(field,""))
		{
			client_print(id,print_chat,"[ItemMod] You have no items in your inventory^n")
			return PLUGIN_HANDLED
		}
		new total = explode(output,field,' ')
		beginid = g_page[id] * 8
		if((beginid + 9) > total)
		{
			numofitems = total - beginid
			endid = numofitems + beginid
			nextpage = 0
		}
		if((beginid + 9) < total)
		{
			numofitems = 9
			endid = numofitems + beginid
			nextpage = 1
		}
		if((beginid + 9) == total)
		{
			numofitems = 9
			endid = numofitems + beginid
			nextpage = 0
		}
		new a = 1
		for( new i = beginid + 1;  i < endid; i++ )
		{
			new output2[2][32]
			explode(output2,output[i],'|')
			g_itemholder[id][a][0] = str_to_num(output2[0])
			g_itemholder[id][a][1] = str_to_num(output2[1])
			a++
		}
		show_itemmenu(id,nextpage,numofitems)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	print_text(id)
	return PLUGIN_HANDLED
}

// Gathering information about items then showing it
public show_itemmenu(id,nextpage,numofitems)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new itembody[1024], query[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new len = format(itembody,sizeof(itembody),"Inventory Menu - Page %i^n^n",g_page[id]+1)
	for(new i = 1; i < numofitems; i++)
	{
		format(query,255,"SELECT title FROM items WHERE itemid=%i",g_itemholder[id][i][0])
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new title[32]
			dbi_field(result,1,title,31)
			dbi_free_result(result)
			len += format(itembody[len],1023-len,"%i. %i x %s^n",i,g_itemholder[id][i][1],title)
		}
		else dbi_free_result(result)
	}
	if(nextpage == 1) add(itembody,sizeof(itembody),"^n9. Next Page")
	add(itembody,sizeof(itembody),"^n0. Close Inventory^n")
	g_isnextpage[id] = nextpage
	show_menu(id,key,itembody)
	return PLUGIN_HANDLED
}

public action_itemmenu(id,key)
{
	switch(key){
	case 0:{
		if(g_itemholder[id][1][0] > 0) use_item_show(id,g_itemholder[id][1][0],g_itemholder[id][1][1])
		else build_itemmenu(id,g_page[id])
	}
	case 1:{
		if(g_itemholder[id][2][0] > 0) use_item_show(id,g_itemholder[id][2][0],g_itemholder[id][2][1])
		else build_itemmenu(id,g_page[id])
	}
	case 2:{
		if(g_itemholder[id][3][0] > 0) use_item_show(id,g_itemholder[id][3][0],g_itemholder[id][3][1])
		else build_itemmenu(id,g_page[id])
	}
	case 3:{
		if(g_itemholder[id][4][0] > 0) use_item_show(id,g_itemholder[id][4][0],g_itemholder[id][4][1])
		else build_itemmenu(id,g_page[id])
	}
	case 4:{
		if(g_itemholder[id][5][0] > 0) use_item_show(id,g_itemholder[id][5][0],g_itemholder[id][5][1])
		else build_itemmenu(id,g_page[id])
	}
	case 5:{
		if(g_itemholder[id][6][0] > 0) use_item_show(id,g_itemholder[id][6][0],g_itemholder[id][6][1])
		else build_itemmenu(id,g_page[id])
	}
	case 6:{
		if(g_itemholder[id][7][0] > 0) use_item_show(id,g_itemholder[id][7][0],g_itemholder[id][7][1])
		else build_itemmenu(id,g_page[id])
	}
	case 7:{
		if(g_itemholder[id][8][0] > 0) use_item_show(id,g_itemholder[id][8][0],g_itemholder[id][8][1])
		else build_itemmenu(id,g_page[id])
	}
	case 8:{
		if(g_isnextpage[id] == 1) build_itemmenu(id,(g_page[id]+1))
		else build_itemmenu(id,g_page[id])
	}
	case 9:{
		return PLUGIN_HANDLED
	}
	}
	return PLUGIN_HANDLED
}

// When using one of the items
public use_item_show(id,item_id,item_amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new itembody[512], query[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9)
	format(query,255,"SELECT title FROM items WHERE itemid=%i",item_id)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new title[32]
		dbi_field(result,1,title,31)
		dbi_free_result(result)
		format(itembody,sizeof(itembody),"Item: %s ( x %i )^n^n",title,item_amount)
		add(itembody,sizeof(itembody),"1. Use^n")
		add(itembody,sizeof(itembody),"2. Give^n")
		add(itembody,sizeof(itembody),"3. Drop^n")
		add(itembody,sizeof(itembody),"4. Show^n")
		add(itembody,sizeof(itembody),"5. Examine^n^n")
		add(itembody,sizeof(itembody),"0. Close Menu^n")
		g_selecteditem[id][0] = item_id
		g_selecteditem[id][1] = item_amount
		show_menu(id,key,itembody)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

public action_item_use_menu(id,key)
{
	switch(key){
	case 0:{
		item_use(id,g_selecteditem[id][0])
	}
	case 1:{
		item_amount(id,g_selecteditem[id][0],1)
	}
	case 2:{
		item_amount(id,g_selecteditem[id][0],2)
	}
	case 3:{
		item_show(id,g_selecteditem[id][0],g_selecteditem[id][1])
	}
	case 4:{
		item_examine(id,g_selecteditem[id][0],g_selecteditem[id][1])
	}
	case 9:{
		return PLUGIN_HANDLED
	}
	}
	return PLUGIN_HANDLED
}

// Asking how many to drop/transfer
public item_amount(id,itemid,function)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new menu[256], key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), str[32], itemname[64], id_str[32]
	if(function == 1) format(str,sizeof(str),"Transfer")
	else format(str,sizeof(str),"Drop")
	num_to_str(itemid,id_str,31)
	select_string(id,"items","title","itemid",id_str,itemname)
	format(menu,sizeof(menu),"%s - %s^n^n",str,itemname)

	g_selecteditem[id][1] = function

	add(menu,sizeof(menu),"1. x 1^n")
	add(menu,sizeof(menu),"2. x 5^n")
	add(menu,sizeof(menu),"3. x 10^n")
	add(menu,sizeof(menu),"4. x 20^n")
	add(menu,sizeof(menu),"5. x 50^n")
	add(menu,sizeof(menu),"6. x 100^n")
	add(menu,sizeof(menu),"7. x All^n^n")
	add(menu,sizeof(menu),"0. x Close Menu^n")

	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public action_item_amount(id,key)
{
	key++
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(key == 10) return PLUGIN_HANDLED
	new amount
	if(key == 1) amount = 1
	else if(key == 2) amount = 5
	else if(key == 3) amount = 10
	else if(key == 4) amount = 20
	else if(key == 5) amount = 50
	else if(key == 6) amount = 100
	else if(key == 7) amount = get_item_amount(id,g_selecteditem[id][0],"money")
	if(amount > get_item_amount(id,g_selecteditem[id][0],"money")) {
			client_print(id,print_chat,"[ItemMod] You don't have specified amount of the item in your inventory")
			return PLUGIN_HANDLED
	}
	else
	{
		if(g_selecteditem[id][1] == 1) item_transfer(id,g_selecteditem[id][0],amount)
		if(g_selecteditem[id][1] == 2) item_drop(id,g_selecteditem[id][0],amount,"Menu")
	}
	return PLUGIN_HANDLED
}



// When using an item
public item_use(id,itemid)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(cuffed[id] == 1)
	{
 		client_print(id,print_chat,"[ItemMod] You cannot use items while cuffed")  
		return PLUGIN_HANDLED
	}
	new amount = get_item_amount(id,itemid,"money")
	if(amount == 0) return PLUGIN_HANDLED
	new query[256], itemname[32], function[64], useup, authid[32]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT title,command,useup FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,itemname,31)
		dbi_field(result,2,function,63)
		useup = dbi_field(result,3)
		dbi_free_result(result)
		if(equali(function,""))
		{
			client_print(id,print_chat,"[ItemMod] This item is not useable!^n")
			return PLUGIN_HANDLED
		}
		if(containi(function,"<name>") != -1)
		{
			new name[33]
			get_user_name(id,name,sizeof(name))
			replace(function,63,"<name>",name)
		}
		if(containi(function,"<targetid>") != -1)
		{
			if(!is_user_alive(id)) return PLUGIN_HANDLED
			new entid, entbody, buffer[32]
			get_user_aiming(id,entid,entbody,200)
			if(!is_user_connected(entid))
			{
				client_print(id,print_chat,"[ItemMod] You must be looking at another player^n")
				return PLUGIN_HANDLED
			}
			if(!is_user_alive(entid)) return PLUGIN_HANDLED
			num_to_str(entid,buffer,sizeof(buffer))
			replace(function,63,"<targetid>",buffer)
		}
		if(containi(function,"<itemname>") != -1)
		{
			replace(function,63,"<itemname>",itemname)
		}
		if(containi(function,"<id>") != -1)
		{
			new strid[32]
			num_to_str(id,strid,31)
			replace(function,63,"<id>",strid)
		}
		if(containi(function,"<itemid>") != -1)
		{
			new strid[32]
			num_to_str(itemid,strid,31)
			replace(function,63,"<itemid>",strid)
		}
		if(useup == 1)
		{
		new currentamount = get_item_amount(id,itemid,"money")
		if(currentamount <= 0) return PLUGIN_HANDLED
		set_item_amount(id,"-",itemid,1,"money")
		}
		server_cmd(function)
		server_exec()
		
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

// Giving an item to another person
public item_transfer(id,itemid,amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new authid[32], name[33], entid, entbody, authid2[32], name2[33], query[256], title[32], giveable
	get_user_name(id,name,sizeof(name))
	get_user_authid(id,authid,31)
	get_user_aiming(id,entid,entbody,150)
	if(!is_user_connected(entid))
	{
		client_print(id,print_chat,"[ItemMod] You must be looking at another player^n")
		return PLUGIN_HANDLED
	}
	if( count_total_items( entid ) > get_cvar_num( "rp_item_limit" ) )
	{
		client_print( id, print_chat, "[Prodigy Storage] Backpack is already full of items ( Limit %i )", get_cvar_num( "rp_item_limit" ) );
		return PLUGIN_HANDLED
	}
	get_user_name(entid,name2,sizeof(name2))
	get_user_authid(entid,authid2,31)
	format(query,255,"SELECT title,give FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,title,31)
		giveable = dbi_field(result,2)
		dbi_free_result(result)
		if(giveable == 0)
		{
			client_print(id,print_chat,"[ItemMod] This item is not giveable^n")
			return PLUGIN_HANDLED
		}
		new currentamount = get_item_amount(id,itemid,"money")
		if(currentamount <= 0) return PLUGIN_HANDLED
		set_item_amount(id,"-",itemid,amount,"money")

		set_item_amount(entid,"+",itemid,amount,"money")

		client_print(id,print_chat,"[ItemMod] Gave %i x %s to player %s^n",amount,title,name2)
		client_print(entid,print_chat,"** [ItemMod] Received %i x %s from player %s **^n",amount,title,name)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

// Dropping an item
public item_drop(id,itemid,amount,event[])
{
	if(equali(event,"Menu")) {
		if(!is_user_alive(id)) return PLUGIN_HANDLED
	}
	new query[256], drop, title[32], authid[32]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT title,dropable FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,title,31)
		drop = dbi_field(result,2)
		dbi_free_result(result)
		if(drop == 0)
		{
			client_print(id,print_chat,"[ItemMod] This item can't be dropped!^n")
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)
	new currentamount = get_item_amount(id,itemid,"money")
	if(currentamount <= 0) return PLUGIN_HANDLED
	set_item_amount(id,"-",itemid,amount,"money")

	// Getting the users origin
	new origin[3], Float:originF[3]
	get_user_origin(id,origin)
		
	originF[0] = float(origin[0])
	originF[1] = float(origin[1])
	originF[2] = float(origin[2])

	new item = create_entity("info_target")		// Create Entity

	if(!item) {	// Incase item for some reason was not created
	client_print(id,print_chat,"[ItemMod] Error #505. Please contact an administrator^n")
	return PLUGIN_HANDLED
	}

	// Sizes and Angles
	new Float:minbox[3] = { -2.5, -2.5, -2.5 }
	new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
	new Float:angles[3] = { 0.0, 0.0, 0.0 }

	angles[1] = float(random_num(0,270)) 

	entity_set_vector(item,EV_VEC_mins,minbox)
	entity_set_vector(item,EV_VEC_maxs,maxbox)
	entity_set_vector(item,EV_VEC_angles,angles)

	entity_set_float(item,EV_FL_dmg,0.0)
	entity_set_float(item,EV_FL_dmg_take,0.0)
	entity_set_float(item,EV_FL_max_health,99999.0)
	entity_set_float(item,EV_FL_health,99999.0)

	entity_set_int(item,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(item,EV_INT_movetype,MOVETYPE_TOSS)

	new itemstr[32]
	format(itemstr,31,"%i|%i",itemid,amount)

	entity_set_string(item,EV_SZ_targetname,itemstr)
	entity_set_string(item,EV_SZ_classname,"item_dropped")

	entity_set_model(item,"models/hwrp/w_backpack.mdl")
	entity_set_origin(item,originF)

	g_delay_item[id] = 2

	if(equali(event,"Menu"))
	{
		client_print(id,print_chat,"[ItemMod] You have dropped %i x %s^n",amount,title)
		emit_sound(id, CHAN_ITEM, "items/ammopickup1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	return PLUGIN_HANDLED
}

// Showing an item to another person
public item_show(id,itemid,amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new name[33], entid, entbody, name2[33], title[32], custom[256], query[256]
	get_user_aiming(id,entid,entbody,150)
	if(!is_user_connected(entid))
	{
		client_print(id,print_chat,"[ItemMod] You must be looking at another player^n")
		return PLUGIN_HANDLED
	}
	get_user_name(id,name,sizeof(name))
	get_user_name(entid,name2,sizeof(name2))
	format(query,255,"SELECT title,custom_show FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,title,31)
		dbi_field(result,2,custom,255)
		dbi_free_result(result)
		if(!equal(custom,""))
		{
			new command[64]
			format(command,63,"%s %s %s",custom,name,name2)
			server_cmd(command)
			server_exec()
			return PLUGIN_HANDLED
		}
		else
		{
			client_print(id,print_chat,"** [ItemMod] You show player %s your %s **^n",name2,title) // Hmm.. sounds strange :S
			client_print(entid,print_chat,"** [ItemMod] Player %s showed you his/her %s **^n",name,title)
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

// Examine Item
public item_examine(id,itemid,amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new query[256]
	format(query,255,"SELECT description FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new des[256]
		dbi_field(result,1,des,255)
		dbi_free_result(result)

		client_print(id,print_chat,"[ItemMod] %s^n",des)
		return PLUGIN_HANDLED
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}
new pickup[33]
// Picking up a dropped item
public item_pickup(entid,id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(g_delay_item[id] > 0) return PLUGIN_HANDLED
	if(pickup[id] == 1) return PLUGIN_HANDLED
	new authid[32], query[256], itemstr[32]
	get_user_authid(id,authid,31)
	entity_get_string(entid,EV_SZ_targetname,itemstr,31)
	new items_core[2][32]
	explode(items_core,itemstr,'|')
	if(is_user_database(id) == 0)
	{
		print_text(id)
		return PLUGIN_HANDLED
	}
	if( count_total_items( id ) > get_cvar_num( "rp_item_limit" ) )
	{
		client_print( id, print_chat, "[Prodigy Storage] Backpack is already full of items ( Limit %i )", get_cvar_num( "rp_item_limit" ) );
		pickup[id] = 1
		set_task(1.0,"unpickup",id)
		return PLUGIN_HANDLED
	}
	set_item_amount(id,"+",str_to_num(items_core[0]),str_to_num(items_core[1]),"money")
	format(query,255,"SELECT title FROM items WHERE itemid=%i",str_to_num(items_core[0]),"money")
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new title[32]
		dbi_field(result,1,title,31)
		dbi_free_result(result)
		client_print(id,print_chat,"[ItemMod] Picked up %i x %s^n",str_to_num(items_core[1]),title)
		emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(entid)
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}
public unpickup(id) pickup[id] = 0

///////////////////////////////////
// Shops for Item Mod
///////////////////////////////////

// Opens up a menu with the shop name and Buy and Examine Options
public shop_options(id,sellerid)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	g_shopid[id] = sellerid
	new itembody[512], query[256]
	new key = (1<<0|1<<1|1<<2|1<<9)

	format(query,255,"SELECT name FROM npc WHERE npcid=%i",g_shopid[id])
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new name[32]
		dbi_field(result,1,name,31)
		dbi_free_result(result)

		format(itembody,sizeof(itembody),"NPC: %s^n^n",name)
		add(itembody,sizeof(itembody),"1. Buy an item^n")
		add(itembody,sizeof(itembody),"2. Examine items^n")
		if(get_cvar_num("rp_npcid_market") == sellerid) {
			if(rob711currentcash >= get_cvar_num( "rp_711_minium" ) && temptime711rob == 0 && whorob711 <= 0 )
			{
				add(itembody,sizeof(itembody),"3. Rob^n")
			}
		}
		if(get_cvar_num("rp_npcid_diner") == sellerid) {
			if(robdinercurrentcash >= get_cvar_num( "rp_diner_minium" ) && temptimedinerrob == 0 && whorobdiner <= 0 )
			{
				add(itembody,sizeof(itembody),"3. Rob^n")
			}
		}
			
		add(itembody,sizeof(itembody),"0. Close Menu")

		show_menu(id,key,itembody)
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

public shop_options_actions(id,key)
{
	switch(key){
	case 0:{
		shop_build(id,0)
		g_shopfunc[id] = 1
	}
	case 1:{
		shop_build(id,0)
		g_shopfunc[id] = 2
	}
	case 2:{
		if(get_cvar_num("rp_npcid_market") == g_shopid[id]) {
			if(rob711currentcash >= get_cvar_num( "rp_711_minium" ) && temptime711rob == 0 && whorob711 <= 0  )
			{
				rob(id)
			}
		}
		if(get_cvar_num("rp_npcid_diner") == g_shopid[id]) {
			if(robdinercurrentcash >= get_cvar_num( "rp_diner_minium" ) && temptimedinerrob == 0 && whorobdiner <= 0 )
			{
				rob(id)
			}
		}
		else shop_options(id,g_shopid[id])
	}
	}
	return PLUGIN_HANDLED
}

// Building the shop items
public shop_build(id,currentpage)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	for(new i = 0; i < 10; i++)
	{
		g_itemholder[id][i][0] = 0
		g_itemholder[id][i][1] = 0
		g_itemholder[id][i][2] = 0
	}
	g_page[id] = currentpage
	new query[256]
	format(query,255,"SELECT itemids,quantities,prices FROM npc WHERE npcid=%i",g_shopid[id])
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new itemids[256], quantities[256], prices[256]
		dbi_field(result,1,itemids,255)
		dbi_field(result,2,quantities,255)
		dbi_field(result,3,prices,255)
		dbi_free_result(result)

		new output_itemid[ITEMS][10], output_quantity[ITEMS][10], output_price[ITEMS][10]
		new total = explode(output_itemid,itemids,'|')
		explode(output_quantity,quantities,'|')
		explode(output_price,prices,'|')
		new beginid = g_page[id] * 8
		new a = 0
		for(new i = beginid; i < (beginid + 9); i++)
		{
			if(i >= total) break
			g_itemholder[id][a][0] = str_to_num(output_itemid[i])
			g_itemholder[id][a][1] = str_to_num(output_quantity[i])
			g_itemholder[id][a][2] = str_to_num(output_price[i])
			a++
		}
	}
	else dbi_free_result(result)
	shop_show(id)
	return PLUGIN_HANDLED
}

// Showing the shop items
public shop_show(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new itembody[1024], query[256]
	new len = format(itembody,sizeof(itembody),"Items for Sale - Page %i^n^n",g_page[id]+1)
	for(new i = 0; i < 8; i++)
	{
		if(g_itemholder[id][i][0] == 0) break
		format(query,255,"SELECT title FROM items WHERE itemid=%i",g_itemholder[id][i][0])
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new title[32]
			dbi_field(result,1,title,31)
			dbi_free_result(result)
			if(g_itemholder[id][i][1] == 1) len += format(itembody[len],1023-len,"%i. %s ($%i)^n",i+1,title,g_itemholder[id][i][2])
			else len += format(itembody[len],1023-len,"%i. %i x %s ($%i)^n",i+1,g_itemholder[id][i][1],title,g_itemholder[id][i][2])
		}
		else dbi_free_result(result)
	}
	if(g_itemholder[id][8][0] > 0)
	{
		add(itembody,sizeof(itembody),"9. Next Page^n")
	}
	add(itembody,sizeof(itembody),"^n^n0. Close Menu")
	show_menu(id,key,itembody)
	return PLUGIN_HANDLED
}

public shop_show_action(id,key)
{
	switch(key){
	case 0:{
		if(g_itemholder[id][0][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][0][0],g_itemholder[id][0][1],g_itemholder[id][0][2])
		else shop_build(id,g_page[id])
	}
	case 1:{
		if(g_itemholder[id][1][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][1][0],g_itemholder[id][1][1],g_itemholder[id][1][2])
		else shop_build(id,g_page[id])
	}
	case 2:{
		if(g_itemholder[id][2][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][2][0],g_itemholder[id][2][1],g_itemholder[id][2][2])
		else shop_build(id,g_page[id])
	}
	case 3:{
		if(g_itemholder[id][3][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][3][0],g_itemholder[id][3][1],g_itemholder[id][3][2])
		else shop_build(id,g_page[id])
	}
	case 4:{
		if(g_itemholder[id][4][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][4][0],g_itemholder[id][4][1],g_itemholder[id][4][2])
		else shop_build(id,g_page[id])
	}
	case 5:{
		if(g_itemholder[id][5][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][5][0],g_itemholder[id][5][1],g_itemholder[id][5][2])
		else shop_build(id,g_page[id])
	}
	case 6:{
		if(g_itemholder[id][6][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][6][0],g_itemholder[id][6][1],g_itemholder[id][6][2])
		else shop_build(id,g_page[id])
	}
	case 7:{
		if(g_itemholder[id][7][0] > 0) shop_buy(id,g_shopfunc[id],g_itemholder[id][7][0],g_itemholder[id][7][1],g_itemholder[id][7][2])
		else shop_build(id,g_page[id])
	}
	case 8:{
		if(g_itemholder[id][8][0] > 0) shop_build(id,(g_page[id]+1))
		else shop_build(id,g_page[id])
	}
	}
	return PLUGIN_HANDLED
}

// The actual function of buying/examining the weapons
public shop_buy(id,function,itemid,amount,price)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new authid[32], query[256], origin[3]
	get_user_origin(id,origin)
	get_user_authid(id,authid,31)
	
	format(query,255,"SELECT x,y,z FROM npc WHERE npcid=%i",g_shopid[id])
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new n_origin[3]

		n_origin[0] = dbi_field(result,1)
		n_origin[1] = dbi_field(result,2)
		n_origin[2] = dbi_field(result,3)

		dbi_free_result(result)
		if(get_distance(origin,n_origin) > 25.0) return PLUGIN_HANDLED

	}
	else return PLUGIN_HANDLED


	format(query,255,"SELECT title,description FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new title[32], description[256]
		dbi_field(result,1,title,31)
		dbi_field(result,2,description,255)
		dbi_free_result(result)
		if(function == 1)
		{
			if(wallet3[id] < price)
			{
				client_print(id,print_chat,"[EconomyMod] You don't have enough money in your wallet to buy this item^n")
				return PLUGIN_HANDLED
			}
			if( count_total_items( id ) > get_cvar_num( "rp_item_limit" ) )
			{
				client_print( id, print_chat, "[Prodigy Storage] Backpack is already full of items ( Limit %i )", get_cvar_num( "rp_item_limit" ) );
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","wallet","-",price)
			wallet3[id] -= price

			new output[64], npcid_str[32]
			num_to_str(g_shopid[id],npcid_str,63)
			select_string(id,"npc","doorname","npcid",npcid_str,output)
			if(!equali(output,""))
			{
				format(query,255,"UPDATE property SET profit=profit+%i WHERE doorname='%s'",price/2,output)
				dbi_query(dbc,query)
			}

			set_item_amount(id,"+",itemid,amount,"money")
			client_print(id,print_chat,"[EconomyMod] Bought %i x %s for $%i^n",amount,title,price)
			return PLUGIN_HANDLED
		}
		if(function == 2)
		{
			client_print(id,print_chat,"[ItemMod] %s^n",description)
			return PLUGIN_HANDLED
		}
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

// Bank NPC'S
public Bank_Npc(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new bankbody[256], origin[3]
	get_user_origin(id,origin)
	new key = (1<<0|1<<1|1<<2|1<<3|1<<9)
	format(bankbody,sizeof(bankbody),"Nations Bank Employee^n^n")

	add(bankbody,sizeof(bankbody),"1. Deposit/Withdraw^n")
	add(bankbody,sizeof(bankbody),"2. Transfer Money^n")
	add(bankbody,sizeof(bankbody),"3. Buy ATM Card ($10 from bank)^n")
	
	/*new query[256]
	format(query,255,"SELECT val FROM misc WHERE title='BankRob'")
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 )
	{
		new str[32], robtime
		dbi_field(result,1,str,31)
		dbi_free_result(result)
		robtime = str_to_num(str)
		if(robtime <= 0)
		{
			add(bankbody,sizeof(bankbody),"4. Rob^n")
		}
	}
	else dbi_free_result(result)*/
	add(bankbody,sizeof(bankbody),"^n0. Close Menu")
	show_menu(id,key,bankbody)
	return PLUGIN_HANDLED
}

public bank_npc_action(id,key)
{
	new origin[3]
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_one")) || allowed_npc_distance(id,get_cvar_num("rp_npcid_bank_two")))
	{
		switch(key){
		case 0:{
			client_print(id,print_chat,"[Bank] Write /withdraw amount or /deposit amount^n")
		}
		case 1:{
			client_print(id,print_chat,"[Bank] Transfer money by typing /transfer player amount^n")
		}
		case 2:{
			new query[256], authid[32]
			get_user_authid(id,authid,31)
			if(balance3[id] < 10) {
				client_print(id,print_chat,"[Bank] Not enough money in bank to buy one^n")
				return PLUGIN_HANDLED
			}
			if( count_total_items( id ) > get_cvar_num( "rp_item_limit" ) )
			{
				client_print( id, print_chat, "[Prodigy Storage] Backpack is already full of items ( Limit %i )", get_cvar_num( "rp_item_limit" ) );
				return PLUGIN_HANDLED
			}
			edit_value(id,"money","balance","-",10)
			balance3[id] -= 10
			new output[64]
			select_string(id,"npc","doorname","npcid","BANKNPC",output)
			if(!equali(output,""))
			{
				format(query,255,"UPDATE property SET profit=profit+%i WHERE doorname='%s'",10,output)
				dbi_query(dbc,query)
			}
			dbi_query(dbc,query)
			set_item_amount(id,"+",get_cvar_num("rp_itemid_atmcard"),1,"money")
			client_print(id,print_chat,"[Bank] ATM Card succesfully purchased!^n")
		}
		case 3:{
				new query[256]
				format(query,255,"SELECT val FROM misc WHERE title='BankRob'")
				result = dbi_query(dbc,query)
				if( dbi_nextrow( result ) > 0 )
				{
					new str[32], robtime
					dbi_field(result,1,str,31)
					dbi_free_result(result)
					robtime = str_to_num(str)
					if(robtime <= 0)
					{
						rob(id)
					}
					else Bank_Npc(id)
				}
				else dbi_free_result(result)
			}
	}
	}
	return PLUGIN_HANDLED
}

////////////////////////////////
// PRODIGY STORAGE CODE
///////////////////////////////

public prodigy(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(!is_user_database(id)) {
		print_text(id)
		return PLUGIN_HANDLED
	}
	for(new i = 0; i < 10; i++)
	{
		g_itemholder[id][i][0] = 0
		g_itemholder[id][i][1] = 0
		g_itemholder[id][i][2] = 0
	}
	new authid[32], query[256], prodigy_body[512], origin[3]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<9)
	g_prodigy_time[id] = 0
	g_prodigy_func[id] = 0
	g_prodigy_sel[id] = 0
	get_user_origin(id,origin)
	if(!allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy")) && get_distance(origin,Storageone) > 20.0 && get_distance(origin,Storagetwo) > 20.0 && get_distance(origin,Storagethree) > 20.0 && get_distance(origin,Storagefour) > 20.0 && get_distance(origin,Storagefive) > 20.0 ) return PLUGIN_HANDLED
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy")) <= 25.0) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefive) <= 20.0) format(authid,31,"STEAM_MCMD")

	new len = format(prodigy_body,sizeof(prodigy_body),"Prodigy Employee^n^n")
	format(query,255,"SELECT minutes FROM prodigy WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		g_prodigy_time[id] = dbi_field(result,1)
		dbi_free_result(result)
		if(g_prodigy_time[id] <= 0)
		{
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"Continue your current account.^n")
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"If you had items on your account^n")
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"you can deposit/withdraw them!^n^n")
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"1. Bronze Account ($%i)^n",get_cvar_num("rp_prodigy_price_bronze"))
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"2. Silver Account ($%i)^n",get_cvar_num("rp_prodigy_price_silver"))
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"3. Gold Account ($%i)^n",get_cvar_num("rp_prodigy_price_gold"))
			len += format(prodigy_body[len],sizeof(prodigy_body)-len,"4. Platinum Account ($%i)^n",get_cvar_num("rp_prodigy_price_platinum"))
		}
		if(g_prodigy_time[id] > 0)
		{
			add(prodigy_body,sizeof(prodigy_body),"1. Deposit Items^n")
			add(prodigy_body,sizeof(prodigy_body),"2. Withdraw Items^n")
			add(prodigy_body,sizeof(prodigy_body),"3. Examine Items^n")
			add(prodigy_body,sizeof(prodigy_body),"4. Storage Status^n")
		}
	}
	else
	{
		dbi_free_result(result)
		len += format(prodigy_body[len],sizeof(prodigy_body)-len,"1. Open Bronze Account ($%i)^n",get_cvar_num("rp_prodigy_price_bronze"))
		len += format(prodigy_body[len],sizeof(prodigy_body)-len,"2. Open Silver Account ($%i)^n",get_cvar_num("rp_prodigy_price_silver"))
		len += format(prodigy_body[len],sizeof(prodigy_body)-len,"3. Open Gold Account ($%i)^n",get_cvar_num("rp_prodigy_price_gold"))
		len += format(prodigy_body[len],sizeof(prodigy_body)-len,"4. Open Platinum Account ($%i)^n",get_cvar_num("rp_prodigy_price_platinum"))
		g_prodigy_time[id] = 0
	}
	add(prodigy_body,sizeof(prodigy_body),"^n0. Close Menu")
	show_menu(id,key,prodigy_body)
	return PLUGIN_HANDLED
}

public action_prodigy(id,key)
{
	new origin[3]
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy")) || get_distance(origin,Storageone) <= 20.0 || get_distance(origin,Storagetwo) <= 20.0 || get_distance(origin,Storagethree) <= 20.0 || get_distance(origin,Storagefour) <= 20.0 || get_distance(origin,Storagefive) <= 20.0 )
	{
		switch(key){
		case 0:{
			if(g_prodigy_time[id] <= 0) Prodigy_Buy(id,get_cvar_num("rp_prodigy_price_bronze"),get_cvar_num("rp_prodigy_min_bronze"),"Bronze",get_cvar_num("rp_prodigy_limit_bronze"))
			else if(g_prodigy_time[id] > 0) Prodigy_Build(id,0,1)
		}
		case 1:{
			if(g_prodigy_time[id] <= 0) Prodigy_Buy(id,get_cvar_num("rp_prodigy_price_silver"),get_cvar_num("rp_prodigy_min_silver"),"Silver",get_cvar_num("rp_prodigy_limit_silver"))
			else if(g_prodigy_time[id] > 0) Prodigy_Build(id,0,2)
		}
		case 2:{
			if(g_prodigy_time[id] <= 0) Prodigy_Buy(id,get_cvar_num("rp_prodigy_price_gold"),get_cvar_num("rp_prodigy_min_gold"),"Gold",get_cvar_num("rp_prodigy_limit_gold"))
			else if(g_prodigy_time[id] > 0) Prodigy_Build(id,0,3)
		}
		case 3:{
			if(g_prodigy_time[id] <= 0) Prodigy_Buy(id,get_cvar_num("rp_prodigy_price_platinum"),get_cvar_num("rp_prodigy_min_platinum"),"Platinum",get_cvar_num("rp_prodigy_limit_platinum"))
			else if(g_prodigy_time[id] > 0) Prodigy_Status(id)
		}
		}
	}
	return PLUGIN_HANDLED
}

// Buying time for Prodigy
public Prodigy_Buy(id,price,minutes,Account[],Slots)
{
	new query[256], authid[32], authid2[32]
	get_user_authid(id,authid2,31)
	new origin[3]
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy"))) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_MCMD")
	if(wallet3[id] < price) {
		client_print(id,print_chat,"^n[Prodigy Shop] Not enough money in your wallet^n")
		return PLUGIN_HANDLED
	}
	format(query,255,"SELECT items FROM prodigy WHERE steamid='%s'",authid2)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0) format(query,255,"UPDATE prodigy SET minutes=%i, account='%s', Slots=%i WHERE steamid='%s'",minutes,Account,Slots,authid)
	else format(query,255,"INSERT INTO prodigy (steamid,minutes,account,slots) VALUES('%s',%i,'%s',%i)",authid,minutes,Account,Slots)
	dbi_free_result(result)

	dbi_query(dbc,query)
	edit_value(id,"money","wallet","-",price)
	wallet3[id] -= price
	new output[64]
	select_string(id,"npc","doorname","npcid","PRODIGYNPC",output)
	if(!equali(output,""))
	{
		format(query,255,"UPDATE property SET profit=profit+%i WHERE doorname='%s'",price/4,output)
		dbi_query(dbc,query)
	}
	dbi_query(dbc,query)
	client_print(id,print_chat,"^n[Prodigy Storage] Purchased a %s Account (%i Minutes)^n",Account,minutes)
	return PLUGIN_HANDLED
}

// Building the items in storage
public Prodigy_Build(id,currentpage,Func)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	for(new i = 0; i < 10; i++)
	{
		g_itemholder[id][i][0] = 0
		g_itemholder[id][i][1] = 0
		g_itemholder[id][i][2] = 0
	}
	g_page[id] = currentpage
	new query[MAXIUMSTR+20], itemfield[MAXIUMSTR], authid[32], beginid, authid2[32], origin[3]
	get_user_authid(id,authid2,31)
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy"))) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefive) <= 20.0) format(authid,31,"STEAM_MCMD")
	if(Func == 1) format(query,sizeof(query)+19,"SELECT items FROM money WHERE steamid='%s'",authid2)
	else format(query,sizeof(query)+19,"SELECT items FROM prodigy WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,itemfield,MAXIUMSTR-1)
		dbi_free_result(result)
	}
	else dbi_free_result(result)
	if(equal(itemfield,""))
	{
		if(Func == 1) client_print(id,print_chat,"[Prodigy Storage] You have no items in your inventory^n")
		else client_print(id,print_chat,"[Prodigy Storage] You have no items in storage^n")
		return PLUGIN_HANDLED
	}
	new output[ITEMS][10]
	new total = explode(output,itemfield,' ')
	beginid = g_page[id] * 8
	new a = 0
	for(new i = beginid; i < (beginid + 10); i++)
	{
		if(i >= total) break
		new output2[2][10]
		explode(output2,output[i],'|')
		g_itemholder[id][a][0] = str_to_num(output2[0])
		g_itemholder[id][a][1] = str_to_num(output2[1])
		a++
	}
	g_prodigy_func[id] = Func
	Prodigy_Show(id)
	return PLUGIN_HANDLED
}

// Showing the Items List
public Prodigy_Show(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new itembody[1024], query[256], string[32]
	if(g_prodigy_func[id] == 1) format(string,31,"Inventory")
	else format(string,31,"Storage")
	new len = format(itembody,sizeof(itembody),"Prodigy Store (%s) - Page %i^n^n",string,g_page[id]+1)
	for(new i = 1; i < 9; i++)
	{
		if(g_itemholder[id][i][0] == 0) break
		format(query,255,"SELECT title FROM items WHERE itemid=%i",g_itemholder[id][i][0])
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			new title[32]
			dbi_field(result,1,title,31)
			dbi_free_result(result)
			if(g_itemholder[id][i][1] == 1) len += format(itembody[len],1023-len,"%i. %i x %s^n",i,g_itemholder[id][i][1],title)
			else len += format(itembody[len],1023-len,"%i. %i x %s^n",i,g_itemholder[id][i][1],title)
		}
		else dbi_free_result(result)
	}
	if(g_itemholder[id][9][0] > 0)
	{
		add(itembody,sizeof(itembody),"9. Next Page^n")
	}
	add(itembody,sizeof(itembody),"^n0. Close Menu")
	show_menu(id,key,itembody)
	return PLUGIN_HANDLED
}

public Prodigy_Show_Action(id,key)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new origin[3]
	get_user_origin(id,origin)
	key++
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy")) || get_distance(origin,Storageone) <= 20.0 || get_distance(origin,Storagetwo) <= 20.0 || get_distance(origin,Storagethree) <= 20.0 || get_distance(origin,Storagefour) <= 20.0 || get_distance(origin,Storagefive) <= 20.0 )
	{
		if(key >= 0 && key <= 8)
		{
			if(g_itemholder[id][key][0] > 0) Prodigy_Amount_Menu(id,g_itemholder[id][key][0])
			else Prodigy_Build(id,g_page[id],g_prodigy_func[id])
		}
		if(key == 9)
		{
			if(g_itemholder[id][9][0] > 0) Prodigy_Build(id,(g_page[id]+1),g_prodigy_func[id])
			else Prodigy_Build(id,g_page[id],g_prodigy_func[id])
		}
	}
	return PLUGIN_HANDLED
}

// Asking how many to deposit
public Prodigy_Amount_Menu(id,itemid)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(g_prodigy_func[id] == 3) {
		Prodigy_Function(id,itemid,1)
		Prodigy_Build(id,g_page[id],g_prodigy_func[id])
		return PLUGIN_HANDLED
	}
	new menu[256], key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), str[32], itemname[64], id_str[32]
	if(g_prodigy_func[id] == 1) format(str,sizeof(str),"Deposit")
	else format(str,sizeof(str),"Withdraw")
	num_to_str(itemid,id_str,31)
	select_string(id,"items","title","itemid",id_str,itemname)
	format(menu,sizeof(menu),"%s - %s^n^n",str,itemname)

	g_prodigy_sel[id] = itemid

	add(menu,sizeof(menu),"1. x 1^n")
	add(menu,sizeof(menu),"2. x 5^n")
	add(menu,sizeof(menu),"3. x 10^n")
	add(menu,sizeof(menu),"4. x 20^n")
	add(menu,sizeof(menu),"5. x 50^n")
	add(menu,sizeof(menu),"6. x 100^n")
	add(menu,sizeof(menu),"7. x All^n^n")
	add(menu,sizeof(menu),"0. x Close Menu^n")

	show_menu(id,key,menu)
	return PLUGIN_HANDLED
}

public Action_Amount_Menu(id,key)
{
	key++
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(key == 10) return PLUGIN_HANDLED
	new origin[3], authid[32]
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy"))) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefive) <= 20.0) format(authid,31,"STEAM_MCMD")
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy")) || get_distance(origin,Storageone) <= 20.0 || get_distance(origin,Storagetwo) <= 20.0 || get_distance(origin,Storagethree) <= 20.0 || get_distance(origin,Storagefour) <= 20.0 || get_distance(origin,Storagefive) <= 20.0 )
	{
		new amount
		if(key == 1) amount = 1
		else if(key == 2) amount = 5
		else if(key == 3) amount = 10
		else if(key == 4) amount = 20
		else if(key == 5) amount = 50
		else if(key == 6) amount = 100
		else if(key == 7)
		{
			if(g_prodigy_func[id] == 1) amount = get_item_amount(id,g_prodigy_sel[id],"money")
			else if(g_prodigy_func[id] == 2) amount = get_item_amount(id,g_prodigy_sel[id],"prodigy",authid)
		}
		if(g_prodigy_func[id] == 1)
		{
			if(amount > get_item_amount(id,g_prodigy_sel[id],"money")) {
				client_print(id,print_chat,"[Prodigy Storage] You don't have specified amount of the item in your inventory")
				return PLUGIN_HANDLED
			}
			else Prodigy_Function(id,g_prodigy_sel[id],amount)
		}
		else if(g_prodigy_func[id] == 2)
		{
			if(amount > get_item_amount(id,g_prodigy_sel[id],"prodigy",authid)) {
				client_print(id,print_chat,"[Prodigy Storage] You don't have specified amount of the item in your storage")
				return PLUGIN_HANDLED
			}
			else Prodigy_Function(id,g_prodigy_sel[id],amount)
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

			

// Actual Code for transfering items into and outof the Prodigy Storage
public Prodigy_Function(id,itemid,amount)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new authid[32], query[256], origin[3]
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy"))) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefive) <= 20.0) format(authid,31,"STEAM_MCMD")
	format(query,255,"SELECT title,description FROM items WHERE itemid=%i",itemid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		new title[32], description[256]
		dbi_field(result,1,title,31)
		dbi_field(result,2,description,255)
		dbi_free_result(result)
		if(g_prodigy_func[id] == 1)
		{
			format(query,255,"SELECT items,slots FROM prodigy WHERE steamid='%s'",authid)
			result = dbi_query(dbc,query)
			if(dbi_nextrow(result) > 0)
			{
				new slots, itemfield[MAXIUMSTR], output[ITEMS][10]
				dbi_field(result,1,itemfield,MAXIUMSTR-1)
				slots = dbi_field(result,2)
				dbi_free_result(result)

				new total = explode(output,itemfield,' ')


				if(total > slots) {
					client_print(id,print_chat,"[Prodigy Store] Your storage space is full. Withdraw some items to clean up^n")
					return PLUGIN_HANDLED
				}
			}
			else {
				dbi_free_result(result)
				return PLUGIN_HANDLED
			}

			set_item_amount(id,"+",itemid,amount,"prodigy",authid)
			set_item_amount(id,"-",itemid,amount,"money")

			client_print(id,print_chat,"[Prodigy Storage] Deposited %i x %s^n",amount,title)
		}
		if(g_prodigy_func[id] == 2)
		{	
			if( count_total_items( id ) > get_cvar_num( "rp_item_limit" ) )
			{
				client_print( id, print_chat, "[Prodigy Storage] Backpack is already full of items ( Limit %i )", get_cvar_num( "rp_item_limit" ) );
				return PLUGIN_HANDLED
			}
			set_item_amount(id,"+",itemid,amount,"money")
			set_item_amount(id,"-",itemid,amount,"prodigy",authid)

			client_print(id,print_chat,"[Prodigy Storage] Withdrawn %i x %s^n",amount,title)
		}
		if(g_prodigy_func[id] == 3)
		{
			client_print(id,print_chat,"[ItemMod] %s^n",description)
		}
	}
	else dbi_free_result(result)
	return PLUGIN_HANDLED
}

// Remove time from Prodigy storage time from players that are online
public prodigytime()
{
	new players[32], num, query[256]
	get_players(players,num,"c")
	for(new i = 0; i < num;i++)
	{
		new authid[32], minutes
		get_user_authid(players[i],authid,31)
		format(query,255,"SELECT minutes FROM prodigy WHERE steamid='%s'",authid)
		result = dbi_query(dbc,query)
		if(dbi_nextrow(result) > 0)
		{
			minutes = dbi_field(result,1)
			dbi_free_result(result)
			if(minutes > 0)
			{
				format(query,255,"UPDATE prodigy SET minutes=minutes-10 WHERE steamid='%s'",authid)
				dbi_query(dbc,query)
			}
		}
		else dbi_free_result(result)
	}
	return PLUGIN_HANDLED
}

public Prodigy_Status(id)
{
	new name[33], authid[32], minutes, itemfield[MAXIUMSTR], query[MAXIUMSTR+20], account[32], slots,origin[3]

	get_user_name(id,name,sizeof(name))
	get_user_origin(id,origin)
	if(allowed_npc_distance(id,get_cvar_num("rp_npcid_prodigy"))) get_user_authid(id,authid,31)
	if(get_distance(origin,Storageone) <= 20.0) format(authid,31,"STEAM_MCPD")
	if(get_distance(origin,Storagetwo) <= 20.0) format(authid,31,"STEAM_APPARTMENT_A")
	if(get_distance(origin,Storagethree) <= 20.0) format(authid,31,"STEAM_APPARTMENT_B")
	if(get_distance(origin,Storagefour) <= 20.0) format(authid,31,"STEAM_APPARTMENT_C")
	if(get_distance(origin,Storagefive) <= 20.0 ) format(authid,31,"STEAM_MCMD")
	format(query,255,"SELECT minutes,items,account,slots FROM prodigy WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		minutes = dbi_field(result,1)
		dbi_field(result,2,itemfield,MAXIUMSTR-1)
		dbi_field(result,3,account,31)
		slots = dbi_field(result,4)
		dbi_free_result(result)
	}
	else dbi_free_result(result)
	new output[ITEMS][10]
	new total = explode(output,itemfield,' ')

	new status[512]
	new len = format(status,511,"Name: %s^n^n",name)
	len += format(status[len],511-len,"SteamID: %s^n^n",authid)
	len += format(status[len],511-len,"Minutes Left: %i^n^n",minutes)
	len += format(status[len],511-len,"Storage Status/Capacity: %i items out of %i^n^n",total-1,slots)
	len += format(status[len],511-len,"Account Type: %s^n^n",account)
	show_motd(id,status,"PRODIGY STORAGE STATUS")
	return PLUGIN_HANDLED
}


/////////////////////////////////////////////
// Hunger Mod Alpha 1
//
// Written by: Eric Andrews aka Harbu
////////////////////////////////////////////

public hunger()
{
	new players[32], num
	get_players(players,num,"ac")
	for(new i = 0; i < num;i++)
	{
		new ran = random_num(1,6)
		if(ran == 1)
		{
			if(is_user_database(players[i]) == 1)
			{
				edit_value(players[i],"money","hunger","+",random_num(1,5))
				new query[256], authid[32]
				get_user_authid(players[i],authid,31)
				format(query,255,"SELECT hunger FROM money WHERE steamid='%s'",authid)
				result = dbi_query(dbc,query)
				if(dbi_nextrow(result) > 0)
				{
					new currenthunger = dbi_field(result,1)
					dbi_free_result(result)
					if(currenthunger >= 100)
					{
						client_print(players[i],print_chat,"[HungerMod] You died because of hunger!^n")
						user_kill(players[i])
					}
				}
				dbi_free_result(result)
			}
		}
	}
	return PLUGIN_HANDLED
}

public spawn_remove(id)
{
	new origin[3], classname[32], Float:forigin[3]
	get_user_origin(id,origin)
	forigin[0] = float(origin[0])
	forigin[1] = float(origin[1])
	forigin[2] = float(origin[2])
	new ent = find_ent_in_sphere(-1,forigin,20.0)
	if(!ent) return PLUGIN_HANDLED
	entity_get_string(ent,EV_SZ_classname,classname,31)
	if(equali(classname,"ts_groundweapon")) {
		client_print(id,print_console,"[AMXX] Weaponspawn successfully removed!")
		remove_entity(ent)
	}
	else client_print(id,print_console,"[AMXX] No weaponspawn found in your players positions range")
	return PLUGIN_HANDLED
}

////////////////////////
// Laptop Mod
///////////////////////

public laptop_leet_guess(id)
{
	new body[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)

	new len = format(body,sizeof(body),"RDRP Laptop (Amd Athlon 64 x2 3200+)^n")
	len += format(body[len],sizeof(body)-len,"---------------------------------------^n")
	len += format(body[len],sizeof(body)-len,"              .%i.%i.%i.%i.%i.        ^n",leet_guesscode[id][0],leet_guesscode[id][1],leet_guesscode[id][2],leet_guesscode[id][3],leet_guesscode[id][4])
	len += format(body[len],sizeof(body)-len,"---------------------------------------^n")

	add(body,sizeof(body),"^n0. Exit^n")
	show_menu(id,key,body)
	return PLUGIN_HANDLED
}

public action_leet_guess(id,key)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,leet_laptop) > 25.0) return PLUGIN_HANDLED
	if(key == 9) return PLUGIN_HANDLED

	for(new i = 0;i < 5;i++) {	// Search for the specific slot and set value
		if(leet_guesscode[id][i] == 0) {
		leet_guesscode[id][i] = key+1
		break
		}
	}

	if(leet_guesscode[id][4] != 0)	// If last number then show menu
	{
		if(leet_guesscode[id][0] == leet_rightpass[0] && leet_guesscode[id][1] == leet_rightpass[1] && leet_guesscode[id][2] == leet_rightpass[2] && leet_guesscode[id][3] == leet_rightpass[3] && leet_guesscode[id][4] == leet_rightpass[4]) leet_menu(id)
		else {
			for(new i = 0;i < 5;i++) {
			leet_guesscode[id][i] = 0
			}
		}
		return PLUGIN_HANDLED
	}

	else				// If NOT last then reshow menu
	{
		laptop_leet_guess(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED

}

// Laptop Mod Menu to do stuff
public leet_menu(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	client_print(id,print_chat,"[LaptopMod] Correct Code!")
	for(new i = 0;i < 5;i++) {
		leet_guesscode[id][i] = 0
	}

	new body[256]
	new key = (1<<0|1<<9)

	new len = format(body,sizeof(body),"Ze Menu^n")

	add(body,sizeof(body),"^n1. MCPD Doors^n")
	add(body,sizeof(body),"^n0. Close Menu^n")
	show_menu(id,key,body)
	return PLUGIN_HANDLED
}

public action_leet_menu(id,key)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,leet_laptop) > 25.0) return PLUGIN_HANDLED
	if(key == 9) return PLUGIN_HANDLED
	if(key == 0) leet_control_mcpd_show(id)
	return PLUGIN_HANDLED
}

// Controling MCPD Doors
public leet_control_mcpd_show(id)
{
	new body[256]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)

	new len = format(body,sizeof(body),"MCPD Door Control^n^n")

	add(body,sizeof(body),"1. MCPD Main Door^n")
	add(body,sizeof(body),"2. Jail Door 1^n")
	add(body,sizeof(body),"3. Jail Door 2^n")
	add(body,sizeof(body),"4. Jail Door 3^n")
	add(body,sizeof(body),"5. Jail Door 4^n")
	add(body,sizeof(body),"6. Interrigation Door^n")
	add(body,sizeof(body),"7. MCPD Main Door #2^n")
	add(body,sizeof(body),"8. Helipad Door^n")
	add(body,sizeof(body),"9. MCPD Lights^n")
	add(body,sizeof(body),"^n0. Close Menu^n")
	show_menu(id,key,body)
	return PLUGIN_HANDLED
}

public leet_control_mcpd(id,key)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,leet_laptop) > 25.0) return PLUGIN_HANDLED
	if(key == 9) return PLUGIN_HANDLED
	if(key == 0) force_use(id,find_ent_by_tname(-1,"prison_door_main2"))
	if(key == 1) force_use(id,find_ent_by_tname(-1,"prison_door_3"))
	if(key == 2) force_use(id,find_ent_by_tname(-1,"prison_door_2"))
	if(key == 3) force_use(id,find_ent_by_tname(-1,"prison_door_1"))
	if(key == 4) force_use(id,find_ent_by_tname(-1,"prison_door_4"))
	if(key == 5) force_use(id,find_ent_by_tname(-1,"interigation_door"))
	if(key == 6) force_use(id,find_ent_by_tname(-1,"prison_door_main"))
	if(key == 7) force_use(id,find_ent_by_tname(-1,"prison_door_hele"))
	if(key == 8) force_use(id,find_ent_by_tname(-1,"policedlights"))
	leet_control_mcpd_show(id)
	return PLUGIN_HANDLED
}

/////////////////////////////////////////////////////////
//	FINE SYSTEM
/////////////////////////////////////////////////////////

public func_fine( id, amount )
{

	if( !amount ) {
		client_print( id, print_chat, "Usage:  /fine <amount> ^n" );
		return PLUGIN_HANDLED
	}

	new name[32]
	get_user_name( id, name, sizeof( name ) )

	if( JobID3[id] < mcpdjobs[0] || JobID3[id] > mcpdjobs[1] )
	{
		client_print( id, print_chat, "[FineMod] You need to work for MCPD to use fines!^n" )
		return PLUGIN_HANDLED
	}

	if( amount < 1 )
	{
		client_print( id, print_chat, "[FineMod] The amount has to be more than one dollar!^n" )
		return PLUGIN_HANDLED
	}

	new tid, body
	get_user_aiming( id, tid, body, 25 )
	if( !is_user_alive( tid ) ) {
		client_print( id, print_chat, "[FineMod] Must be looking at another player!^n" )
		return PLUGIN_HANDLED
	}

	g_fine[tid][0] = 0
	g_fine[tid][1] = 0

	// If rp_forced_fine is on causing the fine to forced taken

	if( get_cvar_num( "rp_forced_fine" ) )
	{
		func_fine_pay( tid, id, amount )
		return PLUGIN_HANDLED
	}

	new t_name[32]
	get_user_name( tid, t_name, sizeof( t_name ) )
	client_print( id, print_chat, "[FineMod] Fine order sent to %s!", t_name )

	g_fine[tid][0] = id
	g_fine[tid][1] = amount

	new menu[256]
	new key = (1<<0)|(1<<1)

	new len = format( menu, sizeof( menu ), "Fine Order^n^n" )

	len += format( menu[len], sizeof( menu ) - len, "Issuer: %s ^n", name )
	len += format( menu[len], sizeof( menu ) - len, "Amount: $%i ^n^n", amount )

	len += format( menu[len], sizeof( menu ) - len, "1. Accept Fine^n" )
	len += format( menu[len], sizeof( menu ) - len, "2. Decline Fine^n" )

	show_menu( tid, key , menu )

	return PLUGIN_HANDLED
}

public action_fine( tid, key )
{
	if( key == 0 )
	{
		func_fine_pay( tid, g_fine[tid][0], g_fine[tid][1] )
		return PLUGIN_HANDLED
	}
	if( key == 1 )
	{
		new t_name[32]
		get_user_name( tid, t_name, sizeof( t_name ) );

		client_print( tid, print_chat, "[FineMod] You declined the ordered fine! ^n" )
		client_print( g_fine[tid][0], print_chat,  "[FineMod] %s declined your fine order! ^n", t_name )

		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}

// Hahahh... that bastard's paying the fine!
public func_fine_pay( target, issuer, amount )
{
	new t_name[32]

	get_user_name( target, t_name, sizeof( t_name ) )

	if( amount > balance3[target] )
	{
		client_print( target, print_chat, "[FineMod] You don't have enough money in your bank balance to pay the fine! ^n" )
		client_print( issuer, print_chat, "[FineMod] %s dosen't have enough money in his bank balance to pay the fine! ^n" )

		return PLUGIN_HANDLED
	}

	edit_value( target, "money" , "balance", "-" , amount)
        edit_value( issuer, "money" , "balance", "+" , amount)
	balance3[target] -= amount

	client_print( target, print_chat, "[FineMod] You successfully payed the fine of $%i! ^n", amount )
	client_print( issuer, print_chat, "[FineMod] %s payed the $%i fine you ordered! ^n", t_name, amount )
	
	return PLUGIN_HANDLED

}
//////////////////////////////
// Police shout   
//////////////////////////////

//Shout Action
 public pshout_action(id)
 {
	
	{
		client_cmd(id,"say shout Hands in the Air, get down!!!");
                emit_sound(id,CHAN_VOICE,"rdrp/police1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	return PLUGIN_HANDLED
}
		