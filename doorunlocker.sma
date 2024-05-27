
 // Door (Un)locker 0.31 by Avalanche
 //
 // Lock doors, unlock doors, use doors,
 // give door keys, take door keys, view
 // list of players with key to this door...
 // all that good stuff in this plugin.

 #include <amxmodx>
 #include <amxmisc>
 #include <fakemeta>
 #include <engine>

 #define MAXDOORS 999 // max amount of doors

 new doorislocked[MAXDOORS]; // if door is locked
 new doorhaskey[33][MAXDOORS]; // if player has key for door

 new doorbuttonid[MAXDOORS]; // id of button entity for door (if it has one)
 new doorbuttontarget[MAXDOORS][64]; // target of button entity for door (if it has one)

 //////////////////////////////////////////////////////////////////////////////////////////
 // LOCKING A DOOR
 //////////////////////////////////////////////////////////////////////////////////////////
 public doorlock(id,level,cid) {
	/*if(!cmd_access(id,level,cid,1)) {
	return PLUGIN_HANDLED;
	}*/

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid)) { // if valid entity
		isdoor = is_door(doorid);
	}
	else {
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) {
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	// if this entity id exceeds our array size
	if(doorid > MAXDOORS-1) {
		client_print(id,print_chat,"* [DOOR] ERROR: Too many entities^n");
		return PLUGIN_HANDLED;
	}

	// if no key and not master admin
	if(doorhaskey[id][doorid] == 0 && !access(id,ADMIN_LEVEL_A)) {
		client_print(id,print_chat,"* [DOOR] You do not have a key for this door^n");
		return PLUGIN_HANDLED;
	}

	// if door is currenty unlocked
	if(doorislocked[doorid] == 0) {
		doorislocked[doorid] = 1;

		new mapname[256];
		get_mapname(mapname,255);
		strtolower(mapname);

		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%d=islocked",mapname,doorid);
		set_vaultdata(vaultstring,"1"); // set it in our vault

		new targetname[256];
		entity_get_string(doorid,EV_SZ_targetname,targetname,255);

		// if this door has a button
		if(!equal(targetname,"")) {
			new ent = find_ent_by_target(-1,targetname);

			if(is_valid_ent(ent)) { // if we found an entity
				entity_get_string(ent,EV_SZ_target,doorbuttontarget[doorid],63);
				entity_set_string(ent,EV_SZ_target,"");
				doorbuttonid[doorid] = ent;
			}
		}

		client_print(id,print_chat,"* [DOOR] Door is now locked^n");
	}
	else if(doorislocked[doorid] == 1) { // if door is locked
		client_print(id,print_chat,"* [DOOR] Door is already locked^n");
	}

	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // UNLOCKING A DOOR
 //////////////////////////////////////////////////////////////////////////////////////////
 public doorunlock(id,level,cid) {
	/*if(!cmd_access(id,level,cid,1)) {
	return PLUGIN_HANDLED;
	}*/

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid) > 0) { // if valid entity
		isdoor = is_door(doorid);
	}
	else { // if not a valid entity
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) { // if not really a door
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if this exceeds our array bounds
		client_print(id,print_chat,"* [DOOR] ERROR: Too many entities^n");
		return PLUGIN_HANDLED;
	}

	// if player doesn't have key and isn't master admin
	if(doorhaskey[id][doorid] == 0 && !access(id,ADMIN_LEVEL_A)) {
		client_print(id,print_chat,"* [DOOR] You do not have a key for this door^n");
		return PLUGIN_HANDLED;
	}

	// if door is unlocked
	if(doorislocked[doorid] == 1) {
		doorislocked[doorid] = 0;

		new mapname[256];
		get_mapname(mapname,255);
		strtolower(mapname);

		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%d=islocked",mapname,doorid);

		if(vaultdata_exists(vaultstring) == 1) {
			remove_vaultdata(vaultstring); // get it out of our vault
		}

		new targetname[256];
		entity_get_string(doorid,EV_SZ_targetname,targetname,255);

		// if it has a button
		if(doorbuttonid[doorid] > 0) {
			new ent = doorbuttonid[doorid];

			if(is_valid_ent(ent)) { // set button back to this door
				entity_set_string(ent,EV_SZ_target,doorbuttontarget[doorid]);
			}
		}

		client_print(id,print_chat,"* [DOOR] Door is now unlocked^n");
	}
	else if(doorislocked[doorid] == 0) { // if door unlocked
		client_print(id,print_chat,"* [DOOR] Door is already unlocked^n");
	}

	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // GIVING A DOOR KEY
 //////////////////////////////////////////////////////////////////////////////////////////
 public doorgivekey(id,level,cid) {
	if(!cmd_access(id,level,cid,1)) {
		return PLUGIN_HANDLED;
	}

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid)) { // if valid ent
		isdoor = is_door(doorid);
	}
	else { // if invalid entity
		console_print(id,"* [DOOR] Door is invalid or non-existant");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) { // if not a door entity
		console_print(id,"* [DOOR] Door is invalid or non-existant");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if exceeds our array
		console_print(id,"* [DOOR] ERROR: Too many entities");
		return PLUGIN_HANDLED;
	}

	new arg[256];
	read_args(arg,255);
	new playerid = cmd_target(id,arg,2);

	// if an invalid player
	if(!playerid) {
		return PLUGIN_HANDLED;
	}

	// if player does not have key
	if(doorhaskey[playerid][doorid] == 0) {
		doorhaskey[playerid][doorid] = 1;

		new steamid[256], mapname[256];
		get_user_authid(playerid,steamid,255);
		get_mapname(mapname,255);
		strtolower(mapname);

		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%s=%d=haskey",steamid,mapname,doorid);
		set_vaultdata(vaultstring,"1"); // store it in our vault

		new playername[256];
		get_user_name(playerid,playername,255);
		console_print(id,"* [DOOR] Door key has been given to %s for this door",playername);
	}
	else if(doorhaskey[playerid][doorid] == 1) {
		console_print(id,"* [DOOR] Door key is already owned by that player for this door");
	}

	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // TAKING A DOOR KEY
 //////////////////////////////////////////////////////////////////////////////////////////
 public doortakekey(id,level,cid) {
	if(!cmd_access(id,level,cid,1)) {
		return PLUGIN_HANDLED;
	}

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid)) { // if valid entity
		isdoor = is_door(doorid);
	}
	else { // invalid entity
		console_print(id,"* [DOOR] Door is invalid or non-existant");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) { // isn't a door entity
		console_print(id,"* [DOOR] Door is invalid or non-existant");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if exceeds our array
		console_print(id,"* [DOOR] FAILURE: Too many entities");
		return PLUGIN_HANDLED;
	}

	new arg[256];
	read_args(arg,255);
	new playerid = cmd_target(id,arg,2);

	// if invalid player
	if(!playerid) {
		return PLUGIN_HANDLED;
	}

	// if player has key
	if(doorhaskey[playerid][doorid] == 1) {
		doorhaskey[playerid][doorid] = 0;

		new steamid[256], mapname[256];
		get_user_authid(playerid,steamid,255);
		get_mapname(mapname,255);
		strtolower(mapname);

		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%s=%d=haskey",steamid,mapname,doorid);

		if(vaultdata_exists(vaultstring) == 1) {
			remove_vaultdata(vaultstring); // remove it from our vault
		}

		new playername[256];
		get_user_name(playerid,playername,255);
		console_print(id,"* [DOOR] Door key has been taken from %s for this door",playername);
	}
	else if(doorhaskey[playerid][doorid] == 0) { // if player does not have door key
		console_print(id,"* [DOOR] ERROR: Door key is not owned by that player for this door");
	}

	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // USING A LOCKED DOOR
 //////////////////////////////////////////////////////////////////////////////////////////
 public dooruse(id) {
	/*if(!cmd_access(id,level,cid,1)) {
	return PLUGIN_HANDLED;
	}*/

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid)) { // if valid ent
		isdoor = is_door(doorid);
	}
	else { // if invalid ent
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) { // if not a door entity
		if(is_button(doorid)) { // if really a button
			buttonuse(id); // go to button use
			return PLUGIN_HANDLED;
		}

		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if exceeds our array
		client_print(id,print_chat,"* [DOOR] ERROR: Too many entities^n");
		return PLUGIN_HANDLED;
	}

	// if door is unlocked
	if(doorislocked[doorid] == 0) {
		client_print(id,print_chat,"* [DOOR] Door is currently unlocked, no need to use this^n");
		return PLUGIN_HANDLED;
	}

	// if door is locked, doesn't have key, and isn't master admin
	if((doorislocked[doorid] == 1 && doorhaskey[id][doorid] == 0) && !access(id,ADMIN_LEVEL_A)) {
		client_print(id,print_chat,"* [DOOR] You do not have a key to this door^n");
		return PLUGIN_HANDLED;
	}

	force_use(id,doorid); // use the darn door

	client_print(id,print_chat,"* [DOOR] Door has been opened/closed^n");
	return PLUGIN_HANDLED;
 }

 // use door via button
 public buttonuse(id) {
	/*if(!cmd_access(id,level,cid,1)) {
	return PLUGIN_HANDLED;
	}*/

	new doorid, buttonid, buttonbody, isbutton;
	get_user_aiming(id,buttonid,buttonbody,9999);

	if(is_valid_ent(buttonid)) { // if valid ent
		isbutton = is_button(buttonid);
	}
	else { // if invalid ent
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(isbutton == 0) { // if not a button entity
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	// go through doors
	for(new i=0;i<MAXDOORS;i++) {
		if(doorbuttonid[i] == buttonid) { // if this button belongs to this door
			doorid = i; // let us know
			break;
		}
	}

	// if no doors found
	if(doorid == 0 || !is_valid_ent(doorid)) {
		client_print(id,print_chat,"* [DOOR] No locked doors belong to this button^n");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if exceeds our array
		client_print(id,print_chat,"* [DOOR] ERROR: Too many entities^n");
		return PLUGIN_HANDLED;
	}

	// if door is unlocked
	if(doorislocked[doorid] == 0) {
		client_print(id,print_chat,"* [DOOR] Door is currently unlocked, no need to use this^n");
		return PLUGIN_HANDLED;
	}

	// if door is locked, doesn't have key, and isn't master admin
	if((doorislocked[doorid] == 1 && doorhaskey[id][doorid] == 0) && !access(id,ADMIN_LEVEL_A)) {
		client_print(id,print_chat,"* [DOOR] You do not have a key to this door^n");
		return PLUGIN_HANDLED;
	}

	force_use(id,doorid); // use the darn door

	client_print(id,print_chat,"* [DOOR] Door has been opened/closed^n");
	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // LISTING OF PLAYERS WITH KEYS TO DOOR
 //////////////////////////////////////////////////////////////////////////////////////////
 public doorkeys(id,level,cid) {
	if(!cmd_access(id,level,cid,1)) {
		client_print(id,print_chat,"* [DOOR] Only admins may use this command^n");
		return PLUGIN_HANDLED;
	}

	new doorid, doorbody, isdoor;
	get_user_aiming(id,doorid,doorbody,9999);

	if(is_valid_ent(doorid)) { // if valid ent
		isdoor = is_door(doorid);
	}
	else { // if invalid ent
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(isdoor == 0) { // if not a door entity
		client_print(id,print_chat,"* [DOOR] Door is invalid or non-existant^n");
		return PLUGIN_HANDLED;
	}

	if(doorid > MAXDOORS-1) { // if exceeds our array
		client_print(id,print_chat,"* [DOOR] ERROR: Too many entities^n");
		return PLUGIN_HANDLED;
	}

	new foundkey;

	// go through players
	for(new i=1;i<=32;i++) {
		if(!is_user_connected(i)) { // if player index not connected
			continue; // skip this check
		}

		// if player has door key or is master admin
		if(doorhaskey[i][doorid] == 1 || access(i,ADMIN_LEVEL_A)) {
			if(foundkey == 0) { // if we have found no users with key so far
				foundkey = 1;
				client_print(id,print_chat,"* [DOOR] The following in-game players have keys to this door:^n");
			}
			new playername[256];
			get_user_name(i,playername,255);
			client_print(id,print_chat,"*            - %s^n",playername);
		}
	}

	// if didn't find any users with keys
	if(foundkey == 0) {
		client_print(id,print_chat,"* [DOOR] No in-game players have a key to this door^n");
	}

	return PLUGIN_HANDLED;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // ENTITY TYPE CHECKING
 //////////////////////////////////////////////////////////////////////////////////////////
 public is_door(ent) {
	new classname[256];
	entity_get_string(ent,EV_SZ_classname,classname,255);

	// affirm that it is a door because it has one of these door classnames
	if(equal(classname,"func_door") || equal(classname,"func_door_rotating") || equal(classname,"func_door_toggle")) {
		return 1;
	}

	return 0;
 }

 public is_button(ent) {
	new classname[256];
	entity_get_string(ent,EV_SZ_classname,classname,255);

	// affirm that it is a button because it has one of these button classnames
	if(equal(classname,"func_button") || equal(classname,"func_rot_button") || equal(classname,"momentary_rot_button")) {
		return 1;
	}

	return 0;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // ONE ENTITY TOUCHING ANOTHER (HEHE)
 //////////////////////////////////////////////////////////////////////////////////////////
 public touch_door(ptr,ptd) {
	if(!is_valid_ent(ptr) || !is_valid_ent(ptd) || !is_user_connected(ptd) || !is_user_alive(ptd)) { // if an invalid entity
		return PLUGIN_CONTINUE;
	}

	if(doorislocked[ptr] == 1 && doorhaskey[ptd][ptr] == 0) { // if door is locked and player has no key
		return PLUGIN_HANDLED; // don't let him open it
	}

	return PLUGIN_CONTINUE;
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // CLIENT CONNECTION
 //////////////////////////////////////////////////////////////////////////////////////////
 public client_putinserver(id) {
	new steamid[256], mapname[256];
	get_user_authid(id,steamid,255);
	get_mapname(mapname,255);
	strtolower(mapname);

	// assign keys to the player
	for(new i=1;i<MAXDOORS;i++) {
		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%s=%d=haskey",steamid,mapname,i);

		if(vaultdata_exists(vaultstring) == 1) {
			doorhaskey[id][i] = 1;
		}

	}

 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // CLIENT DISCONNECTION
 //////////////////////////////////////////////////////////////////////////////////////////
 public client_disconnect(id) {
	// unassign all keys from the player
	for(new i=1;i<MAXDOORS;i++) {
		doorhaskey[id][i] = 0;
	}
 }

 ///////////////////////////////////////////////////////////////////////////////////////////
 // PLUGIN MODULES
 ///////////////////////////////////////////////////////////////////////////////////////////
 public plugin_modules() {
	require_module("Engine");
	require_module("FakeMeta");
 }

 //////////////////////////////////////////////////////////////////////////////////////////
 // PLUGIN INITIATION
 //////////////////////////////////////////////////////////////////////////////////////////
 public plugin_init() {
	register_plugin("Door (Un)locker","0.31","Avalanche");
	console_print(0,"* Loaded Door (Un)locker 0.31 by Avalanche");

	register_cvar("door_unlocker_version","0.31");

	register_clcmd("say /usedoor","dooruse",-1);
	register_clcmd("say /lockdoor","doorlock",-1);
	register_clcmd("say /unlockdoor","doorunlock",-1);
	register_clcmd("say /doorkeys","doorkeys",ADMIN_LEVEL_A,"- lists who has keys for door in front of you");
	register_clcmd("amx_givedoorkey","doorgivekey",ADMIN_LEVEL_A,"- gives a key to the user specified for the door in front of you");
	register_clcmd("amx_takedoorkey","doortakekey",ADMIN_LEVEL_A,"- takes a key from the user specified for the door in front of you");

	register_touch("func_door","player","touch_door");
	register_touch("func_door_rotating","player","touch_door");
	register_touch("func_door_toggle","player","touch_door");

	// make all doors invincible
	for(new i=0;i<MAXDOORS;i++) {
		if(is_valid_ent(i)) {
			new classname[256];
			entity_get_string(i,EV_SZ_classname,classname,255);

			// if it is a door entity
			if(equal(classname,"func_door") || equal(classname,"func_door_rotating") || equal(classname,"func_door_toggle")) {
				entity_set_float(i,EV_FL_max_health,99999.0); // huge max health
				entity_set_float(i,EV_FL_health,99999.0); // huge current health
				entity_set_float(i,EV_FL_dmg_take,0.0); // damage taken?
				entity_set_float(i,EV_FL_takedamage,0.0); // takes damage?
			}
		}
	}

	// Locking saved doors
	new mapname[256];
	get_mapname(mapname,255);
	strtolower(mapname);

	// go through all the doors
	for(new i=1;i<MAXDOORS;i++) {
		new vaultstring[256];
		format(vaultstring,255,"DOOR=%s=%d=islocked",mapname,i);

		// if door is locked in vault
		if(vaultdata_exists(vaultstring) == 1 && is_valid_ent(i) == 1) {
			doorislocked[i] = 1;

			new targetname[256];
			entity_get_string(i,EV_SZ_targetname,targetname,255);

			// if door has a button
			if(!equal(targetname,"")) {
				new ent = find_ent_by_target(-1,targetname);

				if(is_valid_ent(ent)) { // if we found button
					entity_get_string(ent,EV_SZ_target,doorbuttontarget[i],63);
					entity_set_string(ent,EV_SZ_target,"");
					doorbuttonid[i] = ent;
				}
			}

		}
	}

 }
