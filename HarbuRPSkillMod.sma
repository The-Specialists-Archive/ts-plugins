#include <amxmodx>
#include <amxmisc>
#include <dbi>
#include <tsfun>
#include <engine>
#include <engine_stocks>
#include <fun>
#include <tsxaddon>

#pragma dynamic 32768

#define ITEMS 800
#define MAXKEYS 32
#define MAXIUMSTR 1024		// String maxium byte size for property acesses, items, items storage
#define ITEMARRAY 64

//SKILLS MOD DEFINES
#define PISTOL_TIMEOUT 250.0
#define SMG_TIMEOUT 340.0
#define RIFLE_TIMEOUT 400.0
#define SHOTGUN_TIMEOUT 370.0
#define EXPLOSIVE_TIMEOUT 700.0

#define HACKING_TIMEOUT 120.0
#define PROGRAM_TIMEOUT 120.0

#define MARIJUANA_SEED_ITEM 700
#define ITEMID_MARIJUANA 400

// Bank ATM #1 and #2 Position
new atmone[3]
new atmtwo[3]
new atmthree[3]
new atmfour[3]

// Jail Cell Positions
new jailone[3]
new jailtwo[3]
new jailthree[3]
new jailfour[3]

// Uncuff Positions - Default for Mecklenburg_b5
new uncuffareaone[3]
new uncuffareatwo[3]

//new hasclosedoors = 0 // Close MCPD, Gunshop doors at beginng ( 0 = ON, 1 =OFF)

// JobIDS replace with the ones you have in your MySQL database
new mafiajobs[2]
new mcpdjobs[2]
new mcmdjobs[2]
new jobs711[2]

// Storage Positions
new Storageone[3]			// MCPD Store-o-Matic
new Storagetwo[3]			// Appartment A
new Storagethree[3]			// Appartment B
new Storagefour[3]			// Appartment C
new Storagefive[3]			// MCMD

// Job ID's
new g_barjobs[2] // Bar Worker JobID
new g_dinerjobs[2] // Diner Jobs
new g_bankjobs[2] // Banks jobs
new g_teachjob = 264 // Teacher JobID

// Skills
new g_normalskills[33]; // How much normal skills a person has.
new g_computerskills[33]; // How much skills in the computer a person has.
new g_fightskills[33]; // How much fighting skills a person has.
new g_lawskills[33]; // How much skills a person has in being a lawyer/judge/cop/whatever
new g_weaponskills[33]; // How much skill someone has in weapons, etc.
new g_cookingskills[33]; // Cooking skills a person has.
new g_drugskills[33]; // How much skills does someone have in drugs?
new g_teacherpos[3]; // Teacher NPC's position

new g_offermaker[33][1]; // [0] = ID of offerer
new firesprite; // For the stove

// Positions for HackMod, Etc.
new g_bankpos[3] = { -2951, 1820, 32 } // Required for bank hacking.
new planting_area1[3] = { -1019, 2543, 32 } // Where you plant marijuana seeds and others at.(Mecklenburg)

//Timeouts for Skills
new e_timeout[33]; // Teaching timeout.
new creategun_timeout[33]; // Timeout when creating a weapon.
new createitem_timeout[33]; // Time out when creating an item.
new createdrug_timeout[33]; // Creating drugs timeout
new cook_timeout[33]; // Timeout for cooking
// hacker mod integers
new programming_timeout[33]; // Timeout for programming.
new hacking_timeout[33]; // Timeout for hacking.
//planintg timeout
new plant_insert_timeout[33];
new marijuana_watering_timeout[33]; // Marjuana

// HackerMod
new comhack[33]; // has the person hacked /com communications?

