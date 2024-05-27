
/******************************************************************************************************************
*  AMX Mod script. 
* 
*  Ghost Mode Script 
*  Version 1.4 
*  by Kiosk3 
*  email: GeminiMissiles@aol.com 
* 
*  Changes In 1.4
*
*  -Changed how invisibility works, thanks to jedi's plugin, im using transparency instead of normal.
*
*  Changes In 1.3
*
*  -Added On/Off CSAY Messages
*
*  Changes In 1.2
*
*  -Fixed the speed glitch where if you have it on yourself everyone gets it
*
*  Changes In 1.1
*  
*  -Changed on from ghost to amx_ghost
*  -Changed off from unghost to amx_unghost
*  -Fixed godmode, you will not lose godmode untill you hit amx_unghost
*  -Fixed speed, you will not lose speed while switching weapons
*
*  Description: 
*
*  This plugin turns your admins into a ghost. 
*  What it does is this, records users speed, changes it to 1000, 
*  turns on godmode, and makes the person invisible. 
*  When you turn it off it reverts to your old speed, ungods and makes you visible. 
*  Only admins can use it, and only can use it on themselves. 
*  This is great if you want to run around with a knife scaring people, or to watch for hackers 
*  
*  Console Commands: 
* 
*  amx_ghost - This turns it on. (Turns on invisibility, godmode, and speed.) 
*  amx_unghost - This turns it off. (Turns off invisibility, godmode, and speed.) 
* 
*  Future Plans: 
*  
*  None.
******************************************************************************************************************/ 


#include <amxmodx> 
#include <amxmisc> 
#include <fun>

#define BPID 341219 
#define MAX_TEXT_LENGTH 512
#define MAX_NAME_LENGTH 32 

new Float:oldspeed[33] 
new ccolor[33] 
new IsGhost[33] 

public changecolor(ids[]) { 
new toghost = ids[0] 
switch(ccolor[toghost]) { 
case 0: { 
set_user_rendering(toghost,kRenderFxNone,0,0,0, kRenderTransTexture,0) 
ccolor[toghost] = 1 
} 
case 1: { 
set_user_rendering(toghost,kRenderFxNone,0,0,0, kRenderTransTexture,0)
ccolor[toghost] = 2 
} 
case 2: { 
set_user_rendering(toghost,kRenderFxNone,0,0,0, kRenderTransTexture,0)
ccolor[toghost] = 0 
} 
} 
} 

public admin_ghost(id,level,cid) 
{ 
if (!cmd_access(id,level,cid,1)) 
return PLUGIN_HANDLED 
new params[3]
client_print(id,print_chat,"[AMXX]: You are now a ghost")
params[0] = id 
IsGhost[id] = 1 
oldspeed[id] = get_user_maxspeed(id) 
set_user_maxspeed(id,1000.0) 
set_user_godmode(id,1)
set_user_footsteps (id , 1)
set_task(0.2, "changecolor", BPID + id, params, 2, "b")
return PLUGIN_HANDLED 
} 

public admin_unghost(id, level, cid) 
{ 
if (!cmd_access(id,level,cid,1)) 
return PLUGIN_HANDLED 
IsGhost[id] = 0
client_print(id,print_chat,"[AMXX]: You are no longer a ghost.")
set_user_maxspeed(id,oldspeed[id]) 
set_user_godmode(id,0) 
set_user_footsteps (id , 0)
set_user_rendering(id,kRenderFxNone,255,255,255, kRenderNormal,16)
remove_task(BPID + id) 
return PLUGIN_HANDLED 
} 

public switchweapon(id)
{ 
if(IsGhost[id]) set_user_maxspeed(id,1000.0) 
return PLUGIN_CONTINUE 
} 

public round_start(id) 
{ 
if(IsGhost[id]) set_user_godmode(id,1) 
return PLUGIN_CONTINUE 
}

public client_connect(id){ 
IsGhost[id] = 0 
return PLUGIN_CONTINUE 
} 

public client_disconnect(id){ 
IsGhost[id] = 0 
return PLUGIN_CONTINUE 
} 

public display_msg(msg[],r,g,b) 
{ 

} 

public plugin_init() { 
register_plugin("Ghost Mode","1.4","Kiosk3") 
register_concmd("amx_ghost","admin_ghost") 
register_concmd("amx_unghost","admin_unghost") 
register_event("CurWeapon","switchweapon","be")
register_event("ResetHUD", "round_start", "be")
return PLUGIN_CONTINUE 
} 




