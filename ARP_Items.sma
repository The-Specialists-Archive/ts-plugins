#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Chat>
#include <tsx>
#include <tsfun>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#define ALCOHOL_MULTIPLE 10

new g_AttachMenu[] = "ARP_AttachMenu"
new g_LockMenu[] = "ARP_LockMenu"
new g_Keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9

new g_Attachments[33]
new g_Gun[33]
new g_Cell[33]
new g_Pick[33]
new g_Tazered[33]
new g_SpeedMode[33]
new g_Color[33][3]

new Float:g_LastTazer[33]
new Float:g_MaxSpeed[33]

enum SMOKING
{
	ITEM = 0,
	TIME
}

new g_Smoking[33][SMOKING]
new g_Alcohol[33]

new g_Taped[33]
new g_Roped[33]

enum WEAPON
{
	ITEMID = 0,
	ATTACHMENTS
}

new g_Smoke
new g_Lightning

new g_MsgScreenFade

new g_FlashSound[] = "weapons/sfire-inslow.wav"
new g_HeartSound[] = "harburp/heart.wav"
new g_TazerSound[] = "harburp/tazer.wav"
new g_HealSound[] = "items/smallmedkit1.wav"
new g_FlashlightSound[] = "items/flashlight1.wav"
new g_HitSound[] = "debris/bustmetal2.wav"
new g_Model[] = "models/ceilinggibs.mdl"
new g_ModelId

new g_Flashlight[33]

