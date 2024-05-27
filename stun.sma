/*=======================================*\
|* StunMod                               *|
|*=======================================*|
|* ©Copyright 2006 by James J. Kelly Jr. *|
\*=======================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <string>
#include <fun>

#define Author	"James J. Kelly Jr."
#define Version	"FINAL"
#define Plugin	"StunMod"

#define DAMAGE_SHOCK	256

#define STUN_HIT_SOUND	"stun/stunstick_impact1.wav"
#define STUN_MISS_SOUND	"stun/stunstick_swing1.wav"

new gPlayerLastStun[32];
new gPlayerStunned[32];
new Float:gPlayerSpeed[32];

public plugin_init()
{

	register_plugin(Plugin,Version,Author);
	
	register_cvar("rp_item_stun","0");
	register_cvar("stun_length","20");
	register_cvar("stun_max_length","30");
	
	register_clcmd("drop","dropHandle");
	register_clcmd("say","sayHandle");
	
	register_event("DeathMsg","client_death","a");
	
	register_srvcmd("item_stun","item_stun");
	
	server_cmd("exec addons/amxmodx/configs/stun.cfg");
	server_cmd("exec addons/amxmodx/configs/HarbuRP/harbu_rp_config.cfg");
	
	set_task(1.0,"timer",0,"",0,"b");
	
}

public plugin_precache()
{

	precache_sound(STUN_HIT_SOUND);
	precache_sound(STUN_MISS_SOUND);
		
}

public plugin_credits(id)
{

	client_print(id,engprint_console,"/*=======================================*\^n");
	client_print(id,engprint_console,"|* StunMod                               *|^n");
	client_print(id,engprint_console,"|*=======================================*|^n");
	client_print(id,engprint_console,"|* ©Copyright 2006 by James J. Kelly Jr. *|^n");
	client_print(id,engprint_console,"\*=======================================*/^n");
	
	return PLUGIN_HANDLED;
		
}

public client_putinserver(id)
{

	set_task(8.0,"plugin_credits",id);
		
}

public client_connect(id)
{

	gPlayerLastStun[id] = 0;
	gPlayerStunned[id] = 0;
		
}

public client_disconnect(id)
{

	gPlayerLastStun[id] = 0;
	gPlayerStunned[id] = 0;
		
}

public client_death()
{
	
	new id = read_data(2);
	
	gPlayerLastStun[id] = 0;
	gPlayerStunned[id] = 0;
	
}

public client_PreThink(id) 
{ 

	if( gPlayerStunned[id] > 0 )
	{
	
		new bufferStop = entity_get_int(id,EV_INT_button);

		if( bufferStop != 0 )
		{
			entity_set_int(id,EV_INT_button,bufferStop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE);
		} 

		if((bufferStop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) { 
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP) 
		}
	
	}
	
	return PLUGIN_CONTINUE;
	
}

public dropHandle(id)
{

	if( gPlayerStunned[id] > 0 )
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	return PLUGIN_CONTINUE;	
	
}

public sayHandle(id)
{

	new buffer[256], strArguments[3][32];

	read_argv(1,buffer,255)
	
	parse(buffer,strArguments[0],31,strArguments[1],31,strArguments[2],31);
	
	if( equali(strArguments[0],"/stun") )
	{
		
		item_use(id,get_cvar_num("rp_item_stun"));
		
		return PLUGIN_HANDLED;
			
	}
	
	return PLUGIN_CONTINUE;
		
}

public timer()
{

	new player[32], playerCount;
	get_players(player,playerCount,"ac");
	
	for( new i = 0; i < playerCount; i++ )
	{
	
		gPlayerLastStun[player[i]] -= 1;
		
		if( gPlayerLastStun[player[i]] < 0 ) gPlayerLastStun[player[i]] = 0;
		
		new oldStunned = gPlayerStunned[player[i]];
		gPlayerStunned[player[i]] -= 1;
		
		if( gPlayerStunned[player[i]] > get_cvar_num("stun_max_length") ) gPlayerStunned[player[i]] = get_cvar_num("stun_max_length");
		
		if( gPlayerStunned[player[i]] <= 0 )
		{
			if( oldStunned > 0 )
			{
				set_user_maxspeed(player[i],gPlayerSpeed[player[i]]);
			}
			gPlayerStunned[player[i]] = 0;
		}
		else
		{
			set_user_maxspeed(player[i],0.1);	
		}
			
	}
	
	return PLUGIN_HANDLED;
		
}

public item_stun()
{
	
	new strArguments[1][32];
	
	read_argv(1,strArguments[0],31);
	
	if( equali(strArguments[0],"") ) return PLUGIN_HANDLED;
	
	new numArguments[1];
	
	numArguments[0] = str_to_num(strArguments[0]);
	
	if( !(is_user_connected(numArguments[0]) && is_user_alive(numArguments[0])) ) return PLUGIN_HANDLED;
	
	if( gPlayerLastStun[numArguments[0]] > 0 )
	{
	
		client_print(numArguments[0],print_chat,"[StunMod] Your stun stick is still recharging!^n");
		
		return PLUGIN_HANDLED;
			
	}
	
	new target, body;
	get_user_aiming(numArguments[0],target,body,95);
	
	if( !is_valid_ent(target) || !(is_user_connected(target) && is_user_alive(target)) )
	{
		
		emit_sound(numArguments[0],CHAN_ITEM,STUN_MISS_SOUND,1.0,ATTN_NORM,0,PITCH_NORM);
		
		return PLUGIN_HANDLED;
		
	}
	
	emit_sound(numArguments[0],CHAN_ITEM,STUN_HIT_SOUND,1.0,ATTN_NORM,0,PITCH_NORM);
	
	if( random_num(1,20) == 10 )
	{
		
		client_print(numArguments[0],print_chat,"[StunMod] Your stun stick has backfired!^n");
		
		fakedamage(numArguments[0],"Stun Stick",1.0,DAMAGE_SHOCK);
		
		user_slap(numArguments[0],0,0);
		
		if( gPlayerStunned[numArguments[0]] <= 0 ) gPlayerSpeed[numArguments[0]] = get_user_maxspeed(numArguments[0]);
		gPlayerStunned[numArguments[0]] += get_cvar_num("stun_length");
	
		set_user_maxspeed(numArguments[0],0.1);
		
	}
	else
	{
	
		fakedamage(target,"Stun Stick",1.0,DAMAGE_SHOCK);
	
		user_slap(target,0,0);
	
		if( gPlayerStunned[target] <= 0 ) gPlayerSpeed[target] = get_user_maxspeed(target);
		gPlayerStunned[target] += get_cvar_num("stun_length");
	
		set_user_maxspeed(target,0.1);
	
	}
	
	gPlayerLastStun[numArguments[0]] = 3;
	
	return PLUGIN_HANDLED;
	
}

public item_use(id,itemid)
{
	
	callfunc_begin ("item_use","HarbuRPAlpha.amxx");
	callfunc_push_int(id);
	callfunc_push_int(itemid);
	callfunc_end();
	
	return PLUGIN_HANDLED;
	
}