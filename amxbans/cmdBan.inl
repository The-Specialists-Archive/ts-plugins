public cmdBan(id, level, cid)
{
	/* Checking if the admin has the right access */
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	
	new bool:serverCmd = false
	/* Determine if this was a server command or a command issued by a player in the game */
	if ( id == 0 )
		serverCmd = true;
	
	new text[128], steamidorusername[50], ban_length[50]
	read_args(text, 127)
	parse(text, ban_length, 49, steamidorusername, 49)
	
	/* Check so the ban command has the right format */
	if( !is_str_num(ban_length) || read_argc() < 4 )
	{
		client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"AMX_BAN_SYNTAX")

		return PLUGIN_HANDLED
	}
	
	new length1 = strlen(ban_length)
	new length2 = strlen(steamidorusername)
	new length = length1 + length2
	length+=2

	new reason[128]
	read_args(reason,127)
	format(g_ban_reason, 255, "%s", reason[length])
	
	replace_all(g_ban_reason, 255, "\", "")
	replace_all(g_ban_reason, 255, "'", "´")
	
	new iBanLength = str_to_num(ban_length)
	new cTimeLength[128]
	
	if (iBanLength > 0)
		get_time_length(id, iBanLength, timeunit_minutes, cTimeLength, 127)
	else
		format(cTimeLength, 127, "%L", LANG_PLAYER, "TIME_ELEMENT_PERMANENTLY")

	// This stops admins from banning perm in console if not adminflag n
	if(!(get_user_flags(id)&get_higher_ban_time_admin_flag()) && iBanLength == 0)
	{
		client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"NOT_BAN_PERMANENT")
		
		return PLUGIN_HANDLED
	}

	// This stops admins from banning more than 600 min in console if not adminflag n
	if(!(get_user_flags(id)&get_higher_ban_time_admin_flag()) && iBanLength > get_pcvar_num(consoleBanMax))
	{
		client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"BAN_MAX", get_pcvar_num(consoleBanMax))
		
		return PLUGIN_HANDLED
	}
	
	/* Try to find the player that should be banned */
	new player = locate_player(id, steamidorusername)

	/* Player is a BOT or has immunity */
	if (player == -1)
		return PLUGIN_HANDLED
		
	if(g_being_banned[player]) //triggered error http://amxbans.net/forums/viewtopic.php?p=3468#3468
	{
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[AMXBANS DEBUG Blocking doubleban(g_being_banned)] Playerid: %d BanLenght: %s Reason: %s", player, ban_length, g_ban_reason)
			
		return PLUGIN_HANDLED
	}
	
	g_being_banned[player] = true
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 1]Playerid: %d", player)


	new player_steamid[50], player_ip[30]
	if (player)
	{
		get_user_authid(player, player_steamid, 49)
		get_user_ip(player, player_ip, 29, 1)
	}
	else
	{
		// Must make that false to be able to ban another player not on the server
		// Players that aren't in the server always get id = 0
		g_being_banned[0] = false
		
		/* Get the steamID from the commandline even if it cant be found on the server
		That steamID will be inserted to the DB, if the string contains STEAM_ and if ban_evenif_disconnected == 1 */
		if ( contain(steamidorusername, "STEAM_") != -1 && get_pcvar_num(ban_evenif_disconn) == 1 )
		{
			format(player_steamid, 49, "%s", steamidorusername)
			format(player_ip, 29, "unknown_%s", player_steamid)
			
			// This is an extra check so it is impossible to make doublebans on a STEAM_ID
			// This is a fix when players are not present in the server.
			if ( equal(steamidorusername, g_steamidorusername) )
			{
				if (serverCmd)
					server_print("[AMXXBANS] SteamID %s is already being banned",g_steamidorusername)
				else
					console_print(id, "[AMXXBANS] SteamID %s is already being banned",g_steamidorusername)
	
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXXBANS DEBUG] SteamID %s is already being banned",g_steamidorusername)
	
				return PLUGIN_HANDLED	
			}

			format(g_steamidorusername, 49, "%s", steamidorusername)
		}
		else
		{
			if (serverCmd)
				server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
			else
				console_print(id, "[AMXXBANS] The Player %s was not found",g_steamidorusername)

			if ( get_pcvar_num(amxbans_debug) == 1 )
				log_amx("[AMXXBANS DEBUG] Player %s could not be found",g_steamidorusername)

			return PLUGIN_HANDLED
		}
	}


	/*
	  If it is on a lan the player_steamid must not be inserted to the DB then everybody on the LAN would be considered banned.
 		Only IP and nick is enough for LAN bans. HLTV will also only be banned by IP
		 
		Don't wanna ban a player with STEAM_ID_PENDING to the DB as that can make many others to be considdered banned.
		Make an IP ban instead and don't add player_steamid to the DB
 	*/
	if ( equal("4294967295", player_steamid)
		|| equal("HLTV", player_steamid)
		|| equal("STEAM_ID_LAN",player_steamid)
		|| equal("VALVE_ID_LAN",player_steamid)
		|| equal("VALVE_ID_PENDING",player_steamid)
		|| equal("STEAM_ID_PENDING",player_steamid))
	{
		g_ban_type = "SI"
		player_steamid = ""
	}
	
	new query[1024]
	if (equal(g_ban_type, "S"))
	{
		format(query,1023,"SELECT player_id FROM %s WHERE player_id='%s'", tbl_bans, player_steamid)
		
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[AMXBANS DEBUG cmdBan] Banned a player by SteamID")
	}
	else
	{
		format(query,1023,"SELECT player_ip FROM %s WHERE player_ip='%s'", tbl_bans, player_ip)
		
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[AMXBANS DEBUG cmdBan] Banned a player by IP/steamID")
	}

	new data[3]
	data[0] = id
	data[1] = player
	data[2] = iBanLength
	SQL_ThreadQuery(g_SqlX, "cmd_ban_", query, data, 3)
	
	return PLUGIN_HANDLED
}