new g_GunStats[TS_MAX_WEAPONS][WEAPON] = 
{
	{0,0},
	{50,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SILENCER},
	{0,0},
	{51,TSA_SILENCER},
	{52,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE},
	{53,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{54,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE},
	{55,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{56,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SILENCER},
	{57,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SILENCER},
	{0,0},
	{58,TSA_FLASHLIGHT|TSA_LASERSIGHT},
	{59,TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{60,TSA_SCOPE},
	{61,TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{62,TSA_LASERSIGHT|TSA_SILENCER},
	{0,0},
	{63,TSA_LASERSIGHT|TSA_SILENCER},
	{64,TSA_LASERSIGHT},
	{65,TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{66,TSA_FLASHLIGHT|TSA_LASERSIGHT},
	{67,0},
	{68,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SILENCER},
	{69,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE|TSA_SILENCER},
	{70,0},
	{71,0},
	{72,TSA_FLASHLIGHT|TSA_LASERSIGHT},
	{73,TSA_FLASHLIGHT|TSA_LASERSIGHT|TSA_SCOPE},
	{74,TSA_LASERSIGHT},
	{0,0},
	{0,0},
	{75,TSA_LASERSIGHT|TSA_SCOPE},
	{76,0},
	{77,TSA_LASERSIGHT},
	{78,0},
	{79,0},
	{0,0},
	{0,0},
	{80,TSA_LASERSIGHT|TSA_SCOPE}
}

new g_WeaponAmmo[TS_MAX_WEAPONS] =
{
	0,//"",
	210,//"glock18",
	// what the fuck is this anyway?
	0,//"unk1",
	210,//"uzi",
	60,//"m3",
	90,//"m4a1",
	210,//"mp5sd",
	210,//"mp5k",
	210,//"aberettas",
	175,//"mk23",
	175,//"amk23",
	60,//"usas",
	70,//"deagle",
	90,//"ak47",
	200,//"57",
	90,//"aug",
	210,//"auzi",
	300,//"skorpion",
	30,//"m82a1",
	200,//"mp7",
	60,//"spas",
	200,//"gcolts",
	100,//"glock20",
	175,//"ump",
	0,//"m61grenade",
	0,//"cknife",
	60,//"mossberg",
	90,//"m16a4",
	150,//"mk1",
	0,//"c4",
	200,//"a57",
	50,//"rbull",
	90,//"m60e3",
	60,//"sawed_off",
	0,//"katana",
	0,//"sknife",
	0,//"kungfu",
	0,//"tknife",
	35,//"contender"	
}

new g_AmmoTypes[TS_MAX_WEAPONS] =
{
	0,//"",
	1,//"glock18",
	// what the fuck is this anyway?
	0,//"unk1",
	1,//"uzi",
	2,//"m3",
	3,//"m4a1",
	1,//"mp5sd",
	1,//"mp5k",
	1,//"aberettas",
	4,//"mk23",
	4,//"amk23",
	2,//"usas",
	5,//"deagle",
	6,//"ak47",
	7,//"57",
	3,//"aug",
	1,//"auzi",
	12,//"skorpion",
	8,//"m82a1",
	7,//"mp7",
	2,//"spas",
	4,//"gcolts",
	9,//"glock20",
	4,//"ump",
	0,//"m61grenade",
	0,//"cknife",
	2,//"mossberg",
	3,//"m16a4",
	10,//"mk1",
	0,//"c4",
	7,//"a57",
	11,//"rbull",
	3,//"m60e3",
	2,//"sawed_off",
	0,//"katana",
	0,//"sknife",
	0,//"kungfu",
	0,//"tknife",
	13//"contender"
}

new g_Cigarette
new g_Cigar
new g_Pipe

new g_Beer
new g_Gin
new g_Whiskey
new g_Vodka
new g_HawkMiller

new g_Tazer

new g_Spray

new g_Restricted

new g_FlashlightId

// TS ammo types
new g_9Parabellum
new g_12Gauge
new g_556NATO
new g_45ACP
new g_50AE
new g_762Soviet
new g_57FN
new g_50BMG
new g_10Auto
new g_22Hornet
new g_454Casull
new g_32ACP
new g_762NATO

// SC ammo types
#if 0
new g_357
new g_Buckshot
new g_762
new g_Bolts
new g_Cells
new g_RPG
new g_ARGrenades
new g_9mm
new g_Minigun
#endif

new g_DoorC2

new g_AssassinKnife[33]

enum MODS
{
	TS = 0,
	SC
}

new MODS:g_Mod

#define EAT_TASK_OFFSET 1231231

public plugin_init()
{	
	register_impulse(201,"SprayAttempt")
	register_impulse(100,"FlashlightAttempt")
	
	ARP_RegisterEvent("HUD_Render","EventHudRender")
	
	//register_clcmd("say","CmdSay")
	//ARP_RegisterEvent("Player_Say","CmdSay")
	ARP_AddChat(_,"CmdSay")
	
	if(module_exists("tsfun")) g_Mod = TS
	// No such module
	else /*if(module_exists("svencoop")*/ g_Mod = SC
	
	register_event("DeathMsg","EventDeathMsg","a")
	
	g_MsgScreenFade = get_user_msgid("ScreenFade")
	
	set_task(0.1,"Flashlight")
	
	RegisterHam(Ham_TakeDamage,"player","_Ham_TakeDamage")
}

public ARP_Init()
	ARP_RegisterPlugin("Items",ARP_VERSION,"The Apollo RP Team","Adds basic items")

public ARP_Error(const Reason[])
	pause("d")

public plugin_natives()
{
    set_module_filter("ModuleFilter")
    set_native_filter("NativeFilter")
}

public ModuleFilter(const Module[])
{
    if(equali(Module,"tsfun") || equali(Module,"tsx"))
        return PLUGIN_HANDLED
	
    return PLUGIN_CONTINUE
}
public NativeFilter(const Name[],Index,Trap)
{
    if(!Trap)
        return PLUGIN_HANDLED
        
    return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	g_Tazered[id] = 0

	g_LastTazer[id] = 0.0
	g_MaxSpeed[id] = 0.0
	
	g_Alcohol[id] = 0
	
	g_Flashlight[id] = 0
}
	
public plugin_precache()
{
	g_Smoke = precache_model("sprites/steam1.spr")
	g_Lightning = precache_model("sprites/lgtning.spr")	// Lightning effect from Tazer
	precache_sound(g_HeartSound)
	precache_sound(g_TazerSound)
	precache_sound(g_FlashSound)
	precache_sound(g_HealSound)
	precache_sound(g_FlashlightSound)
	
	precache_sound(g_HitSound)
	g_ModelId = precache_model(g_Model)
	
	set_task(4.0,"AlcoholCheck",_,_,_,"b")
	
	register_menucmd(register_menuid(g_AttachMenu),g_Keys,"AttachMenuHandle")
	register_menucmd(register_menuid(g_LockMenu),g_Keys,"LockMenuHandle")
}

public ARP_RegisterItems()
{
	switch(g_Mod)
	{
		case TS :
		{
			new TSWeaponNames[TS_MAX_WEAPONS][2][] =
			{
				{"",""},
				{"GLOCK-18","Handgun; Non-Restricted; 9mm Parabellum"},
				{"",""},
				{"Mini-Uzi","Sub-machine Gun; Non-Restricted; 9mm Parabellum"},
				{"Benelli M3","Shotgun; Restricted; 12 gauge 2 3/4^""},
				{"Colt M4A1","Rifle; Restricted; 5.56mm (NATO)"},
				{"H&K MP5SDA5","Sub-machine Gun; Restricted; 9mm Parabellum"},
				{"H&K MP5K","Sub-machine Gun; Non-Restricted; 9mm Parabellum"},
				{"Akimbo Beretta 92Fs","Handgun(s); Non-Restricted; 9mm Parabellum"},
				{"H&K SOCOM MK23","Handgun; Non-Restricted; .45 ACP"},
				{"",""},
				{"Daewoo USAS-12","Shotgun; Restricted; 12 gauge 2 3/4^""},
				{"IMI Desert Eagle","Handgun; Non-Restricted; .50 AE"},
				{"Kalashnikova AK-47","Rifle; Prohibited; 7.62mm"},
				{"FN Five-seveN Tactical","Handgun; Non-Restricted; 5.7mm"},
				{"Steyr AUG","Rifle; Restricted; 5.56mm (NATO)"},
				{"",""},
				{"vz. 61 ^"Skorpion^"","Sub-machine Gun; Non-Restricted; .32 ACP"},
				{"Barrett M82A1","Rifle; Prohibited; .50 BMG"},
				{"H&K MP7","Sub-machine Gun; Non-Restricted; 4.6mm"},
				{"SPAS-12","Shotgun; Restricted; 12 gauge 2 3/4^""},
				{"Golden Colt 1911A1s","Handgun; Non-Restricted; .45 ACP"},
				{"GLOCK-20C","Handgun; Non-Restricted; 10mm Auto"},
				{"H&K UMP","Sub-machine Gun; Non-Restricted; .45 ACP"},
				{"M61 Grenade","Special; Prohibited"},
				{"Combat Knife","Special; Non-Restriced"},
				{"Mossberg 500","Shotgun; Non-Restriced; 12 gauge 2 3/4^""},
				{"Colt M16A4","Rifle; Restricted; 5.56mm (NATO)"},
				{"Ruger MK1","Handgun; Non-Restricted; .22 LR"},
				{"",""},
				{"",""},
				{"Taurus Raging Bull","Handgun; Restricted; .454 Casull"},
				{"U.S. Ordnance M60E3","Machine-gun; Prohibited; 7.62mm (NATO)"},
				{"Sawed-Off Shotgun","Shotgun; Prohibited; 12 gauge 2 3/4^""},
				{"Katana","Special; Non-Restricted"},
				{"Seal Knife","Special; Non-Restricted"},
				{"G2 Contender","Handgun; Prohibited; 7.62mm NATO"},
				{"",""},
				{"",""}
			}
			
			for(new Count;Count < TS_MAX_WEAPONS;Count++)
				if(TSWeaponNames[Count][0][0])
					g_GunStats[Count][ITEMID] = ARP_RegisterItem(TSWeaponNames[Count][0],"_WeaponHandle",TSWeaponNames[Count][1],1)
			
			g_9Parabellum = ARP_RegisterItem("9mm Parabellum Ammo","_Ammo","9mm Parabellum ammo for weapons",1)
			g_12Gauge = ARP_RegisterItem("12 Gauge Shells Ammo","_Ammo","12 Gauge shells for weapons",1)
			g_556NATO = ARP_RegisterItem("5.56mm NATO Ammo","_Ammo","5.56mm NATO ammo for weapons",1)
			g_45ACP = ARP_RegisterItem(".45 ACP Ammo","_Ammo",".45 ACP ammo for weapons",1)
			g_50AE = ARP_RegisterItem(".50 AE Ammo","_Ammo",".50 AE ammo for weapons",1)
			g_762Soviet = ARP_RegisterItem("7.62mm Soviet Ammo","_Ammo","7.62mm Soviet ammo for weapons",1)
			g_57FN = ARP_RegisterItem("5.7mm FN Ammo","_Ammo","5.7mm FN ammo for weapons",1)
			g_50BMG = ARP_RegisterItem(".50 BMG Ammo","_Ammo",".50 BMG ammo for weapons",1)
			g_10Auto = ARP_RegisterItem("10mm Auto Ammo","_Ammo","10mm Auto ammo for weapons",1)
			g_22Hornet = ARP_RegisterItem(".22 Hornet Ammo","_Ammo",".22 Hornet ammo for weapons",1)
			g_454Casull = ARP_RegisterItem(".454 Casull Ammo","_Ammo",".454 Casull ammo for weapons",1)
			g_32ACP = ARP_RegisterItem(".32 ACP Ammo","_Ammo",".32 ACP ammo for weapons",1)
			g_762NATO = ARP_RegisterItem("7.62mm NATO Ammo","_Ammo","7.62mm NATO ammo for weapons",1)
		}
		case SC :
		{
			new SCWeaponNames[SC_MAX_WEAPONS][2][] =
			{
				{"",""},
				{"Crowbar","Melee; Non-Restricted"},
				{"9mm Handgun","Handgun; Non-Restricted; 9mm"},
				{".357 Handgun","Handgun; Non-Restricted; .357"},
				{"9mm Assault Rifle","Sub-machine Gun; Non-Restricted; 9mm/AR Grenades"},
				{"",""},
				{"Crossbow","Special; Restricted; Bolts"},
				{"Shotgun","Shotgun; Non-Restricted; Shells"},
				{"Rocket-Propelled Grenade Launcher","Explosive; Prohibited; Rockets"},
				{"Gauss Gun","Energy; Prohibited; Cells"},
				{"EGON Gun","Energy; Prohibited; Cells"},
				{"Hornet Gun","Alien; Restricted"},
				{"Hand Grenade","Explosive; Restricted"},
				{"Trip Mine","Explosive; Restricted"},
				{"Satchel","Explosive; Restricted"},
				{"Snark","Alien; Restricted"},
				{"Akimbo Uzis","Sub-machine Gun; Non-Restricted; 9mm"},
				{"Uzi","Sub-machine Gun; Non-Restricted; 9mm"},
				{"Medkit","Special; Non-Restricted"},
				{"",""},
				{"Pipe Wrench","Melee; Non-Restricted"},
				{"Minigun","Machine-gun; Prohibited; Chaingun Ammo"},
				{"Grapple Gun","Alien; Non-Restricted"},
				{"Sniper Rifle","Rifle; Restricted; 7.62"},
				{"",""},
				{"",""},
				{"",""},
				{"",""},
				{"",""},
				{"",""},
				{"",""}
			}
			
			for(new Count;Count < SC_MAX_WEAPONS;Count++)
				if(SCWeaponNames[Count][0][0])
					g_GunStats[Count][ITEMID] = ARP_RegisterItem(SCWeaponNames[Count][0],"_WeaponHandle",SCWeaponNames[Count][1],1)
				
#if 0
			g_357
			g_Buckshot
			g_762
			g_Bolts
			g_Cells
			g_RPG
			g_ARGrenades
			g_9mm
			g_Minigun
#endif
		}
	}
	
	g_Restricted = ARP_RegisterItem("Restricted License","_License","Allows possession and acquisition of restricted firearms.",0)
	ARP_RegisterItem("Permitted License","_License","Allows possession and acquisition of permitted firearms.",0)
	
	g_Cigar = ARP_RegisterItem("Cuban Cigar","_Smoke","A heavy tobacco product from Cuba.",1)
	g_Cigarette = ARP_RegisterItem("Cigarette","_Smoke","A small tobaco product.",1)
	g_Pipe = ARP_RegisterItem("Tobacco Pipe","_Smoke","A pipe that can have tobacco placed in it and lit.",1)
	
	ARP_RegisterItem("Lighter","_Lighter","A small plastic lighter.")
	ARP_RegisterItem("Zippo Lighter","_Lighter","A large metal lighter with a wide flame.")
	
	g_FlashlightId = ARP_RegisterItem("Flashlight","_Flashlight","A small flashlight to illuminate dark areas.")
	
	g_Spray = ARP_RegisterItem("Spray Can","_Spray","A metallic canister containing paint.")
	
	ARP_RegisterItem("Flashbang","_Flashbang","A metallic canister that blinds those who see it explode.",1)
	
	ARP_RegisterItem("Lockpick","_Lockpick","Used to open locks.")
	ARP_RegisterItem("Electric Lockpick","_ELockpick","Used to open locks.")
	
	g_Tazer = ARP_RegisterItem("Tazer","_Tazer","Can be used to stun enemies.")
	
	ARP_RegisterItem("First Aid Kit","_Heal","Used to heal wounds.")
	
	g_Beer = ARP_RegisterItem("Beer","_Alcohol","An alcoholic beverage - 5 blood alcohol.",1)
	g_Gin = ARP_RegisterItem("Gin","_Alcohol","An alcoholic beverage - 10 blood alcohol.",1)
	g_Whiskey = ARP_RegisterItem("Whiskey","_Alcohol","An alcoholic beverage - 20 blood alcohol.",1)
	g_Vodka = ARP_RegisterItem("Vodka","_Alcohol","An alcoholic beverage - 40 blood alcohol.",1)
	g_HawkMiller = ARP_RegisterItem("Hawk Miller Light","_Alcohol","An alcoholic beverage - 80 blood alcohol.",1)
	
	ARP_RegisterItem("Crack","_Crack","The drug crack",1)
	ARP_RegisterItem("Heroin","_Heroin","The drug heroin",1)
	ARP_RegisterItem("PCP","_PCP","The drug PCP",1)
	ARP_RegisterItem("Mushroom","_Mushroom","The drug mushroom (^"shrooms^")",1)
	ARP_RegisterItem("Cocaine","_Cocaine","The drug cocaine",1)
	ARP_RegisterItem("Acid","_Acid","The drug acid",1)
	
	ARP_RegisterItem("Steel Axe","_DoorBreaker","Used to smash doors",0)
	g_DoorC2 = ARP_RegisterItem("Door C2","_DoorBreaker","Used to blow doors open",1)
	
	ARP_RegisterItem("ATM Card","_Atm","A card used to operate an ATM machine.")
	ARP_RegisterItem("Debit Card","_Debit","A card used to allow you to withdraw money anywhere.")
	
	ARP_RegisterItem("Chlorofoam","_Chlorofoam","Puts a person to sleep in an instant.",1)
#if 0 // Hawk552
	ARP_RegisterItem("Tape","_Tape","Keeps a person from talking",1)
	ARP_RegisterItem("Rope","_Rope","Lets the user drag a person on a rope",0)
#endif
	
	ARP_RegisterItem("Assassin Knife","_AssassinKnife","Makes next attack an instant kill with fu if it's a backstab",0)
}

public EventDeathMsg()
{
	new id = read_data(2)
	
	g_Tazered[id] = 0
	g_MaxSpeed[id] = 0.0
	g_LastTazer[id] = 0.0
	
	g_Alcohol[id] = 0
	client_cmd(id,"-forward;-back;-moveleft;-moveright")
	
	g_Flashlight[id] = 0
}

public CmdSay(id,Mode,Args[])
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	
	if(g_Taped[id])
	{
		client_print(id,print_chat,"[ARP] Your mouth is taped, you can't talk!^n")
		return PLUGIN_HANDLED
	}
	
	new Index, Body
	get_user_aiming(id,Index,Body,50)

	if(equali(Args,"/removetape",11))
	{
		client_print(id,print_chat,"[ARP] You removed the tape on the person's mouth.^n")
		g_Taped[Index] = 0
		
		return PLUGIN_HANDLED
	}
#if 0 // Hawk552
	else if(equali(Args,"/rope",5))
	{
		g_Roped[Index] = 0
		client_print(id,print_chat,"[ARP] You removed the rope on the player!^n")
		client_print(Index,print_chat,"[ARP] The rope was removed on you!^n")
		
		return PLUGIN_HANDLED
	}
#endif
	else if(equali(Args,"/tazer",6))
	{
		ARP_GetUserItemNum(id,g_Tazer) ? _Tazer(id,g_Tazer) : client_print(id,print_chat,"[ARP] You don't have any tazers.")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public _Atm(id,ItemId)
	client_print(id,print_chat,"[ARP] This item cannot be used; walk up to an ATM to use it.")

public _Debit(id,ItemId)
	client_print(id,print_chat,"[ARP] Say /withdraw to use this item.")
	
public AlcoholCheck()
{
	new Players[32],Playersnum,Player,Command[12]
	get_players(Players,Playersnum,"ac")
	
	for(new Count;Count < Playersnum;Count++)
	{
		Player = Players[Count]
		
		if(g_Alcohol[Player] > 0)
			g_Alcohol[Player] -= ALCOHOL_MULTIPLE
		
		if(g_Alcohol[Player] / ALCOHOL_MULTIPLE > 100)
		{
			client_cmd(Player,"-forward;-back;-moveleft;-moveright")
			
			message_begin(MSG_ONE_UNRELIABLE,g_MsgScreenFade,{0,0,0},Player)
			write_short(102400)
			write_short(22756)
			write_short(0)
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(255)
			message_end()
			
			emit_sound(Player,CHAN_AUTO,g_HeartSound,1.0,ATTN_NORM,0,PITCH_NORM)
		}
		else if(g_Alcohol[Player] / ALCOHOL_MULTIPLE > 70)
		{
			set_rendering(Player,kRenderFxGlowShell,255,255,0,kRenderNormal,16)
			
			switch(random_num(0,3))
			{
				case 0 :
					Command = "+forward"
				case 1 :
					Command = "+moveleft"
				case 2 :
					Command = "+moveright"
				case 3 :
					Command = "+back"
			}
			
			client_cmd(Player,"-forward;-moveleft;-moveright;-back;%s",Command)
		}
		else if(g_Alcohol[Player] / ALCOHOL_MULTIPLE == 69)
		{
			client_cmd(Player,"-forward;-moveleft;-moveright;-back")
			
			set_rendering(Player,kRenderFxNone,255,255,255,kRenderNormal,16)
		}
	}
}

public _Alcohol(id,ItemId)
{
	new Alcohol
	// argh, stupid "must be constant expression" if you use switch
	if(ItemId == g_Beer)
		Alcohol = 5 * ALCOHOL_MULTIPLE
	else if(ItemId == g_Gin)
		Alcohol = 10 * ALCOHOL_MULTIPLE
	else if(ItemId == g_Whiskey)
		Alcohol = 20 * ALCOHOL_MULTIPLE
	else if(ItemId == g_Vodka)
		Alcohol = 40 * ALCOHOL_MULTIPLE
	else if(ItemId == g_HawkMiller)
		Alcohol = 80 * ALCOHOL_MULTIPLE
	
	g_Alcohol[id] += Alcohol
	
	new ItemName[33]
	ARP_GetItemName(ItemId,ItemName,32)
	
	client_print(id,print_chat,"[ARP] You have drank the %s.",ItemName)
}

public EventHudRender(Name[],Data[],Len)
{
	new id = Data[0]
	if(!is_user_alive(id) || !g_Alcohol[id] || Data[1] != HUD_PRIM)
		return
	
	static Message[64]
	format(Message,63,"Blood Alcohol Level: %d",g_Alcohol[id] / ALCOHOL_MULTIPLE)
	
	ARP_AddHudItem(id,HUD_PRIM,0,Message)
}

public _Heal(id,ItemId)
{
	new Index,Body
	get_user_aiming(id,Index,Body,200)
	
	if(!Index || !is_user_alive(Index))
		Index = id
	
	new Float:Health = entity_get_float(Index,EV_FL_health)
	
	if(Health > 99.0)
		return client_print(id,print_chat,"[ARP] %s health is already full.",Index == id ? "Your" : "That user's")
	
	if(Health < 50.0)
		return client_print(id,print_chat,"[ARP] %s too badly wounded, get%s to a doctor.",Index == id ? "You are" : "That user is",Index == id ? "" : " them")
	
	entity_set_float(Index,EV_FL_health,float(min(floatround(Health + 15.0),100)))
	
	emit_sound(id,CHAN_AUTO,g_HealSound,1.0,ATTN_NORM,0,PITCH_NORM)
	
	new Name[33]
	get_user_name(id,Name,32)
	
	if(Index != id)
		client_print(Index,print_chat,"[ARP] You have been healed by %s.",Name)
	
	get_user_name(Index,Name,32)
	client_print(id,print_chat,"[ARP] You have healed %s.",Index == id ? "yourself" : Name)
	
	ARP_SetUserItemNum(id,ItemId,ARP_GetUserItemNum(id,ItemId) - 1)
	
	return PLUGIN_CONTINUE
}

public _Tazer(id,ItemId)
{
	if(!is_user_alive(id))
		return
	
	new Index,Body
	get_user_aiming(id,Index,Body,200)
	
	// this was used for testing since I have no friends
	//Index = id
	
	if(!Index || !is_user_alive(Index))
	{
		client_print(id,print_chat,"[ARP] You are not looking at another player.")
		return
	}
	
	new Float:Time = get_gametime()
	if(Time - g_LastTazer[id] < 60.0 && g_LastTazer[id])
	{
		client_print(id,print_chat,"[ARP] Your tazer is currently recharging.")
		return
	}
	
	if(g_Tazered[id])
	{
		client_print(id,print_chat,"[ARP] You cannot tazer someone else while you are tazered.")
		return
	}
	
	if(g_Tazered[Index])
	{
		client_print(id,print_chat,"[ARP] That user is already tazered.")
		return
	}
	
	if(ARP_IsCop(Index))
	{
		client_print(id,print_chat,"[ARP] You cannot tazer other cops.")
		return
	}
	
	if(random_num(0,100) == 50)
	{
		client_print(id,print_chat,"[ARP] Your tazer has short-circuited.")
		ARP_SetUserItemNum(id,ItemId,ARP_GetUserItemNum(id,ItemId) - 1)
		return
	}
	
	g_LastTazer[id] = Time
	g_Tazered[Index] = 1
	
	new pOrigin[3],tOrigin[3]
	get_user_origin(id,pOrigin)
	get_user_origin(Index,tOrigin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(pOrigin[0])
	write_coord(pOrigin[1])
	write_coord(pOrigin[2])
	write_coord(tOrigin[0])
	write_coord(tOrigin[1])
	write_coord(tOrigin[2])
	write_short(g_Lightning)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(8) // life
	write_byte(20) // width
	write_byte(30) // noise
	write_byte(200) // r, g, b
	write_byte(200) // r, g, b
	write_byte(200) // r, g, b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()

	//message_begin(MSG_PVS,SVC_TEMPENTITY,tOrigin)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPARKS)
	write_coord(tOrigin[0])
	write_coord(tOrigin[1])
	write_coord(tOrigin[2])
	message_end()
	
	g_MaxSpeed[Index] = entity_get_float(Index,EV_FL_maxspeed)
	g_SpeedMode[Index] = 0
	
	set_rendering(Index,kRenderFxGlowShell,0,0,255,kRenderNormal,16)
	
	emit_sound(id,CHAN_AUTO,g_TazerSound,1.0,ATTN_NORM,0,PITCH_NORM)
	
	fakedamage(Index,"Tazer",10.0,DMG_SHOCK /* 256 SHOCK */)
	
	if(get_user_health(Index) <= 0)
		return
		
	for(new Count = 1;Count < 36;Count++)
		client_cmd(Index,"weapon_%d;drop",Count)
	
	set_task(1.0,"ScreenFade",Index)
	set_task(2.0,"HeartBeat",Index)
	set_task(5.0,"Clear",Index)
	
	return
}

public ScreenFade(id)
{
	new Time = floatround((1<<10) * 10.0 * (3)) 
	
	message_begin(MSG_ONE_UNRELIABLE,g_MsgScreenFade,{0,0,0},id)
	write_short(Time)
	write_short(Time) 
	write_short(0x0000) 
	write_byte(0) 
	write_byte(0)  
	write_byte(0)   
	write_byte(255)
	message_end()
}

public HeartBeat(id)
	client_cmd(id,"spk %s",g_HeartSound)

public Clear(id)
{
	new Float:Punch[3]
	
	for(new Count;Count < 3;Count++)
		Punch[Count] = random_float(-50.0,50.0)
	
	entity_set_vector(id,EV_VEC_punchangle,Punch)
	
	entity_set_float(id,EV_FL_maxspeed,g_MaxSpeed[id])
	g_MaxSpeed[id] = 0.0
	set_rendering(id,kRenderFxNone,255,255,255,kRenderNormal,16)
	g_Tazered[id] = 0
}

public _ELockpick(id,ItemId)
{
	new Index,Body
	get_user_aiming(id,Index,Body,100)
	
	if(!Index)
	{
		client_print(id,print_chat,"[ARP] You are not looking at a door.")
		return PLUGIN_CONTINUE
	}
	
	new Classname[33]
	entity_get_string(Index,EV_SZ_classname,Classname,32)
	
	if(equali(Classname,"func_door") || equali(Classname,"func_door_toggle"))
	{
		client_print(id,print_chat,"[ARP] You must be looking at a rotating door.")
		return PLUGIN_CONTINUE
	}
	else if(!equali(Classname,"func_door_rotating"))
	{
		client_print(id,print_chat,"[ARP] You are not looking at a door.")
		return PLUGIN_CONTINUE
	}
	
	client_print(id,print_chat,"[ARP] The electric lockpick opens the door.")
			
	force_use(id,Index)
	fake_touch(Index,id)
	
	return PLUGIN_CONTINUE
}

public _Lockpick(id,ItemId)
{
	g_Pick[id] = 0
	
	LockpickHandle(id,ItemId)
}

LockpickHandle(id,ItemId)
{
	new Index,Body
	get_user_aiming(id,Index,Body,100)
	
	if(!Index)
	{
		client_print(id,print_chat,"[ARP] You are not looking at a door.")
		return PLUGIN_CONTINUE
	}
	
	new Classname[33]
	entity_get_string(Index,EV_SZ_classname,Classname,32)
	
	if(equali(Classname,"func_door") || equali(Classname,"func_door_toggle"))
	{
		client_print(id,print_chat,"[ARP] You must be looking at a rotating door.")
		return PLUGIN_CONTINUE
	}
	else if(!equali(Classname,"func_door_rotating"))
	{
		client_print(id,print_chat,"[ARP] You are not looking at a door.")
		return PLUGIN_CONTINUE
	}
	
	new Menu[512]
	format(Menu,511,"ARP Lock Pick^n^n%s%s%s%s^n^n1. Up^n2. Down^n3. Left^n4. Right^n^n0. %s",g_Pick[id] & (1<<0) ? "-" : "|",g_Pick[id] & (1<<1) ? "-" : "|",g_Pick[id] & (1<<2) ? "-" : "|",g_Pick[id] & (1<<3) ? "-" : "|",g_Pick[id] & (1<<3) ? "Open Door" : "Exit")
	
	show_menu(id,g_Keys,Menu,-1,g_LockMenu)
	
	// used as cache - name is decieving
	g_Attachments[id] = ItemId
	g_Gun[id] = Index
	
	// although it's not, we're mucking around with menus
	return PLUGIN_CONTINUE
}

public LockMenuHandle(id,Key)
{
	if(!is_user_alive(id) || !ARP_NpcDistance(id,g_Gun[id]))
		return PLUGIN_CONTINUE
	
	if(Key > 3 && Key != 9)
		return LockpickHandle(id,g_Attachments[id])
	
	if(Key == 9)
	{
		if(g_Pick[id] & (1<<3))
		{
			client_print(id,print_chat,"[ARP] You have opened the door.")
			
			force_use(id,g_Gun[id])
			fake_touch(g_Gun[id],id)
			
			return PLUGIN_CONTINUE
		}
		else
			return PLUGIN_CONTINUE
	}
	
	if(Key == random_num(0,3))
	{
		for(new Count;Count < 4;Count++)
			if(!(g_Pick[id] & (1<<Count)))
			{
				g_Pick[id] += (1<<Count)
				break
			}
		
		client_print(id,print_chat,"[ARP] You get one prong on the lock.")
	}
	else if(random_num(1,6) == 1)
	{
		g_Pick[id] = 0
		client_print(id,print_chat,"[ARP] The lock reset with a false move.")
	}
	
	if(random_num(1,30) == 25)
	{
		ARP_SetUserItemNum(id,g_Attachments[id],ARP_GetUserItemNum(id,g_Attachments[id]) - 1)
		return client_print(id,print_chat,"[ARP] Your lock pick snapped.")
	}
	
	return LockpickHandle(id,g_Attachments[id])
}

public _Flashbang(id,ItemId)
{
	new Players[32],Playersnum,Player,Float:tOrigin[3],Float:pOrigin[3]
	get_players(Players,Playersnum,"ac")
	
	entity_get_vector(id,EV_VEC_origin,pOrigin)
	
	for(new Count;Count < Playersnum;Count++)
	{
		Player = Players[Count]
		entity_get_vector(Player,EV_VEC_origin,tOrigin)
		
		if(trace_line(id,tOrigin,pOrigin,tOrigin) != Player || get_distance_f(tOrigin,pOrigin) > 600.0)
			continue
		
		message_begin(MSG_ONE_UNRELIABLE,g_MsgScreenFade,{0,0,0},Player)
		write_short(102400)
		write_short(22756)
		write_short(0)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
		
		// tOrigin used as temp
		for(new Count2;Count2 < 3;Count2++)
			tOrigin[Count2] = random_float(-5000.0,5000.0)
			
		entity_set_vector(Player,EV_VEC_punchangle,tOrigin)
	}
	
	emit_sound(id,CHAN_AUTO,g_FlashSound,1.0,ATTN_NORM,0,PITCH_HIGH)
}

public _Spray(id,ItemId)
	client_cmd(id,"impulse 201")

public SprayAttempt(id)
{
	new Num = ARP_GetUserItemNum(id,g_Spray)
	
	if(!Num)
	{
		client_print(id,print_chat,"[ARP] You need a spray can to use your spray.")
		return PLUGIN_HANDLED
	}
	
	ARP_SetUserItemNum(id,g_Spray,Num - 1)
	
	return PLUGIN_CONTINUE
}

public FlashlightAttempt(id)
{
	if(!ARP_GetUserItemNum(id,g_FlashlightId))
	{
		client_print(id,print_chat,"[ARP] You do not have a flashlight.")
		return PLUGIN_HANDLED
	}
	
	_Flashlight(id,0)
	
	return PLUGIN_HANDLED
}

public _Lighter(id,ItemId)
{
	if(!g_Smoking[id][TIME])
	{
		client_print(id,print_chat,"[ARP] You do not have any tobacco products in your mouth.")
		return
	}
	
	new Float:Health = entity_get_float(id,EV_FL_health)
	if(Health <= 10.0)
	{
		client_print(id,print_chat,"[ARP] You are not healthy enough to smoke this.")
		return
	}
	
	entity_set_float(id,EV_FL_health,Health - 10.0)
	
	new ItemName[33]
	ARP_GetItemName(g_Smoking[id][ITEM],ItemName,32)
	
	client_print(id,print_chat,"[ARP] You begin smoking the %s.",ItemName)
	
	set_task(1.0,"SmokeItem",id)
}

public SmokeItem(id)
	if(!g_Smoking[id][TIME])
	{		
		new ItemName[33]
		ARP_GetItemName(g_Smoking[id][ITEM],ItemName,32)
		
		client_print(id,print_chat,"[ARP] You finish the %s and toss it on the ground.",ItemName)
	}
	else
	{
		g_Smoking[id][TIME]--
		
		new Origin[3]
		get_user_origin(id,Origin)
		
		// Thanks to harbu for this part
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(TE_SMOKE) // 5
		write_coord(Origin[0] + random_num(-5,5)) 
		write_coord(Origin[1] + random_num(-5,5)) 
		write_coord(Origin[2] + 30)
		write_short(g_Smoke)
		write_byte(10)  // 10
		write_byte(15)  // 10
		message_end()
		
		set_task(1.0,"SmokeItem",id)
	}

public _Smoke(id,ItemId)
{
	new Time
	
	if(ItemId == g_Cigarette)
		Time = 30
	else if(ItemId == g_Cigar)
		Time = 60
	else if(ItemId == g_Pipe)
		Time = 90
	
	g_Smoking[id][TIME] = Time
	g_Smoking[id][ITEM] = ItemId
	
	new ItemName[33]
	ARP_GetItemName(ItemId,ItemName,32)
	
	client_print(id,print_chat,"[ARP] You put a %s in your mouth.",ItemName)
}

public _Flashlight(id,ItemId)
{
	g_Flashlight[id] = !g_Flashlight[id]
	
	client_print(id,print_chat,"[ARP] You have turned your flashlight %s.",g_Flashlight[id] ? "on" : "off")
	
	emit_sound(id,CHAN_AUTO,g_FlashlightSound,1.0,ATTN_NORM,0,PITCH_NORM)
}

public Flashlight()
{
	static Players[32],Playersnum,Player
	get_players(Players,Playersnum,"a")
	
	for(new Count;Count < Playersnum;Count++)
	{
		Player = Players[Count]
		if(!g_Flashlight[Player] || !ARP_GetUserItemNum(Player,g_FlashlightId))
			continue
	
		static Origin[3]
		get_user_origin(Player,Origin,3)
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_DLIGHT)
		write_coord(Origin[0])
		write_coord(Origin[1])
		write_coord(Origin[2])
		write_byte(10)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(2)
		write_byte(1)
		message_end()
	}
	
	return set_task(0.1,"Flashlight")
}

public _AssassinKnife(id,ItemId)
{
	g_AssassinKnife[id] = !g_AssassinKnife[id]
	
	client_print(id,print_chat,"[ARP] You have %sequipped your assassin knife.",g_AssassinKnife[id] ? "" : "un")
}

public _Ham_TakeDamage(id,Inflictor,Attacker,Float:Damage,DamageBits)
{
	if(!is_user_alive(id) || !is_user_alive(Attacker) || !g_AssassinKnife[Attacker])
		return HAM_IGNORED
	
	new Float:Origin[3],tName[33],aName[33]
	pev(Attacker,pev_origin,Origin)
	
	new Float:vOrigin[3]
	pev(id,pev_origin,vOrigin)
	
	if(vector_distance(vOrigin,Origin) > 100.0)
		return HAM_IGNORED
	
	get_user_name(id,tName,32)
	get_user_name(Attacker,aName,32)
	
	g_AssassinKnife[Attacker] = 0
	
	if(is_in_viewcone(id,Origin))
	{
		client_print(id,print_chat,"[ARP] %s missed an assassination against you.",aName)
		client_print(Attacker,print_chat,"[ARP] You missed an assassination against %s.",tName)
	}
	else
	{
		client_print(id,print_chat,"[ARP] %s has assassinated you.",aName)
		client_print(Attacker,print_chat,"[ARP] You have assassinated %s.",tName)
		
		SetHamParamFloat(4,float(get_user_health(id) + 1))
		
		drop_to_floor(id)
		vOrigin[2] -= 1.0
		set_pev(id,pev_origin,vOrigin)
	}
	
	return HAM_IGNORED
}
	
public client_PreThink(id)
	if(g_MaxSpeed[id])
		entity_set_float(id,EV_FL_maxspeed,g_SpeedMode[id] ? g_MaxSpeed[id] * 2 : g_MaxSpeed[id] / 2)	

public _WeaponHandle(id,ItemId)
{	
	g_Attachments[id] = 0
	g_Gun[id] = ItemId
	
	_Weapon(id,ItemId)
}

public _Weapon(id,ItemId)
{		
	new Menu[512],Pos,Cell = -1,Num,ItemName[33]
	ARP_GetItemName(ItemId,ItemName,32)
	Pos += format(Menu,511,"ARP %s Attachments^n^n",ItemName)
	
	for(new Count;Count < TS_MAX_WEAPONS;Count++)
		if(g_GunStats[Count][ITEMID] == ItemId && g_GunStats[Count][ITEMID])
		{			
			Cell = Count
			g_Cell[id] = Count
			break
		}
	
	if(Cell == -1)
		return
	
	if(!g_GunStats[Cell][ATTACHMENTS])
	{
		GiveWeapon(id)
		return
	}
	
	if(g_GunStats[Cell][ATTACHMENTS] & TSA_FLASHLIGHT)
		Pos += format(Menu[Pos],511 - Pos,"%d. Flashlight %s^n",++Num,g_Attachments[id] & TSA_FLASHLIGHT ? "*" : "")
	if(g_GunStats[Cell][ATTACHMENTS] & TSA_LASERSIGHT)
		Pos += format(Menu[Pos],511 - Pos,"%d. Lasersight %s^n",++Num,g_Attachments[id] & TSA_LASERSIGHT ? "*" : "")
	if(g_GunStats[Cell][ATTACHMENTS] & TSA_SCOPE)
		Pos += format(Menu[Pos],511 - Pos,"%d. Scope %s^n",++Num,g_Attachments[id] & TSA_SCOPE ? "*" : "")
	if(g_GunStats[Cell][ATTACHMENTS] & TSA_SILENCER)
		Pos += format(Menu[Pos],511 - Pos,"%d. Suppressor %s^n",++Num,g_Attachments[id] & TSA_SILENCER ? "*" : "")
		
	format(Menu[Pos],511-Pos,"^n0. Done")
	
	new Keys = (1<<9)
	for(new Count;Count < Num;Count++)	
		Keys |= (1<<Count)
	
	show_menu(id,Keys,Menu,-1,g_AttachMenu)
}

public AttachMenuHandle(id,Key)
{
	new Attachments[4],Num,Temp
	Temp = g_GunStats[g_Cell[id]][ATTACHMENTS]
	for(new Count;Count < 4;Count++)
		if(Temp & TSA_FLASHLIGHT)
		{
			Attachments[Num++] = TSA_FLASHLIGHT
			// &= ~x seems to be broken
			Temp -= TSA_FLASHLIGHT
		}
		else if(Temp & TSA_LASERSIGHT)
		{
			Attachments[Num++] = TSA_LASERSIGHT
			Temp -= TSA_LASERSIGHT
		}
		else if(Temp & TSA_SCOPE)
		{
			Attachments[Num++] = TSA_SCOPE
			Temp -= TSA_SCOPE
		}
		else if(Temp & TSA_SILENCER)
		{
			Attachments[Num++] = TSA_SILENCER
			Temp -= TSA_SILENCER
		}
	
	if(Key != 9 && !Attachments[Key])
	{
		_Weapon(id,g_Gun[id])
		return
	}
	
	if(Key == 9)
	{
		GiveWeapon(id)
		return
	}
	
	if(!(g_Attachments[id] & Attachments[Key]))
		g_Attachments[id] += Attachments[Key]
	else
		g_Attachments[id] -= Attachments[Key]
		
	_Weapon(id,g_Gun[id])
}	

GiveWeapon(id)
	ts_giveweapon(id,g_Cell[id],250,g_Attachments[id])

public _License(id,ItemId)
	client_print(id,print_chat,"[ARP] This is a %s firearms license.",ItemId == g_Restricted ? "restricted" : "non-restricted")

public _Ammo(id,ItemId)
{
	new Mode
	
	if(ItemId == g_9Parabellum)
		Mode = 1
	else if(ItemId == g_12Gauge)
		Mode = 2
	else if(ItemId == g_556NATO)
		Mode = 3 
	else if(ItemId == g_45ACP)
		Mode = 4
	else if(ItemId == g_50AE)
		Mode = 5
	else if(ItemId == g_762Soviet)
		Mode = 6
	else if(ItemId == g_57FN)
		Mode = 7
	else if(ItemId == g_50BMG)
		Mode = 8
	else if(ItemId == g_10Auto)
		Mode = 9
	else if(ItemId == g_22Hornet)
		Mode = 10
	else if(ItemId == g_454Casull)
		Mode = 11
	else if(ItemId == g_32ACP)
		Mode = 12
	else if(ItemId == g_762NATO)
		Mode = 13
	else
		return PLUGIN_HANDLED
		
	new Dummy,Wpn = ts_getuserwpn(id,Dummy,Dummy,Dummy,Dummy)
	if(Mode == g_AmmoTypes[Wpn] && ts_setuserammo(id,Wpn,g_WeaponAmmo[Wpn]))
		return ARP_ClientPrint(id,"You loaded up on ammo.")

	ARP_SetUserItemNum(id,ItemId,ARP_GetUserItemNum(id,ItemId) + 1)
	return ARP_ClientPrint(id,"You are not wielding any weapon with this ammo type.")
}	
 
public _Crack(id,ItemId)
{
	pev(id,pev_maxspeed,g_MaxSpeed[id])
	
	new Float:Health
	g_Color[id] = {0,0,255}
	pev(id,pev_health,Health)
	set_pev(id,pev_health,Health / 2)
	
	ScreenPulse(id)
	
	for(new Float:Count = 2.0;Count <= 10.0;Count += 2.0)
		set_task(Count,"ScreenPulse",id)
	
	set_task(12.0,"ClearEffects",id)
	
	g_SpeedMode[id] = 0
	
	return PLUGIN_CONTINUE
}

public _Heroin(id,ItemId)
{	
	set_pev(id,pev_health,75.0)
	
	g_Color[id] = {255,0,255}
	
	ScreenPulse(id)
	
	for(new Float:Count = 2.0;Count <= 10.0;Count += 2.0)
		set_task(Count,"ScreenPulse",id)
		
	g_SpeedMode[id] = 1
	
	pev(id,pev_maxspeed,g_MaxSpeed[id])
	
	set_task(12.0,"ClearEffects",id)
	
	return PLUGIN_CONTINUE
}

public _PCP(id,ItemId)
{
	new Float:Health
	pev(id,pev_health,Health)
	set_pev(id,pev_health,float(clamp(floatround(Health + 100.0),0,200)))
	
	g_Color[id] = {0,255,0}
	
	set_user_godmode(id,1)
	
	ScreenPulse(id)
	
	for(new Float:Count = 2.0;Count <= 10.0;Count += 2.0)
		set_task(Count,"ScreenPulse",id)
		
	pev(id,pev_maxspeed,g_MaxSpeed[id])
		
	g_SpeedMode[id] = 1
	
	set_rendering(id,kRenderFxGlowShell,255,0,255,kRenderNormal,16)
	
	set_task(12.0,"ClearEffects",id)
	
	return PLUGIN_CONTINUE
}

public _Mushroom(id,ItemId)
{
	g_SpeedMode[id] = 1
	
	pev(id,pev_maxspeed,g_MaxSpeed[id])
	
	set_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,16)
	
	new Float:Health
	pev(id,pev_health,Health)
	set_pev(id,pev_health,float(clamp(floatround(Health + 50.0),0,200)))
	
	for(new Float:Count = 0.5;Count <= 25.0;Count += 0.5)
		set_task(Count,"Hallucinate",id)
	
	set_task(26.0,"ClearEffects",id)
	
	return PLUGIN_CONTINUE
}	

public _Cocaine(id,ItemId)
{
	g_SpeedMode[id] = 0
	
	pev(id,pev_maxspeed,g_MaxSpeed[id])
	
	set_task(7.0,"ClearEffects",id)
	
	new Float:Health
	pev(id,pev_health,Health)
	set_pev(id,pev_health,float(clamp(floatround(Health + 30.0),0,200)))
	
	set_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16)
	
	return PLUGIN_CONTINUE
}

public _Acid(id,ItemId)
{
	g_SpeedMode[id] = 1
	
	pev(id,pev_maxspeed,g_MaxSpeed[id])
	
	new Float:Health
	pev(id,pev_health,Health)
	set_pev(id,pev_health,float(clamp(floatround(Health + 50.0),0,200)))
	
	for(new Float:Count = 0.25;Count <= 180.0;Count += 0.5)
		set_task(Count,"Hallucinate",id + 32)
	
	set_task(181.0,"ClearEffects",id)
	
	return PLUGIN_CONTINUE
}	

public ScreenPulse(id)
{
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(1<<300)
	write_short(1<<300)
	write_short(1<<12)
	write_byte(g_Color[id][0])
	write_byte(g_Color[id][1]) 
	write_byte(g_Color[id][2])
	write_byte(150)
	message_end()
}

public ClearEffects(id)
{
	set_pev(id,pev_maxspeed,g_MaxSpeed[id])
	g_MaxSpeed[id] = 0.0
	
	set_user_godmode(id)
	
	set_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,255)
}

public Hallucinate(id)
{
	new Mode
	if(id > 32)
	{
		id -= 32
		Mode = 1
		
		set_rendering(id,kRenderFxGlowShell,random_num(0,255),random_num(0,255),random_num(0,255),kRenderNormal,16)
	}
	
	new Origin[3],Num
	FindEmptyLoc(id,Origin,Num)
	
	switch(random_num(0,Mode ? 9 : 4))
	{
		case 0 :
		{			
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_GUNSHOT)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		
		case 1 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_EXPLOSION2)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			write_byte(0)
			write_byte(255)
			message_end()
		}
		
		case 2 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_IMPLOSION)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			write_byte(255)
			write_byte(255)
			write_byte(20)
			message_end()
		}
		
		case 3 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_LAVASPLASH)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		
		case 4 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_TELEPORT)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		
		case 5 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_SPARKS)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		
		case 6 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_TAREXPLOSION)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			message_end()
		}
		
		case 7 :
		{
			new Float:Punchangle[3]
			for(new Count;Count < 3;Count++)
				Punchangle[Count] = random_float(-100.0,100.0)
			
			entity_set_vector(id,EV_VEC_punchangle,Punchangle)
		}
		
		case 8 :
		{
			for(new Count;Count < 3;Count++)
				g_Color[id][Count] = random_num(0,255)
			
			ScreenPulse(id)
		}
		
		case 9 :
		{
			message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,Origin,id)
			write_byte(TE_ARMOR_RICOCHET)
			write_coord(Origin[0])
			write_coord(Origin[1])
			write_coord(Origin[2])
			write_byte(2)
			message_end()
		}			
	}			
}

