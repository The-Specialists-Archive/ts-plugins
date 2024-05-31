#include <ApolloRP>
#include <amxmisc>
#include <geoip>

public ARP_Init()
	ARP_RegisterPlugin("Show IP", "1.0.1", "Spunky", "Shows the IP address of connecting players to admins")

public client_connect(id)
{
	new szName[32]
	get_user_name(id, szName, 31)

	new szID[20]
	get_user_authid(id, szID, 19)

	new szIP[20]
	get_user_ip(id, szIP, 19, 1)

	new szCountry[32]
	geoip_country(szIP, szCountry, 31)

	new iPlayers[32], iPlayerNum
	get_players(iPlayers, iPlayerNum)

	for (new i = 0; i < iPlayerNum; i++)
	{
		if (access(iPlayers[i], ADMIN_BAN))
			client_print(iPlayers[i], print_chat, "[ARP] %s (%s) has connected from %s. (%s)", szName, szID, szCountry, szIP)
		else
			client_print(iPlayers[i], print_chat, "[ARP] %s has connected from %s.", szName, szCountry)
	}

	ARP_Log("%s (%s) has connected from %s. (%s)", szName, szID, szCountry, szIP)
}

public client_disconnect(id)
{
	new szName[32]
	get_user_name(id, szName, 31)

	new szID[20]
	get_user_authid(id, szID, 19)

	new szIP[20]
	get_user_ip(id, szIP, 19, 1)

	new szCountry[32]
	geoip_country(szIP, szCountry, 31)

	ARP_Log("%s (%s) has disconnected from %s. (%s)", szName, szID, szCountry, szIP)
}