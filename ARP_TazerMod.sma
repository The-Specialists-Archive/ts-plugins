#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Chat>
#include <fakemeta>
#include <tsfun>
#include <engine>
#include <tsx>
#include <fun>

new g_Tazered[33]
new g_HasTazer[33]
new g_SwitchedToTazer[33]
new g_TazerAmmo[33]

new Float:g_MaxSpeed[33]
new Float:g_LastTazer[33]

new g_Lightning

new g_MsgScreenFade

new g_FlashSound[] = "weapons/sfire-inslow.wav"
new g_HeartSound[] = "harburp/heart.wav"
new g_TazerSound[] = "harburp/tazer.wav"

new g_Tazer

public plugin_init()
{
	g_Tazer = ARP_FindItem("Tazer")
	ARP_AddChat(_,"CmdSay")
	register_event("WeaponInfo","WeaponChange","be")
	register_event("DeathMsg","EventDeathMsg","a")
	ARP_RegisterEvent("Item_Use","ItemUseHandler")
	g_MsgScreenFade = get_user_msgid("ScreenFade")
	register_cvar("arp_tazer_mode","1")
	register_cvar("arp_tazer_maxammo","1")
	register_cvar("arp_tazer_distance","200")
	
}

public ARP_Init()
{
	ARP_RegisterPlugin("TazerMod","1.1","EagleEye","Changes the tazer into an actual weapon")
	ARP_RegisterEvent("HUD_Render","EventHudRender")
}

