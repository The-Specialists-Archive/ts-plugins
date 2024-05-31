/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover

		web		: http://amxbans.net/
		IRC		: #hlm (Quakenet, nickname lantz69)
		IRC2		: #amxmodx (GameSurge, nickname lantz69)

		This file is part of AMXBans.

	AMXBans is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	AMXBans is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with AMXBans; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	Check out readme.html for more information


	Current version: v5.0
	--------------------------------------------------------------
	Changelog for Plugin Amxbans changes/fixes by lantz69 after version 4.0 by YoMama
	--------------------------------------------------------------
	
	
	5.0 Sat Oct 28, 2006 16:00
	- Fixed: runtime error when trying to ban admin with immunity
	

	4.4RC6 Wed Oct 04, 2006 18:39
	- Changed: Cvar amxbans_max_time_gone_to_unban was changed from seconds to minutes instead.
	- Changed: Cvar amxbans_max_time_to_show_preban was changed from seconds to days instead.
	- Updated: The langfile amxbans.txt with all the static ban reasons. (thx Gizmo)
	- Updated: amxbans.cfg with the new values that was changed to minutes/days. Also updated text and the order of the settings.
	- Removed: [ru] Rushian language had to be removed in amxbans.txt because it is not in the official Amxmodx.
	- Added: Block for multiple bans with ATAC when the player was not present in the server (rep. Scooby)
	- Changed: Now you see 7 players/page in the menu instead of only 6.
	- Changed: now you can have 1-12 bantimes in the menu. See amxbans.cfg (done by Gizmo)
	- Fixed: If player has VALVE_ID_PENDING the ban will be an IP ban (LAN Servers)
	- Removed: replaceall func. Now using the replace_all func from amxmodx instead.
	- Changed: Banhistory Menu is now automatically loaded to the amxmodx menu
	
	4.4RC5 Mon Sep 18, 2006 16:58
	- Fixed: The banmenu did not get enabled at once when a new server was added.
	- Fixed: amx_list is now a server command. (rep. Mayhem)
	- Added: Extra check for bad characters in ban_reason for sql query.
	- Changed: Now uses the new replace_all func from amxmodx to have safe sql queries
	- Fixed: An INSERT query for mysql 5.x servers that have Set the SQL mode to STRICT...
	- Fixed: motd when using motdURL (ONLY LAN Servers)
	- Added: amxbans.cfg that should be in addons/amxmodx/configs/ (thx. Gizmo)
	- Fixed: Bantime in console must be a number and can not be text anymore.
	- Fixed: Menu sometimes made non admins red. (thx. Gizmo)

	4.4RC4 Fri Sep 08, 2006 9:12
	- Fixed: The connection info to the sql server was set to late on mapchange.

	4.4RC3 Wed Sep 06, 2006 2:33
	- Changed: Optimized the code by removing a redundant function.
	- Changed: Made the pruning of bans better and at the same time fixed an issue for LAN bans.
	- Fixed: Amxbans interfered with other plugins like timeleft to not function properly (server_exec())
	- Added: The banned Player nick is shown to the banned player that reconnect to the server (sugg. rhino)
	- Added: The banannounce will also print to console and not only to chat.
	- Updated: The lang file amxbans.txt
	- Fixed: Another mix of lang in rare circumstances

	4.4RC2 Sun Sep 03, 2006 18:31
	- Added: New cvar amxbans_show_name_evenif_mole If you have this set to 1 the showacivity system will not be overidden.
	- Added: New compiler option ADMIN_MOLE_ACCESS to be able to choose which admin flag the admin must have to be a mole.
	- Added: New flagsystem by Gizmo so you can mark a player being checked out. That is found in the ban menu by changing bantimes.
					 This is useful if you are recording a demo for proof and dont want another admin to ban him right away.
	- Fixed: UnBan was broken.
	
	4.4RC1 Sat Sep 02, 2006 10:53
	- Fixed: language was sometimes wrong/mixed in messages in logs or to players.
	- Changed: removed redundant functions and some debug code
	- Changed: pcvar is now used (thx Gizmo)
	- Added: New cvar amxbans_show_prebans_from_atac 1 // neohasses custom to not report/count expired atac bans in the amx_chat to admins

	4.4b13 Sun Aug 27, 2006 14:03
	- Fixed: Bug with prebanned showed wrong info sometimes.
	- Added: New cvar amxbans_max_time_to_show_preban "999999999" // How many seconds must go if the ban should not count
		This cvar is useful if you dont want to show 6 months old bans or maybe 1-2 year old bans in the bancount report to admins in amx_chat.
	- Update: lang file amxbans.txt
	- Changed: Optimized code (thx Gizmo)

	4.4b12 Fri Aug 18, 2006 18:48
	- Fixed: Some old unnecesary variables.
	- Fixed: banmenu was not updated
	- Update: lang file amxbans.txt removed old strings

	4.4b11 Sun Jul 30, 2006 22:31
	- Changed: Gizmo converted amxbans to threaded sqlX (Very big thx)
	- Fixed: Lan bans could get same IP on all db rows sometimes.
	- Fixed: Bancounts printed to adminis on LAN servers was wrong.
	- Added: Added compile option #define SHOW_IN_HLSW To be able to disable the greed hud when a player is banned.
	- Added: Added compile option #define SHOW_HUD_MESSAGES To be able to remove bans being showed as green hudmessage

	4.4b10 Sat Jul 22, 2006 12:12
	- Fixed: Multiple bantimes on the same steamID
	- Fixed: If a ban is done by the ATAC plugin, the adminNick will be [ATAC]
	- Fixed: Banning admin with immunity or a bot from console generated wrong output
	
	4.4b9 Thu May 25, 2006 15:51 (CVS)
	- Fixed: Banmenu showed wrong bantimes
	- Added: Optional SQL connection type <Persistant|NonPersistant> Persistant is default
	- Updated: amxbans.txt (Langfile)
	- Fixed: SQL-fix for amxmodx 1.75 (thx teame06)

	4.4b8 Sun May 21, 2006 12:26 (CVS) 
	- Changed: Static reasons is auto loaded if none is found in database
	- Fixed: Only the reasons added in database will show in menu. No more the number and emty reason.(Prevents blank resons)
	- Added: The banmenu will now show the bantime in weeks, days, hours instead of only minutes
	- Added: new compiler option (g_FirstBanMenuValue) to be able to set the first ban time in the menu (in minutes)
	- Updated: More language strings added in the langfile amxbans.txt
	
	4.4b7 Fri May 12, 2006 12:04 (CVS)
	- Changed: The sql connection is not persistent anymore
		
	4.4b6 Mon Apr 24, 2006 20:16 (CVS)
	- Added: New CVAR amxbans_show_prebanned <0|1> which show if a player has been banned before as amx_chat to admins.
	- Added: New CVAR amxbans_show_prebanned_num <1,2,3,...> How many offences should the player have atleast to notify admins?
	- Fixed: hudmessages was not properly translated to players
		
	4.4b5 Fri Apr 14, 2006 13:59 (CVS)
	- Merged sql_ban() into cmdBan()
	- Added: New cvar amxbans_complain_url so banned players know where to complain :D
	- Added: All strings are now translated (except debugmessages)
	- Added: A green Hudmessage will show when you ban a player.
	- Added: Normal admins (d-flag) can only unban if the ban is max 1 day old
					 This can be configured with the define in the amxbans.sma (MAX_TIME_GONE_TO_UNBAN)
	- Updated: amxbans.txt (Languagefile)
	- Removed: steamID pending check. But if a player has STEAM_ID_PENDING when banning his IP will be banned instead of steamID.

	4.4b4 Thu Apr 13, 2006 15:34 (CVS)
	- Changed: HLTV will be checked when connecting
	- Added: InGame amx_unban command. Syntax: amx_unban <STEAMID>
	- Updated: amxbans.txt (Languagefile)

	4.4b3 Wed Mar 15, 2006 22:52 (CVS)
	- Changed: AMXMODX 1.70 is now required
	- Changed: Brads time functions is now used from the amxmodx includes instead.
	- Updated: amxbans.txt (Languagefile)

	4.4b2 Wed Mar 15, 2006 20:31 (CVS)
	- Added: If a ban is done by ATAC or HLGUARD the adminname will be [ATAC] OR [HLGUARD] in the banlist
	- Changed: Optimized the two ban functions to one ban function

	4.4b1 Mon Nov 7, 2005 19:21 (CVS)
	- Fixed: Baning on LAN only bans the IP and not the authid
	- Fixed: The Ban menu now also only bans the IP if the server is on a LAN
	- Fixed: Now you can ban using IP again (amx_ban <time> <IP> <reason>)
	- Added: 2 More bantimes (total 6)
	- Added: new CVAR amxbans_ban_evenif_disconnected ( default 0 )
	  This is to be able to ban a steamID even if the player is not on the server.

	------------------------------------------------------------
	4.3 Friday October 28, 2005
	- Fixed: MOTDURL in amxbans web Interface was broken in 4.2 (reported by QuakerOates)
	- Fixed: amx_find & amx_findex got an error when no result was found.(reported by QuakerOates)
	- Fixed: Better filtering of data before it goes to a mysql query.
	- Added: log_amx commands to make all sql errors write to the amxmodx/logs.
	- Changed: New method of banning players to minimize bad data to the DB.
	  You can enable the old system by commenting #define USE_NEW_BANMETHOD
	- Fixed: Removed some dbi_free_result that should not be there. (reported by Janet J)
	- Fixed: (DOD) When banning with HLSW or in server console an error would occour. (reported by [MUPPETS]Gonzo])
	- Added: A check for STEAM_ID_PENDING so they will be kicked.
	  a new cvar is added for the above amxbans_steamid_pending 1 enabled 0 disabled (default 1)
	- Added: new cvar amxbans_servernick to be able to set the admin name you want to have when the server bans with Ie. hlsw, atac or hlguard
	         this was requested by Us3r.

	-------------------------------------------------------------
	4.2 Thursday October 13, 2005
	- Changed: Merged amxbans and amxbans_menu into one plugin (amxbans_4.2.sma).
	- Added: Made defines at the top of source to make it easy to change bantimes etc.
	- Changed: Rearranged the functions and changed the coding style.
	- Fixed: The get port bug is solved. Before the port always was 27015 even if the server was 27017 or another port.
	- Fixed: Some data was not written to the data base correctly when player pruned the data base himself
	- Changed: Now you get the bantime in weeks, days, hours, minutes and seconds instead of only minutes (thx Brad Jones)
	- Recomendation: Dont use the MOTDURL from the web. You should use the one in the plugin as it is more reliable and faster.
	- Fixed: amx_find now works and searches the active amx_ban table. Syntax: amx_find <steamID>.
	- Added: amx_findex searches in the expired ban_history table. Syntax: amx_findex <steamID>.
	- Fixed: Banmenu reasons could max be 6 now it can be 7 like it should (thx DerProfi)
	- Added: The map name can be added to the servername in the ban. This is by Default disabled.
	- Added: New cvar amxbans_debug <1|0>. Use this if you want to debug false kicked players.
	- Changed: Implemented Brad Jones function to get hours,days week in HLSW chat and amxx logs (thx Brad Jones)
	- Updated: Language file amxmodx\data\lang\amxbans.txt is updated. Dont forget to update or amxbans 4.2 won't work properly

	--------------------------------------------------------------
	4.1 Fri Sep 23, 2005
	- Added so admins with the d-flag can ban max 600 minutes in console.
	- Added so admins with the d-flag AND n-flag can ban whatever time they like in console and will also get higher bantimes in the menu.
	- Fixed an issue when a string was formatted incorrectly when banning.
	- Changed the way results from the data base are handled to ged rid of memory leaks.
	- Fixed so you can compile when you want STATIC REASONS and not reasons from the DB.

	--------------------------------------------------------------
	4.01 Sun Sep 04, 2005
	- Fixed some result variables that where wrong and crashed the server when using amxmodx 1.50 and later versions.
	- Fixed when a recently banned player comes back after ban is expired. Now the data base gets pruned correctly.
	- Fixed so Bots don't triggers errors in the logs when connecting.
	- Changed so players recieve better info when they get kicked when they are banned.

