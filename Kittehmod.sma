/*************************************
*
* Kitten Mod! ^_^
* Version 1.1b
*
* Developed by Aryel 'DfKimera' Tupinambá
*   http://www.aryel-tupinamba.com
*   Slight Modifying By Kate, Locate me At, l.s.o@hotmail.com :)
*   Kate's Site: www.theicecave.net/kate, (New Forums Ariving soon)
* Licensed with Creative Commons
*   http://creativecommons.org/licenses/by-nc-sa/3.0/
*************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>

public client_init() {
   register_plugin("Kitten Mod","1.1b","DfKimera");
   
   register_clcmd("say /scratch","client_scratch");

}

public client_scratch(id) {
   new target, body, targetname[32], playername[32];
   
   // Get who the player is aiming
   get_user_aiming(id,target,body,512);
   
   if(!target) { // If there's no one
      return PLUGIN_HANDLED; // Cancel it
   }
   
   // Gets player and target's name
   get_user_name(target,targetname,31);
   get_user_name(id,playername,31);
   
   // Send the messages
   client_print(id,print_chat,"You have scratched %s!",targetname);
   client_print(target,print_chat,"%s Scratches You, And you Start Bleeding.",playername);
   
   // Apply fake damage to player
   fakedamage(target, "player", 10.0, 4);
   fakedamage(target, "player", 10.0, 4);
   
   return PLUGIN_HANDLED;
}

