

public actionBanMenu(id,key)
{
	switch (key)
	{
		case 7:
		{
			// Admins with flag n or what HIGHER_BAN_TIME_ADMIN is set to, will get the following ban times
			if (get_user_flags(id)&get_higher_ban_time_admin_flag())
			{
				++g_menuOption[id]
				g_menuOption[id] %= g_highbantimesnum

				new i
				for(i = 0; i < g_highbantimesnum; i++)
				{
					if(g_menuOption[id] == i)
						g_menuSettings[id] = g_HighBanMenuValues[i]
					else if(g_menuOption[id] == -1)
						g_menuSettings[id] = -1
				}
			}
			else // Admins with flag d (std for BAN) will get the following ban times
			{
				++g_menuOption[id]
				g_menuOption[id] %= g_lowbantimesnum

				new i
				for(i = 0; i < g_lowbantimesnum; i++)
				{
					if(g_menuOption[id] == i)
						g_menuSettings[id] = g_LowBanMenuValues[i]
					else if(g_menuOption[id] == -1)
						g_menuSettings[id] = -1
				}
			}

			displayBanMenu(id,g_menuPosition[id])
		}

		case 8: displayBanMenu(id,++g_menuPosition[id])
		case 9: displayBanMenu(id,--g_menuPosition[id])

		default:
		{
			g_bannedPlayer = g_menuPlayers[id][g_menuPosition[id] * 7 + key]
			
			if(g_menuSettings[id] == -1)
			{
				flag_player(id)
				displayBanMenu(id,g_menuPosition[id] = 0)
			}
			else
			displayBanMenuReason(id)
		}
	}

	return PLUGIN_HANDLED
}

