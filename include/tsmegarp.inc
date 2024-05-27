/*
 * TS Include file for TS Mega RP Plugins
 * By Sandurr
 *
 */

#include <amxmodx>
#include <tsx>
#include <tsxaddon>
#include <fakemeta>
#include <engine>

#if defined _tsmegarp_included
  #endinput
#endif
#define _tsmegarp_included

#define MAX_PLAYERS	33

stock get_id_by_steamid(steamid[64])
{
	new authid[64]
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		get_user_authid(i,authid,31)
		if(equali(authid,steamid) && is_user_alive(i))
			return i
	}
	return 0
}

stock player_exist(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return 0

	if(!is_user_alive(id) && !is_user_connected(id))
		return 0

	return 1
}

stock explode_include(output[][],input[],delimiter) 
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

stock cvar_to_array(SzCvar[],length,origin[],dimension = 3)
{
	new output[6][32]
	get_cvar_string(SzCvar,SzCvar,length)
	explode_include(output,SzCvar,' ')
	for(new i=0;i < dimension;i++) {
	origin[i] = str_to_num(output[i])
	}
	return PLUGIN_HANDLED
}

public advertise_register(id)
{
	client_print(id,print_chat,"[MegaRP] Please register for full use of the plugins (amx_register)! ^n")
	return PLUGIN_HANDLED
}