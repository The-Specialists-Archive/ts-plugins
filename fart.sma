 /////////////////////////////////
 //       Coded for RDRP        //
 //         by Shin Lee         //
 //   www.red-dragon-rp.de.vu   //
 //     effects by Shin Lee     //
 // need help to fix puke effect//
 /////////////////////////////////

 #include <amxmodx>

 new fartsmoke
 new pukemodel

 public plugin_init()
 {
	register_plugin("Fartmod","x.26","Shin");
	register_clcmd("say /fart","fart_action");
        register_clcmd("say /puke","puke_action");
 }
//fart action
 public fart_action(id)
 {
	
	{
		client_cmd(id,"say /me Farts Loudly");
		client_print(id,print_chat,"[RD] You Fart Loud!");
                emit_sound(id,CHAN_VOICE,"fart.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
                fart_effect(id)
	}

	return PLUGIN_HANDLED;
}
//fart effect
  public fart_effect(id)
{
         new origin[3];
         get_user_origin(id, origin, 0);
         origin[1] = origin[1] -10;
 
         message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
         write_byte(17);
         write_coord(origin[0]);
         write_coord(origin[1]);
         write_coord(origin[2]);
         write_short(fartsmoke);
         write_byte(10);
         write_byte(150);
         message_end();

   	 return PLUGIN_HANDLED;
}				

//puke action
 public puke_action(id)
 {
	
	{
		client_cmd(id,"say /me pukes!");
		client_print(id,print_chat,"[RD] You puked!");
                emit_sound(id,CHAN_VOICE,"puke.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
                puke_effect(id)
	}

	return PLUGIN_HANDLED;
}
//puke effect
  public puke_effect(id)
{
         new origin[3];
         get_user_origin(id, origin, 0);
         origin[1] = origin[1] -10;
 
         message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
         write_byte(17);
         write_coord(origin[0]);
         write_coord(origin[1]);
         write_coord(origin[2]);
         write_short(pukemodel);
         write_byte(10);
         write_byte(150);
         message_end();

   	 return PLUGIN_HANDLED;
}	

public plugin_precache() 
{ 
//sound
	if (file_exists("sound/fart.wav"))
		precache_sound( "fart.wav") 
//models,sprites
        fartsmoke = precache_model("sprites/xsmoke1.spr");        
        pukemodel = precache_model("models/puke_puddle.mdl");
   	return PLUGIN_CONTINUE 
}
