#include <amxmodx>

new cvar

public plugin_init() {
	register_plugin("No-Deathmessages","1.00","NL)Ramon(NL")
	cvar = register_cvar("amx_blockdeathmessage","1")
	register_message(get_user_msgid("DeathMsg"),"msg")
}

public msg() {
	if(get_pcvar_num(cvar)) return PLUGIN_HANDLED // block
	return PLUGIN_CONTINUE // dont block
}
