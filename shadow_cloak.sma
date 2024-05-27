#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <tsconst>
#include <tsfun>

new g_LastRender[33]
new g_Cloaked[33]

public plugin_init()
{
	register_plugin("Shadow Cloak","1.0","Hawk552")
	
	register_srvcmd("item_cloak","CmdCloak")
	
	register_event("DeathMsg","EventDeathMsg","a")
	
	register_forward(FM_PlayerPostThink,"ForwardPlayerPostThink")
}

public CmdCloak()
{
	new Arg[10]
	read_argv(1,Arg,9)
	
	new id = str_to_num(Arg)
	if(!id || !is_user_alive(id))
		return
		
	new Cloaked = (g_Cloaked[id] = !g_Cloaked[id])
	Cloaked ? (g_LastRender[id] = 0) : set_pev(id,pev_renderamt,255.0)
		
	client_print(id,print_chat,"[CLOAK] You have %sabled your cloak.",Cloaked ? "en" : "dis")
}

public EventDeathMsg()
	g_Cloaked[read_data(2)] = 0

public client_disconnect(id)
	g_Cloaked[id] = 0

public ForwardPlayerPostThink(id)
{
	if(!g_Cloaked[id])
		return FMRES_IGNORED
	
	new Float:Velocity[3]
	pev(id,pev_velocity,Velocity)
	new Float:Speed = Velocity[0] + Velocity[1] + Velocity[2],Modifier = Speed != 0.0 ? 1 : -1,Float:RenderAmount = float((g_LastRender[id] = clamp(g_LastRender[id] + Modifier,0,255)) + 50),Dummy,Weapon = ts_getuserwpn(id,Dummy,Dummy,Dummy,Dummy)
	switch(Weapon)
	{
		case TSW_KATANA,TSW_KUNG_FU,TSW_CKNIFE,TSW_SKNIFE,TSW_TKNIFE:
			RenderAmount -= 50.0
	}
	
	set_pev(id,pev_renderfx,kRenderFxGlowShell)
	set_pev(id,pev_rendercolor,Float:{0.0,0.0,0.0})
	set_pev(id,pev_rendermode,kRenderTransAlpha)
	set_pev(id,pev_renderamt,RenderAmount)
	
	return FMRES_IGNORED
}