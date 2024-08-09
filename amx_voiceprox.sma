/*
   VOICE PROXIMITY
   Created by the 29th Infantry Division
   www.29th.org
   www.dodrealism.branzone.com -- Revolutionizing Day of Defeat Realism
   
   DESCRIPTION
   This plugin forces voice communication only to players within a certain
   radius of the speaker, which makes it so you cannot communicate to 
   players accross the map; but rather within "speaking range," which is a
   distance defined in a cvar. This also allows communication between teams
   if the players are within proximity.

   CREDITS
   TwilightSuzuka for the original idea and loop code.
   
   FREQUENTLY ASKED QUESTION
   If alltalk is ON, the dead and spectators will be able to communicate with
   alive players. If it is OFF, they will not be able to, but either way 
   players will be able to communicate to the other team.
   Also, it is less buggy with alltalk OFF.
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Voice Proximity"
#define VERSION "1.0"
#define AUTHOR "29th ID"

new g_enabled, g_distance

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_enabled  = register_cvar("amx_voiceprox", "0")
	g_distance = register_cvar("amx_voiceprox_distance", "1300")
	
	register_forward(FM_PlayerPreThink, "forward_player_prethink")
}

public forward_player_prethink(id) {
	if( (get_pcvar_num(g_enabled)) && (is_user_alive(id)) )
		check_area(id)
}

public check_area(id) {
	new players[32]
	new i, pNum
	get_players(players, pNum, "a")
	for (i=0; i < pNum; i++) {
		if(players[i] == id) continue
		
		if(entity_distance_stock(id, players[i]) <= get_pcvar_num(g_distance))
			engfunc(EngFunc_SetClientListening, id, players[i], 1)
		else
			engfunc(EngFunc_SetClientListening, id, players[i], 0)
	}
}

stock Float:vecdist(Float:vec1[3], Float:vec2[3])
{
        new Float:x = vec1[0] - vec2[0]
        new Float:y = vec1[1] - vec2[1]
        new Float:z = vec1[2] - vec2[2]
        x*=x;
        y*=y;
        z*=z;
        return floatsqroot(x+y+z);
}
 
stock Float:entity_distance_stock(ent1, ent2)
{
        new Float:orig1[3]
        new Float:orig2[3]
 
        pev(ent1, pev_origin, orig1)
        pev(ent2, pev_origin, orig2)
 
        return vecdist(orig1, orig2)
} 