FindEmptyLoc(id,Origin[3],&Num)
{
	if(Num++ > 100)
		return client_print(id,print_chat,"You are in an invalid position to use this drug.")
	
	new Float:pOrigin[3]
	pev(id,pev_origin,pOrigin)
	
	for(new Count;Count < 2;Count++)
		pOrigin[Count] += random_float(-100.0,100.0)
	
	if(PointContents(pOrigin) != CONTENTS_EMPTY && PointContents(pOrigin) != CONTENTS_SKY)
		return FindEmptyLoc(id,Origin,Num)
	
	Origin[0] = floatround(pOrigin[0])
	Origin[1] = floatround(pOrigin[1])
	Origin[2] = floatround(pOrigin[2])
	
	return PLUGIN_HANDLED
}

public _DoorBreaker(id,ItemId)
{
	if(!ARP_IsCop(id))
	{
		client_print(id,print_chat,"[ARP] You are not a cop.")
		return
	}
	
	new Index,Body,Mode = ItemId == g_DoorC2
	get_user_aiming(id,Index,Body,100)
	
	if(!Index)
	{
		ARP_ClientPrint(id,"You are not looking at a door")
		return
	}
	
	new Classname[33]
	entity_get_string(Index,EV_SZ_classname,Classname,32)
	
	if(containi(Classname,"door") == -1 && containi(Classname,"breakable") == -1)
	{
		ARP_ClientPrint(id,"You are not looking at a door")
		return
	}
	
	ARP_ClientPrint(id,Mode ? "You plant the C2 on the door^nIt has a 5 second fuse" : "You hit the door with the axe")
	
	if(Mode)
	{
		new Params[4]
		Params[0] = -9999999999
		set_task(5.0,"DoorEffect",Index,Params,4)
	}
	else
	{			
		new Float:Origin[3]
		//get_brush_entity_origin(Index,Origin)
		entity_get_vector(Index,EV_VEC_origin,Origin)
		entity_set_origin(Index,Float:{4000.0,4000.0,4000.0})
		
		new Params[4]
		for(new Count;Count < 3;Count++)
			Params[Count] = _:Origin[Count]
		
		DoorEffect(Params,Index)
			
		set_task(10.0,"ReturnOrigin",Index,Params,3)	
	}
}