public cmd_ban_(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new player = data[1]
	new iBanLength = data[2]
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 2]Playerid: %d", player)
	
	new bool:serverCmd = false
	/* Determine if this was a server command or a command issued by a player in the game */
	if ( id == 0 )
		serverCmd = true;
	
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 )
	}
	else
	{

		new player_steamid[50], player_ip[30], player_nick[50]
		
		if (!SQL_NumResults(query))
		{
			if (player)
			{
				get_user_authid(player, player_steamid, 49)
				get_user_name(player, player_nick, 49)
				get_user_ip(player, player_ip, 29, 1)
				
				replace_all(player_nick, 49, "\", "")
				replace_all(player_nick, 49, "'", "´")
			}
			else /* The player was not found in server */
			{
				// Must make that false to be able to ban another player not on the server
				// Players that aren't in the server always get id = 0
				g_being_banned[0] = false
			
				/* Get the steamID from the commandline even if it cant be found on the server
				That steamID will be inserted to the DB, if the string contains STEAM_ and if ban_evenif_disconnected == 1 */
				if ( contain(g_steamidorusername, "STEAM_") != -1 && get_pcvar_num(ban_evenif_disconn) == 1 )
				{
					format(player_steamid, 49, "%s", g_steamidorusername)
					format(player_nick, 49, "unknown_%s", player_steamid)
					format(player_ip, 29, "unknown_%s", player_steamid)
				}
				else
				{
					if (serverCmd)
						server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
					else
						console_print(id, "[AMXXBANS] The Player %s was not found",g_steamidorusername)
		
					if ( get_pcvar_num(amxbans_debug) == 1 )
						log_amx("[AMXXBANS DEBUG] Player %s could not be found",g_steamidorusername)
		
					return PLUGIN_HANDLED
				}
				
			}
			
			new admin_nick[100], admin_steamid[50], admin_ip[20]
			get_user_name(id, admin_nick, 99)
			get_user_ip(id, admin_ip, 19, 1)
			
			replace_all(admin_nick, 99, "\", "")
			replace_all(admin_nick, 99, "'", "´")
			
			if (!serverCmd)
			{
				get_user_authid(id, admin_steamid, 49)
	
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXBANS DEBUG cmdBan] Adminsteamid: %s, Servercmd: %s", admin_steamid, serverCmd)
			}
			else
			{
				/* If the server does the ban you cant get any steam_ID or team */
				admin_steamid = ""
		
				/* This is so you can have a shorter name for the servers hostname.
				Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad */
				new servernick[100]
				get_pcvar_string(server_nick, servernick, 99)
				if (strlen(servernick))
					admin_nick = servernick
			}
		
			/* If HLGUARD ban, the admin nick will be set to [HLGUARD] */
			if ( contain(g_ban_reason, "[HLGUARD]") != -1 )
				admin_nick = "[HLGUARD]"
		
			/* If ATAC ban, the admin nick will be set to [ATAC] */
			if ( contain(g_ban_reason, "Max Team Kill Violation") != -1 )
				admin_nick = "[ATAC]"
				
			if ( get_pcvar_num(amxbans_debug) == 1 )
				log_amx("[AMXBANS DEBUG cmdBan] Admin nick: %s, Admin userid: %d", admin_nick, get_user_userid(id))
			
			new server_name[100]
			get_cvar_string("hostname", server_name, 99)
			
			new ban_created = get_systime(0)

			if ( get_pcvar_num(add_mapname_in_servername) == 1 )
			{
				new mapname[32], pre[4],post[4]
				get_mapname(mapname,31)
				pre = " ("
				post = ")"
				add(server_name,255,pre,0)
				add(server_name,255,mapname,0)
				add(server_name,255,post,0)
			}

			replace_all(server_name, 99, "\", "")
			replace_all(server_name, 99, "'", "´")
			
			new BanLength[50]
			num_to_str(iBanLength, BanLength, 49)

			/*
			  If it is on a lan the player_steamid must not be inserted to the DB then everybody on the LAN would be considered banned.
		 		Only IP and nick is enough for LAN bans. HLTV will also only be banned by IP
				 
				Don't wanna ban a player with STEAM_ID_PENDING to the DB as that can make many others to be considdered banned.
				Make an IP ban instead and don't add player_steamid to the DB
		 	*/
			if ( equal("4294967295", player_steamid)
				|| equal("HLTV", player_steamid)
				|| equal("STEAM_ID_LAN",player_steamid)
				|| equal("VALVE_ID_LAN",player_steamid)
				|| equal("VALVE_ID_PENDING",player_steamid)
				|| equal("STEAM_ID_PENDING",player_steamid))
			{
				g_ban_type = "SI"
				player_steamid = ""
			}

			new query[512]
			format(query, 511, "INSERT INTO `%s` (player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,ban_reason,ban_created,ban_length,server_name,server_ip) VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%i','%s','%s','%s:%s')", tbl_bans, player_steamid, player_ip, player_nick, admin_ip, admin_steamid, admin_nick, g_ban_type, g_ban_reason, ban_created, BanLength, server_name, g_ip, g_port)
			
			new data[3]
			data[0] = id
			data[1] = player
			data[2] = iBanLength
			SQL_ThreadQuery(g_SqlX, "insert_bandetails", query, data, 3)
		}
		else
		{
			if ( serverCmd )
				log_message("[AMXBANS] %L",LANG_SERVER,"ALREADY_BANNED", player_steamid, player_ip)
			else
				client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"ALREADY_BANNED", player_steamid, player_ip)
				
			// Must make that false to be able to ban another player not on the server
			// Players that aren't in the server always get id = 0
			g_being_banned[0] = false

		}
	}
	
	return PLUGIN_HANDLED
}


