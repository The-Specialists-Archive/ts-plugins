public prebanned_check(id)
{
	if(is_user_bot(id))
		return PLUGIN_HANDLED
	
	new player_steamid[32], player_ip[20]
	get_user_authid(id, player_steamid, 31)
	get_user_ip(id, player_ip, 19, 1)
		
	new query[4096]
	new data[1]
	
	format(query, 4096, "SELECT ban_created,admin_nick FROM `%s` WHERE ( player_id='%s' AND ban_type='S' ) OR ( player_ip='%s' AND ban_type='SI' )",tbl_banhist, player_steamid, player_ip)

	data[0] = id
	SQL_ThreadQuery(g_SqlX, "prebanned_check_", query, data, 1)
	
	return PLUGIN_HANDLED
}

public prebanned_check_(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 16 )
	}
	else
	{
		
		if(!SQL_NumResults(query))
		{
			return PLUGIN_HANDLED
		}
		else
		{
			new admin_nick[32]
			new current_time_int, ban_count, ban_created, banned_days_ago
			current_time_int = get_systime(0)
			new preBanTime = get_pcvar_num(max_time_to_show_preban )
			new showAtacbans = get_pcvar_num(show_atacbans)

			while (SQL_MoreResults(query))
			{
				ban_created = SQL_ReadResult(query, 0)
				SQL_ReadResult(query, 1, admin_nick, 31)
				
				/* Check how many days have gone since the ban was created */
				banned_days_ago = (current_time_int - ban_created) / 86400
				
				if ( ( banned_days_ago > preBanTime ) || ( containi(admin_nick, "[ATAC]") != -1 && showAtacbans == 0 ) )
				{
					if ( get_pcvar_num(amxbans_debug) == 1 && ( banned_days_ago > preBanTime ))
						log_amx("To OLD ban: %i > %d", banned_days_ago, preBanTime )

					if ( get_pcvar_num(amxbans_debug) == 1 &&  ( containi(admin_nick, "[ATAC]") != -1 && showAtacbans == 0 ))
						log_amx("Showing atacbans is off, admin: %s", admin_nick)

				}
				else
				{
					ban_count++
					if ( get_pcvar_num(amxbans_debug) == 1 )
						log_amx("PreBan count: %i < %d Total:%i",banned_days_ago, preBanTime, ban_count )
				}
				
				SQL_NextRow(query)
			}
			
			new name[32], player_steamid[32]
			get_user_authid(id, player_steamid, 31)
			get_user_name(id, name, 31)

			if( !(get_user_flags(id)&ADMIN_IMMUNITY) && !(is_user_bot(id)) && !(equal("", player_steamid)) && (ban_count >= get_pcvar_num(show_prebanned_num)) )
				server_cmd("amx_chat %L", LANG_PLAYER, "PLAYER_BANNED_BEFORE", name, player_steamid, ban_count)
		}
	}
	
	return PLUGIN_HANDLED
}

/*************************************************************************/

public check_player(id)
{
	new player_steamid[32], player_ip[20]
	get_user_authid(id, player_steamid, 31)
	get_user_ip(id, player_ip, 19, 1)

	new query[4096]
	new data[1]
	format(query, 4095, "SELECT bid,ban_created,ban_length,ban_reason,admin_nick,admin_id,admin_ip,player_nick,player_id,player_ip,server_name,server_ip,ban_type FROM `%s` WHERE ( player_id='%s' AND ban_type='S' ) OR ( player_ip='%s' AND ban_type='SI' )",tbl_bans, player_steamid, player_ip)
											 
	data[0] = id
	SQL_ThreadQuery(g_SqlX, "check_player_", query, data, 1)
	
	return PLUGIN_HANDLED
}