public DoorEffect(Params[4],Index)
{
	emit_sound(Index,CHAN_AUTO,g_HitSound,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	
	if(Params[0] == -9999999999)
	{
		new Float:Origin[3]
		//get_brush_entity_origin(Index,Origin)
		entity_get_vector(Index,EV_VEC_origin,Origin)
		entity_set_origin(Index,Float:{4000.0,4000.0,4000.0})
		
		new Params2[3]
		for(new Count;Count < 3;Count++)
			Params2[Count] = _:Origin[Count]
		
		set_task(5.0,"ReturnOrigin",Index,Params2,3)
		
		Params = Params2
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY,Params2)
		write_byte(TE_EXPLOSION2)
		write_coord(floatround(Float:Params[0]))
		write_coord(floatround(Float:Params[1]))
		write_coord(floatround(Float:Params[2]))
		write_byte(0)
		write_byte(255)
		message_end()
		
		radius_damage(Float:Params2,100,80)
	}
	
	// add the shatter
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BREAKMODEL) // TE_BREAKMODEL
	write_coord(floatround(Float:Params[0])) // x
	write_coord(floatround(Float:Params[1])) // y
	write_coord(floatround(Float:Params[2]) + 10) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50,50)) // velocity x
	write_coord(random_num(-50,50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_ModelId) // model
	write_byte(50) // count
	write_byte(50) // life
	write_byte(0x01) // flags: BREAK_GLASS
	message_end()
}

