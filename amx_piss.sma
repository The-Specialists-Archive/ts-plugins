/*

Plugin: Amxx Piss
Version: 1.2
Author: KRoTaL (Based on TakeADookie by PaintLancer and Amx Te Model by Ludwig van)
		    Thanks to Rastin for his brag sounds.

1.0 Release
1.1 Better effect
1.2 Bug fix

Commands: 

	To piss on a dead body you have to bind a key to: piss
	Open your console and write: bind "key" "piss"
	ex: bind "x" "piss"
	Then stand still above a dead player, press your key and you'll piss on them !
	You can control the direction of the stream with your mouse.
	You are not able to move or to shoot for 10 seconds when you piss, so beware ;)

	Players can say "/piss" in the chat to get some help.

Cvars:

	amx_maxpees 6		-	Maximum number of times a player is allowed to piss per round.

	amx_piss_distance 140	-	Distance from where you stand after which your stream of piss will not appear : between 1 and 4000

	amx_piss_duration 255	-	Duration of piss on ground : between 1 and 255

	amx_piss_admin 0		-	0 : All the players are allowed to piss
				    	      1 : Only admins with ADMIN_LEVEL_A flag are allowed to piss

*/


#include <amxmodx> 
#include <fun>

new piss_model
new piss_sprite
new player_origins[33][3]
new count_piss[33]
new bool:PissFlag[33]
new Float:maxspeed

public sqrt(num) { 
new div = num 
new result = 1 
while (div > result) { 
	div = (div + result) / 2 
	result = num / div 
} 
return div 
} 

public piss_on_player(id) {

if (get_cvar_num("amx_maxpees")==0) 
	return PLUGIN_HANDLED 
if (!is_user_alive(id)) 
	return PLUGIN_HANDLED 
if ( (get_cvar_num("amx_piss_admin")==1) && !(get_user_flags(id) & ADMIN_LEVEL_A) )
{
	console_print(id, "[AMXX] You have not access to this command.")
	return PLUGIN_HANDLED
}

new player_origin[3], players[32], inum=0, dist, last_dist=99999, last_id 

get_user_origin(id,player_origin,0) 
get_players(players,inum,"b") 
if (inum>0) { 
	for (new i=0;i<inum;i++) { 
		if (players[i]!=id) { 
			dist = get_distance(player_origin,player_origins[players[i]]) 
			if (dist<last_dist) { 
				last_id = players[i] 
				last_dist = dist 
			} 
		} 
	} 
	if (last_dist<80) { 
		if (count_piss[id] > get_cvar_num("amx_maxpees")) { 
			client_print(id,print_chat,"You can only piss on a player %d time%s in a round !", get_cvar_num("amx_maxpees"), (get_cvar_num("amx_maxpees")>1) ? "s" : "") 
			return PLUGIN_CONTINUE 
		}
		new player_name[32], dead_name[32]
		get_user_name(id, player_name, 31)
		get_user_name(last_id, dead_name, 31)
		emit_sound(id,CHAN_VOICE,"piss/pissing.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
		client_print(0,print_chat,"%s Is Pissing On %s's Dead Body !! HaHaHaHa !!", player_name, dead_name)
		count_piss[id]+=1
		new ids[1]
		ids[0]=id
		PissFlag[id]=true
		maxspeed=get_user_maxspeed(id)
		set_user_maxspeed(id, -1.0)
		set_task(0.1,"make_pee",1481+id,ids,1,"a",106)
		set_task(12.0,"weapons_back",6794+id,ids,1)
	}
	else
		client_print(id,print_chat,"There are no dead bodies around you.")
}
return PLUGIN_HANDLED
}

public make_pee(ids[]) { 
new id=ids[0]
new vec[3] 
new aimvec[3] 
new velocityvec[3] 
new length 
get_user_origin(id,vec) 
get_user_origin(id,aimvec,3) 
new distance = get_distance(vec,aimvec) 
new speed = floatround(distance*1.8)

velocityvec[0]=aimvec[0]-vec[0] 
velocityvec[1]=aimvec[1]-vec[1] 
velocityvec[2]=aimvec[2]-vec[2] 

length=sqrt(velocityvec[0]*velocityvec[0]+velocityvec[1]*velocityvec[1]+velocityvec[2]*velocityvec[2]) 

velocityvec[0]=velocityvec[0]*speed/length 
velocityvec[1]=velocityvec[1]*speed/length 
velocityvec[2]=velocityvec[2]*speed/length 

if(distance<=get_cvar_num("amx_piss_distance"))
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(106) 
	write_coord(vec[0]) 
	write_coord(vec[1]) 
	write_coord(vec[2]) 
	write_coord(velocityvec[0]) 
	write_coord(velocityvec[1]) 
	write_coord(velocityvec[2]+100) 
	write_angle (0) 
	write_short (piss_model) 
	write_byte (0) 
	write_byte (get_cvar_num("amx_piss_duration")) 
	message_end()  

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte (1)    
	write_short (id) 
	write_coord(aimvec[0]) 
	write_coord(aimvec[1]) 
	write_coord(aimvec[2]) 
	write_short(piss_sprite) 
	write_byte( 1 ) // framestart 
	write_byte( 5 ) // framerate 
	write_byte( 1 ) // life 
	write_byte( 8 ) // width 
	write_byte( 0 ) // noise 
	write_byte( 255 ) // r, g, b 
	write_byte( 255 ) // r, g, b 
	write_byte( 0 ) // r, g, b 
	write_byte( 200 ) // brightness 
	write_byte( 10 ) // speed 
	message_end()
}
} 

public death_event() { 
   	new victim = read_data(2)
   	get_user_origin(victim,player_origins[victim],0) 

	if(PissFlag[victim]) 
		reset_piss(victim)

   	return PLUGIN_CONTINUE 
}

public weapons_back(ids[]) { 
   	PissFlag[ids[0]]=false 
	set_user_maxspeed(ids[0], maxspeed)

   	return PLUGIN_HANDLED
}

public piss_help(id) {
	client_print(id, print_chat, "To piss on a dead body you have to bind a key to: piss")
	client_print(id, print_chat, "Open your console and write: bind ^"key^" ^"piss^"")
	client_print(id, print_chat, "ex: bind ^"x^" ^"piss^"")

	return PLUGIN_CONTINUE
}

public handle_say(id) {
	new said[192]
	read_args(said,192)
	remove_quotes(said)

	if( (containi(said, "piss") != -1) && !(containi(said, "/piss") != -1) ) {
		client_print(id, print_chat, "[AMXX] For Piss help say /piss")
	}

	return PLUGIN_CONTINUE
}

public plugin_precache() { 
	if (file_exists("sound/piss/pissing.wav"))
		precache_sound( "piss/pissing.wav") 
	if (file_exists("models/piss/piss.mdl"))  	
		piss_model = precache_model("models/piss/piss.mdl")  
	piss_sprite = precache_model("sprites/laserbeam.spr")

   	return PLUGIN_CONTINUE 
}

public plugin_init() { 
	register_plugin("AMXX Piss","1.2","KRoTaL") 
	register_clcmd("piss","piss_on_player",0,"- Piss on a dead player") 
	register_clcmd("say /piss","piss_help",0,"- Displays piss help") 
	register_clcmd("say","handle_say")
	register_cvar("amx_maxpees","6")
	register_cvar("amx_piss_distance","140")
	register_cvar("amx_piss_duration","255")
	register_cvar("amx_piss_admin","0")
	register_event("DeathMsg","death_event","a") 
	return PLUGIN_CONTINUE
}
