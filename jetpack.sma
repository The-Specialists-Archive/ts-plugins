/* AMX Mod Script
  Revamped Jetpack v3.0. Originally done by Lazy. Reworked by sambro.

  Based on Lazy's original Jetpack. Jetpack thrust moves in the direction you are pointed at now.
  Added the sound effects from Natural Selection (woot :P). Cleaned the code up, commented it. Etc.
  Took out the armour cost, atm it's free, and can go as long as you like, my players thought this was
  better too. So meh! :P I left the UTIL_TextMsg function in, even though it's just extra unnecessary code.
  I spose it will enlighten people as to how the client_print REALLY works (ooh, conspiracy! :P)

  mp_jetpack: Enabled/deisables jetpacks on the server.
  jetpack, /jetpack, say jetpack, say /jetpack: All of these turn on the jetpack (might as well give em a choice :D)
*/

#include <amxmodx>
#include <fun>
#include <engine>

new bool:jetpack_status[32]
new gmsgTextMsg
new smokesprite

//This function is called a "callback". It gets called by AMXX at certain special times. In this case, it is being called
//when the server is starting up. AMXX needs to know about all it's plugins before hand. So it calls this function to allow
//us to tell it about our plugin, what commands and cvars, what events it hooks into etc.
public plugin_init()
{
  //Register the plugin with AMXX.
  register_plugin("Jetpack", "3.0", "sambro.");

  //All cvars and cmds will be registered here.
 //All cvars and cmds will be registered here.
  register_cvar("mp_jetpack", "1", FCVAR_SERVER);      //Allows admin to restrict jetpack usage.
  register_clcmd("jetpack", "CMD_Jetpack", ADMIN_LEVEL_E, "");    //Allows client to engage jetpack.
  register_clcmd("/jetpack", "CMD_Jetpack", ADMIN_LEVEL_E, "");  //Allows client to engage jetpack.
  register_clcmd("say jetpack", "CMD_Jetpack", ADMIN_LEVEL_E, "");  //Allows client to engage jetpack.
  register_clcmd("say /jetpack", "CMD_Jetpack", ADMIN_LEVEL_E, ""); //Allows client to engage jetpack.

  //The ID of the Text Message message :P Woulda just been easier to use client_print.... Dunno what Lazy was thinking?
  gmsgTextMsg = get_user_msgid("TextMsg")
}

//This is where we can precache any specials files we may use in this plugin. For e.g, sounds, models, sprites, etc.
//It must be done here, as this gets called when the server is starting up, and precaching everything will need.
public plugin_precache()
{
  //Precache sounds here.
  precache_sound("weapons/357_cock1.wav");	//The clicking sound when you turn jetpack on.
  precache_sound("jetpack.wav");			//The whirring sounds when using jetpack, courtesy of Natural selection!

  //The smoke sprite that we create behind us when using jetpack.
  smokesprite = precache_model("sprites/blood_smoke.spr");
}

//This is a callback function, it gets called by AMXX when a client disconnects from the server.
public client_disconnect(id)
{
  //Did this player have their jetpack turned on when they disconnected?
  if (jetpack_status[id])
  {
    remove_task(id + 500);		//Yep. Obviously we should stop the task, saves wasted CPU obviously :P
  }
}

//This is another callback function, it gets called by AMX when a client connects to the server.
public client_connect(id)
{
  jetpack_status[ id ] = false;		//They don't have their jetpack engaged yet.
}

//A wrapper function to send a text to the client. client_print is identical to this...
public UTIL_TextMsg(id, message[], msg_type)
{
  //Flags the HL engine, tells it we're beginning to send an MSG.
  message_begin(MSG_ONE, gmsgTextMsg, { 0, 0, 0 }, id);
  write_byte(msg_type);		//The message type.
  write_string(message);	//The actual msg.
  message_end();		//We're finished with the msg.
}

//This function creates the smoke effect you see when using the jetpack.
public smoke_effect(id)
{
  new origin[3];
  get_user_origin(id, origin, 0);
  origin[2] = origin[2] - 10;

  message_begin(MSG_BROADCAST, SVC_TEMPENTITY);		//MSG_BROADCAST sends to all players and doesn't care if it fails.
  write_byte(17);
  write_coord(origin[0]);
  write_coord(origin[1]);
  write_coord(origin[2]);
  write_short(smokesprite);
  write_byte(10);
  write_byte(150);
  message_end();
}