public ReturnOrigin(Params[3],Ent)
	entity_set_origin(Ent,Float:Params)

public _Chlorofoam(id,ItemId)
{
	new Index, Body
	get_user_aiming(id,Index,Body,50)
	
	if(!Index)
		client_print(id,print_chat,"[ARP] You're not close enough to put a user to sleep!^n")
	else
	{
		SleepUser(Index)
		client_print(id,print_chat,"[ARP] You made the person take a sniff of chlorofoam and put him/her to sleep.^n")
	}
}

SleepUser(Index)
{
	client_print(Index,print_chat,"[ARP] You were put to sleep by a person!^n")
	
	client_cmd(Index,"+duck")
	
	set_user_maxspeed(Index, 0.0)
	
	set_user_rendering(Index, kRenderFxGlowShell, 0, 255, 0, kRenderTransAlpha, 25)
	message_begin(MSG_ONE, get_user_msgid("TSFade"), {0,0,0}, Index)
	write_short(~0)
	write_short(~0)
	write_short(1<<12)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()
	
	client_cmd(Index,"spk %s",g_HeartSound)
	
	set_task(40.0,"FinishSleep",Index)
}

public FinishSleep(Index)
{
	client_print(Index,print_chat,"[ARP] You woke up!^n")
	
	client_cmd(Index,"-duck")
	
	set_user_maxspeed(Index, 320.0)
	
	set_user_rendering(Index, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
	message_begin(MSG_ONE, get_user_msgid("TSFade"), {0,0,0}, Index)
	write_short(~0)
	write_short(~0)
	write_short(1<<12)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()
}

public _Tape(id,ItemId)
{
	new Index, Body
	get_user_aiming(id,Index,Body,50)
	
	client_print(id,print_chat,"[ARP] You taped a person's mouth!^n")
	
	client_print(Index,print_chat,"[ARP] Your mouth is taped; you can't talk now!^n")
	
	g_Taped[Index]++
}

public _Rope(id,ItemId)
{
	new Index, Body
	get_user_aiming(id,Index,Body,50)
	
	if(!Index)
	{
		client_print(id,print_chat,"[ARP] You have to be aiming at someone!^n")
		return
	}
	
	client_print(id,print_chat,"[ARP] You roped a person!^n")
	
	client_print(Index,print_chat,"[ARP] You've been roped!^n")
	
	g_Roped[Index]++
	
	new Params[2]
	Params[0] = id
	Params[1] = Index
	set_task(0.1,"Follow",_,Params,2)
}

public Follow(Params[2])
{
	new id = Params[0], Index = Params[1]
	
	new Float:Origin[3], Float:IndexOrigin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	entity_get_vector(Index,EV_VEC_origin,IndexOrigin)
	
	new Float:Distance = vector_distance(Origin,IndexOrigin)
	if(Distance > 100.0 && g_Roped[Index])
	{
		new Float:Velocity[3],Float:Factor
		
		for(new Count;Count < 3;Count++)
		{
			Velocity[Count] = 20.0 * (Origin[Count] - IndexOrigin[Count])
			
			if(floatabs(Velocity[Count]) > 280.0 && floatabs(Velocity[Count]) >= floatabs(Velocity[0]) && floatabs(Velocity[Count]) >= floatabs(Velocity[1]) && floatabs(Velocity[Count]) >= floatabs(Velocity[2]))
				Factor = floatabs(Velocity[Count]) / 280.0
		}
		
		if(Factor)
			for(new Count;Count < 3;Count++)
				Velocity[Count] /= Factor
			
		if(Velocity[2] > 0.0)
			Velocity[2] = -floatabs(Velocity[2])
			
		entity_set_vector(Index,EV_VEC_velocity,Velocity)
	}
}

// the dot product is performed in 2d, making the view cone infinitely tall
stock bool:fm_is_in_viewcone(index, const Float:point[3]) {
	new Float:angles[3]
	pev(index, pev_angles, angles)
	engfunc(EngFunc_MakeVectors, angles)
	global_get(glb_v_forward, angles)
	angles[2] = 0.0

	new Float:origin[3], Float:diff[3], Float:norm[3]
	pev(index, pev_origin, origin)
	xs_vec_sub(point, origin, diff)
	diff[2] = 0.0
	xs_vec_normalize(diff, norm)

	new Float:dot, Float:fov
	dot = xs_vec_dot(norm, angles)
	pev(index, pev_fov, fov)
	if (dot >= floatcos(fov * M_PI / 360))
		return true

	return false
}

 // Avalanches Ammo Code (Thanks for letting me use it)
 // Set a user's ammo amount
 public ts_setuserammo(id,weapon,ammo) {

   // Kung Fu
   if(weapon == 36) {
     client_cmd(id,"weapon_0"); // switch to kung fu
     return 0; // stop now
   }

   // Invalid Weapon
   if(weapon < 0 || weapon > 35) {
     return 0; // stop now
   }

   client_cmd(id,"weapon_%d",weapon); // switch to whatever weapon

   // C4 or Katana
   if(weapon == 29 || weapon == 34) {
     return 0; // stop now
   }

   // TS AMMO OFFSETS
   new tsweaponoffset[37];
   tsweaponoffset[1] = 51; // Glock18
   tsweaponoffset[3] = 50; // Uzi
   tsweaponoffset[4] = 52; // M3
   tsweaponoffset[5] = 53; // M4A1
   tsweaponoffset[6] = 50; // MP5SD
   tsweaponoffset[7] = 50; // MP5K
   tsweaponoffset[8] = 50; // Beretta
   tsweaponoffset[9] = 51; // Socom
   tsweaponoffset[11] = 52; // USAS
   tsweaponoffset[12] = 59; // Desert Eagle
   tsweaponoffset[13] = 55; // AK47
   tsweaponoffset[14] = 56; // Fiveseven
   tsweaponoffset[15] = 53; // Steyr AUG
   tsweaponoffset[17] = 61; // Skorpion
   tsweaponoffset[18] = 57; // Barret
   tsweaponoffset[19] = 56; // Mp7
   tsweaponoffset[20] = 52; // Spas
   tsweaponoffset[21] = 51; // Golden Colts
   tsweaponoffset[22] = 58; // Glock20
   tsweaponoffset[23] = 51; // UMP
   tsweaponoffset[24] = 354; // M61 Grenade
   tsweaponoffset[25] = 366; // Combat Knife
   tsweaponoffset[26] = 52; // Mossberg
   tsweaponoffset[27] = 53; // M16
   tsweaponoffset[28] = 59; // Ruger Mk1
   tsweaponoffset[31] = 60; // Raging Bull
   tsweaponoffset[32] = 53; // M60
   tsweaponoffset[33] = 52; // Sawed Off
   tsweaponoffset[35] = 486; // Seal Knife
   tsweaponoffset[36] = 62; // Contender

   new currentent = -1, tsgun = 0; // used for getting user's weapon_tsgun

   // get origin
   new Float:origin[3];
   entity_get_vector(id,EV_VEC_origin,origin);

   // loop through "user's" entities (whatever is stuck to user, basically)
   while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0) {
     new classname[32];
     entity_get_string(currentent,EV_SZ_classname,classname,31);

     if(equal(classname,"weapon_tsgun")) { // Found weapon_tsgun
       tsgun = currentent; // remember it
     }

   }

   // Couldn't find weapon_tsgun
   if(tsgun == 0) {
     return 0; // stop now
   }

   // Get some of their current settings
   new currclip, currammo, currmode, currextra;
   ts_getuserwpn(id,currclip,currammo,currmode,currextra);

   set_pdata_int(tsgun,tsweaponoffset[weapon],ammo); // set their ammo

   // Grenade or knife, set clip
   if(weapon == 24 || weapon == 25 || weapon == 35) {
     set_pdata_int(tsgun,41,ammo); // special clip storage
     set_pdata_int(tsgun,839,ammo); // more special clip storage
     currclip = ammo; // change what we send to WeaponInfo
     ammo = 0; // once again, change what we send to WeaponInfo
   }
   else { // Not a grenade or knife, set ammo
     set_pdata_int(tsgun,850,ammo); // special ammo storage
   }

   // Update user's HUD
   message_begin(MSG_ONE,get_user_msgid("WeaponInfo"),{0,0,0},id);
   write_byte(weapon);
   write_byte(currclip);
   write_short(ammo);
   write_byte(currmode);
   write_byte(currextra);
   message_end();

   return 1; // wooh!
 }