displayBanMenu(id,pos)
{
	if (pos < 0)  return

	get_players(g_menuPlayers[id],g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 7

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "BAN_MENU", pos+1,(  g_menuPlayersNum[id] / 7 + ((g_menuPlayersNum[id] % 7) ? 1 : 0 )) )

	new end = start + 7
	new keys = MENU_KEY_0|MENU_KEY_8
	new flagged[32]

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]


	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i,name,31)

		if(g_player_flagged[i])
			format(flagged, 31, "%L", id, "FLAGGED")
		else
			format(flagged, 31, "")


		if ( (is_user_bot(i)) || (access(i,ADMIN_IMMUNITY)))
		{
			++b
			if ( g_coloredMenus )
				len += format(menuBody[len],511-len,"\d%d. %s\w^n", b, name, flagged)
			else
				len += format(menuBody[len],511-len,"#. %s  %s^n", name, flagged)

		}
		else
		{
			keys |= (1<<b)
			if (is_user_admin(i))
				len += format(menuBody[len],511-len, g_coloredMenus ? "\w%d. %s \r* %s\w^n" : "%d. %s *   %s^n", ++b, name, flagged)
			else
				len += format(menuBody[len],511-len, g_coloredMenus ? "\w%d. %s \r%s\w^n" : "%d. %s   %s^n", ++b, name, flagged)
		}
	}
	
	new iBanLength = g_menuSettings[id]
	new cTimeLength[128]
	if(iBanLength == -1)
		len += format(menuBody[len],511-len, g_coloredMenus ? "\w^n8. %L^n" : "^n8. %L^n", id, "FLAG_PLAYER" )
	else if(iBanLength == 0)
		len += format(menuBody[len],511-len, g_coloredMenus ? "\w^n8. %L^n" : "^n8. %L^n", id, "BAN_PERMANENT")
	else
	{
		get_time_length(id, iBanLength, timeunit_minutes, cTimeLength, 127)

		len += format(menuBody[len],511-len, g_coloredMenus ? "\w^n8. %L^n" : "^n8. %L^n", id, "BAN_FOR_MINUTES", cTimeLength)
	}
	
	if (end != g_menuPlayersNum[id])
	{
		len += format(menuBody[len],511-len,"^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		len += format(menuBody[len],511-len,"^n0. %L", id, pos ? "BACK" : "EXIT")

	len+=format(menuBody[len],1023-len, g_coloredMenus ? "\y^nAmxbans version %s\w^n" : "^nAmxbans version %s^n", VERSION)
	
	show_menu(id,keys,menuBody,-1,"Ban Menu")
}

public cmdBanMenu(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED

	g_menuOption[id] = 0   // This is the first menuoption that is used
	g_menuSettings[id] = get_pcvar_num(firstBanmenuValue)//g_FirstBanMenuValue, this is the first bantime option when you ban with the menu
	displayBanMenu(id,g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}


/* Here comes the reason menu */
public actionBanMenuReason(id,key)
{
	switch (key)
	{
		case 9: // go back to ban menu
		{
			displayBanMenu(id,g_menuPosition[id])
		}

		case 7:
		{
			g_inCustomReason[id]=1
			client_cmd(id,"messagemode amxbans_custombanreason")

			return PLUGIN_HANDLED
		}

		case 8:
		{
			banUser(id,g_lastCustom[id])
		}

		default:
		{
			banUser(id,g_banReasons[key])
		}
	}
	displayBanMenu(id,g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}

//cmdBanReasonMenu(id)
displayBanMenuReason(id)
{
	new menuBody[1024]
	new len = format(menuBody,1023, g_coloredMenus ? "\y%s\R^n\w^n" : "%s^n^n", "Reason")
	new i = 0;

	while (i < g_aNum)
	{
		if (strlen(g_banReasons[i])) // Checks if there is a reason text
			len+=format(menuBody[len],1023-len,"%d. %s^n",i+1,g_banReasons[i])
		
		i++
	}
	
	len+=format(menuBody[len],1023-len,"^n8. Custom^n")
	if (g_lastCustom[id][0]!='^0')
		len+=format(menuBody[len],1023-len,"^n9. %s^n",g_lastCustom[id])

	len+=format(menuBody[len],1023-len,"^n0. %L^n",id,"EXIT")	
	
	len+=format(menuBody[len],1023-len, g_coloredMenus ? "^n\yAmxbans version %s^n" : "^nAmxbans version %s\w^n", VERSION)

	new keys = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_7 | MENU_KEY_8 | MENU_KEY_0

	if (g_lastCustom[id][0]!='^0')
		keys |= MENU_KEY_9

	show_menu(id,keys,menuBody,-1,"Ban Reason Menu")
}

/* This function only sets the custom ban reason */
public setCustomBanReason(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
	{
		return PLUGIN_HANDLED
	}

	new szReason[128]
	read_argv(1,szReason,127)
	copy(g_lastCustom[id],127,szReason)

	if (g_inCustomReason[id])
	{
		g_inCustomReason[id]=0
		banUser(id,g_lastCustom[id])
	}

	return PLUGIN_HANDLED
}


/* id is the player banning, not player being banned :] */
banUser(id,banReason[])
{
	new player = g_bannedPlayer

	new name[32], name2[32], authid[32],authid2[32]
	get_user_name(player,name2,31)
	get_user_authid(player,authid2,31)
	get_user_authid(id,authid,31)
	get_user_name(id,name,31)

	/* lan */
	if ( equal("4294967295", authid2)
	  || equal("HLTV", authid2)
	  || equal("STEAM_ID_LAN",authid2)
	  || equal("VALVE_ID_LAN",authid2)
	  || equal("STEAM_ID_PENDING",authid2)
	  || equal("VALVE_ID_PENDING",authid2))
	{
		new ipa[32]
		get_user_ip(player,ipa,31,1)
		console_cmd(id,"amx_banip %d %s %s" ,g_menuSettings[id],ipa,banReason)
	}
	else
		console_cmd(id,"amx_ban %d %s %s" ,g_menuSettings[id],authid2,banReason)
}


/*************************************************************

   Check banhistory menu
   
*************************************************************/

public actionBanhistoryMenu(id, key)
{
	switch (key)
	{
		case 8: displayBanhistoryMenu(id, ++g_menuPosition[id])
		case 9: displayBanhistoryMenu(id, --g_menuPosition[id])
		default:
		{
			new authid[32]
			new player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]
			
			new banhistMOTD_url[256], msg[2048]
			get_user_authid(player, authid, 31)

			get_pcvar_string(banhistmotd_url, banhistMOTD_url, 255)
			format(msg, 2047, banhistMOTD_url, authid)

			show_motd(id, msg, "Banhistory")
			displayBanhistoryMenu(id, g_menuPosition[id] = 0)
		}
	}
	return PLUGIN_HANDLED
}

displayBanhistoryMenu(id, pos)
{
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 8

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "BANHISTORY_MENU", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
	new end = start + 8
	new keys = MENU_KEY_0|MENU_KEY_8

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (is_user_bot(i))
		{
			++b

			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s\w^n", b, name)
			else
				len += format(menuBody[len], 511-len, "#. %s^n", name)
		} 
		else
		{
			keys |= (1<<b)
			if (is_user_admin(i))
			   len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*\w^n" : "%d. %s *   %s^n", ++b, name)
			else
			    len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s\w^n" : "%d. %s   %s^n", ++b, name)
		}
	}
	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Banhistory Menu")
}

public cmdBanhistoryMenu(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	displayBanhistoryMenu(id, g_menuPosition[id] = 0)
	return PLUGIN_HANDLED
}

flag_player(id)
{
	new player = g_bannedPlayer
	new name[32]
	get_user_name(player, name, 31)
	
	if(!g_player_flagged[player])
	{
		g_player_flagged[player] = true
		client_print(id,print_chat,"[AMXBANS] %L",LANG_PLAYER,"FLAGG_MESS", name)
	}
	else
	{
		g_player_flagged[player] = false
		client_print(id,print_chat,"[AMXBANS] %L",LANG_PLAYER,"UN_FLAGG_MESS", name)
	}

	return PLUGIN_HANDLED
}
