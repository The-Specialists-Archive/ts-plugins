#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <engine_stocks>
#include <fun>
#include <harbu>

#define SHOVE_BIND "+back;wait;wait;wait;wait;wait;+alt1;+jump;wait;wait;-alt1;-back;-jump;"
#define SHOVE_DISTANCE 200
#define SHOVE_HEAR 450

new lastShove[32];

public plugin_init()
{

	register_plugin("Shove","FINAL","James J Kelly Jr");
	
	register_clcmd("say /shove","sayHandle");

}

public client_disconnect(id)
{

	lastShove[id] = 0;

}

public client_connect(id)
{

	lastShove[id] = 0;

}

public sayHandle(id)
{

	new buffer[256], strArguments[3][32];

	read_argv(1,buffer,255)
	
	parse(buffer,strArguments[0],31,strArguments[1],31,strArguments[2],31);
	
	if( equali(strArguments[0],"/shove") || equali(strArguments[0],"/push") )
	{
	
		if( !(is_user_connected(id) && is_user_alive(id)) ) return PLUGIN_HANDLED;
		
		if( (get_systime()-lastShove[id]) < 5 )
		{
			client_print(id,print_chat,"[ShoveMod] Stop spamming shove!^n");
			return PLUGIN_HANDLED;
		}
		
		lastShove[id] = get_systime();
		
		new target, body;
		get_user_aiming(id,target,body,SHOVE_DISTANCE);
		
		if( !(is_user_connected(target) && is_user_alive(target)) )
		{
			client_print(id,print_chat,"[ShoveMod] You need to be looking at someone to shove!^n");
			return PLUGIN_HANDLED;
		}
		
		new playerOrigin[3];
		get_user_origin(id,playerOrigin);
		
		new name[2][32];
		get_user_mask(id,name[0],31);
		get_user_mask(target,name[1],31);
		
		client_cmd(target,SHOVE_BIND);
		
		new players, player[32];
		
		get_players(player,players,"ac");
		
		for( new i = 0; i < players; i++ )
		{
		
			new origin[3];
			get_user_origin(player[i],origin);
			
			if( get_distance(playerOrigin,origin) <= SHOVE_HEAR )
			{
			
				client_print(player[i],print_chat,"[ShoveMod] %s shoved %s to the ground!^n",name[0],name[1]);
			
			}
		
		}
		
		return PLUGIN_HANDLED;
			
	}
	
	return PLUGIN_CONTINUE;
		
}