public insert_bandetails(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new player = data[1]
	new iBanLength = data[2]
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 4]Playerid: %d", player)

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 7 )
	}
	else
	{
		
		new player_steamid[50], player_ip[30]

		get_user_authid(player, player_steamid, 49)
		get_user_ip(player, player_ip, 29, 1)
		
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[cmdBan function 4]PlayerSteamid: %s,PlayerIp: %s, BanType: %s", player_steamid, player_ip, g_ban_type)

		new query[512]
		if (equal(g_ban_type, "S"))
		{
			format(query, 511, "SELECT bid FROM `%s` WHERE player_id='%s' AND player_ip='%s' AND ban_type='%s'", tbl_bans, player_steamid, player_ip, g_ban_type)
		}
		else
		{
			format(query, 511, "SELECT bid FROM `%s` WHERE player_ip='%s' AND ban_type='%s'", tbl_bans, player_ip, g_ban_type)
		}
		
		new data[3]
		data[0] = id
		data[1] = player
		data[2] = iBanLength
		SQL_ThreadQuery(g_SqlX, "select_bid", query, data, 3)
	}
	
	return PLUGIN_HANDLED
}

public select_bid(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new player = data[1]
	new iBanLength = data[2]
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 5]Playerid: %d", player)
	
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 8 )
	}
	else
	{
		new bid
		if (!SQL_NumResults(query))
		{
			bid = 0
		}
		else
		{
			bid = SQL_ReadResult(query, 0)
		}
		
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[cmdBan function 5]Bid: %d", bid)

		new query[512]
		format(query, 511, "SELECT amxban_motd FROM `%s` WHERE address = '%s:%s'", tbl_svrnfo, g_ip, g_port)
		
		new data[4]
		data[0] = id
		data[1] = player
		data[2] = bid
		data[3] = iBanLength
		SQL_ThreadQuery(g_SqlX, "select_amxbans_motd", query, data, 4)
	}
	
	return PLUGIN_HANDLED
}