*/

new AUTHOR[] = "YoMama/Lux & lantz69 -Sqlx by Gizmo"
new PLUGIN_NAME[] = "AMXBans"
new VERSION[] = "5.0" // This is used in the plugins name

new amxbans_version[] = "amxx_5.0" // This is for the DB

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <time>

// Amxbans .inl files
#include "amxbans/global_vars.inl"
#include "amxbans/init_functions.inl"
#include "amxbans/check_player.inl"
#include "amxbans/menu.inl"
#include "amxbans/cmdBan.inl"
#include "amxbans/cmdUnban.inl"
#include "amxbans/search.inl"

// 16k * 4 = 64k stack size
#pragma dynamic 16384 		// Give the plugin some extra memory to use

public plugin_init()
{

	register_concmd("amx_reloadreasons", "reasonReload", ADMIN_CFG)

	register_clcmd("amx_banmenu", "cmdBanMenu", ADMIN_BAN, "- displays ban menu") //Changed this line to make this menu come up instead of the normal amxx ban menu
	register_clcmd("amxbans_custombanreason", "setCustomBanReason", ADMIN_BAN, "- configures custom ban message")
	register_clcmd("amx_banhistorymenu", "cmdBanhistoryMenu", ADMIN_BAN, "- displays banhistorymenu")
	
	register_menucmd(register_menuid("Ban Menu"), 1023, "actionBanMenu")
	register_menucmd(register_menuid("Ban Reason Menu"), 1023, "actionBanMenuReason")
	register_menucmd(register_menuid("Banhistory Menu"), 1023, "actionBanhistoryMenu")

	g_coloredMenus = colored_menus()
	g_MyMsgSync = CreateHudSyncObj()

	register_plugin(PLUGIN_NAME, VERSION, AUTHOR)
	register_cvar("amxbans_version", VERSION, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)

	amxbans_cmd_sql = register_cvar("amxbans_cmd_sql", "0") // A custom plugin that is not released yet so dont touch this cvar.
	amxbans_debug = register_cvar("amxbans_debug", "0") // Set this to 1 to enable debug
	server_nick = register_cvar("amxbans_servernick", "") // Set this cvar to what the adminname should be if the server make the ban.
																											  // Ie. amxbans_servernick "My Great server" put this in server.cfg or amxx.cfg
	ban_evenif_disconn = register_cvar("amxbans_ban_evenif_disconnected", "0") // 1 enabled and 0 disabled ban of players not in server
	complainurl = register_cvar("amxbans_complain_url", "www.yoursite.com") // Dont use http:// then the url will not show
	show_prebanned = register_cvar("amxbans_show_prebanned", "1") // Will show if a player has been banned before as amx_chat to admins. 0 to disable
	show_prebanned_num = register_cvar("amxbans_show_prebanned_num", "2") // How many offences should the player have to notify admins?
	max_time_to_show_preban = register_cvar("amxbans_max_time_to_show_preban", "9999") // How many days must go if the ban should not count
	banhistmotd_url = register_cvar("amxbans_banhistmotd_url","http://pathToYour/findex.php?steamid=%s")
	show_atacbans = register_cvar("amxbans_show_prebans_from_atac", "1") // neohasses custom to not count or count atac bans in the chat to admins
	show_name_evenif_mole = register_cvar("amxbans_show_name_evenif_mole", "1")
	firstBanmenuValue = register_cvar("amxbans_first_banmenu_value", "5")
	consoleBanMax = register_cvar("amxbans_consolebanmax", "1440")
	max_time_gone_to_unban = register_cvar("amxbans_max_time_gone_to_unban", "1440") // This is set in minutes
	higher_ban_time_admin = register_cvar("amxbans_higher_ban_time_admin", "n")
	admin_mole_access = register_cvar("amxbans_admin_mole_access", "r")
	show_in_hlsw = register_cvar("amxbans_show_in_hlsw", "1")
	show_hud_messages = register_cvar("amxbans_show_hud_messages", "1")
	add_mapname_in_servername = register_cvar("amxbans_add_mapname_in_servername", "0")
	
	register_dictionary("amxbans.txt")
	register_dictionary("common.txt")
	register_dictionary("time.txt")

	register_concmd("amx_ban", "cmdBan", ADMIN_BAN, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
	register_srvcmd("amx_ban", "cmdBan", -1, "<time in min> <steamID or nickname or #authid or IP> <reason>")
	register_concmd("amx_banip", "cmdBan", ADMIN_BAN, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
	register_srvcmd("amx_banip", "cmdBan", -1, "<time in mins> <steamID or nickname or #authid or IP> <reason>")
	register_concmd("amx_unban", "cmdUnBan", ADMIN_BAN, "<steamID>")
	register_srvcmd("amx_unban", "cmdUnBan", -1, "<steamID>")
	register_concmd("amx_find", "amx_find", ADMIN_BAN, "<steamID>")
	register_srvcmd("amx_find", "amx_find", -1, "<steamID>")
	register_concmd("amx_findex", "amx_findex", ADMIN_BAN, "<steamID>")
	register_srvcmd("amx_findex", "amx_findex", -1, "<steamID>")
	register_srvcmd("amx_list", "cmdLst", -1, "Displays playerinfo")
	register_srvcmd("amx_sethighbantimes", "setHighBantimes")
	register_srvcmd("amx_setlowbantimes", "setLowBantimes")

	new configsDir[64]
	get_configsdir(configsDir, 63)

	new configfile[128]
	format(configfile, 127, "%s/amxbans.cfg", configsDir)
	
	server_cmd("exec %s/sql.cfg", configsDir)
	if(file_exists(configfile))
	{
		server_cmd("exec %s", configfile)
	}
	else
	{
		loadDefaultBantimes(0)
		server_print("[AMXBANS] Could not find amxbans.cfg, loading default bantimes")
		log_amx("[AMXBANS] Could not find amxbans.cfg, loading default bantimes")
		log_amx("[AMXBANS] You should put amxbans.cfg in addons/amxmodx/configs/")
	}
	//server_exec() // Made other plugins dont work properly b/c settings in amxx.cfg was not read properly

	set_task(0.5, "sql_init")
	set_task(5.0, "addBanhistMenu")

}

public addBanhistMenu()
	AddMenuItem("Banhistory Menu", "amx_banhistorymenu", ADMIN_BAN, "AMXBans")

public sql_init()
{
	new host[64], user[64], pass[64], db[64]

	get_cvar_string("amx_sql_host", host, 63)
	get_cvar_string("amx_sql_user", user, 63)
	get_cvar_string("amx_sql_pass", pass, 63)
	get_cvar_string("amx_sql_db", db, 63)

	g_SqlX = SQL_MakeDbTuple(host, user, pass, db)
	
	set_task(1.0, "banmod_online")
	set_task(1.0, "fetchReasons")
}

public reasonReload(id,level,cid)
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	else
	{	
		fetchReasons(id)
		
		if (id != 0)
		{
			if (g_aNum == 1)
				console_print(id,"[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASON" )
			else
				console_print(id,"[AMXBANS] %L", LANG_SERVER, "SQL_LOADED_REASONS", g_aNum )
		}
	}

	return PLUGIN_HANDLED
}

public client_connect(id)
{
	if( (id > 0 || id < 32) && is_user_connected(id) )
	{
		g_lastCustom[id][0] = '^0'
		g_inCustomReason[id] = 0
		g_player_flagged[id] = false
		g_being_banned[id] = false
	}
	
}

public client_disconnect(id)
{
	g_lastCustom[id][0] = '^0'
	g_inCustomReason[id] = 0
	g_player_flagged[id] = false
	g_being_banned[id] = false
}

public client_authorized(id)
{
	if (get_pcvar_num(show_prebanned) == 1)
	{
		set_task(1.0, "prebanned_check", id)
	}
	set_task(1.1, "check_player", id)

	return PLUGIN_CONTINUE
}

public delayed_kick(id_str[])
{
	new player_id = str_to_num(id_str)
	new userid = get_user_userid(player_id)
	new kick_message[128]
	format(kick_message,127,"%L", LANG_PLAYER,"KICK_MESSAGE")

	if ( get_pcvar_num(amxbans_debug) == 1 )
		log_amx("[AMXBANS DEBUG] Delayed Kick ID: <%s>", id_str)

	server_cmd("kick #%d  %s",userid, kick_message)
	
	return PLUGIN_CONTINUE
}

/*********    This is used by live ban on the webpages     ************/
public cmdLst(id,level,cid)
{
	new players[32], inum, authid[32],name[32],ip[50]

	get_players(players,inum)
	console_print(id,"playerinfo")

	for(new a = 0; a < inum; a++)
	{
		get_user_ip(players[a],ip,49,1)
		get_user_authid(players[a],authid,31)
		get_user_name(players[a],name,31)
		console_print(id,"#WM#%s#WMW#%s#WMW#%s#WMW#",name,authid,ip)
	}

	return PLUGIN_HANDLED
}

public get_higher_ban_time_admin_flag()
{
	new flags[24]
	get_pcvar_string(higher_ban_time_admin, flags, 23)
	
	return(read_flags(flags))
}

public get_admin_mole_access_flag()
{
	new flags[24]
	get_pcvar_string(admin_mole_access, flags, 23)
	
	return(read_flags(flags))
}

/* This function will attempt to find a player based on the following options:
	- Partial Player Name
	- Steam ID
	- User ID
	- User IP Address
*/
public locate_player(id, identifier[])
{

	g_ban_type = "S"

	// Check based on steam ID
	new player = find_player("c", identifier)

	// Check based on a partial non-case sensitive name
	if (!player) {
		player = find_player("bl", identifier)
	}

	if (!player) {
		// Check based on IP address
		player = find_player("d", identifier)

		if ( player )
			g_ban_type = "SI"
	}

	// Check based on user ID
	if ( !player && identifier[0]=='#' && identifier[1] ) {
		player = find_player("k",str_to_num(identifier[1]))
	}

	if ( player )
	{
		/* Check for immunity */
		if (get_user_flags(player) & ADMIN_IMMUNITY) {
			new name[32]
			get_user_name(player, name, 31)
			if( id == 0 )
				server_print("[AMXBANS] Client ^"%s^" has immunity", name)
			else
				console_print(id,"[AMXBANS] Client ^"%s^" has immunity", name)
			return -1
		}
		/* Check for a bot */
		else if (is_user_bot(player)) {
			new name[32]
			get_user_name(player, name, 31)
			if( id == 0 )
				server_print("[AMXBANS] Client ^"%s^" is a bot", name)
			else
				console_print(id,"[AMXBANS] Client ^"%s^" is a bot", name)
			return -1
		}

	}
	return player
}

public setHighBantimes()
{
	new arg[32]
	new argc = read_argc() - 1
	g_highbantimesnum = argc
	//server_print("args: %d", argc)

	if(argc < 1 || argc > 12)
	{
		log_amx("[AMXBANS] You have more than 12 or less than 1 bantimes set in amx_sethighbantimes")
		log_amx("[AMXBANS] Loading default bantimes")
		loadDefaultBantimes(1)

		return PLUGIN_HANDLED
	}

	new i = 0
	new num[32], flag[32]
	while (i < argc)
	{
		read_argv(i + 1, arg, 31)
		parse(arg, num, 31, flag, 31)
		//server_print("Num: %s, Flag: %s", num, flag)

		if(equali(flag, "m"))
		{ 
			g_HighBanMenuValues[i] = str_to_num(num)
		}
		else if(equali(flag, "h"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 60)
		}
		else if(equali(flag, "d"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 1440)
		}
		else if(equali(flag, "w"))
		{
			g_HighBanMenuValues[i] = (str_to_num(num) * 10080)
		}
		//server_print("HighBantime: %d", str_to_num(num))

		i++
	}
	return PLUGIN_HANDLED
}

public setLowBantimes()
{
	new arg[32]
	new argc = read_argc() - 1
	g_lowbantimesnum = argc
	//server_print("args: %d", argc)
	if(argc < 1 || argc > 12)
	{
		log_amx("[AMXBANS] You have more than 12 or less than 1 bantimes set in amx_setlowbantimes")
		log_amx("[AMXBANS] Loading default bantimes")
		loadDefaultBantimes(2)
		
		return PLUGIN_HANDLED
	}

	new i = 0
	new num[32], flag[32]
	while (i < argc)
	{
		read_argv(i + 1, arg, 31)
		parse(arg, num, 31, flag, 31)
		//server_print("Num: %s, Flag: %s", num, flag)

		if(equali(flag, "m"))
		{ 
			g_LowBanMenuValues[i] = str_to_num(num)
		}
		else if(equali(flag, "h"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 60)
		}
		else if(equali(flag, "d"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 1440)
		}
		else if(equali(flag, "w"))
		{
			g_LowBanMenuValues[i] = (str_to_num(num) * 10080)
		}
		//server_print("LowBantime: %d", str_to_num(num))

		i++
	}
	return PLUGIN_HANDLED
}

loadDefaultBantimes(num)
{
	if(num == 1 || num == 0)
		server_cmd("amx_sethighbantimes 5 60 240 600 6000 0 -1")
	if(num == 2 || num == 0)
		server_cmd("amx_setlowbantimes 5 30 60 480 600 1440 -1")
}

/*********  Error handler  ***************/
MySqlX_ThreadError(szQuery[], error[], errnum, failstate, id)
{
	
	if (failstate == TQUERY_CONNECT_FAILED)
	{
		log_amx("%L", LANG_SERVER, "TCONNECTION_FAILED")
	}
	else if (failstate == TQUERY_QUERY_FAILED)
	{
		log_amx("%L", LANG_SERVER, "TQUERY_FAILED")
	}
	log_amx("%L", LANG_SERVER, "TQUERY_ERROR", id)
	log_amx("%L", LANG_SERVER, "TQUERY_MSG", error, errnum)
	log_amx("%L", LANG_SERVER, "TQUERY_STATEMENT", szQuery)
}

public plugin_end()
{
	SQL_FreeHandle(g_SqlX)
}
