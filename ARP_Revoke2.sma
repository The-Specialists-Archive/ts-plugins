#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Items>
#include <ApolloRP_Chat>

new cDestroy
new cPermittedl 
new cRestrictedl

public ARP_Init()
{
	ARP_RegisterPlugin("License Revoke", "1", "karn", "Cops are able to revoke gun licenses")
	ARP_RegisterChat("/revoke", "startrevoke", "- revokes license")
	cDestroy = register_cvar("arp_destroy_license", "1")
	cRestrictedl = register_cvar("arp_rlicense_num", "53")
	cPermittedl = register_cvar("arp_plicense_num", "54")
}

public startrevoke(id)
{	
	new id2 
	new plyLook
	get_user_aiming(id, id2, plyLook, 180)
	
	if ( !ARP_IsCop(id) )
	{
		client_print(id, print_chat, "[ARP] You cannot revoke licenses.")
		return PLUGIN_HANDLED
	}
	
	if ( !is_user_alive(id) )
	{
		client_print(id, print_chat, "[ARP] You have to be alive to do that.")
		return PLUGIN_HANDLED
	}
	
	if ( !is_user_alive(id2) ) 
	{
		client_print(id, print_chat, "[ARP] You have to be aiming at someone to do that.")
		return PLUGIN_HANDLED
	}

	if ( ARP_IsCop(id2) )
	{
		client_print(id, print_chat, "[ARP] You cannot take away another cop's license(s).")
		return PLUGIN_HANDLED
	}
	
	new plyTarName[32]
	new plyCopName[32]		
	new checkRestrictedl
	new checkPermittedl
	new getlr
	new getlp
	new total
	get_user_name(id2, plyTarName, 31)
	get_user_name(id, plyCopName, 31)

	checkRestrictedl = get_pcvar_num( cRestrictedl )
	checkPermittedl = get_pcvar_num( cPermittedl )
	getlr = ARP_GetUserItemNum(id2,checkRestrictedl)
	getlp = ARP_GetUserItemNum(id2,checkPermittedl)
	total = getlr + getlp  //if they have any it will be over 0

	if( total > 0 )
	{
	ARP_SetUserItemNum(id2,checkRestrictedl,0)
	ARP_SetUserItemNum(id2,checkPermittedl,0)
	client_print(id, print_chat, "[ARP] You take away %s's license(s)", plyTarName)
	client_print(id2, print_chat, "[ARP] %s has taken away your license(s)", plyCopName)
	
	new checkDestroy
	checkDestroy = get_pcvar_num( cDestroy )
	
	if ( checkDestroy < 1 )
	{
		ARP_GiveUserItem(id,checkRestrictedl,getlr)
		ARP_GiveUserItem(id,checkPermittedl,getlp)
	}
	
	}
	else
	{	
		client_print(id, print_chat, "[ARP] %s has no licenses!", plyTarName)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
