#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <dbi>
#include <fun>

#define PLUGIN "Ram Mod"
#define VERSION "FINAL"
#define AUTHOR "Shinni Winni."

#define HARBURP	"HarbuRPAlpha.amxx"

#define RAM_INDEX_INDEX	0
#define RAM_INDEX_TRIES	1
#define RAM_INDEX_NEXT	2

#define RAMING_SOUND	"smash.wav"

new gPlayerRam[32][3];

new Sql:myConnection;
new bool:myConnected;

new nullstring[1];

public plugin_init()
{

	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("DeathMsg","client_death","a");
	
	// register_srvcmd("item_tvirus","item_tvirus");
	register_srvcmd("item_present","item_present");
	register_srvcmd("item_cuff","item_cuff");
	register_srvcmd("item_ram","item_ram");
	register_srvcmd("item_restraint","item_restraint");
	
	register_concmd("amx_itemuse","game_itemuse",ADMIN_ALL,"Allows you to bind an item to a key");
	register_concmd("amx_itemshow","game_itemshow",ADMIN_ALL,"Allows you to bind an item to a key");
	
	set_task(1.0,"timer",0,"",0,"b");

}

public plugin_precache()
{

	precache_sound(RAMING_SOUND);
		
}

public client_connect(id)
{
	
	gPlayerRam[id][RAM_INDEX_NEXT] = 0;
	
}

public client_disconnect(id)
{
	
	gPlayerRam[id][RAM_INDEX_NEXT] = 0;
	
}

public client_death()
{
	
	new id = read_data(2);
	
	gPlayerRam[id][RAM_INDEX_NEXT] = 0;
	
}

public item_ram(id)
{

	new strArguments[1][32];
	
	read_argv(1,strArguments[0],31);
	
	if( equali(strArguments[0],"") ) return PLUGIN_HANDLED;
	
	new numArguments[1];
	
	numArguments[0] = str_to_num(strArguments[0]);
	
	if( !(is_user_connected(numArguments[0]) && is_user_alive(numArguments[0])) ) return PLUGIN_HANDLED;
	
	if( gPlayerRam[numArguments[0]][RAM_INDEX_NEXT] > 0 ) return PLUGIN_HANDLED;
	
	new target, body;
	get_user_aiming(numArguments[0],target,body,50);
	
	if( !is_valid_ent(target) )
	{
	
		client_print(numArguments[0],print_chat,"[RamMod] You must be looking at a door!^n");
		return PLUGIN_HANDLED;
			
	}
	
	new className[64];
	entity_get_string(target,EV_SZ_classname,className,63);
	
	if( !(equali(className,"func_door") || equali(className,"func_door_rotating")) )
	{
	
		client_print(numArguments[0],print_chat,"[RamMod] You must be looking at a door!^n");
		return PLUGIN_HANDLED;
			
	}
	
	if( target != gPlayerRam[numArguments[0]][RAM_INDEX_INDEX] )
	{
	
		gPlayerRam[numArguments[0]][RAM_INDEX_INDEX] = target;
		gPlayerRam[numArguments[0]][RAM_INDEX_TRIES] = random_num(3,5);
			
	}
	
	gPlayerRam[numArguments[0]][RAM_INDEX_TRIES] -= 1;
	
	if( gPlayerRam[numArguments[0]][RAM_INDEX_TRIES] <= 0 )
	{
	
		force_use(numArguments[0],gPlayerRam[numArguments[0]][RAM_INDEX_INDEX]);
		fake_touch(gPlayerRam[numArguments[0]][RAM_INDEX_INDEX],numArguments[0]);
			
	}
	
	gPlayerRam[numArguments[0]][RAM_INDEX_NEXT] = 3;
	
	emit_sound(numArguments[0],CHAN_ITEM,RAMING_SOUND,1.0,ATTN_NORM,0,PITCH_NORM);
	
	return PLUGIN_HANDLED;
		
}