//This function does all the jetpack goody stuff.
public jetpackTask(args[])
{
  //We'll store the velocity in here later.
  new Float:velocity[3];

  //Store the id in a var for easier access.
  new id = args[0];

  //Max speed of the jetpack thrust. I might make this modifiable later.
  new Float:maxThrust = get_user_maxspeed(id) * 2.0;

  //Is the user still alive?
  if(!is_user_alive(id))
  {
    //Nope, he musta died sometime before the last time we updated jetpack.
    //We can flag him as a jumpjet-pundit, and remove his jetpack task.
    jetpack_status[id] = false;
    remove_task(id + 500);
		
    return PLUGIN_HANDLED;
  }

  //Is the user jumping at this moment?
  if(get_user_button(id) & IN_JUMP)
  {
    //He is indeed. This is where we can start updating velocity. We can do basically anything we want here.

    //We'll base direction on where they're pointing their xhair, but give them a gradual rise, unelss they're pointing downwards.
    new Float:pointVelocity[3];
    VelocityByAim(id, floatround(maxThrust), pointVelocity);

    velocity[0] = pointVelocity[0];
    velocity[1] = pointVelocity[1];
    velocity[2] = pointVelocity[2];

    set_user_velocity(id, velocity);

    //What jumpjet would be complete without smoke effects?!
    smoke_effect(id);

    //BZZZZZZZZZZZEWWWWWWWWW.. Etc etc. A Jumpjet wouldn't be a jumpjet without sound either.
    
  }

  return PLUGIN_CONTINUE;
}

//This function gets called when someone types jetpack in their console.
//It was registered in the plugin_init() callback function.
public CMD_Jetpack(id)
{
  //Is jetpack enabled or not? Let's find out with the cvar we registered earlier (plugin_init)
  new status = get_cvar_num("mp_jetpack");

  //Is the player enslaved to the mortal coil we fondly call Earth?
  new alive = is_user_alive(id);

  //First let's check to see if jetpack is even enabled on this server.
  if(status)
  {
    //Now let's see if jetpack is already enabled on this player. If it is, let's deactivate it.
    if(jetpack_status[id])
    {
      //Set their flag to false (not jetpacking :P)
      jetpack_status[id] = false;

      //Stop running the jetpack task. We obviously don't need it anymore :P
      remove_task(id + 500);

      //Tell the user their jetpack is stopped, with the totally-useless UTIL_TextMsg function.
      UTIL_TextMsg(id, "You disabled your Jetpack!", print_center);
      //client_print(id, print_center, "Siperman Powers Disabled");		<--- what it SHOULD be.

      //Play the "cock" sound (lol), to let the user (and those around him) know that he's using/not using the jetpack.
      emit_sound(id, CHAN_WEAPON, "weapons/357_cock1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

      //This tells AMX that we did alright. If we didn't return this, they'd get a message in conlse saying "Unknown command".
      return PLUGIN_HANDLED
    }

    //Is the user even alive?
    if (!alive)
    {
      //Nope. Tell them to be patient until the afterlife.
      UTIL_TextMsg(id, "Jetpack only works for mortal beings.", print_center);

      return PLUGIN_HANDLED;
    }

    //Jetpack on. Rawr.		
    UTIL_TextMsg(id, "Jetpack Enabled!", print_center);

    //Play the "cock" sound (lol), to let the user (and those around him) know that he's using/not using the jetpack.
    emit_sound(id, CHAN_WEAPON, "weapons/357_cock1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

    //Flag the user as a jetpack-jumper.
    jetpack_status[id] = true;

    //We pass args to our "task" via an array.
    new args[1]; args[0] = id;

    //Begin our "task". this task gets called ever millisecond, and updates user velocity if he's jumping.
    //Layman terms: it makes him go plenty high if he's jumping, and does a pretty smoke thing behind him!
    set_task(0.1, "jetpackTask", id + 500, args, 1, "b")
  }

  //This code executes if the jetpack isn't enabled.
  else 
  {
    //Tell the user our sexy plugin has been snatched from their grasp.
    UTIL_TextMsg(id, "Jetpack disabled on server. Flame your local admin.", print_center)
  }

  //We're done.
  return PLUGIN_HANDLED
}

