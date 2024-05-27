 //Pinkfairie's TS Oralsexmod .1 by Pinkfairie
 //
 //Made it all bymyself, on first try 0 errors
 //I have a sickmind and i just made it for fun, Enjoy.

  #include <amxmodx>
  #include <fun>
  #include <xtrafun>
  #include <amxmisc> 
  #include <engine>
  #include <fakemeta>

 public plugin_init() {
    register_plugin("Oralsexmod","2.37","Pinkfairie");
    console_print(0,"* Loaded Pinkfairie's TS Oralsexmod 2.37 by Pinkfairie");
    register_clcmd("say /Suckdick","suckdick",-1);
    register_clcmd("say /Lickpussy","lickpussy",-1);
    register_clcmd("say /bang","bang",-1);
    register_clcmd("say /StopSuckdick","stopsuckdick",-1);
    register_clcmd("say /stoplickpussy","stoplickpussy",-1);
    register_clcmd("say /stopbang","stopbang",-1);
}
	public suckdick(id) {
	client_print(id, print_chat, "You start sucking on your partners dick.")
	client_cmd(id, "+duck")
	set_user_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16);
	emit_sound(id, CHAN_VOICE, "cheese.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_user_maxspeed(id, 1.0)
	client_cmd(id, "say /me sucks on dick")
	set_task(2.0, "stopsuckdick", id)
}
	public stopsuckdick(id) {
	client_print(id, print_chat, "You have stoped sucking on your partners dick.")
	client_cmd(id, "-duck")
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,0);
	set_user_maxspeed(id, 320.0)
}
	public lickpussy(id) {
	client_print(id, print_chat, "You start licking on your partners pussy.")
	client_cmd(id, "+duck")
	set_user_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16);
	emit_sound(id, CHAN_VOICE, "cheese.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_user_maxspeed(id, 1.0)
	client_cmd(id, "say /me licks on pussy")
	set_task(2.0, "stoplickpussy", id)
}
	public stoplickpussy(id) {
	client_print(id, print_chat, "You have stoped licking on your partners pussy.")
	client_cmd(id, "-duck")
	client_cmd(id, "say Mmm.. tastey.")
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,0);
	set_user_maxspeed(id, 320.0)
}

	public bang(id) {
	set_task(0.1, "stopfucking", id)
	set_task(0.2, "noforward", id)
	set_task(0.3, "back", id)
	set_task(0.4, "noback", id)
	set_task(0.5, "stopfucking", id)
	set_task(0.6, "noforward", id)
	set_task(0.7, "back", id)
	set_task(0.8, "noback", id)
	set_task(0.9, "stopfucking", id)
	set_task(1.0, "noforward", id)
	set_task(1.1, "back", id)
	set_task(1.2, "noback", id)
	set_task(1.3, "stopfucking", id)
	set_task(1.4, "noforward", id)
	set_task(1.5, "back", id)
	set_task(1.6, "noback", id)
	set_task(1.7, "stopfucking", id)
	set_task(1.8, "noforward", id)
	set_task(1.9, "back", id)
	set_task(2.0, "noback", id)
	set_task(2.1, "stopfucking", id)
	set_task(2.2, "noforward", id)
	set_task(2.3, "back", id)
	set_task(2.4, "noback", id)
	set_task(2.5, "stopfucking", id)
	set_task(2.6, "noforward", id)
	set_task(2.7, "back", id)
	set_task(2.8, "noback", id)
	set_user_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,16);
	client_print(id, print_chat, "You start fucking on that dick or banging in that pussy")
	client_cmd(id, "say /me Bangs Bangs Bangs")
	client_cmd(id, "say Ahh Harder!!!")
	set_task(3.0, "stopbang", id)

}
	public stopbang(id) {
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,0);
	client_print(id, print_chat, "You stop fucking on that dick or banging in that pussy")
	client_cmd(id, "say Get me a douche bag QUICK!")
}
	public stopfucking(id) {
	client_cmd(id, "+forward")
}
	public noforward(id) {
	client_cmd(id, "-forward")
}
	public back(id) {
	client_cmd(id, "+back")
}
	public noback(id) {
	client_cmd(id, "-back")
}

  public plugin_precache() {
  precache_sound( "cheese.wav")
}