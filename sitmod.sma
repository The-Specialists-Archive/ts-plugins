 /////////////////////////////////
 //       Coded for RDRP        //
 //     Modify by Shin Lee      //
 //     Thanks to Avalanche     //
 /////////////////////////////////

 #include <amxmodx>

 new sitting[33];

 public plugin_init()
 {
	register_plugin("SitMod","0.10","Avalanche");
	register_clcmd("say /sit","sit");
 }

 public client_putinserver(id)
 {
	sitting[id] = 0;
 }

 public sit(id)
 {
	if(sitting[id])
	{
		sitting[id] = 0;
		client_cmd(id,"say /me stands up!;wait;-duck");
		client_print(id,print_chat,"[SITMOD] You stand up!");
	}
	else
	{
		sitting[id] = 1;
		client_cmd(id,"say /me sits down!;wait;+duck");
		client_print(id,print_chat,"[SITMOD] You sit down!");
	}

	return PLUGIN_HANDLED;
 }
