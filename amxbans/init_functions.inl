
/*********************  Banmod online  ********************/
public banmod_online(id)
{
	get_cvar_string("ip", g_ip, 31)
	// This is a new way of getting the port number
	new ip_port[42], ip_tmp[32]
	get_user_ip(0, ip_port, 41) // Takes in the whole IP:port string.. (0 is always the server)
	strtok(ip_port, ip_tmp, 31, g_port, 9, ':') // Divides the string with the help of strtok and delimiter :

	if ( get_pcvar_num(amxbans_debug) == 1 )
	{
		server_print("[AMXBANS DEBUG] The server IP:PORT is: %s:%s", g_ip, g_port)
		log_amx("[AMXBANS DEBUG] The server IP:PORT is: %s:%s", g_ip, g_port)
	}
	
	new query[512]
	new data[1]

	format(query, 511, "SELECT timestamp,hostname,address,gametype,rcon,amxban_version,amxban_motd,motd_delay FROM `%s` WHERE address = '%s:%s'",tbl_svrnfo,g_ip,g_port)
	
	data[0] = id

	SQL_ThreadQuery(g_SqlX, "banmod_online_", query, data, 1)
}

public banmod_online_(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]

	new timestamp = get_systime(0)
	new servername[100]
	get_cvar_string("hostname",servername,99)
	new modname[32]
	get_modname(modname,31)

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 1 )
	}
	else
	{
		replace_all(servername, 99, "\", "")
		replace_all(servername, 99, "'", "´")
	
		if (!SQL_NumResults(query))
		{
	
			if ( get_pcvar_num(amxbans_debug) == 1 )
			{
				server_print("AMXBANS DEBUG] INSERT INTO `%s` VALUES ('', '%i','%s', '%s:%s', '%s', '', '%s', '', '', '0')", tbl_svrnfo, timestamp, servername, g_ip, g_port, modname, amxbans_version)
				log_amx("AMXBANS DEBUG] INSERT INTO `%s` VALUES ('', '%i','%s', '%s:%s', '%s', '', '%s', '', '', '0')", tbl_svrnfo, timestamp, servername, g_ip, g_port, modname, amxbans_version)
			}
			
			new query[512]
			new data[1]

			format(query, 511,"INSERT INTO `%s` (timestamp, hostname, address, gametype, amxban_version, amxban_menu) VALUES ('%i', '%s', '%s:%s', '%s', '%s', '1')", tbl_svrnfo, timestamp, servername, g_ip, g_port, modname, amxbans_version)
			
			data[0] = id

			SQL_ThreadQuery(g_SqlX, "banmod_online_insert", query, data, 1)
		}
		else
		{
			new kick_delay_str[10]
			SQL_ReadResult(query, 7, kick_delay_str, 10)  // inte säker på om det ska vara 7 eller 8

			if (floatstr(kick_delay_str)>2.0)
			{
				kick_delay=floatstr(kick_delay_str)
			}
			else
			{
				kick_delay=10.0
			}
	
			if ( get_pcvar_num(amxbans_debug) == 1 )
			{
				server_print("AMXBANS DEBUG] UPDATE `%s` SET timestamp='%i',hostname='%s',gametype='%s',amxban_version='%s', amxban_menu='1' WHERE address = '%s:%s'", tbl_svrnfo, timestamp, servername, modname, amxbans_version, g_ip, g_port)
				log_amx("[AMXBANS DEBUG] UPDATE `%s` SET timestamp='%i',hostname='%s',gametype='%s',amxban_version='%s', amxban_menu='1' WHERE address = '%s:%s'", tbl_svrnfo, timestamp, servername, modname, amxbans_version, g_ip, g_port)
			}
	
			new query[512]
			new data[1]

			format(query, 511, "UPDATE `%s` SET timestamp='%i',hostname='%s',gametype='%s',amxban_version='%s', amxban_menu='1' WHERE address = '%s:%s'", tbl_svrnfo, timestamp, servername, modname, amxbans_version, g_ip, g_port)
			
			data[0] = id

			SQL_ThreadQuery(g_SqlX, "banmod_online_update", query, data, 1)

		}
		
		if ( !(get_pcvar_num(amxbans_debug) == 10) )
			log_amx("[AMXBANS] %L", LANG_SERVER, "SQL_BANMOD_ONLINE", VERSION)
	}
	
	return PLUGIN_CONTINUE
}

public banmod_online_insert(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 2)
	}
}

public banmod_online_update(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 3)
	}
}

/************  Start fetch reasons  *****************/
public fetchReasons(id)
{
	new query[512]
	new data[1]
	
	format(query, 511, "SELECT reason FROM %s WHERE address = '%s:%s'", tbl_reasons, g_ip, g_port)
	
	data[0] = id
	
	SQL_ThreadQuery(g_SqlX, "fetchReasons_", query, data, 1)
}

public fetchReasons_(failstate, Handle:query, error[], errnum, data[], size)
{
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 5 )
	}
	else
	{
		if (!SQL_NumResults(query))
		{
			server_print("[AMXBANS] %L",LANG_SERVER,"NO_REASONS")
			
			format(g_banReasons[0], 127, "%L", LANG_SERVER, "REASON_1")
			format(g_banReasons[1], 127, "%L", LANG_SERVER, "REASON_2")
			format(g_banReasons[2], 127, "%L", LANG_SERVER, "REASON_3")
			format(g_banReasons[3], 127, "%L", LANG_SERVER, "REASON_4")
			format(g_banReasons[4], 127, "%L", LANG_SERVER, "REASON_5")
			format(g_banReasons[5], 127, "%L", LANG_SERVER, "REASON_6")
			format(g_banReasons[6], 127, "%L", LANG_SERVER, "REASON_7")
		
			server_print("[AMXBANS] %L",LANG_SERVER,"SQL_LOADED_STATIC_REASONS")
			log_amx("[AMXBANS] %L",LANG_SERVER,"SQL_LOADED_STATIC_REASONS")

			g_aNum = 7
	
			return PLUGIN_HANDLED
		}
		else
		{
			g_aNum = 0
			while(SQL_MoreResults(query))
			{
				SQL_ReadResult(query, 0, g_banReasons[g_aNum], 127)
				SQL_NextRow(query)
				g_aNum++
			}
		}
		
		if (g_aNum == 1)
			server_print("[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASON" )
		else
			server_print("[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASONS", g_aNum )
	}
	
	return PLUGIN_HANDLED
}