public check_player_(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 17 )
	}
	else
	{
		if(!SQL_NumResults(query))
		{
			return PLUGIN_HANDLED
		}
		else
		{

			new ban_length[50], ban_reason[255], admin_nick[100],admin_steamid[50],admin_ip[30],ban_type[4]
			new player_nick[50],player_steamid[50],player_ip[30],server_name[100],server_ip[30]
			
			new bid = SQL_ReadResult(query, 0)
			new ban_created = SQL_ReadResult(query, 1)
			SQL_ReadResult(query, 2, ban_length, 49)
			SQL_ReadResult(query, 3, ban_reason, 254)
			SQL_ReadResult(query, 4, admin_nick, 99)
			SQL_ReadResult(query, 5, admin_steamid, 49)
			SQL_ReadResult(query, 6, admin_ip, 29)
			SQL_ReadResult(query, 7, player_nick, 49)
			SQL_ReadResult(query, 8, player_steamid, 49)
			SQL_ReadResult(query, 9, player_ip, 29)
			SQL_ReadResult(query, 10, server_name, 99)
			SQL_ReadResult(query, 11, server_ip, 29)
			SQL_ReadResult(query, 12, ban_type, 3)

			
			if ( get_pcvar_num(amxbans_debug) == 1 )
			     	log_amx("^nbid: %d ^nwhen: %d ^nlenght: %s ^nreason: %s ^nadmin: %s ^nadminsteamID: %s ^nPlayername %s ^nserver: %s ^nserverip: %s ^nbantype: %s",bid,ban_created,ban_length,ban_reason,admin_nick,admin_steamid,player_nick,server_name,server_ip,ban_type)

			new current_time_int = get_systime(0)
			new ban_length_int = str_to_num(ban_length) * 60 // in secs
	
	

			// A ban was found for the connecting player!! Lets see how long it is or if it has expired
			if ((ban_length_int == 0) || (ban_created ==0) || (ban_created+ban_length_int > current_time_int))
			{
				
				new complain_url[256]
				get_pcvar_string(complainurl ,complain_url,255)
				
				client_cmd(id, "echo [AMXBANS] ===============================================")
				
				new show_activity = get_cvar_num("amx_show_activity")
				
				if(get_user_flags(id)&ADMIN_LEVEL_F || id == 0)
				show_activity = 1
				
				if (show_activity == 2)
				{
					client_cmd(id, "echo [AMXBANS] %L",LANG_PLAYER,"MSG_8", admin_nick)
				}
				
				if (show_activity == 1)
				{
					client_cmd(id, "echo [AMXBANS] %L",LANG_PLAYER,"MSG_9")
				}
				
				if (ban_length_int==0)
				{
					client_cmd(id, "echo [AMXBANS] %L",LANG_PLAYER,"MSG_10")
				}
				else
				{
					new cTimeLength[128]
					new iSecondsLeft = (ban_created + ban_length_int - current_time_int)
					get_time_length(id, iSecondsLeft, timeunit_seconds, cTimeLength, 127)
					client_cmd(id, "echo [AMXBANS] %L" ,LANG_PLAYER, "MSG_12", cTimeLength)
				}
				
				client_cmd(id, "echo [AMXBANS] %L", LANG_PLAYER, "MSG_13", player_nick)
				client_cmd(id, "echo [AMXBANS] %L", LANG_PLAYER, "MSG_2", ban_reason)
				client_cmd(id, "echo [AMXBANS] %L", LANG_PLAYER, "MSG_7", complain_url)
				client_cmd(id, "echo [AMXBANS] %L", LANG_PLAYER, "MSG_4", player_steamid)
				client_cmd(id, "echo [AMXBANS] %L", LANG_PLAYER, "MSG_5", player_ip)
				client_cmd(id, "echo [AMXBANS] ===============================================")
	
	
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXBANS DEBUG] BID:<%d> Player:<%s> <%s> connected and got kicked, because of an active ban", bid, player_nick, player_steamid)
	
				new id_str[3]
				num_to_str(id,id_str,3)
	
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXBANS DEBUG] Delayed Kick-TASK ID1: <%d>  ID2: <%s>", id, id_str)
	
				set_task(3.5,"delayed_kick",0,id_str,3)
	
				return PLUGIN_HANDLED
			}
			else // The ban has expired
			{
				client_cmd(id, "echo [AMXBANS] %L",LANG_PLAYER,"MSG_11")
	
				new unban_created = get_systime(0)
	
				//make sure there are no single quotes in these 4 vars
				replace_all(player_nick, 49, "\", "")
				replace_all(player_nick, 49, "'", "´")
	
				replace_all(admin_nick, 99, "\", "")
				replace_all(admin_nick, 99, "'", "´")
	
				replace_all(ban_reason, 254, "\", "")
				replace_all(ban_reason, 254, "'", "´")
	
				replace_all(server_name, 99, "\", "")
				replace_all(server_name, 99, "'", "´")
				
				new query[512]
				new data[2]
	
				format(query, 511, "INSERT INTO `%s` (player_id,player_ip,player_nick,admin_id,admin_nick,admin_ip,ban_type,ban_reason,ban_created,ban_length,server_ip,server_name,unban_created,unban_reason,unban_admin_nick) VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%d','%s','%s','%s','%i','Bantime expired','amxbans')",tbl_banhist, player_steamid, player_ip, player_nick, admin_steamid, admin_nick, admin_ip, ban_type, ban_reason, ban_created, ban_length, server_ip, server_name, unban_created)
				data[0] = id
				data[1] = bid
				SQL_ThreadQuery(g_SqlX, "insert_to_banhistory", query, data, 2)
				
				if ( get_pcvar_num(amxbans_debug) == 1 )
					log_amx("[AMXBANS DEBUG] PRUNE BAN: INSERT INTO `%s` (VALUES('%s','%s','%s')",tbl_banhist, player_steamid, player_nick, ban_length)
				
			}
		}
	}
	return PLUGIN_HANDLED
}

public insert_to_banhistory(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new bid = data[1]

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 18 )
	}
	else
	{
		new query[512]
		new data[1]
	
		format(query, 511,"DELETE FROM `%s` WHERE bid='%d'",tbl_bans, bid)
		
		data[0] = id
		SQL_ThreadQuery(g_SqlX, "delete_expired_ban", query, data, 1)
	
		if ( get_pcvar_num(amxbans_debug) == 1 )
			log_amx("[AMXBANS DEBUG] PRUNE BAN: DELETE FROM `%s` WHERE bid='%d'",tbl_bans, bid)
	}
	
	return PLUGIN_HANDLED
}

public delete_expired_ban(failstate, Handle:query, error[], errnum, data[], size)
{

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 19 )
	}
}
