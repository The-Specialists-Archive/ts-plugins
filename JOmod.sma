
  //Pinkfairie's TS Jackoffmod 0.17 by Pinkfairie
  //
  //Yet another sick/fun Plugin by me
  //Type /Jackoff For a 1 minute speed boost

  
  #include <amxmodx>
  #include <fun>
  #include <xtrafun>
  #include <amxmisc> 
  #include <engine>
  #include <fakemeta>

  new Float:lastjackofftime[33]

  public plugin_init() {
    register_plugin("Jackoffmod","0.17","Pinkfairie");
    console_print(0,"* Loaded Pinkfairie's TS Jackoffmod 0.17 by Pinkfairie");
    register_clcmd("say /cum","jackoff",-1);
    register_clcmd("say /stopcum","stopjackoff",-1);  
}
	public jackoff(id) {
	if(get_gametime() < lastjackofftime[id] + 700) {
	client_print(id, print_chat, "[JACKOFF]Sorry but you have recently jacked off, meaning you dont have much cum coming.")
	return PLUGIN_HANDLED
	}
	lastjackofftime[id] = get_gametime()
	set_user_maxspeed(id, 550.0)
	client_print(id, print_chat, "[JACKOFF]You start to jack off and damn does it feel good, You have a speed bost(60 sec).")
	client_cmd(id, "say /me jacks off, and out comes cum!")
	new ent = create_entity("info_target");
	entity_set_model(ent,"models/cum1.mdl");
	new Float:userorigin[3];
	entity_get_vector(id,EV_VEC_origin,userorigin);
	entity_set_vector(ent,EV_VEC_origin,userorigin);
	drop_to_floor(ent);
	set_task(60.0, "stopjackoff", id)
	return PLUGIN_HANDLED;
}
	public stopjackoff(id) {
	set_user_maxspeed(id, 320.0)
	client_print(id, print_chat, "[JACKOFF]Your all out of cum :-( ")
}
  public plugin_precache() {
  precache_model("models/cum1.mdl")
}