// Registering the database
new Sql:dbc
new Result:result
new Result:result2
public plugin_init()
{
	register_plugin("HarbuRP Skills Mod", "1.0", "Smokey485")
	// Commands
	register_clcmd("say", "say_handle")
	
	////////////
	// Menus //
	//////////
	
	//SKILLS USAGE
	register_menucmd(register_menuid("Job Opportunities"),1023,"jobopp_use") // Jobs you can get with your aquired skills
	register_menucmd(register_menuid( "Create an item"), 1023, "createitem_use") // Create item
	register_menucmd(register_menuid("Create a weapon"),1023,"createweapon_use") // Create weapon
	register_menucmd(register_menuid("Create-a-weapon Page: 2"),1023,"createweapon_use2") //Create a weapon(page 2)
	register_menucmd(register_menuid("Cook Food"),1023,"cookfood_use") // Cook Food
	register_menucmd(register_menuid("Create Drugs"),1023,"createdrug_use") // Create drugs.
	register_menucmd(register_menuid("Use Computer:"),1023,"hackstuff_use") // Hack something.
	//TEACHING MENUS
	register_menucmd( register_menuid( "Education Offer" ), 1023, "educationoffer_use") // %s is offering you education.
	//register_menucmd( register_menuid( "Education-Request" ), 1023, "educationrequest_use") // %s would like %s
	register_menucmd( register_menuid( "Teach Yourself" ), 1023, "education_teach_self") // teach yourself
	register_menucmd( register_menuid( "Use your skills:" ), 1023, "education_use_skills") // use your skills
	
	register_menucmd(register_menuid("WEED_Plant_Marijuana"),1023,"action_plant_marijuana") // Plant Marijuana
	
	register_cvar("rp_enforce_realhud", "0") // Enforce CL_REALHUD?
	
	//Tasks
	set_task(1.0,"sql_init")
	set_task(2.0, "fire_sprite_value")
	set_task(10.0,"fix_cvars")
	set_task(900.0,"plant_health_drop",0,"",0,"b")
	set_task(60.0,"plant_grow",0,"",0,"b")
	set_task(3.0, "realhud_enforce",0,"",0,"b")
}
// Initializing the MySQL database 
public sql_init()
{
	new host[64], username[33], password[32], dbname[32], error[32]
	get_cvar_string("economy_mysql_host",host,64) 
	get_cvar_string("economy_mysql_user",username,32) 
	get_cvar_string("economy_mysql_pass",password,32) 
	get_cvar_string("economy_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if(dbc == SQL_FAILED)
	{
		server_print("[HarbuRPSkills] Could Not Connect To SQL Database^n")
	}
	else
	{
		server_print("[HarbuRPSkills] Connected To SQL, Have A Nice Day!^n")
	}
	return PLUGIN_HANDLED;
}
public fire_sprite_value()
{
	callfunc_begin("firesprite_value","HarbuRPAlpha.amxx")
	firesprite = callfunc_end()
	server_print("[URP] Fire-sprite has been transfered from plugin 'HarbuRPAlpha.amxx' NUM: %i",firesprite)
	log_amx("[URP] Fire-sprite has been transfered from plugin 'HarbuRPAlpha.amxx' NUM: %i",firesprite)
	return PLUGIN_HANDLED;
}
public say_handle(id)
{
	new buffer[256], buffer1[33], buffer2[33], buffer3[33], origin[3]
	get_user_origin(id,origin)
	read_argv(1,buffer,255)
	parse(buffer, buffer1, 32, buffer2, 32, buffer3, 32)
	if(equali(buffer1,"/skills"))
	{
		skills_motd(id)
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/skillmenu"))
	{
		build_skillmenu(id)
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/offereducation"))
	{
		build_educationoffer(id)
		//educationoffer_use
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/requesteducation"))
	{
		build_educationrequest(id)
		//educationrequest_use
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/viewskills"))
	{
		if(strlen(buffer2) < 1)
		{
			client_print(id,print_chat,"[SKILLS] Usage: say /viewskills <name>")
			return PLUGIN_HANDLED;
		}
		// if they do specify something
		new target = cmd_target(id,buffer2,0)
		if(target < 1 || target > get_maxplayers())
		{
			client_print(id,print_chat,"[SKILLS] Invalid person.")
			return PLUGIN_HANDLED;
		}
		viewskills(target,id)
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/educationprices"))
	{
		view_eduprices(id)
		return PLUGIN_HANDLED;
	}
	if(equali(buffer1,"/useskills"))
	{
		client_print(id,print_console,"Say command executed: /useskills")
		build_use_skills(id)
		return PLUGIN_HANDLED;
	}
	/*
	if(equali(buffer1,"/harvestmarijuana"))
	{
		marijuana_harvest(id)
		return PLUGIN_HANDLED;
	}
	*/
	return PLUGIN_CONTINUE;
}
public client_putinserver(id)
{
	set_task(0.1,"load_skills",id,"",0,"a",3)
	g_normalskills[id] = 1
	g_computerskills[id] = 1
	g_fightskills[id] = 1
	g_lawskills[id] = 1
	g_weaponskills[id] = 1
	plant_insert_timeout[id] = 0
	comhack[id] = 0
	g_cookingskills[id] = 1
	if(is_user_database(id) > 0)
	{
		new query[256],authid[32]
		get_user_authid(id,authid,31)
		format(query,255, "SELECT normalskills,computerskills,fightskills,lawskills,weaponskills,cookingskills,drugskills FROM skills WHERE steamid='%s'", authid)
		result = dbi_query(dbc,"%s",query)
		if(dbi_nextrow(result) > 0)
		{
			g_normalskills[id] = dbi_field(result,1)
			g_computerskills[id] = dbi_field(result,2)
			g_fightskills[id] = dbi_field(result,3)
			g_lawskills[id] = dbi_field(result,4)
			g_weaponskills[id] = dbi_field(result,5)
			g_cookingskills[id] = dbi_field(result,6)
			g_drugskills[id] = dbi_field(result,7)
		}
		dbi_free_result(result)
	}
}
public client_disconnect(id)
{
	g_normalskills[id] = 1
	g_computerskills[id] = 1
	g_fightskills[id] = 1
	g_lawskills[id] = 1
	g_weaponskills[id] = 1
	g_cookingskills[id] = 1
	g_drugskills[id] = 1
	cook_timeout[id] = 0
	client_cmd(id,"cl_realhud 0")
	client_cmd(id,"cl_laser 0")
	createitem_timeout[id] = 0
	creategun_timeout[id] = 0
	return PLUGIN_CONTINUE
}
public load_skills(id)
{
	new query[256],authid[32]
	get_user_authid(id,authid,31)
	if(is_user_database(id) > 0)
	{
		//set_task(15.0, "print_jobfair", id)
		format( query, 255, "SELECT torturecredits FROM money WHERE steamid='%s'", authid)
		result = dbi_query( dbc, "%s",query)
		dbi_free_result(result)
		format(query,255, "SELECT normalskills,computerskills,fightskills,lawskills,weaponskills,cookingskills,drugskills FROM skills WHERE steamid='%s'", authid)
		result = dbi_query(dbc,"%s",query)
		if(dbi_nextrow(result) > 0)
		{
			g_normalskills[id] = dbi_field(result,1)
			g_computerskills[id] = dbi_field(result,2)
			g_fightskills[id] = dbi_field(result,3)
			g_lawskills[id] = dbi_field(result,4)
			g_weaponskills[id] = dbi_field(result,5)
			g_cookingskills[id] = dbi_field(result,6)
			g_drugskills[id] = dbi_field(result,7)
		}
		dbi_free_result(result)
	}
	return PLUGIN_HANDLED;
}
//////////////
// HACKMOD //
////////////
///////////////////////////////
// SKILLS MENU, SKILLS MOD! //
/////////////////////////////

public createdrug_cleartimeout(id)
{
	createdrug_timeout[id] = 0;
	return PLUGIN_HANDLED;
}
public cook_cleartimeout(id)
{
	remove_task(id+213)
	remove_task(id+214)
	cook_timeout[id] = 0;
	return PLUGIN_HANDLED;
}
public createitem_cleartimeout(id)
{
	createitem_timeout[id] = 0;
	return PLUGIN_HANDLED;
}
public creategun_cleartimeout(id)
{
	creategun_timeout[id] = 0;
	return PLUGIN_HANDLED;
}	
public no_etimeout(id)
{
	e_timeout[id] = 0;
	return PLUGIN_HANDLED;
}
public no_hackertimeout(id)
{
	hacking_timeout[id] = 0;
	client_print(id,print_chat,"[SKILLS] You can now hack.")
	return PLUGIN_HANDLED;
}
public no_programtimeout(id)
{
	programming_timeout[id] = 0;
	client_print(id,print_chat,"[SKILLS] You can now make a program.")
	return PLUGIN_HANDLED;
}
new g_cookingpos[3] = { -1111, -1595, 36 } // where you can cook food * IN DINER BY STOVE FOR NOW *
new g_cookingpos2[3] = { -1070, -1305, -200 } // IN & out cooking position
//register_menucmd(register_menuid("Job Opportunities"),1023,"jobopp_use") // Jobs you can get with your aquired skills
//	register_menucmd(register_menuid( "Create an Item"), 1023, "createitem_use") // Create item
//	register_menucmd(register_menuid("Create a weapon"),1023,"createweapon_use") // Create weapon
//	register_menucmd(register_menuid("Cook Food"),1023,"cookfood_use") // Cook Food

public build_educationrequest(id)
{
	if(!is_user_alive(id))
	{
		client_print(id,print_chat,"[EDUCATION] Your dead, no kthx.")
		return PLUGIN_HANDLED;
	}
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,g_teacherpos) > 200)
	{
		client_print(id,print_chat,"[EDUCATION] You are not close enough to the teacher!")
		return PLUGIN_HANDLED;
	}
	new menu[1024]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9)
	format(menu,sizeof(menu),"Education Request^n ")
	add(menu,sizeof(menu),"^n 1. Normal Skills: $200")
	add(menu,sizeof(menu),"^n 2. Computer Skills: $400")
	add(menu,sizeof(menu),"^n 3. Fighting Skills: $400")
	add(menu,sizeof(menu),"^n 4. Law Skills: $600")
	add(menu,sizeof(menu),"^n 5. Weapon Skills: $600")
	add(menu,sizeof(menu),"^n 6. Cooking Skills: $350")
	add(menu,sizeof(menu),"^n 7. Drug Skills: $400")
	add(menu,sizeof(menu),"^n^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public educationrequest_use(id,key)
{
	new rndupgrade = random_num(2,5)
	switch(key)
	{
		case 0:
		{
			if(!has_money(id,200,"balance")) // normal skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			//gain_skills(id,skill[],func[],amount)
			//edit_money(id,amount,where[],func[])
			//edit_value(id,"money","balance","-",cost)
			edit_value(id,"money","balance","-",200)
			gain_skills(id,"normalskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!has_money(id,400,"balance"))// computer skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",400)
			gain_skills(id,"computerskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			if(!has_money(id,400,"balance"))// fighting skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",400)
			gain_skills(id,"fightingskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(!has_money(id,600,"balance")) // law skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",600)
			gain_skills(id,"lawskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			if(!has_money(id,600,"balance")) // weapon skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",600)
			gain_skills(id,"weaponskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			if(!has_money(id,350,"balance")) // cooking skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",350)
			gain_skills(id,"cookingskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			if(!has_money(id,400,"balance")) // drug skills
			{
				not_enough_money(id)
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",400)
			gain_skills(id,"drugskills","+",rndupgrade)
			return PLUGIN_HANDLED;
		}
		case 9: client_print(id,print_chat,"[EDUCATION] Request closed.")
	}
	return PLUGIN_HANDLED;
}
public not_enough_money(id)
{
	client_print(id,print_chat,"[MONEY] You do not have enough money for this!")
	return PLUGIN_HANDLED;
}
public build_use_skills(id)
{
	new menu[1024]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4)
	format(menu,sizeof(menu),"Use your skills: ^n^n ")
	add(menu,sizeof(menu),"1. Job-Opportunities^n ")
	add(menu,sizeof(menu),"2. Create-item^n ")
	add(menu,sizeof(menu),"3. Create-weapon^n ")
	add(menu,sizeof(menu),"4. Cook-food^n ")
	add(menu,sizeof(menu),"5. Create-drugs^n ")
	if(get_jobid(id) == 271 || get_jobid(id) == 301 || job_check(id,"hack") == 1 || job_check(id,"engineer") == 1 || job_check(id,"matrix") == 1 || job_check(id,"scriptkiddy") == 1 || job_check(id,"meck") == 1)
	{
		if(get_item_amount(id,get_cvar_num("rp_itemid_laptop"),"money") > 0 || get_item_amount(id,get_cvar_num("rp_itemid_computer"),"money") > 0)
		{
			add(menu,sizeof(menu),"6. Computer Skills^n ")
			key += (1<<5)
		}
	}
	key += (1<<9)
	add(menu,sizeof(menu),"^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public education_use_skills(id,key)
{
	switch(key)
	{
		case 0: build_job_opportunities(id)
		case 1: build_create_item(id)
		case 2: build_create_weapon(id)
		case 3: build_cook_food(id)
		case 4: build_drug_create(id)
		case 5: build_hacker_menu(id)
		case 9: client_print(id,print_chat,"[SKILLS] Menu closed.");
	}
	return PLUGIN_HANDLED;
}
public build_hacker_menu(id)
{
	new menu[1024],key
	format(menu,sizeof(menu),"Use Computer:^n^n ")
	if(g_computerskills[id] > 10)
	{
		add(menu,sizeof(menu),"1. Create basic program^n ")
		key += (1<<0)
	} else {
		add(menu,sizeof(menu),"1. NOT ENOUGH SKILL^n ")
	}
	if(g_computerskills[id] > 20)
	{
		add(menu,sizeof(menu),"2. Hack Communication Radios^n ") // Hack into /com radio
		key += (1<<1)
	} else {
		add(menu,sizeof(menu),"2. NOT ENOUGH SKILL^n ")
	}
	if(g_computerskills[id] > 30)
	{
		add(menu,sizeof(menu),"3. Hack ATM Machine^n ") // Hack into ATM Machines
		key += (1<<2)
	} else {
		add(menu,sizeof(menu),"3. NOT ENOUGH SKILL^n ")
	}
	if(g_computerskills[id] > 50)
	{
		add(menu,sizeof(menu),"4. Hack Door^n ") // Hack into doors and stuff
		key += (1<<3)
	} else {
		add(menu,sizeof(menu),"4. NOT ENOUGH SKILL^n ")
	}
	if(g_computerskills[id] > 1000)
	{
		add(menu,sizeof(menu),"5. Create advanced program^n ")
		key += (1<<4)
	} else {
		add(menu,sizeof(menu),"5. NOT ENOUGH SKILL^n ")
	}
	key += (1<<9)
	add(menu,sizeof(menu),"^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public hackstuff_use(id,key)
{
	switch(key)
	{
		//hackmod_use(id,function[],cost)
		//case 0: hackmod_use(id,"basicprogram",1,PROGRAM_TIMEOUT) // basic programming
		//case 0: build_program_menu(id)
		case 1: hackmod_use(id,"comhack",1,HACKING_TIMEOUT) // /com radio hacking
		case 2: hackmod_use(id,"atmhack",1,HACKING_TIMEOUT) // ATM Machine hacking
		case 3: hackmod_use(id,"hackdoor",1,HACKING_TIMEOUT) // hacking doors
		//case 4: hackmod_use(id,"advancedprogram",1,PROGRAM_TIMEOUT) // Advanced Programming
		case 4: client_print(id,print_chat,"[SKILLS] Option disabled for now.")
		//action_bank_hack triggered by below
		//case 5: build_bank_hacking(id)
		//case 3: client_print(id,print_chat,"[COMPUTER] Feature not implemented yet.") // ???? hacking
		case 9: client_print(id,print_chat,"[COMPUTER] Menu closed.")
	}
	return PLUGIN_HANDLED;
}
public build_drug_create(id)
{
	new menu[1024],key
	format(menu,sizeof(menu),"Create Drugs^n^n ")
	if(g_drugskills[id] > 10)
	{
		add(menu,sizeof(menu),"1. Create Cigarette: $5^n ") // itemid 8
		key += (1<<0)
	} else {
		add(menu,sizeof(menu),"1. NOT AVAILABLE^n ")
	}
	if(g_drugskills[id] > 15)
	{
		key += (1<<1)
		add(menu,sizeof(menu),"2. Create Cuban Cigar: $10^n ") //itemid 10
	} else {
		add(menu,sizeof(menu),"2. NOT AVAILABLE^n ")
	}
	if(g_drugskills[id] > 20)
	{
		key += (1<<2|1<<3)
		add(menu,sizeof(menu),"3. Create Weed: $25^n ") // ItemID 400
		add(menu,sizeof(menu),"4. Create LSD: $35^n ") // ItemID 402
	} else {
		add(menu,sizeof(menu),"3. NOT AVAILABLE^n 4. NOT AVAILABLE^n ")
	}
	if(g_drugskills[id] > 30)
	{
		key += (1<<4)
		add(menu,sizeof(menu),"5. Create Steroids: $40^n ") // ItemID 403
	} else {
		add(menu,sizeof(menu),"5. NOT AVAILABLE^n ")
	}
	if(g_drugskills[id] > 40)
	{
		key += (1<<5)
		add(menu,sizeof(menu),"6. Marijuana Seed: $10^n ") // ItemID 404
	} else {
		add(menu,sizeof(menu),"6. NOT AVAILABLE^n ")
	}
	key += (1<<7|1<<8|1<<9)
	//add(menu,sizeof(menu),"8. Water Marijuana^n ")
	//add(menu,sizeof(menu),"9. Plant: Marijuana^n ")
	add(menu,sizeof(menu),"^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public createdrug_use(id,key)
{
	switch(key)
	{
		// make_drug(id,itemid,amount,cost,drugname[],Float:timeout)
		case 0: make_drug(id,8,1,5,"Marlboro Cigarette",40.0)
		case 1: make_drug(id,10,1,10,"Cuban Cigar",60.0)
		case 2: make_drug(id,400,1,25,"Weed",40.0)
		case 3: make_drug(id,402,1,35,"LSD",60.0)
		case 4: make_drug(id,403,1,40,"Steroids",60.0)
		case 5: make_drug(id,MARIJUANA_SEED_ITEM,1,10,"Marijuana Seed",15.0)
		//case 7: water_marijuana(id)
		//case 8: plant_marijuana_menu(id)
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public plant_marijuana_menu(id)
{
	new origin[3]
	get_user_origin(id,origin)
	if(plant_insert_timeout[id] == 1)
	{
		client_print(id,print_chat,"[DRUGS] You cannot plant marijuana at this time.")
		return PLUGIN_HANDLED;
	}
	if(get_distance(origin,planting_area1) >= 1000)
	{
		client_print(id,print_chat,"[DRUGS] You must be by the Apartment Complex shed to plant marijuana!")
		return PLUGIN_HANDLED;
	}
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	new menu[1024]
	format(menu,sizeof(menu),"WEED_Plant_Marijuana^n^n ")
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
public action_plant_marijuana(id,key)
{
	new origin[3]
	get_user_origin(id,origin)
	new plant_amount;
	switch(key)
	{
		case 0:
		{
			plant_amount = 1
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 600)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 1:
		{
			plant_amount = 5
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 600)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 2:
		{
			plant_amount = 10
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 3:
		{
			plant_amount = 25
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 4: 
		{
			plant_amount = 50
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 5: 
		{
			plant_amount = 100
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 6:
		{
			plant_amount = 250
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 7:
		{
			plant_amount = 500
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 8: 
		{
			plant_amount = get_item_amount(id,MARIJUANA_SEED_ITEM,"money")
			if(plant_amount > get_item_amount(id,MARIJUANA_SEED_ITEM,"money"))
			{
				client_print(id,print_chat,"[DRUGS] You do not have the specified amount of marijuana seeds!")
				return PLUGIN_HANDLED;
			}
			if(get_distance(origin,planting_area1) <= 1000)
			{
				plant_insert(id,"Marijuana",125,plant_amount*2+7200,100,plant_amount,origin[0],origin[1],origin[2],ITEMID_MARIJUANA)
				set_item_amount(id,"-",MARIJUANA_SEED_ITEM,plant_amount,"money")
				client_print(id,print_chat,"[DRUGS] You have planted %i marijuana here.", plant_amount)
			}
		}
		case 9: client_print(id,print_chat,"[DRUGS] Menu closed.")
	}
	return PLUGIN_HANDLED;
}
public marijuana_harvest(id)
{
	// Harvest marijuana nearest to you.
	new query[512],authid[32],origin[3]
	get_user_authid(id,authid,31)
	get_user_origin(id,origin)
	format(query,sizeof(query),"SELECT * FROM planting WHERE authid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		client_print(id,print_chat,"[DRUGS] You have not planted any marijuana yet!")
		dbi_free_result(result)
		return PLUGIN_HANDLED;
	}
	new rows = dbi_num_rows(result)
	//otherwise, just search for the closest marijuana.
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
				if(health > 0)
				{
					if(val < 1)
					{
						set_item_amount(id,"+",ITEMID_MARIJUANA,amount,"money")
						set_item_amount(id,"+",MARIJUANA_SEED_ITEM,amount / 4,"money")
						client_print(id,print_chat,"[DRUGS] %i Weed has been harvested into your inventory, %i seeds taken from the plants.", amount, amount / 4)
						client_cmd(id,"say /me harvests his marijuana.")
						new query2[256]
						format(query2,sizeof(query2),"DELETE FROM planting WHERE authid='%s' AND x=%i AND y=%i AND z=%i",authid,x,y,z)
						dbi_query(dbc,query2)
					}
				}
			}
		} else {
			client_print(id,print_chat,"[DRUGS] No marijuana is found here.",amount)
		}
		dbi_nextrow(result)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED;
}
public water_marijuana(id)
{
	new query[512],authid[32],origin[3]
	get_user_authid(id,authid,31)
	get_user_origin(id,origin)
	format(query,sizeof(query),"SELECT * FROM planting WHERE authid='%s'",authid)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) <= 0)
	{
		client_print(id,print_chat,"[DRUGS] You have not planted any marijuana yet!")
		dbi_free_result(result)
		return PLUGIN_HANDLED;
	}
	//otherwise, just search for the closest marijuana.
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
						client_print(id,print_chat,"[DRUGS] You have recently watered your plant, try later.")
						return PLUGIN_HANDLED;
					}
					new hpmark
					hpmark = plant_get_health(id,authid,x,y,z)
					if(hpmark <= 0)
					{
						client_print(id,print_chat,"[DRUGS] You discover that your plants have died.")
						new quarry[256]
						format(quarry,sizeof(quarry),"DELETE FROM planting WHERE authid='%s' AND x=%i AND y=%i AND z=%i",authid,x,y,z)
						dbi_query(dbc,query)
						return PLUGIN_HANDLED;
					}
					new rndupgrade = random_num(1,6)
					hpmark += rndupgrade
					client_print(id,print_chat,"[DRUGS] Your plant had %i health, now it has %i health!",hpmark-rndupgrade,hpmark)
					client_cmd(id,"say /me waters his plant")
					marijuana_watering_timeout[id] = 1;
					set_task(60.0, "allow_watering",id)
					new query2[256]
					format(query2,sizeof(query2),"UPDATE planting SET health=health+%i WHERE authid='%s' AND x=%i AND y=%i AND z=%i",rndupgrade,authid,x,y,z)
					dbi_query(dbc,query2)
				}
			}
		} else {
			client_print(id,print_chat,"[DRUGS] You must be standing by one of your plants to water them!")
		}
		dbi_nextrow(result)
	}
	dbi_free_result(result)
	return PLUGIN_HANDLED;
}
public plant_health_drop()
{
	new query[256] // the evil query that kills plants :D!
	format(query,sizeof(query),"UPDATE planting SET health=health-1")
	dbi_query(dbc,query)
	return PLUGIN_HANDLED;
}
public plant_grow()
{
	new query[256]
	format(query,sizeof(query),"UPDATE planting SET val=val-1")
	dbi_query(dbc,query)
	return PLUGIN_HANDLED;
}
public allow_watering(id)
{
	marijuana_watering_timeout[id] = 0;
	client_print(id,print_chat,"[DRUGS] You can now water your marijuana.")
	return PLUGIN_HANDLED;
}
public build_job_opportunities(id)
{
	new menu[1024],key
	format(menu,sizeof(menu),"Job Opportunities^n^n ")
	if(g_lawskills[id] > 20)
	{
		add(menu,sizeof(menu),"1. Lawyer^n ") // JobID 101
		add(menu,sizeof(menu),"2. Jury^n ") // JobID 102
		add(menu,sizeof(menu),"3. Judge^n ") // JobID 103
		key += (1<<0|1<<1|1<<2)
	}
	if(g_computerskills[id] > 30)
	{
		add(menu,sizeof(menu),"4. Hacker^n ") // JobID 271
		add(menu,sizeof(menu),"5. Computer Programmer^n ") // JobID 301
		key += (1<<3|1<<4)
	}
	if(g_fightskills[id] > 15)
	{
		add(menu,sizeof(menu),"6. Dojo Worker^n ") // JobID 350
		add(menu,sizeof(menu),"7. Fighter^n ") // JobID 360
		key += (1<<5|1<<6)
	}
	if(g_weaponskills[id] > 20)
	{
		add(menu,sizeof(menu),"8. Gun Dealer^n ") // JobID 296
		key += (1<<7)
	}
	add(menu,sizeof(menu),"^n 0. Close Menu")
	key += (1<<9)
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public jobopp_use(id,key)
{
	switch(key)
	{
		case 0: give_job(id,101,"[JOB] You are now hired as a Lawyer!")
		case 1: give_job(id,102,"[JOB] You are now hired as a Jury!")
		case 2: give_job(id,103,"[JOB] You are now hired as a Judge!")
		case 3: give_job(id,271,"[JOB] You are now hired as a Hacker!")
		case 4: give_job(id,301,"[JOB] You are now hired as a Computer Programmer!")
		case 5: give_job(id,350,"[JOB] You are now hired as a Dojo Worker!")
		case 6: give_job(id,360,"[JOB] You are now hired as a Fighter!")
		case 7: give_job(id,296,"[JOB] You are now hired as a Gun Dealer!")
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public build_create_item(id)
{
	new menu[1024]
	new key
	format(menu,sizeof(menu),"Create an item^n^n ")
	if(g_normalskills[id] >= 20)
	{
		add(menu,sizeof(menu),"1. Create Ducktape: $1^n ") // ItemID 34
		key += (1<<0)
	} else {
		add(menu,sizeof(menu),"1. NOT ENOUGH SKILL^n ")
	}
	if(g_normalskills[id] >= 40)
	{
		add(menu,sizeof(menu),"2. Create Lockpick: $100^n ") // ItemID 22
		add(menu,sizeof(menu),"3. Create Watch: $10^n ") // ItemID 32
		key += (1<<1|1<<2)
	} else {
		add(menu,sizeof(menu),"2. NOT ENOUGH SKILL^n ")
		add(menu,sizeof(menu),"3. NOT ENOUGH SKILL^n ")
	}
	if(g_normalskills[id] >= 60)
	{
		add(menu,sizeof(menu),"4. Create Rolex Watch: $1000^n ") // ItemID 31
		key += (1<<3)
	} else {
		add(menu,sizeof(menu),"4. NOT ENOUGH SKILL^n ")
	}
	if(g_normalskills[id] >= 100)
	{
		add(menu,sizeof(menu),"5. Create Phone Hacking Device: $20000^n ") // ItemID 30
		key += (1<<4)
	} else {
		add(menu,sizeof(menu),"5. NOT ENOUGH SKILL^n ")
	}
	if(g_normalskills[id] >= 150)
	{
		add(menu,sizeof(menu),"6. Create Computer: $1000^n ") // ItemID 95
		key += (1<<5)
	} else {
		add(menu,sizeof(menu),"6. NOT ENOUGH SKILL^n ")
	}
	if(g_normalskills[id] >= 200)
	{
		add(menu,sizeof(menu),"7. Create Laptop: $2000^n ") // ItemID 96
		key += (1<<6)
	} else {
		add(menu,sizeof(menu),"7. NOT ENOUGH SKILL^n ")
	}
	add(menu,sizeof(menu),"^n 0. Close Menu")
	key += (1<<9)
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public createitem_use(id,key)
{
	//make_item(id,itemid,amount,cost,itemname[],Float:timeout)
	switch(key)
	{
		case 0: make_item(id,34,1,1,"Ducktape",60.0)
		case 1: make_item(id,22,1,100,"Lockpick",250.0)
		case 2: make_item(id,32,1,10,"Watch",80.0)
		case 3: make_item(id,31,1,1000,"Rolex Watch",500.0)
		case 4: make_item(id,30,1,20000,"Phone Hacking Device", 900.0)
		case 5: make_item(id,95,1,1000,"Computer",600.0)
		case 6: make_item(id,96,1,2000,"Laptop",800.0)
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public build_create_weapon(id)
{
	new key
	new menu[1024]
	format(menu,sizeof(menu),"Create a weapon^n^n ")
	if(g_weaponskills[id] >= 35)
	{
		add(menu,sizeof(menu),"1. Create Ruger: $50^n ") // ItemID 606
		add(menu,sizeof(menu),"2. Create Five-Seven: $100^n ") // ItemID 604
		add(menu,sizeof(menu),"3. Create Glock18: $50^n ") // ItemID 601
		key += (1<<0|1<<1|1<<2)
	} else {
		add(menu,sizeof(menu),"1. NOT ENOUGH SKILL^n 2. NOT ENOUGH SKILL^n 3. NOT ENOUGH SKILL^n ")
	}
	if(g_weaponskills[id] >= 50)
	{
		add(menu,sizeof(menu),"4. Create M4A1 Carbine: $150^n ") // ItemID 630
		add(menu,sizeof(menu),"5. Create AK47: $175^n ") // ItemID 633
		add(menu,sizeof(menu),"6. Create Akimbo Berettas: $100^n ") // ItemID 600
		key += (1<<3|1<<4|1<<5)
	} else {
		add(menu,sizeof(menu),"4. NOT ENOUGH SKILL^n 5. NOT ENOUGH SKILL^n 6. NOT ENOUGH SKILL^n ")
	}
	if(g_weaponskills[id] >= 60)
	{
		add(menu,sizeof(menu),"7. Create Teargas: $100^n ") // ItemID 121
		add(menu,sizeof(menu),"8. Create Smoke Grenade: $200^n ") // ItemID 123
		key += (1<<6|1<<7)
	} else {
		add(menu,sizeof(menu),"7. NOT ENOUGH SKILL^n 8. NOT ENOUGH SKILL^n ")
	}
	/*
	if(g_weaponskills[id] >= 50)
	{
		add(menu,sizeof(menu),"9. Create Door C2: $2500^n ") // ItemID 23
		key += (1<<8)
	} else {
		add(menu,sizeof(menu),"9. NOT ENOUGH SKILL^n ")
	}
	*/
	add(menu,sizeof(menu),"9. Next Page^n ")
	key += (1<<8)
	add(menu,sizeof(menu),"^n 0. Close Menu")
	key += (1<<9)
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public build_create_weapon2(id)
{
	new key
	new menu[1024]
	format(menu,1023,"Create-a-weapon Page: 2^n ")
	if(g_weaponskills[id] >= 35)
	{
		add(menu,sizeof(menu),"1. Create Steyr TMP: $100^n ");
		add(menu,sizeof(menu),"2. Create HK Pdw: $112^n ");
		add(menu,sizeof(menu),"3. Create Golden Colts: $125^n ");
		key += (1<<0|1<<1|1<<2)
	} else {
		add(menu,sizeof(menu),"1. NOT ENOUGH SKILL^n ");
		add(menu,sizeof(menu),"2. NOT ENOUGH SKILL^n ");
		add(menu,sizeof(menu),"3. NOT ENOUGH SKILL^n ");
	}
	if(g_weaponskills[id] >= 45)
	{
		add(menu,sizeof(menu),"4. Create UMP45: $100^n ");
		add(menu,sizeof(menu),"5. Create Mini Uzi: $100^n ");
		add(menu,sizeof(menu),"6. Create MP5K: $100^n ");
		key += (1<<3|1<<4|1<<5)
	} else {
		add(menu,sizeof(menu),"4. NOT ENOUGH SKILL^n ");
		add(menu,sizeof(menu),"5. NOT ENOUGH SKILL^n ");
		add(menu,sizeof(menu),"6. NOT ENOUGH SKILL^n ");
	}
	if(g_weaponskills[id] >= 55)
	{
		add(menu,sizeof(menu),"7. Create Mossberg 500: $125^n ");
		add(menu,sizeof(menu),"8. Create Benelli M3: $125^n ");
		key += (1<<6|1<<7)
	} else {
		add(menu,sizeof(menu),"7. NOT ENOUGH SKILL^n ");
		add(menu,sizeof(menu),"8. NOT ENOUGH SKILL^n ");
	}
	if(g_weaponskills[id] >= 65)
	{
		add(menu,sizeof(menu),"9. Create M16A4: $200^n ");
		key += (1<<8)
	} else {
		add(menu,sizeof(menu),"9. NOT ENOUGH SKILL^n ");
	}
	add(menu,sizeof(menu),"^n 0. Close Menu");
	key += (1<<9)
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
public createweapon_use(id,key)
{
	switch(key)
	{
		/////////////////// ITEMID, AMOUNT, COST, NAME, FLOAT:TIMEOUT /////////////
		case 0: make_weapon(id,606,1,50,"Ruger",PISTOL_TIMEOUT)
		case 1: make_weapon(id,604,1,100,"Five-Seven",PISTOL_TIMEOUT)
		case 2: make_weapon(id,601,1,50,"Glock 18",PISTOL_TIMEOUT)
		case 3: make_weapon(id,630,1,150,"M4A1 Carbine",RIFLE_TIMEOUT)
		case 4: make_weapon(id,632,1,175,"AK47",RIFLE_TIMEOUT)
		case 5: make_weapon(id,600,1,100,"Akimbo Berettas",SMG_TIMEOUT)
		case 6: make_weapon(id,121,1,100,"Teargas",EXPLOSIVE_TIMEOUT)
		case 7: make_weapon(id,123,1,200,"Smoke Grenade",EXPLOSIVE_TIMEOUT)
		//case 8: make_weapon(id,23,1,2500,"Door C2", EXPLOSIVE_TIMEOUT)
		case 8: build_create_weapon2(id)
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public createweapon_use2(id,key)
{
	switch(key)
	{
		/////////////////// ITEMID, AMOUNT, COST, NAME, FLOAT:TIMEOUT /////////////
		case 0: make_weapon(id,613,1,100,"Steyr Tmp",SMG_TIMEOUT)
		case 1: make_weapon(id,614,1,112,"HK Pdw",SMG_TIMEOUT)
		case 2: make_weapon(id,608,1,125,"Golden Colts",SMG_TIMEOUT)
		case 3: make_weapon(id,615,1,100,"UMP45",SMG_TIMEOUT)
		case 4: make_weapon(id,609,1,100,"Mini Uzi", SMG_TIMEOUT)
		case 5: make_weapon(id,612,1,100,"MP5K",SMG_TIMEOUT)
		case 6: make_weapon(id,624,1,125,"Mossberg 500",SHOTGUN_TIMEOUT)
		case 7: make_weapon(id,620,1,125,"Benelli M3",SHOTGUN_TIMEOUT)
		case 8: make_weapon(id,636,1,200,"M16A4",RIFLE_TIMEOUT)
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public build_cook_food(id)
{
	new menu[1024],key
	new origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,g_cookingpos) > 150 && get_distance(origin,g_cookingpos2) > 150)
	{
		client_print(id,print_chat,"[COOKING] You must be at the diner's stove to cook.")
		return PLUGIN_HANDLED;
	}
	format(menu,sizeof(menu),"Cook Food^n^n ")
	if(g_cookingskills[id] >= 10)
	{
		// Cook Hamburgers and shytt maybez, lawlz0rs?
		add(menu,sizeof(menu),"1. Cook Small Fries^n ") // 42
		add(menu,sizeof(menu),"2. Cook Hotdog^n ") // 43
		add(menu,sizeof(menu),"3. Cook Hamburger^n ") // 45
		key += (1<<0|1<<1|1<<2)
	} else {
		add(menu,sizeof(menu),"1. NOT ENOUGH SKILL^n 2. NOT ENOUGH SKILL^n 3. NOT ENOUGH SKILL^n ")
	}
	if(g_cookingskills[id] >= 20)
	{
		add(menu,sizeof(menu),"4. Cook Pizza^n ") // 44
		add(menu,sizeof(menu),"5. Cook Pasta^n ") // 46
		add(menu,sizeof(menu),"6. Cook Steak^n ") // 47
		key += (1<<3|1<<4|1<<5)
	} else {
		add(menu,sizeof(menu),"4. NOT ENOUGH SKILL^n 5. NOT ENOUGH SKILL^n 6. NOT ENOUGH SKILL^n ")
	}
	add(menu,sizeof(menu),"^n 0. Close Menu")
	key += (1<<9)
	show_menu(id,key,menu)
	//client_print(id,print_chat,"[SKILL] This feature has not been implemented yet.")
	return PLUGIN_HANDLED;
}
public cookfood_use(id,key)
{
	new position,origin[3]
	get_user_origin(id,origin)
	if(get_distance(origin,g_cookingpos) <= 150)
	{
		position = 1 // Diner sprite position
	}
	if(get_distance(origin,g_cookingpos2) <= 150)
	{
		position = 2 // IN & Out sprite position
	}
	new rndamount = random_num(1,3)
	switch(key)
	{
		// cook_food(id,itemid,amount,cost,foodname[],Float:timeout)
		case 0: cook_food(id,42,rndamount,rndamount,"Small Fries",30.0)
		case 1: cook_food(id,43,rndamount,rndamount,"Hotdog",30.0)
		case 2: cook_food(id,45,rndamount,rndamount,"Hamburger",60.0)
		case 3: cook_food(id,44,rndamount,rndamount,"Pizza",60.0)
		case 4: cook_food(id,46,rndamount,rndamount,"Pasta",60.0)
		case 5: cook_food(id,47,rndamount,rndamount,"Steak",60.0)
		case 9: build_use_skills(id)
	}
	return PLUGIN_HANDLED;
}
public skills_motd(id)
{
	new motd[1024], normalskills[12], computerskills[12],fightskills[12],lawskills[12],weaponskills[12],cookingskills[12],drugskills[12]
	format(motd,sizeof(motd)," Your current skills! ")
	
	format(normalskills,11,"%d",g_normalskills[id])
	format(computerskills,11,"%d",g_computerskills[id])
	format(fightskills,11,"%d",g_fightskills[id])
	format(lawskills,11,"%d",g_lawskills[id])
	format(weaponskills,11,"%d",g_weaponskills[id])
	format(cookingskills,11,"%d", g_cookingskills[id])
	format(drugskills,11,"%d",g_drugskills[id])
	
	add(motd,sizeof(motd),"^n^n NORMAL SKILLS: ")
	add(motd,sizeof(motd),normalskills)
	add(motd,sizeof(motd),"^n COMPUTER SKILLS: ")
	add(motd,sizeof(motd),computerskills)
	add(motd,sizeof(motd),"^n FIGHT SKILLS: ")
	add(motd,sizeof(motd),fightskills)
	add(motd,sizeof(motd),"^n LAW SKILLS: ")
	add(motd,sizeof(motd),lawskills)
	add(motd,sizeof(motd),"^n WEAPON SKILLS: ")
	add(motd,sizeof(motd),weaponskills)
	add(motd,sizeof(motd),"^n COOKING SKILLS: ")
	add(motd,sizeof(motd),cookingskills)
	add(motd,sizeof(motd),"^n DRUG SKILLS: ")
	add(motd,sizeof(motd),drugskills)
	add(motd,sizeof(motd),"^n^n To see other's skills, type /viewskills <name> ^n Teachers, to offer education say /offereducation^n^n This all costs money, and to teach yourself a skill, say /skillmenu, to use skills, type /useskills^n^n Teachers: type /educationprices to see prices of your lessons")
	show_motd(id,motd,"SkillMod v1 by Smokey")
	return PLUGIN_HANDLED;
	//edit_value(id,"money","torturecredits", "+", amount)
}
public view_eduprices(id)
{
	new motd[1024]
	format(motd,sizeof(motd)," Education Prices!")
	add(motd,sizeof(motd),"^n These are how much stuff costs when you offer education to people(if your a teacher)^n^n ")
	add(motd,sizeof(motd),"1. Normal Skills: $200")
	add(motd,sizeof(motd),"^n 2. Computer Skills: $400")
	add(motd,sizeof(motd),"^n 3. Fighting Skills: $400")
	add(motd,sizeof(motd),"^n 4. Law Skills: $600")
	add(motd,sizeof(motd),"^n 5. Weapon Skills: $600")
	add(motd,sizeof(motd),"^n 6. Cooking Skills: $350^n 7. Drug Skills: $400^n^n To see your current skills, type /skills, to offer education, type /offereducation when looking at someone.")
	show_motd(id,motd,"SkillMod v1 by Smokey")
	return PLUGIN_HANDLED;
}
public viewskills(id,viewer)
{
	new idname[32],viewername[32]
	get_user_name(id,idname,31)
	get_user_name(viewer,viewername,31)
	client_print(id,print_chat,"[SKILLS] %s is looking into your skills.",viewername)
	client_print(viewer,print_chat,"[SKILLS] You are looking into %s's skills.",idname)
	
	new motd[1024], normalskills[12], computerskills[12],fightskills[12],lawskills[12],weaponskills[12],cookingskills[12],drugskills[12]
	format(motd,sizeof(motd)," %s's current skills! ",idname)
	
	format(normalskills,11,"%d",g_normalskills[id])
	format(computerskills,11,"%d",g_computerskills[id])
	format(fightskills,11,"%d",g_fightskills[id])
	format(lawskills,11,"%d",g_lawskills[id])
	format(weaponskills,11,"%d",g_weaponskills[id])
	format(cookingskills,11,"%d", g_cookingskills[id])
	format(drugskills,11,"%d", g_drugskills[id])
	
	add(motd,sizeof(motd),"^n^n NORMAL SKILLS: ")
	add(motd,sizeof(motd),normalskills)
	add(motd,sizeof(motd),"^n COMPUTER SKILLS: ")
	add(motd,sizeof(motd),computerskills)
	add(motd,sizeof(motd),"^n FIGHT SKILLS: ")
	add(motd,sizeof(motd),fightskills)
	add(motd,sizeof(motd),"^n LAW SKILLS: ")
	add(motd,sizeof(motd),lawskills)
	add(motd,sizeof(motd),"^n WEAPON SKILLS: ")
	add(motd,sizeof(motd),weaponskills)
	add(motd,sizeof(motd),"^n COOKING SKILLS: ")
	add(motd,sizeof(motd),cookingskills)
	add(motd,sizeof(motd),"^n DRUG SKILLS: ")
	add(motd,sizeof(motd),drugskills)
	add(motd,sizeof(motd),"^n^n To see usage on skills, type /useskills^n^n To see other's skills, type /viewskills <name> ^n Teachers, to offer education say /offereducation^n^n This all costs money, and to teach yourself a skill, say /skillmenu^n^n For teachers: To see what prices you give off to your customers, say /educationprices.")
	show_motd(viewer,motd,"SkillMod v1 by Smokey")
	server_print("[SKILLMOD] %s view's %s's skills.",viewername,idname)
	return PLUGIN_HANDLED;
}
public build_skillmenu(id)
{
	new menu[1024]
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9)
	format(menu,sizeof(menu),"Teach Yourself")
	add(menu,sizeof(menu)," ^n^n 1. Normal Skills: $100")
	add(menu,sizeof(menu),"^n 2. Computer Skills: $250")
	add(menu,sizeof(menu),"^n 3. Fighting Skills: $250")
	add(menu,sizeof(menu),"^n 4. Law Skills: $300")
	add(menu,sizeof(menu),"^n 5. Weapon Skills: $300")
	add(menu,sizeof(menu),"^n 6. Cooking Skills: $150")
	add(menu,sizeof(menu),"^n 7. Drug Skills: $200")
	add(menu,sizeof(menu),"^n^n 0. Close Menu")
	show_menu(id,key,menu)
	return PLUGIN_HANDLED;
}
//education_teach_self(id,key)
public education_teach_self(id,key)
{
	switch(key)
	{
		case 0: 
		{
			if(!has_money(id,100,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",100)
			economy_add_misc("taxfunds","val",100 / 2)
			gain_skills(id,"normalskills","+",1)
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!has_money(id,250,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",250)
			economy_add_misc("taxfunds","val",250 / 2)
			gain_skills(id,"computerskills","+", 1)
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			if(!has_money(id,250,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",250)
			economy_add_misc("taxfunds","val",250 / 2)
			gain_skills(id,"fightskills","+",1)
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(!has_money(id,300,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",300)
			economy_add_misc("taxfunds","val",300 / 2)
			gain_skills(id,"lawskills", "+", 1)
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			if(!has_money(id,300,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",300)
			economy_add_misc("taxfunds","val",300 / 2)
			gain_skills(id,"weaponskills", "+", 1)
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			if(!has_money(id,150,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",150)
			economy_add_misc("taxfunds","val",150 / 2)
			gain_skills(id,"cookingskills","+", 1)
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			if(!has_money(id,200,"balance"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				return PLUGIN_HANDLED;
			}
			edit_value(id,"money","balance","-",200)
			economy_add_misc("taxfunds","val",200 / 2)
			gain_skills(id,"drugskills","+",1)
			return PLUGIN_HANDLED;
		}
		case 9: client_print(id,print_chat,"[SKILLS] Menu closed.")
	}
	return PLUGIN_HANDLED;
}
public build_educationoffer(id)
{
	new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9)
	new target,hitbox
	get_user_aiming(id,target,hitbox,9999) // get users aiming within 9999 units
	if(target < 1 || target > get_maxplayers())
	{
		client_print(id,print_chat,"[SKILL] Invalid target to offer education to.")
		return PLUGIN_HANDLED;
	}
	if(e_timeout[id] > 0)
	{
		client_print(id,print_chat,"[SKILL] Please try again in a few seconds...")
		return PLUGIN_HANDLED;
	}
	if(get_jobid(target) == g_teachjob)
	{
		client_print(id,print_chat,"[SKILL] You cannot educate another teacher!")
		return PLUGIN_HANDLED;
	}
	if(job_check(id,"school") || job_check(id,"teacher"))
	{
		e_timeout[id] = 1
		set_task(5.0, "no_etimeout", id)
		new menu[1024],name[32]
		get_user_name(id,name,31)
		g_offermaker[target][0] = id
		format(menu,sizeof(menu),"Education Offer from %s", name)
		add(menu,sizeof(menu),"^n 1. Normal Skills: $200")
		add(menu,sizeof(menu),"^n 2. Computer Skills: $400")
		add(menu,sizeof(menu),"^n 3. Fighting Skills: $400")
		add(menu,sizeof(menu),"^n 4. Law Skills: $600")
		add(menu,sizeof(menu),"^n 5. Weapon Skills: $600")
		add(menu,sizeof(menu),"^n 6. Cooking Skills: $350")
		add(menu,sizeof(menu),"^n 7. Drug Skills: $400")
		add(menu,sizeof(menu),"^n^n 0. Close Menu")
		show_menu(target,key,menu)
	} else {
		client_print(id,print_chat,"[SKILLS] You are not a teacher!")
	}
	return PLUGIN_HANDLED;
}
public educationoffer_use(id,key)
{
	new educater = g_offermaker[id][0] // who educated meh?
	if(!is_user_connected(educater))
	{
		client_print(id,print_chat,"[EDUCATION] Your teacher is not present in the server.")
		return PLUGIN_HANDLED;
	}
	switch(key)
	{
		case 0:
		{
			if(!has_money(id,200,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"normalskills","+",random_num(2,5))
			edit_value(educater,"money","wallet","+",30)
			edit_value(id,"money","wallet","-",200)
			economy_add_misc("taxfunds","val",200 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Normal Skills)")
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(!has_money(id,400,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"computerskills","+",random_num(2,5))
			edit_value(educater,"money","wallet","+",50)
			edit_value(id,"money","wallet","-",400)
			economy_add_misc("taxfunds","val",200 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Computer Skills)")
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			if(!has_money(id,400,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"fightskills","+",random_num(2,5))
			edit_value(educater,"money","wallet","+",50)
			edit_value(id,"money","wallet","-",400)
			economy_add_misc("taxfunds","val",400 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Fighting Skills)")
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(!has_money(id,600,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"lawskills","+",random_num(2,4))
			edit_value(educater,"money","wallet","+",100)
			edit_value(id,"money","wallet","-",600)
			economy_add_misc("taxfunds","val",600 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Law Skills)")
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			if(!has_money(id,600,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"weaponskills","+",random_num(2,5))
			edit_value(educater,"money","wallet","+",100)
			edit_value(id,"money","wallet","-",600)
			economy_add_misc("taxfunds","val",600 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Weapon Skills)")
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			if(!has_money(id,350,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"cookingskills","+",random_num(3,8))
			edit_value(educater,"money","wallet","+",25)
			edit_value(id,"money","wallet","-",350)
			economy_add_misc("taxfunds","val",350 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer!(Cooking Skills)")
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			if(!has_money(id,400,"wallet"))
			{
				client_print(id,print_chat,"[EDUCATION] You do not have enough money!")
				client_print(educater,print_chat,"[EDUCATION] The person you offered education cannot pay.")
				return PLUGIN_HANDLED;
			}
			gain_skills(id,"drugskills","+",random_num(3,6))
			edit_value(educater,"money","wallet","+",50)
			edit_value(id,"money","wallet","-",400)
			economy_add_misc("taxfunds","val",400 / 2)
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has accepted the offer(Drug Skills)")
			return PLUGIN_HANDLED;
		}
		case 9:
		{
			client_print(id,print_chat,"[EDUCATION] You have denied this education offer!")
			client_print(educater,print_chat,"[EDUCATION] The person you offered education has declined your offer!")
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}
public no_more_comhack(id)
{
	client_print(id,print_chat,"[HACKING] Your connection with the MCPD and MCMD communication radios has been cut.")
	comhack[id] = 0;
}
public cook_effect(id)
{
	id -= 213
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(17)
	write_coord(g_cookingpos[0])
	write_coord(g_cookingpos[1])
	write_coord(g_cookingpos[2])
	write_short(firesprite)
	write_byte(10) // width/height of sprite
	write_byte(15) // framerate
	message_end()
	//cook_effect_2()
	return PLUGIN_HANDLED;
}
public cook_effect_2()
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(17)
	write_coord(g_cookingpos2[0])
	write_coord(g_cookingpos2[1])
	write_coord(g_cookingpos2[2])
	write_short(firesprite)
	write_byte(10) // width/height of cooking sprite
	write_byte(15) // framerate
	message_end() // end message
	return PLUGIN_HANDLED;
}
public burnsound2(id)
{
	id -= 214
	emit_sound(id, CHAN_AUTO, "harburp/leaves2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED;
}

public realhud_enforce() // enforces cl_realhud 1 on the player and cl_laser 2
{
	if(get_cvar_num("rp_enforce_realhud") == 0)
	{
		return PLUGIN_HANDLED;
	}
	new players[32],num
	get_players(players,num,"ac")
	for( new i = 0; i < num; i++ )
	{
		if(g_weaponskills[players[i]] < 60)
		{
			client_cmd(players[i],"cl_realhud 1")
			client_cmd(players[i],"cl_laser 2")
		}
	}
	return PLUGIN_HANDLED;
}

public fix_cvars()
{
	//cvar_to_array("rp_position_gunshop",31,gunshop,3)

	cvar_to_array("rp_position_atmone",31,atmone,3)
	cvar_to_array("rp_position_atmtwo",31,atmtwo,3)
	cvar_to_array("rp_position_atmthree",31,atmthree,3)
	cvar_to_array("rp_position_atmfour",31,atmfour,3)

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
	cvar_to_array("rp_jobid_diner",31,g_dinerjobs,2)
	cvar_to_array("rp_jobid_bank",31,g_bankjobs,2)
	cvar_to_array("rp_jobid_bar",31,g_barjobs,2)
	cvar_to_array("rp_position_teacher",31,g_teacherpos,3)
}


//////////////////
// ALL STOCKS ///
// Check the amount of the specified item
stock get_item_amount(id,itemid,table[],customid[]="")
{
	new authid[32], amount, query[1024]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
	format(query,sizeof(query),"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		new field[MAXIUMSTR]
		new output[ITEMS][32]
		dbi_field(result,1,field,MAXIUMSTR-1)
		new total = explode(output,field,' ')
		for( new i = 0;  i < total; i++ )
		{
			new output2[2][164]
			explode(output2,output[i],'|')
			if(str_to_num(output2[0]) == itemid)
			{
				amount = str_to_num(output2[1])
				return amount
			}
		}
		dbi_free_result(result)
	} else {
		dbi_free_result(result)
	}
	return amount
}

// For Adding/Subtracting Items Quickly
stock set_item_amount(id,func[],itemid,amount,table[],customid[]="")
{
	new authid[32], query[1024], itemfield[MAXIUMSTR]
	if(equali(customid,"")) get_user_authid(id,authid,31)
	else format(authid,31,customid)
	new currentamount = get_item_amount(id,itemid,table,customid)
	format(query,sizeof(query),"SELECT items FROM %s WHERE steamid='%s'",table,authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,itemfield,MAXIUMSTR-1)
		dbi_free_result(result)
		/*
		if(equali(func,"-"))
		{
			new string[1024]
			format(string,sizeof(string)," %i|%i",itemid,currentamount)
			if(containi(itemfield,string) != -1)
			{
				if((currentamount - amount) <= 0)
				{
					replace(itemfield,MAXIUMSTR-1,string,"")
				}
				else
				{
					new newstring[1024]
					format(newstring,sizeof(newstring)," %i|%i",itemid,currentamount-amount)
					replace(itemfield,sizeof(itemfield),string,newstring)
				}
				format(query,sizeof(query),"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,"%s",query)
			}
			else
			{
				client_print(id,print_chat,"[ItemMod] Error #150 LOOP. Please contact an administrator^n")
				return PLUGIN_HANDLED
			}
		}
		*/
		if(equali(func,"-"))
		{
			if(get_item_amount(id,itemid,table,authid) == 0)
			{
				new str[1024]
				format(str,sizeof(str)," %i|%i",itemid,(currentamount -amount))
				add(itemfield,sizeof(itemfield),str)
				format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,"%s",query)
			}
			else
			{
				if(currentamount - amount <= 0)
				{
					new string[1024]
					format(string,sizeof(string)," %i|%i",itemid,currentamount)
					replace(itemfield,MAXIUMSTR-1,string,"")
					format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
					dbi_query(dbc,"%s",query)
					
				}
				if(currentamount > 1)
				{
					new newstr[1024], oldstr[1024]
					format(oldstr,sizeof(oldstr)," %i|%i",itemid,currentamount)
					format(newstr,sizeof(newstr)," %i|%i",itemid,(currentamount -amount))
					replace(itemfield,sizeof(itemfield),oldstr,newstr)
					format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
					dbi_query(dbc,"%s",query)
				}
			}
		}
		if(equali(func,"+"))
		{
			if(get_item_amount(id,itemid,table,authid) == 0)
			{
				new str[1024]
				format(str,sizeof(str)," %i|%i",itemid,(currentamount +amount))
				add(itemfield,sizeof(itemfield),str)
				format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
				dbi_query(dbc,"%s",query)
			}
			else
			{
				if(currentamount > 0)
				{
					new newstr[1024], oldstr[1024]
					format(oldstr,sizeof(oldstr)," %i|%i",itemid,currentamount)
					format(newstr,sizeof(newstr)," %i|%i",itemid,(currentamount +amount))
					replace(itemfield,sizeof(itemfield),oldstr,newstr)
					format(query,MAXIUMSTR-1,"UPDATE %s SET items='%s' WHERE steamid='%s'",table,itemfield,authid)
					dbi_query(dbc,"%s",query)
				}
				else
				{
					client_print(id,print_chat,"[ItemMod] Error #200. Please contact an administrator^n")
					return PLUGIN_HANDLED
				}
			}
		}
	} else {
		dbi_free_result(result)
	}
	return PLUGIN_HANDLED
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
	dbi_query(dbc,"%s",query)
	return PLUGIN_HANDLED
}

// Selecting one string from the database
public select_string(id,table[],index[],condition[],equals[],output[])
{
	new query[512]
	format(query,sizeof(query),"SELECT %s FROM %s WHERE %s='%s'",index,table,condition,equals)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0) dbi_field(result,1,output,sizeof(output))
	dbi_free_result(result)
}

// Find user from database, must be registerd a playername
public is_user_database(id)
{
	if(dbc < SQL_OK) return 0
	new authid[32], query[256]
	get_user_authid(id,authid,31)
	format(query,255,"SELECT name FROM money WHERE steamid='%s'",authid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_free_result(result)
		return 1
	} else {
		dbi_free_result(result)
	}
	return 0
}
public has_money(id,amount,where[])
{
	new wallet,balance,buffer[64],authid[32];
	get_user_authid(id,authid,31)
	// does the user have enough money?
	if(equali(where,"wallet"))
	{
		select_string(id,"money","wallet","steamid",authid,buffer)
		wallet = str_to_num(buffer)
		if(wallet < amount)
		{
			return 0;
		} else {
			return 1;
		}
	}
	if(equali(where,"balance"))
	{
		select_string(id,"money","balance","steamid",authid,buffer)
		balance = str_to_num(buffer)
		if(balance < amount)
		{
			return 0;
		} else {
			return 1;
		}
	}
	return 0;
}
stock get_jobid(id)
{
	new JobID;
	if(is_user_database(id) > 0)
	{
		new query[256],authid[32]
		get_user_authid(id,authid,31)
		format( query, 255, "SELECT JobID FROM money WHERE steamid='%s'", authid)
		result = dbi_query( dbc, "%s", query)
		if( dbi_nextrow( result ) > 0 )
		{
			JobID = dbi_field(result,1)
		}
		dbi_free_result(result)
		return JobID;
	}
	return JobID;
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

// Check if origin and NPC are enough close
stock allowed_npc_distance(id,npcid)
{
	new mapname[32],setting,pref[32]
	get_mapname(mapname,31)
	if(containi(mapname,"mecklenburg") != -1)
	{
		setting = 1 //Mecklenburg SettingID
		format(pref,31,"npc")
	} else {
		setting = 2 // Coram_downtown_a1 SettingID
		format(pref,31,"npc2")
	}
	new origin[3], n_origin[3], query[256]
	get_user_origin(id,origin)
	format(query,255,"SELECT x,y,z FROM %s WHERE npcid=%i",pref,npcid)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		n_origin[0] = dbi_field(result,1)
		n_origin[1] = dbi_field(result,2)
		n_origin[2] = dbi_field(result,3)

		dbi_free_result(result)
		if(get_distance(origin,n_origin) <= 25.0) return 1

	} else {
		dbi_free_result(result)
	}
	return 0
}
stock hackmod_use(id,function[],cost,Float:timeout)
{
	if(!has_money(id,cost,"balance"))
	{
		client_print(id,print_chat,"[HACKING] You do not have enough money to %s", function)
		return PLUGIN_HANDLED;
	}
	new target,body,Float:distance,myorigin[3], classname[32]
	distance = get_user_aiming(id,target,body,400)
	get_user_origin(id,myorigin)
	if(target > get_maxplayers())
	{
		entity_get_string(target, EV_SZ_classname, classname, 31)
	}
	if(programming_timeout[id] == 0 && hacking_timeout[id] == 0) // horrible method, it can be glitched and abused.
	{
		edit_value(id,"money","balance","-",cost)
	}
	economy_add_misc("taxfunds","val",cost / 2)
	if(equali(function,"basicprogram"))
	{
		if(programming_timeout[id] >= 1)
		{
			client_print(id,print_chat,"[COMPUTER] You cannot create a basic program at the time.")
			return PLUGIN_HANDLED;
		}
		new rnd;
		if(g_computerskills[id] >= 100 && g_computerskills[id] < 400)
		{
			rnd = random(6)
		} else if(g_computerskills[id] >= 400)
		{
			rnd = random(4)
		} else if(g_computerskills[id] < 100) {
			rnd = random(10)
		}
		new calcpay = random_num(g_computerskills[id],g_computerskills[id] * 2)
		new rnd_upgrade = random(500)
		if(rnd == 1)
		{
			// then have him succeed!
			client_print(id,print_chat,"[COMPUTER] You have created a basic program, earning you $%d.", calcpay)
			programming_timeout[id] = 1
			edit_value(id,"money","balance","+",calcpay)
			set_task(timeout, "no_programtimeout", id)
		}
		if(rnd > 1 || rnd == 0)
		{
			client_print(id,print_chat,"[COMPUTER] You have failed to create a good program, and earn nothing.")
			client_print(id,print_console,"CHOSEN: %i^n", rnd)
			programming_timeout[id] = 1
			set_task(timeout,"no_programtimeout", id)
		}
		if(rnd_upgrade == 250)
		{
			client_print(id,print_chat,"[COMPUTER] BONUS! You have recieved another computer skillpoint!")
			gain_skills(id,"computerskills","+",1)
			g_computerskills[id]++
		}
		return PLUGIN_HANDLED;
	}
	if(equali(function,"advancedprogram"))
	{
		if(programming_timeout[id] == 1)
		{
			client_print(id,print_chat,"[COMPUTER] You cannot create an advanced program at this time.")
			return PLUGIN_HANDLED;
		}
		new rnd;
		if(g_computerskills[id] > 2000)
		{
			rnd = random(5)
		} else if(g_computerskills[id] > 3000)
		{
			rnd = random(3)
		} else if(g_computerskills[id] <= 2000)
		{
			rnd = random(7)
		}
		new calcpay = random_num(g_computerskills[id]*2,g_computerskills[id] * 3)
		new rndupgrade = random(150)
		if(rnd == 1)
		{
			// then have him succeed!
			client_print(id,print_chat,"[COMPUTER] You have created a advanced program, earning you $%d.", calcpay)
			programming_timeout[id] = 1
			edit_value(id,"money","balance","+",calcpay)
			set_task(timeout, "no_programtimeout", id)
		}
		if(rnd > 1 || rnd == 0)
		{
			client_print(id,print_chat,"[COMPUTER] You have failed to create a good program, and earn nothing.")
			client_print(id,print_console,"CHOSEN: %i^n", rnd)
			programming_timeout[id] = 1
			set_task(timeout,"no_programtimeout",id)
		}
		if(rndupgrade == 0)
		{
			client_print(id,print_chat,"[COMPUTER] BONUS! You have received another computer skillpoint!")
			gain_skills(id,"computerskills","+",1)
			g_computerskills[id]++
		}
		return PLUGIN_HANDLED;
	}
	if(equali(function,"hackdoor"))
	{
		if(target <= get_maxplayers())
		{
			client_print(id,print_chat,"[HACKING] You must be looking at a door to hack it!")
			return PLUGIN_HANDLED;
		}
		if(hacking_timeout[id] >= 1)
		{
			client_print(id,print_chat,"[HACKING] You cannot hack so often!")
			return PLUGIN_HANDLED;
		}
		//edit_money(id,amount,where[],func[])
		if(!equali(classname,"func_door"))
		{
			client_print(id,print_chat,"[HACKING] You can only hack sliding doors!")
			return PLUGIN_HANDLED;
		}
		new rndwin
		if(g_computerskills[id] > 190)
		{
			rndwin = random(3)
		} else {
			rndwin = random(8)
		}
		if(rndwin == 0)
		{
			client_print(id,print_chat,"[HACKING] You have successfully hacked the door!")
			force_use(id,target)
			fake_touch(target,id)
			hacking_timeout[id] = 1;
			set_task(timeout, "no_hackertimeout", id)
		}
		if(rndwin > 0)
		{
			client_print(id,print_chat,"[HACKING] You have failed to hack this door, try again later.")
			hacking_timeout[id] = 1;
			set_task(timeout, "no_hackertimeout", id)
		}
	}
	if(equali(function,"atmhack"))
	{
		if(hacking_timeout[id] >= 1)
		{
			client_print(id,print_chat,"[HACKING] You cannot hack so often.")
			return PLUGIN_HANDLED;
		}
		if(get_distance(myorigin,atmone) < 150 || get_distance(myorigin,atmtwo) < 150 || get_distance(myorigin,atmthree) < 150 || get_distance(myorigin,atmfour) < 150)
		{
			new rnd,rndlogged;
			if(g_computerskills[id] > 60)
			{
				rnd = random(8)
				rndlogged = random(50)
			} else if(g_computerskills[id] >= 400)
			{
				rnd = random(6)
				rndlogged = random(100)
			} else if(g_computerskills[id] < 60) {
				rnd = random(25)
				rndlogged = random(25)
			}
			new rndcash = g_computerskills[id]
			if(rndlogged == 0)
			{
				client_print(id,print_chat,"[HACKING] A message shows up: Intrusion detected...logging")
				log_bank(id,404,"ATM Machine Hack Detected")
			}
			if(rnd == 0)
			{
				client_print(id,print_chat,"[HACKING] You have successfully hacked the ATM Machine getting $%d dollars!",rndcash)
				client_cmd(id,"say /me successfully hacks the ATM Machine.")
				edit_value(id,"money","balance","-",cost)
				edit_value(id,"money","balance","+",rndcash)
				hacking_timeout[id] = 1
				set_task(timeout, "no_hackertimeout", id)
				return PLUGIN_HANDLED;
			}
			if(rnd > 0)
			{
				client_cmd(id,"say /me attempts to hack the ATM Machine.")
				client_print(id,print_chat,"[HACKING] You have failed to hack the ATM Machine.")
				edit_value(id,"money","balance","-",cost)
				hacking_timeout[id] = 1
				set_task(timeout, "no_hackertimeout", id)
				return PLUGIN_HANDLED;
			}
		} else {
			client_print(id,print_chat,"[HACKING] You are not close enough to an ATM Machine.")
		}
	}
	if(equali(function,"comhack"))
	{
		if(hacking_timeout[id] == 1)
		{
			client_print(id,print_chat,"[HACKING] You cannot hack so often!")
			return PLUGIN_HANDLED;
		}
		new rnd;
		if(g_computerskills[id] > 50)
		{
			rnd = random(4)
		} else {
			rnd = random(15)
		}
		if(rnd == 0)
		{
			client_print(id,print_chat,"[HACKING] You have successfully hacked the communication radios!")
			comhack[id] = 1;
			set_task(240.0,"no_more_comhack",id)
			client_cmd(id,"say /me hacks into communication radios.")
			hacking_timeout[id] = 1;
			set_task(timeout,"no_hackertimeout",id)
			return PLUGIN_HANDLED;
		} else {
			client_print(id,print_chat,"[HACKING] You have failed to hack the communication radios!")
			client_cmd(id,"say /me attempts to hack the communication radios.")
			hacking_timeout[id] = 1;
			set_task(timeout,"no_hackertimeout",id)
			return PLUGIN_HANDLED;
		}
	}
	client_print(id,print_console,"[HACKING] End of hack.")
	return PLUGIN_HANDLED;
}
stock give_job(id,jobid,message[])
{
	client_print(id,print_chat,message)
	edit_value(id,"money","JobID","=",jobid)
	return PLUGIN_HANDLED;
}
stock job_check(id,name[])
{
	// If a user's job has this word in it, then it returns 1, otherwise, 0.
	new JobID = get_jobid(id)
	new JobName[32]
	new query[256]
	format(query,255,"SELECT JobName from jobs WHERE JobID=%d",JobID)
	result = dbi_query(dbc,"%s",query)
	if(dbi_nextrow(result) > 0)
	{
		dbi_field(result,1,JobName,31)
		dbi_free_result(result)
	} else {
		dbi_free_result(result)
	}
	if(containi(JobName,name) != -1)
	{
		return 1;
	} else {
		return 0;
	}
	return 1;
}
stock edit_money(id,amount,where[],func[])
{
	edit_value(id,"money",where,func,amount)
	return PLUGIN_HANDLED;
}
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
public communication_hack_value(id)
{
	return comhack[id];
}
stock gain_skills(id,skill[],func[],amount)
{
	client_print(id,print_chat,"Your %s has been upgraded by %d point(s).",skill,amount)
	if(equali(skill,"normalskills"))
	{
		g_normalskills[id] += amount
	}
	if(equali(skill,"computerskills"))
	{
		g_computerskills[id] += amount
	}
	if(equali(skill,"fightskills"))
	{
		g_fightskills[id] += amount
	}
	if(equali(skill,"lawskills"))
	{
		g_lawskills[id] += amount
	}
	if(equali(skill,"weaponskills"))
	{
		g_weaponskills[id] += amount
	}
	if(equali(skill,"cookingskills"))
	{
		g_cookingskills[id] += amount
	}
	if(equali(skill,"drugskills"))
	{
		g_drugskills[id] += amount
	}
	edit_value(id,"skills",skill,func,amount)
	return PLUGIN_HANDLED;
}
stock make_weapon(id,itemid,amount,cost,weaponname[],Float:timeout)
{
	if(!has_money(id,cost,"balance"))
	{
		client_print(id,print_chat,"[SKILL] You do not have enough money to make weapon %s",weaponname)
		return PLUGIN_HANDLED;
	}
	if(creategun_timeout[id] >= 1)
	{
		client_print(id,print_chat,"[SKILL] You cannot create weapons so often!")
		return PLUGIN_HANDLED;
	}
	economy_add_misc("taxfunds","val3",cost / 2)
	edit_value(id,"money","balance","-",cost)
	set_item_amount(id,"+",itemid,amount,"money")
	client_print(id,print_chat,"[SKILL] You have created %d of weapon: %s[%d]", amount,weaponname,itemid)
	creategun_timeout[id] = 1
	set_task(timeout,"creategun_cleartimeout",id)
	return PLUGIN_HANDLED;
}
stock make_item(id,itemid,amount,cost,itemname[],Float:timeout)
{
	if(!has_money(id,cost,"balance"))
	{
		client_print(id,print_chat,"[SKILL] You do not have enough money to make item %s",itemname)
		return PLUGIN_HANDLED;
	}
	if(createitem_timeout[id] >= 1)
	{
		client_print(id,print_chat,"[SKILL] You cannot create items so often!")
		return PLUGIN_HANDLED;
	}
	economy_add_misc("taxfunds","val2",cost / 2)
	edit_value(id,"money","balance","-",cost)
	set_item_amount(id,"+",itemid,amount,"money")
	client_print(id,print_chat,"[SKILL] You have created %d of item: %s[ID %d]",amount,itemname,itemid)
	createitem_timeout[id] = 1
	set_task(timeout,"createitem_cleartimeout",id)
	return PLUGIN_HANDLED;
}
stock make_drug(id,itemid,amount,cost,drugname[],Float:timeout)
{
	if(!has_money(id,cost,"balance"))
	{
		client_print(id,print_chat,"[SKILL] You do not have enough money to make drug %s.",drugname)
		return PLUGIN_HANDLED;
	}
	if(createdrug_timeout[id] >= 1)
	{
		client_print(id,print_chat,"[SKILL] You cannot create drugs so often!")
		return PLUGIN_HANDLED;
	}
	edit_value(id,"money","balance","-",cost)
	set_item_amount(id,"+",itemid,amount,"money")
	economy_add_misc("taxfunds", "val4",cost / 2)
	client_print(id,print_chat,"[SKILL] You have created %d of item %s[id %d]", amount,drugname,itemid)
	createdrug_timeout[id] = 1
	set_task(timeout,"createdrug_cleartimeout",id)
	return PLUGIN_HANDLED;
}
stock cook_food(id,itemid,amount,cost,foodname[],Float:timeout)
{
	if(!has_money(id,cost,"balance"))
	{
		client_print(id,print_chat,"[SKILL] You do not have enough money to cook %s",foodname)
		return PLUGIN_HANDLED;
	}
	if(cook_timeout[id] >= 1)
	{
		client_print(id,print_chat,"[SKILL] You cannot cook item's so often!")
		return PLUGIN_HANDLED;
	}
	edit_value(id,"money","balance","-",cost)
	set_item_amount(id,"+",itemid,amount,"money")
	client_print(id,print_chat,"[SKILL] You have cooked %s x %d.",foodname,amount)
	cook_timeout[id] = 1
	set_task(timeout,"cook_cleartimeout",id)
	set_task(0.2, "cook_effect", id+213,"",0,"b")
	set_task(2.0,"burnsound2",id+214,"",0,"b")
	return PLUGIN_HANDLED;
}
stock log_bank(id,var,action[])
{
	new query[256],authid[32],name[32]
	get_user_authid(id,authid,31)
	get_user_name(id,name,31)
	format(query,sizeof(query),"INSERT INTO banklogs(steamid,name,var,logstr) VALUES('%s','%s','%i','%s')",authid,name,var,action)
	dbi_query(dbc,query)
	return PLUGIN_HANDLED;
}
stock economy_add_misc(title[],varname[],value)
{
	new query[256]
	format(query,sizeof(query),"UPDATE misc SET %s=%s+%i WHERE title='%s'",varname,varname,value,title)
	dbi_query(dbc,query)
	return PLUGIN_HANDLED;
}
stock economy_subtract_misc(title[],varname[],value)
{
	new query[256]
	format(query,sizeof(query),"UPDATE misc SET %s=%s-%i WHERE title='%s'", varname, varname, value, title)
	dbi_query(dbc,query)
	return PLUGIN_HANDLED;
}
stock get_misc_value(title[],varname[])
{
	new query[256],amount
	format(query,sizeof(query),"SELECT %s FROM misc WHERE title='%s',varname,title)
	result = dbi_query(dbc,query)
	if(dbi_nextrow(result) > 0)
	{
		amount = dbi_field(result,1)
		dbi_free_result(result)
	} else {
		dbi_free_result(result)
		return -1;
	}
	return amount;
}
stock plant_insert(id,plantname[],allowdistance,grow_time,health,amount,x,y,z,itemid)
{
	new authid[32]
	get_user_authid(id,authid,31)
	new query[512]
	format(query,sizeof(query),"INSERT INTO planting(authid,plantname,allowdistance,val,health,amount,x,y,z,itemid) VALUES('%s','%s','%i','%i','%i','%i','%i','%i','%i','%i')",authid,plantname,allowdistance,grow_time,health,amount,x,y,z,itemid)
	dbi_query(dbc,query)
	plant_insert_timeout[id] = 1;
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
		client_print(id,print_chat,"[DRUGS] Error getting health of your marijuana.")
		dbi_free_result(result)
		return 0;
	}
	return health;
}