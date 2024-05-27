
 //Pinkfairie's TS Suicide by Pinkfairie
 //
 //This should work for all Half-life Mods
 //

  #include <amxmodx>
  #include <fun>
  #include <xtrafun>
  #include <amxmisc> 

	public suicide(id) {
	client_print(id, print_chat, "[SUICIDE]---You can't take life anymore---")
	client_cmd(id, "say me cuts his wrists")
	client_cmd(id, "say shout I CAN'T TAKE LIFE ANYMORE, CUT MY WRISTS AND BLACK MY EYES, I'M A HELPSLES EMO POSER!")
	set_task(3.0, "cut1", id)
	set_task(4.0, "cut2", id)
	set_task(5.0, "cut3", id)
	set_task(5.9, "cut5", id)
	set_task(6.0, "cut4", id)
  }
	public gunshot(id) {
	client_print(id, print_chat, "[SUICIDE]---You can't take life anymore---")
	client_cmd(id, "say /me shoots himself in the face!")
	client_cmd(id, "say shout I CAN'T TAKE LIFE ANYMORE, I'M GONNA FUCKEN PULL THE TRIGGER!")
	set_task(2.8, "shoot", id)
	set_task(2.9, "unshoot", id)
	set_task(3.0, "heal", id)

}
	public drink(id) {
	client_print(id, print_chat, "[SUICIDE]---You can't take life anymore---")
	client_cmd(id, "say /me drinks away")
	client_cmd(id, "say shout I CAN'T TAKE LIFE ANYMORE, I'M FUCKEN PASSIN OUT FROM WHISKEY")
	set_task(3.0, "heal", id)

}
	public heal(id) {
	new hp = get_user_health(id)
	set_user_health(id, hp -1000)
}
	public cut1(id) {
	new hp = get_user_health(id)
	set_user_health(id, hp -25)
	client_cmd(id, "say Ahh!")
	emit_sound(id, CHAN_VOICE, "knife_hitbody.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

	public cut2(id) {
	new hp = get_user_health(id)
	set_user_health(id, hp -25)
	client_cmd(id, "say Ahhhhh Bleed!")
	emit_sound(id, CHAN_VOICE, "knife_hitbody.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

	public cut3(id) {
	new hp = get_user_health(id)
	set_user_health(id, hp -25)
	client_cmd(id, "say Bleed motherfucker bleed!")
	emit_sound(id, CHAN_VOICE, "knife_hitbody.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

	public cut4(id) {
	new hp = get_user_health(id)
	set_user_health(id, hp -25)
	client_cmd(id, "say Ahhhhhhhhhhhhhhhhhhhhhhhhhhhhh!!!!!!!")
}
	public cut5(id) {
	client_cmd(id, "say Ahhhhhhhhhhhhhhhhhhhhhhhhhhhhh!!!!!!!")
	emit_sound(id, CHAN_VOICE, "knife_hitbody.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

	public shoot(id) {
	client_cmd(id, "+attack")
}

	public unshoot(id) {
	client_cmd(id, "-attack")
}
  public plugin_init() {
    register_plugin("sucicide","0.17","Pinkfairie");
    register_clcmd("say /cutwrists","suicide",-1);
    register_clcmd("say /suicide","gunshot",-1);  
    register_clcmd("say /drink","drink",-1); 
}
  public plugin_precache() {
  precache_sound( "knife_hitbody.wav")
 }