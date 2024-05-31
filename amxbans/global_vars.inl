
// Specify tablenames here
#define tbl_reasons "amx_banreasons"
#define tbl_svrnfo "amx_serverinfo"
#define tbl_bans "amx_bans"
#define tbl_banhist "amx_banhistory"

// For hudmessages
new g_MyMsgSync

// Variables for menus
new g_LowBanMenuValues[12]
new g_HighBanMenuValues[12]
new g_coloredMenus
new g_banReasons[7][128]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_menuPosition[33]
new g_menuOption[33]
new g_menuSettings[33]
new g_bannedPlayer
new g_lastCustom[33][128]
new g_inCustomReason[33]
new bool:g_player_flagged[33]
/*****************************/

// pcvars
new amxbans_cmd_sql
new amxbans_debug
new server_nick
new ban_evenif_disconn
new complainurl
new show_prebanned
new show_prebanned_num
new max_time_to_show_preban
new banhistmotd_url
new show_atacbans
new show_name_evenif_mole
new firstBanmenuValue
new consoleBanMax
new max_time_gone_to_unban
new higher_ban_time_admin
new admin_mole_access
new show_in_hlsw
new show_hud_messages
new add_mapname_in_servername

/*****************************/

new Handle:g_SqlX

new g_aNum = 0
new g_ip[32]
new g_port[10]
new ban_motd[4096]
new Float:kick_delay = 10.0
new g_highbantimesnum
new g_lowbantimesnum

/*****************************/

// For the cmdBan.inl
new g_steamidorusername[50] // Only used if the player is not on the server.
new g_ban_reason[256]
new g_ban_type[4] // String that contains "S" for steamID ban and "SI" for IP ban
new bool:g_being_banned[33]

// For the cmdUnban.inl
new g_player_nick[50]
new g_unban_player_steamid[50]
new g_unban_admin_nick[100] //Big b/c it can also be the servername
new g_admin_steamid[50]
new g_unban_admin_team[10]

/*****************************/
