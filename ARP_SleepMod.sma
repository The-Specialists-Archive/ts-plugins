/*
Advanced Bathroom Mod for Apollo RP
Made for: Shin
Made by: Knox
Idea from: Shin
Special Thanks:
Shin, for the support and the scripting support.. (You dont suck)

*/

#include <ApolloRP>
#include <ApolloRP_Chat>
#include <amxmodx>
#include <amxmisc>
#include <fun>




new bool:asleep[33]
new tiredness[33] = 1

public plugin_init()
{
	register_plugin("Advanced Sleep Mod","1.0","Knox")

}
public ARP_Init()
{
	ARP_RegisterEvent("HUD_Render","EventHudRender")
	ARP_AddChat(_,"CmdSay")	
}

public plugin_precache()
{
	precache_sound("misc/snore.wav")
	precache_sound("misc/yawn.wav")
}

// Called when player recieves his salary
public ARP_Salary(id)
{
	tiredness[id] += 2
	if(tiredness[id] >= 50)
	{
		client_print(id,print_chat,"[Sleep Mod] You are starting to feel tired!")
		emit_sound(id,CHAN_VOICE,"misc/yawn.wav",0.1,ATTN_NORM,0,PITCH_NORM)

	}
	if(tiredness[id] == 100)
	{
		client_print(id,print_chat,"[Sleep Mod] You died because of lack of sleep!")
		user_kill(id)
		tiredness[id] = 0
	}
}
public reset_fade(id)
{
	asleep[id] = false
	fadeout(id)
	snore(id)
}
public CmdSay(id,Mode,Args[])
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(equali(Args,"/sleep",5))
	{
		if(asleep[id] == true)
		{
			asleep[id]=false
			client_cmd(id,"-duck")
			set_user_maxspeed(id,320.0)
			set_task(0.1,"fadeout",id)
			set_task(0.1,"snore",id)
			tiredness[id] -= 30 
			set_user_health(id,100)
			client_print(id,print_chat,"[Sleep Mod] You wake up feeling refreshed.")
		}
		if(asleep[id] == false)
		{
			if(tiredness[id] >= 50)
			{
				asleep[id]=true
				client_cmd(id,"+duck")
				set_user_maxspeed(id,1.0)
				set_task(0.1,"fadeout",id)
				set_task(0.1,"snore",id)
				client_print(id,print_chat,"[Sleep Mod] You begin to fall asleep.^n")
				client_print(id,print_chat,"[Sleep Mod] Type /sleep again to wake up.")
			}
			else
			{
				client_print(id,print_chat,"[Sleep Mod] You arent tired enough!")
			}
		}
	}
	return PLUGIN_CONTINUE
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
public EventHudRender(Name[],Data[],Len)
{
	new id = Data[0]
	if(!is_user_alive(id) || Data[1] != HUD_PRIM)
		return
	
	ARP_AddHudItem(id,HUD_PRIM,0,"Tiredness: %i%",tiredness[id])
}	

public client_connect(id)
{
	tiredness[id] = 0
}

public client_disconnect(id) 
{
	tiredness[id] = 0
}

public fadeout(id) // Fade effect
{
	if(asleep[id])
	{
		set_user_rendering(id,kRenderFxGlowShell,0,255,0,kRenderTransAlpha,25)
		message_begin(MSG_ONE,get_user_msgid("TSFade"),{0,0,0},id);
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
		message_begin(MSG_ONE,get_user_msgid("TSFade"),{0,0,0},id);
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


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/