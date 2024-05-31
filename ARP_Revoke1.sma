#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Items>
#include <ApolloRP_Chat>

new cDestroy
new sPermittedl 
new sRestrictedl
new namei[33]

public ARP_Init()
{
	ARP_RegisterPlugin("License Revoke", "1", "karn", "Cops are able to revoke gun licenses")
	ARP_RegisterChat("/revoke", "cmd_revoke", "- revokes license")
	cDestroy = register_cvar("arp_destroy_license", "1")
	sRestrictedl = register_cvar("arp_rlicense_num", "53")
	sPermittedl = register_cvar("arp_plicense_num", "54")

}

public cmd_revoke(id)
{	
	if (!ARP_IsCop(id))
	{
		client_print(id, print_chat, "[ARP] You cannot revoke licenses.")
		return PLUGIN_HANDLED
	}

	new tid, body
	get_user_aiming(id, tid, body, 200)
	
	if (!is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
	if (!tid || !is_user_alive(tid))
	{
		client_print(id, print_chat, "[ARP] You have to be aiming at someone to do that.")
		return PLUGIN_HANDLED
	}

	
	new strName[32]
	get_user_name(id, strName, 31)

	new strTargetName[32]
	get_user_name(tid, strTargetName, 31)

	namei[tid] = id
	
	
	if ( ARP_IsCop(tid) )
	{
		client_print(id, print_chat, "[ARP] You cannot take away another cop's license(s).")
		return PLUGIN_HANDLED
	}

	//client_print(id, print_chat, "[ARP] You are trying to frisk %s.", szTargetName)
	new checkRestrictedl
	new checkPermittedl
	new getl53
	new getl54
	new total

	checkRestrictedl = get_pcvar_num( sRestrictedl )
	checkPermittedl = get_pcvar_num( sPermittedl )
	getl53 = ARP_GetUserItemNum(tid,checkRestrictedl)
	getl54 = ARP_GetUserItemNum(tid,checkPermittedl)
	total = getl53 + getl54

	if( total > 0 )
	{

	ARP_SetUserItemNum(tid,checkRestrictedl,0)
	ARP_SetUserItemNum(tid,checkPermittedl,0)

	//ARP_ForceUseItem(tid,27,1)
	client_print(id, print_chat, "[ARP] You take away %s's license(s)", strTargetName)
	client_print(tid, print_chat, "[ARP] %s has taken away your license(s)", strName)
	
	new checkDestroy
	checkDestroy = get_pcvar_num( cDestroy )
	if ( checkDestroy < 1 )
	{
		ARP_GiveUserItem(id,checkRestrictedl,getl53)
		ARP_GiveUserItem(id,checkPermittedl,getl54)
	}
	
	}
	else
	{	
	client_print(id, print_chat, "[ARP] %s has no licenses!", strTargetName)
	return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