public select_amxbans_motd(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new player = data[1]
	new bid = data[2]
	new iBanLength = data[3]
	
	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[cmdBan function 6]Playerid: %d, Bid: %d", player, bid)

	new bool:serverCmd = false
	/* Determine if this was a server command or a command issued by a player in the game */
	if ( id == 0 )
		serverCmd = true;

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 9 )
	}
	else
	{
		new player_steamid[50], player_ip[30], player_nick[50]
		
		get_user_authid(player, player_steamid, 49)
		get_user_name(player, player_nick, 49)
		get_user_ip(player, player_ip, 29, 1)
		
		replace_all(player_nick, 49, "\", "")
		replace_all(player_nick, 49, "'", "´")
		
		new amxban_motd_url[256]
		if (!SQL_NumResults(query))
		{
			copy(amxban_motd_url,256, "0")	
		}
		else
		{
			SQL_ReadResult(query, 0, amxban_motd_url, 256)
		}
		new admin_team[11], admin_steamid[50], admin_nick[100]
		get_user_team(id, admin_team, 10)
		get_user_authid(id, admin_steamid, 49)
		get_user_name(id, admin_nick, 99)
		
		replace_all(admin_nick, 99, "\", "")
		replace_all(admin_nick, 99, "'", "´")
		
		new cTimeLengthPlayer[128]
		new cTimeLengthServer[128]
		
		if (iBanLength > 0)
		{
			get_time_length(player, iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
			get_time_length(0, iBanLength, timeunit_minutes, cTimeLengthServer, 127)
		}
		else //Permanent Ban
		{
			format(cTimeLengthPlayer, 127, "%L", LANG_PLAYER, "TIME_ELEMENT_PERMANENTLY")
			format(cTimeLengthServer, 127, "%L", LANG_SERVER, "TIME_ELEMENT_PERMANENTLY")
		}
		
		new show_activity = get_cvar_num("amx_show_activity")
		if( (get_user_flags(id)&get_admin_mole_access_flag() || id == 0) && (get_pcvar_num(show_name_evenif_mole) == 0) )
			show_activity = 1
		
		if (player)
		{
			
			new complain_url[256]
			get_pcvar_string(complainurl ,complain_url, 255)
				
			client_print(player,print_console,"[AMXBANS] ===============================================")
				
			if (show_activity == 2)
			{
				client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_6", admin_nick)
				client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_7", complain_url)
				format(ban_motd, 4095, "%L", LANG_PLAYER, "MSG_MOTD_2", g_ban_reason, cTimeLengthPlayer, player_steamid, admin_nick)
			}
			else
			{
				client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_1")
				client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_7", complain_url)
				format(ban_motd, 4095, "%L", LANG_PLAYER, "MSG_MOTD_1", g_ban_reason, cTimeLengthPlayer, player_steamid)
			}
				
			client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_2", g_ban_reason)
			client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_3", cTimeLengthPlayer)
			client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_4", player_steamid)
			client_print(player,print_console,"[AMXBANS] %L",LANG_PLAYER,"MSG_5", player_ip)
			client_print(player,print_console,"[AMXBANS] ===============================================")
			
			new msg[4096], bidstr[10]
			num_to_str(bid, bidstr, 9)
			
			if ( get_pcvar_num(amxbans_debug) == 1 )
				log_amx("[cmdBan function 6.2]Bidstr: %s URL= %s Kickdelay:%f", bidstr, amxban_motd_url, kick_delay)

			if (equal(amxban_motd_url, ""))
			{
					format(msg, 4095, ban_motd)
			}
			else
			{
				format(msg, 4095, amxban_motd_url, bidstr)
			}
	
			new motdTitle[] = "Banned by Amxbans "
			add(motdTitle,255,VERSION,0)
			show_motd(player, msg, motdTitle)
			
			new id_str[3]
			num_to_str(player, id_str, 3)
			set_task(kick_delay, "delayed_kick", 1, id_str, 3)
		}
		else /* The player was not found in server */
		{
			/* Get the steamID from the commandline even if it cant be found on the server
			That steamID will be inserted to the DB, if the string contains STEAM_ and if ban_evenif_disconnected == 1 */
			if ( contain(g_steamidorusername, "STEAM_") != -1 && get_pcvar_num(ban_evenif_disconn) == 1 )
			{
				format(player_steamid, 49, "%s", g_steamidorusername)
				format(player_nick, 49, "unknown_%s", player_steamid)
				format(player_ip, 29, "unknown_%s", player_steamid)
			}
			else
			{
				if (serverCmd)
					server_print("[AMXXBANS] The Player %s was not found",g_steamidorusername)
				else
					console_print(id, "[AMXXBANS] The Player %s was not found",g_steamidorusername)
	
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXXBANS DEBUG] Player %s could not be found",g_steamidorusername)
	
				return PLUGIN_HANDLED
			}
			
		}
				
		if (equal(g_ban_type, "S"))
		{
			if ( serverCmd )
			log_message("[AMXBANS] %L",LANG_PLAYER,"STEAMID_BANNED_SUCCESS_IP_LOGGED",player_steamid)
			else
			client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"STEAMID_BANNED_SUCCESS_IP_LOGGED",player_steamid)
		}
		else
		{
			if ( serverCmd )
			log_message("[AMXBANS] %L",LANG_PLAYER,"STEAMID_IP_BANNED_SUCCESS")
			else
			client_print(id,print_console,"[AMXBANS] %L",LANG_PLAYER,"STEAMID_IP_BANNED_SUCCESS")
		}
		
		if (serverCmd)
		{
			/* If the server does the ban you cant get any steam_ID or team */
			admin_steamid = ""
			admin_team = ""
		}
				
		// Logs all bans by admins/server to amxx logs
		if (iBanLength > 0)
		{
			log_amx("%L", LANG_SERVER, "BAN_LOG",
			admin_nick, get_user_userid(id), admin_steamid, admin_team, player_nick, player_steamid, cTimeLengthServer, iBanLength, g_ban_reason)

			if ( get_pcvar_num(show_in_hlsw) == 1 )
			{
				// If you use HLSW you will see when someone ban a player if you can see the chatlogs
				log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team,
				LANG_SERVER, "BAN_CHATLOG", player_nick, player_steamid, cTimeLengthServer, iBanLength, g_ban_reason)
			}
		}
		else
		{
			log_amx("%L", LANG_SERVER, "BAN_LOG_PERM", admin_nick, get_user_userid(id), admin_steamid, admin_team, player_nick, player_steamid, g_ban_reason)

			if ( get_pcvar_num(show_in_hlsw) == 1 )
			{
				// If you use HLSW you will see when someone ban a player if you can see the chatlogs
				log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team,
				LANG_SERVER, "BAN_CHATLOG_PERM", player_nick, player_steamid, g_ban_reason)
			}
		}
		
		new message[192]
			
		if (show_activity == 1)
		{
			if (iBanLength > 0)
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++)
				{
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					format(message,191,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE", player_nick, cTimeLengthPlayer, g_ban_reason)
					
					if ( get_pcvar_num(show_hud_messages) == 1 )
					{
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					client_print(players[idx],print_chat, "%s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
			else
			{
				new playerCount, idx, players[32]
				
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++)
				{
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					format(message,191,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE_PERM", player_nick, g_ban_reason)
					
					if ( get_pcvar_num(show_hud_messages) == 1 )
					{
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					client_print(players[idx],print_chat, "%s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
		}
		
		if (show_activity == 2)
		{
			if (iBanLength > 0)
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++)
				{
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					format(message,191, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2", player_nick, cTimeLengthPlayer, g_ban_reason, admin_nick)
	
					if ( get_pcvar_num(show_hud_messages) == 1 )
					{
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					client_print(players[idx],print_chat, "%s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
			else
			{
				new playerCount, idx, players[32]
				
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++)
				{
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					format(message,191, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2_PERM", player_nick, g_ban_reason, admin_nick)
					
					if ( get_pcvar_num(show_hud_messages) == 1 )
					{
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					client_print(players[idx],print_chat, "%s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
		}
		
		if ( get_pcvar_num(amxbans_cmd_sql) == 1 )
		{
			new query[512]
			new data[1]
			new command[16] = "Ban"
			new stime[32]
			get_time("%Y-%m-%d %H:%M:%S",stime,31 )
		
			format(query, 511, "INSERT INTO `admincommands` (authid,name,authid2,name2,value,command,reason,stime) values('%s','%s','%s','%s','%i','%s','%s','%s')", admin_steamid, admin_nick, player_steamid, player_nick, iBanLength, command, g_ban_reason, stime)
			
			data[0] = id
			SQL_ThreadQuery(g_SqlX, "insert_ban_cmd", query, data, 1)
		}
	}
	
	return PLUGIN_HANDLED
}

public insert_ban_cmd(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 12 )
	}
	
	return PLUGIN_HANDLED
}
