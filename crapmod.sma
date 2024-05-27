
  //Pinkfairie's TS Crapmod 0.17 by Pinkfairie
  //
  //I made this for my server like my 2nd plugin, have fun?
  //Theres probably some bugs or it may not even work because i accdently deleted the original,
  //So i just modified piss real quick to release it
  
  #include <amxmodx>
  #include <fun>
  #include <amxmisc> 
  #include <engine>
  #include <fakemeta>

  new Float:lastcraptime[33]


  public shit(id) {
    if(get_gametime() < lastcraptime[id] + 120) {
    client_print(id, print_chat, "Sorry but you have recently took a shit, meaning you dont have much shit coming")
    return PLUGIN_HANDLED
    }
    lastshittime[id] = get_gametime()    
    set_task(1.0, "stopshit", id)
    set_task(0.1, "duck", id)
    set_task(1.0, "noduck", id)
    client_print(id, print_chat, "[CRAP] You unzip, pull down your pants and shit.")
    emit_sound(id, CHAN_VOICE, "misc/dookie3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
    emit_sound(id, CHAN_VOICE, "sound/misc/dookie3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
    emit_sound(id, CHAN_VOICE, "dookie3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
    new ent = create_entity("info_target");
    entity_set_model(ent,"models/dookie2.mdl");
    new Float:userorigin[3];
    entity_get_vector(id,EV_VEC_origin,userorigin);
    entity_set_vector(ent,EV_VEC_origin,userorigin);
    drop_to_floor(ent); 
    set_user_maxspeed(id, 100.0)
    set_user_rendering(id,kRenderFxGlowShell,255,180,0,kRenderNormal,16);
    return PLUGIN_HANDLED;
  }
  public stopshit(id) {
    client_print(id, print_chat, "[CRAP] You zip up, and now you are done shitting.")
    set_user_maxspeed(id, 320.0)
    set_user_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,0);
    return PLUGIN_HANDLED;
}
	public duck(id) {
  	client_cmd(id, "+duck")
}
	public noduck(id) {
  	client_cmd(id, "-duck")
}

  public plugin_precache() {
  precache_sound( "misc/dookie3.wav")
  precache_sound( "sound/misc/dookie3.wav")
  precache_sound( "dookie3.wav")
  precache_model("models/dookie2.mdl")
 }

  public plugin_init() {
    register_plugin("Crapmod","0.17","Pinkfairie");
    console_print(0,"* Loaded Pinkfairie's TS Crapmod 0.17 by Pinkfairie");
    register_clcmd("say /shit","shit",-1);
    register_clcmd("say /rofflemywoffle","stopshit",-1); 
 
}