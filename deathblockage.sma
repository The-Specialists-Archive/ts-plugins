
  #include <amxmodx>
  #include <amxmisc>
  #include <engine>

  /////////////////////////////////////////////////////////
  // AMXX CONSOLE COMMANDS
  ////////////////////////////////////////////////////////

  // death blocking command
  public deathblock(id,level,cid) {
    if(!cmd_access(id,level,cid,1)) { // no access
      return PLUGIN_HANDLED;
    }

    new arg1, args[2];
    read_args(args,1); // read argument
    arg1 = str_to_num(args); // convert to number

    // no value at all
    if(equal(args,"")) {
      console_print(id,"Death blocking is currently %s",get_cvar_num("mp_deathblock") ? "enabled" : "disabled");
      return PLUGIN_HANDLED;
    }

    if(arg1 <= 0) { // disable
      set_cvar_num("mp_deathblock",0);
      console_print(id,"Death blocking has been disabled");
      set_msg_block(get_user_msgid("DeathMsg"),BLOCK_NOT);

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: deathblock 0")
        case 2: client_print(0,print_chat,"ADMIN %s: deathblock 0",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" deathblock 0",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }
    else if(arg1 >= 1) { // enable
      set_cvar_num("mp_deathblock",1);
      console_print(id,"Death blocking has been enabled");
      set_msg_block(get_user_msgid("DeathMsg"),BLOCK_SET);

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: deathblock 1")
        case 2: client_print(0,print_chat,"ADMIN %s: deathblock 1",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" deathblock 1",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }

    return PLUGIN_HANDLED;
  }

  // force respawn command
  public forcerespawn(id,level,cid) {
    if(!cmd_access(id,level,cid,1)) { // no access
      return PLUGIN_HANDLED;
    }

    new arg1, args[2];
    read_args(args,1); // read argument
    arg1 = str_to_num(args); // convert to number

    // no value at all
    if(equal(args,"")) {
      console_print(id,"Force respawn is currently %s",get_cvar_num("mp_forcerespawn") ? "enabled" : "disabled");
      return PLUGIN_HANDLED;
    }

    if(arg1 <= 0) { // disable
      set_cvar_num("mp_forcerespawn",0);
      console_print(id,"Force respawn has been disabled");

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: forcerespawn 0")
        case 2: client_print(0,print_chat,"ADMIN %s: forcerespawn 0",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" forcerespawn 0",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }
    else if(arg1 >= 1) { // enable
      set_cvar_num("mp_forcerespawn",1);
      console_print(id,"Force respawn has been enabled");

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: forcerespawn 1")
        case 2: client_print(0,print_chat,"ADMIN %s: forcerespawn 1",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" forcerespawn 1",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }

    return PLUGIN_HANDLED;
  }

  // fade to black on death command
  public fadetoblack(id,level,cid) {
    if(!cmd_access(id,level,cid,1)) { // no access
      return PLUGIN_HANDLED;
    }

    new arg1, args[2];
    read_args(args,1); // read argument
    arg1 = str_to_num(args); // convert to number

    // no value at all
    if(equal(args,"")) {
      console_print(id,"Fade to black on death is currently %s",get_cvar_num("mp_fadetoblack") ? "enabled" : "disabled");
      return PLUGIN_HANDLED;
    }

    if(arg1 <= 0) { // disable
      set_cvar_num("mp_fadetoblack",0);
      console_print(id,"Fade to black on death has been disabled");

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: fadetoblack 0")
        case 2: client_print(0,print_chat,"ADMIN %s: fadetoblack 0",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" fadetoblack 0",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }
    else if(arg1 >= 1) { // enable
      set_cvar_num("mp_fadetoblack",1);
      console_print(id,"Fade to black on death has been enabled");

      // get name
      new playername[32];
      get_user_name(id,playername,31);

      // get authid
      new authid[32];
      get_user_authid(id,authid,31);

      switch(get_cvar_num("amx_show_activity")) {
        case 1: client_print(0,print_chat,"ADMIN: fadetoblack 1")
        case 2: client_print(0,print_chat,"ADMIN %s: fadetoblack 1",playername)
      }

      log_amx("Cmd: ^"%s<%d><%s><>^" fadetoblack 1",playername,get_user_userid(id),authid);

      return PLUGIN_HANDLED;
    }

    return PLUGIN_HANDLED;
  }

  /////////////////////////////////////////////////////////
  // EVENTS AND OTHER CRAP(OLA)
  ////////////////////////////////////////////////////////

  // TSMessage event (called on "Press Fire to Play!")
  public tsmessage(id) {
    if(is_user_alive(id) == 0 && get_cvar_num("mp_forcerespawn") >= 1) { // if dead (might be called other times)
      set_task(1.0,"pressfire",id); // wait a second and then "Press Fire"
    }
  }

  // makes user attack, used to respawn
  public pressfire(id) {
    if(is_user_connected(id) && !access(id,ADMIN_LEVEL_A)) {
      client_cmd(id,"+attack; wait; -attack");
    }
  }

  // DeathMSG event (called on someone's death)
  public deathmsg() {
    if(get_cvar_num("mp_fadetoblack") >= 1 && is_user_connected(read_data(2))) { // if we are fading to black on death
      set_task(2.5,"fade",read_data(2)); // delay for dead body animation
    }
  }

  // actually make user's screen fade to black
  public fade(id) {
    if(is_user_connected(id) == 1 && is_user_alive(id) == 0 && !access(id,ADMIN_LEVEL_A)) {
      message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
      write_short(~0); // duration, ~0 is max
      write_short(~0); // hold time, ~0 is max
      write_short(1<<12); // flags, no idea wtf 1<<12 is
      write_byte(0); // red, 0 for black
      write_byte(0); // green, 0 for black
      write_byte(0); // blue, 0 for black
      write_byte(255); // alpha, 255 for total black
      message_end();

      set_task(15.0,"fade",id); // reset it, screenfade only last for so long

      // techincally we could just do the ScreenFade message in the tsmessage(id)
      // function, but this way we can allow the 2.5 seconds delay for the dying
      // animation of your player. you know everyone loves the dying animation.
    }
  }

  // plugin modules, fruity!
  public plugin_modules() {
    require_module("Engine");
  }

  // plugin initiation, aaarrrrr!
  public plugin_init() {
    register_plugin("DeathBlockage","0.11","Avalanche");
    console_print(0,"* Loaded DeathBlockage 0.11 by Avalanche");

    // events
    register_event("TSMessage","tsmessage","b"); // "Press Fire to Play!"
    register_event("DeathMsg","deathmsg","a","2!0"); // dead person--party!

    // console commands
    register_concmd("amx_deathblock","deathblock",ADMIN_LEVEL_A,"<0|1> - turns death blocking on or off");
    register_concmd("amx_forcerespawn","forcerespawn",ADMIN_LEVEL_A,"<0|1> - turns force respawn on or off");
    register_concmd("amx_fadetoblack","fadetoblack",ADMIN_LEVEL_A,"<0|1> - turns fade to black on death on or off");

    // cvars
    register_cvar("mp_deathblock","0",FCVAR_PRINTABLEONLY);
    register_cvar("mp_forcerespawn","1",FCVAR_PRINTABLEONLY);
    register_cvar("mp_fadetoblack","1",FCVAR_PRINTABLEONLY);

    // handle deathblock on load
    if(get_cvar_num("mp_deathblock") <= 0) { // disable
      set_msg_block(get_user_msgid("DeathMsg"),BLOCK_NOT);
    }
    else if(get_cvar_num("mp_deathblock") >= 1) { // enable
      set_msg_block(get_user_msgid("DeathMsg"),BLOCK_SET);
    }

  }
