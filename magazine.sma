/*=======================================*\
|* Magazine Mod                               *|
|*=======================================*|
|* ©Copyright 2006 by Shin Lee *|
\*=======================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <string>
#include <fun>

#define Author	"Shin Lee"
#define Version	"1.0"
#define Plugin	"Magazine Mod"


public plugin_init()
{

	register_plugin(Plugin,Version,Author);
	
	register_srvcmd("item_magazine","item_magazine");
	
	
	set_task(1.0,"timer",0,"",0,"b");
	
		
}

// USAGE: item_magazine <id> filename header type
// EXAMPLE: item_magazine <id> newsday.txt "Newsday Paper July 1st" newspaper
// create a new folder in yur od directory and name t to "mags"
public item_magazine()
{
	new arg[32],filename[32],header[32],name[32],id
	read_argv(1,arg,31)
	read_argv(2,filename,31)
	read_argv(3,header,31)
	read_argv(4,name,31)
	id = str_to_num(arg)
	// Use the magazine!
	show_motd(id,filename,header)
	client_print(id,print_chat,"[%s] You are reading a %s!",strtoupper(name),name);
        client_cmd(id,"say /me reads a Newspaper!");

	return PLUGIN_HANDLED;
}

public plugin_credits(id)
{

	client_print(id,engprint_console,"/*=======================================*\^n");
	client_print(id,engprint_console,"|* Magazine Mod                             *|^n");
	client_print(id,engprint_console,"|*=======================================*|^n");
	client_print(id,engprint_console,"|* ©Copyright 2006 by Shin Lee *|^n");
	client_print(id,engprint_console,"\*=======================================*/^n");
	
	return PLUGIN_HANDLED;
}