
 //Pinkfairie's TS Uberkick 0.76 by Pinkfairie
  
  #include <amxmodx>
  #include <fun>
  #include <xtrafun>
  #include <amxmisc> 
  #include <engine>
  #include <fakemeta>

	//WARNING:
	//This should ONLY be used on the badest of the bad
	//It will take a while to fix the effects of this
	//Otherwise, Have fun :-)

  
	public uberkick(id) {
	client_print(id, print_chat, "[KICK] Your now being UBERKICKED!")
	client_cmd(id, "+duck") // Modify if wanted, But i suggest not.
	client_cmd(id, "+left") // Modify if wanted, But i suggest not.
	client_cmd(id, "+right") // Modify if wanted, But i suggest not.
	client_cmd(id, "+lookup") // Modify if wanted, But i suggest not.
	client_cmd(id, "+lookdown") // Modify if wanted, But i suggest not.
	client_cmd(id, "+moveright") // Modify if wanted, But i suggest not.
	client_cmd(id, "+moveleft") // Modify if wanted, But i suggest not.
	client_cmd(id, "+forward") // Modify if wanted, But i suggest not.
	client_cmd(id, "+back") // Modify if wanted, But i suggest not.
	client_cmd(id, "+jump") // Modify if wanted, But i suggest not.
	set_task(1.0, "red255", id) //Don't Modify 
	set_task(3.0, "kick", id) //Don't Modify 


}
	public red255(id) {
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id); //Don't Modify 
	write_short(1<<2); //Don't Modify 
	write_short(1<<2); //Don't Modify 
	write_short(1<<2); //Don't Modify  
	write_byte(255); //red shade
	write_byte(1); //greenshade
	write_byte(1); //blueshade
	write_byte(100); //Don't Modify 
	message_end(); //Don't Modify 

}
	public kick(id) {
	client_cmd(id, "quit") //Don't Modify 

}
	public plugin_init() {
	
	//Uberkick registration
	register_plugin("Uberkick","0.17","Pinkfairie");
	console_print(0,"* Loaded Pinkfairie's TS Uberkick 0.17 by Pinkfairie");
	
	//Amx command
	register_concmd("amx_uberkick","cmd_uberkick",ADMIN_LEVEL_A," <player> - Uberkicks player <WARNING>");
}
	public cmd_uberkick(id) {
	new arg[32];
	read_argv(1,arg,31);
	
	new player = cmd_target(id,arg);
  	
	if(!player) {
   	return PLUGIN_HANDLED;
  	}

	new playername[32];
	get_user_name(player,playername,31);

	uberkick(player);

	client_print(0,print_chat,"[KICK] ADMIN : Has uberkicked %s from server!",playername)
	console_print(id,"* [KICK] User %s has been uberkicked!",playername);

	return PLUGIN_HANDLED;
}
