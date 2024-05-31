#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Chat>

new Class:g_Class[33]

public ARP_Init()
{
	ARP_RegisterPlugin("Surrender", "1", "karn", "Players are able to surrender to police.")
	//ARP_RegisterChat("/surrender", "startsurrender", "- player can surrender to police.")
	
	register_concmd ("arp_surrender", "startsurrender")
}

	IsCuffed(id)
		return ARP_ClassGetInt(g_Class[id],"cuff")
		
public startsurrender(id)
{	
	set_user_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16)
	client_cmd(id, "say /me puts hands up")
	client_cmd(id, "say /shout I give up!")
	for(new i=1;i<=35;i++)
	{
		client_cmd(id,"weapon_%d; drop",i)
	}
	client_cmd(id, "+speed")
	set_task(5.0, "wastetime", id)
	return PLUGIN_HANDLED	
	
}

public endsurrender(id)
{
	client_cmd(id, "-speed")
	set_rendering(id,kRenderFxNone,255,255,255,kRenderNormal,16)
	//set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	if ( IsCuffed(id) )
	{
		client_cmd(id, "-speed")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED	
}

public wastetime(id)
{
	return PLUGIN_CONTINUE
}