public ItemUseHandler(Name[],Data[],Len)
{
	new id = Data[0]
	new ItemID = Data[1]
	if((ItemID == g_Tazer) && get_cvar_num("arp_tazer_mode"))
	{
		ToggleTazer(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	g_Lightning = precache_model("sprites/lgtning.spr")	// Lightning effect from Tazer
	precache_sound(g_HeartSound)
	precache_sound(g_TazerSound)
	precache_sound(g_FlashSound)
	precache_model("models/ARP/p_tazer.mdl")
	precache_model("models/ARP/v_tazer.mdl")
}

public client_disconnect(id)
{
	g_Tazered[id] = 0
	g_LastTazer[id] = 0.0
	g_HasTazer[id] = 0
}

public EventDeathMsg()
{
	new id = read_data(2)
	
	g_Tazered[id] = 0
	g_LastTazer[id] = 0.0
	g_HasTazer[id] = 0
}

public CmdSay(id,Mode,Args[])
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(equali(Args,"/tazer",6))
	{
		if(get_cvar_num("arp_tazer_mode") > 0) 
		{
			ARP_GetUserItemNum(id,g_Tazer) ? ToggleTazer(id) : client_print(id,print_chat,"[ARP] You don't have any tazers.")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public ToggleTazer(id)
{
	if(!is_user_alive(id))
		return
	
	if(g_HasTazer[id] == 1)
	{
		entity_set_string(id,EV_SZ_viewmodel,"")
		entity_set_string(id,EV_SZ_weaponmodel,"")
		entity_set_int(id,EV_INT_weaponanim,0)
		g_HasTazer[id] = 0
		client_cmd(id,"say /me puts the tazer back into it's holster")
	}
	else
	{
		g_HasTazer[id] = 1
		
		new weaponid, ammo, clip, mode, extra
		weaponid = ts_getuserwpn(id,clip,ammo,mode,extra)
		if(weaponid != 36 && weaponid != 0)
		{
			g_SwitchedToTazer[id] = 1
			client_cmd(id,"weapon_0")
		}
		set_task(0.8,"SwitchModel",id) // Did as a task because the model doesn't show up if you take out a tazer when holding a gun
		
		g_TazerAmmo[id] = get_cvar_num("arp_tazer_maxammo")
	
		client_cmd(id,"say /me removes a tazer from it's holster")
	}
}

public SwitchModel(id)
{
	if(g_HasTazer[id] == 1)
	{
		entity_set_string(id,EV_SZ_viewmodel,"models/ARP/v_tazer.mdl")
		entity_set_string(id,EV_SZ_weaponmodel,"models/ARP/p_tazer.mdl")
	}
}

public TazerReload(id)
{
	if(!task_exists(id) && g_TazerAmmo[id] < get_cvar_num("arp_tazer_maxammo"))
	{
		client_cmd(id,"say /me reloads his tazer")
		entity_set_int(id,EV_INT_weaponanim,4)
		set_task(3.0,"SetAmmo",id)
	}
}
public SetAmmo(id)
{
	client_print(id,print_chat,"[ARP] You have reloaded your tazer!")
	g_TazerAmmo[id] = get_cvar_num("arp_tazer_maxammo")
}

public TazerAction(id)
{
	new Index,Body
	get_user_aiming(id,Index,Body,get_cvar_num("arp_tazer_distance"))
	
	new Float:Time = get_gametime()
	
	if(get_cvar_num("arp_tazer_mode") == 1) 
	{
		if(!Index || !is_user_alive(Index))
		{
			client_print(id,print_chat,"[ARP] You are not looking at another player.")
			return
		}
		if(Time - g_LastTazer[id] < 60.0 && g_LastTazer[id])
		{
			client_print(id,print_chat,"[ARP] Your tazer is currently recharging.")
			return
		}
	}
	if((get_cvar_num("arp_tazer_mode") == 2))
	{
		if(g_TazerAmmo[id] == 0)
		{
			client_print(id,print_chat,"[ARP] Your need to reload your tazer!.")
			return
		}
	}
	if(Index && is_user_alive(Index))
	{
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
		
		if(ARP_IsCop(Index) && ARP_IsCop(id))
		{
			client_print(id,print_chat,"[ARP] You cannot tazer other cops.")
			return
		}
	}
	
	entity_set_int(id,EV_INT_weaponanim,1)
	
	new pOrigin[3],tOrigin[3]
	g_Tazered[Index] = 1
	get_user_origin(id,pOrigin)
	
	if((get_cvar_num("arp_tazer_mode") == 1) || (Index && is_user_alive(Index)))
	{
		g_LastTazer[id] = Time
		get_user_origin(Index,tOrigin)	
		set_rendering(Index,kRenderFxGlowShell,0,0,255,kRenderNormal,16)
		fakedamage(Index,"Tazer",10.0,DMG_SHOCK /* 256 SHOCK */)
	
		if(get_user_health(Index) <= 0)
			return
			
		for(new Count = 1;Count < 36;Count++)
			client_cmd(Index,"weapon_%d;drop",Count)
			
		if(get_cvar_num("arp_tazer_mode") == 2)
			g_TazerAmmo[id] -= 1
		
		set_task(0.5,"SwitchModel",Index) // Switchs model of the person who was tazered back to a tazer if he had one out
		set_task(1.0,"ScreenFade",Index)
		set_task(2.0,"HeartBeat",Index)
		set_task(7.0,"Clear",Index)
	}
	else
	{
		get_user_origin(id,tOrigin,3)
		//client_cmd(id,"say /me fires his tazer and misses")  // This can get annoying after a few misses, but you can enable it if you want
		g_TazerAmmo[id] -= 1
	}
	
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
	
	emit_sound(id,CHAN_AUTO,g_TazerSound,1.0,ATTN_NORM,0,PITCH_NORM)

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

public client_PreThink(id)
{
	if(g_Tazered[id] == 1)
	{
		entity_set_float(id,EV_FL_maxspeed,10.0)
	}
	if (g_HasTazer[id] == 1)
	{
		new button = pev(id,pev_button) 
		if(button & IN_ATTACK && !(pev(id,pev_oldbuttons) & IN_ATTACK)) 
		{ 
			TazerAction(id)
		}
		if(get_cvar_num("arp_tazer_mode") == 2)
		{
			if(button & IN_RELOAD && !(pev(id,pev_oldbuttons) & IN_RELOAD))
			{
				TazerReload(id)
			}
		}
		new bufferstop = entity_get_int(id,EV_INT_button)
		if(bufferstop != 0) 
		{
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_RELOAD)
		}
	}
}

public WeaponChange(id)
{
	new weaponid, ammo, clip, mode, extra
	weaponid = ts_getuserwpn(id,clip,ammo,mode,extra)
	
	if(g_HasTazer[id] == 1 && weaponid != 36 && g_SwitchedToTazer[id] == 0)
	{
		g_HasTazer[id] = 0
		client_cmd(id,"say /me puts his tazer back into its holster and takes out another weapon")
		return PLUGIN_HANDLED
	}
	if(g_SwitchedToTazer[id] == 1) // Fixes tazer being put away after using a tazer while having a gun out
	{
		g_SwitchedToTazer[id] = 0
	}
	return PLUGIN_CONTINUE
}

public EventHudRender(Name[],Data[],Len)	
{
	new id = Data[0]
	if(Data[1] == HUD_PRIM && g_HasTazer[id]) 
	{
		ARP_AddHudItem(id,HUD_PRIM,0,"Tazer equipped")
		if(get_cvar_num("arp_tazer_mode") == 2)
			ARP_AddHudItem(id,HUD_PRIM,0,"Ammo: %i",g_TazerAmmo[id])
	}
		
}
