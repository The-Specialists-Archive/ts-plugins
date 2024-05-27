/*

Thanks to:
Hawk552
hjvl
Harbu
*/
#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <ApolloRP_Chat>

// name of the data table
new g_AdminTable[64] = "arp_admin"
new g_AdminLogsTable[64] = "arp_adminlogs"
new g_AdminWeaponsTable[64] = "arp_adminweapons"

new g_Admin[33]
new g_AdminAuthId[36]
new g_AdminManage[33]
new g_AdminWeapon[33]
new g_AdminCvar[33]
new g_AdminCustom[33]

public plugin_init()
{
   ARP_RegisterCmd("say /adminmenu","CmdAdminMenu"," - allows you to switch between characters")

   ARP_AddChat(_,"CmdSay")

   //menu registers

   //main menu
   register_menucmd(register_menuid("Admin Menu"),1023,"action_CmdAdminMenu")

   //management
   register_menucmd(register_menuid("Admin Management"),1023,"action_AdminManage")
   register_menucmd(register_menuid("Add Admin"),1023,"action_AdminManage")
   register_menucmd(register_menuid("Is The New Admin Online?"),1023,"action_AdminManage_Add_Q_Online")
   //register_menucmd(register_menuid("Add New Admin Via Name Or SteamID?"),1023,"action_AdminManage_Add_Q_NameOrSteamID")
   register_menucmd(register_menuid("ChoosePlayer"), 1023, "ChooseMenu")
}

public ARP_Init()
   ARP_RegisterPlugin("GUI Admin","1.0","fennec","Adds a new GUI admin menu.")

public plugin_precache()
   SqlInit()

public SqlInit()
{
   format(g_Query,4095,"CREATE TABLE IF NOT EXISTS %s (authid VARCHAR(36),Manage INT(11),Weapon INT(11),Cvar INT(11),Custom INT(11),UNIQUE KEY (authid))",g_AdminTable)
   UTIL_ARP_CleverQuery(g_Plugin,g_SqlHandle,"IgnoreHandle",g_Query)

   format(g_Query,4095,"CREATE TABLE IF NOT EXISTS %s (authid VARCHAR(36),type INT(11),log VARCHAR(100))",g_AdminLogsTable)
   UTIL_ARP_CleverQuery(g_Plugin,g_SqlHandle,"IgnoreHandle",g_Query)

   format(g_Query,4095,"CREATE TABLE IF NOT EXISTS %s (weponid INT(11),weaponname VARCHAR(36),maxammo INT(11),flags INT(11),banned INT(11))",g_AdminWeaponsTable)
   UTIL_ARP_CleverQuery(g_Plugin,g_SqlHandle,"IgnoreHandle",g_Query)
}

public CmdAdminMenu(id)
{
   _AdminAccess(id)
   if(g_Admin[id] = 0)
      client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")

   //Add admin log? record when menu opend hence last used admin <======================================================

   new Menu[256]
   new key = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9)
   add(Menu,255,"Admin Menu^n^n")
   add(Menu,255,"1. Admin Managment^n")
   if(g_AdminManage[id] > 0)
      add(Menu,255,"2. Weapon Spawn Menu^n")
   else
      add(Menu,255,"#. Weapon Spawn Menu - No Access^n")
   if(g_AdminCvar[id] > 0)
      add(Menu,255,"3. Cvar Menu^n")
   else
      add(Menu,255,"#. Cvar Menu - No Access^n")
   add(Menu,255,"4. Kick Menu^n")
   add(Menu,255,"5. Ban Menu^n")
   if(g_AdminCustom[id] > 0)
      add(Menu,255,"6. Custom Server Options^n^n")
   else
      add(Menu,255,"#. Custom Server Options - No Access^n")
   add(Menu,255,"0. Close Menu")
   show_menu(id,key,menu)
}

public CmdAdminMenu(id,key)
{
   switch(key)
   {
      case 0:
         _AdminManage(id)
      case 1:
      {
         if(g_AdminManage[id] > 0)
            _AdminWeapons(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            CmdAdminMenu(id)
         }
      }
      case 2:
      {
         if(g_AdminCvar[id] > 0)
            _AdminCvar(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            CmdAdminMenu(id)
         }
      }
      case 3:
         kickmenu(id) // Find out about these menus <=====================================================================
      case 4:
         banmenu(id)
      case 5:
      {
         if(g_AdminCustom[id] > 0)
            _AdminCustom(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            CmdAdminMenu(id)
         }
      }
      case 9:
      {
         client_print(id,print_chat,"[GUIAdmin] Menu closed.^n")
      }
   }   
}
   
public _AdminAccess(id)
{
   new Authid[36]
   get_user_authid(id,Authid[id],35)

   format(g_Query,4095,"SELECT * FROM arp_admin WHERE authid= '%s'",Authid[id])
   UTIL_ARP_CleverQuery(g_Plugin,g_SqlHandle,"IgnorHandle",g_Query)

   if(SQL_NumResults(Query) < 1)
   {
      g_Admin[id] = 0
      return PLUGIN_HANDLED
   }
   else
      g_Admin[id] = 1

   SQL_ReadResult(Query,0,g_AdminAuthId[id],63)
   SQL_ReadResult(Query,1,g_AdminManage[id],63)
   SQL_ReadResult(Query,2,g_AdminWeapon[id],63)
   SQL_ReadResult(Query,3,g_AdminCvar[id],63)
   SQL_ReadResult(Query,4,g_AdminCustom[id],63)
   return PLUGIN_HANDLED
}

public _AdminManage(id)
{
   new Menu[256]
   new key = (1<<0|1<<1|1<<2|1<<9)
   add(Menu,255,"Admin Management^n^n")
   if(g_AdminManage[id] = 2)
      add(Menu,255,"1. Add Admin^n")
   else
      add(Menu,255,"#. Add Admin - No Access^n")
   if(g_AdminManage[id] = 2)
      add(Menu,255,"2. Remove Admin^n")
   else
      add(Menu,255,"#. Remove Admin - No Access^n")
   if(g_AdminManage[id] = 2)
      add(Menu,255,"3. Set Admin Access^n")
   else
      add(Menu,255,"#. Set Admin Access - No Access^n")
   add(Menu,255,"^n5. Admin Logs^n^n")
   add(Menu,255,"0. Return To Main Menu^n")
   show_menu(id,key,menu)
}

public action_AdminManage(id,key)
{
   switch(key)
   {
      case 0:
      {
         if(g_AdminManage[id] = 2)
            _AdminManage_Add_Q(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            _AdminManage(id)
         }
      }
      case 1:
      {
         if(g_AdminManage[id] = 2)
            _AdminManage_Remove(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            _AdminManage(id)
         }
      }
      case 2:
      {
         if(g_AdminManage[id] = 2)
            _AdminManage_SetAccess(id)
         else
         {
            client_print(id,print_chat,"[GUIAdmin] You do not have access to this menu.^n")
            _AdminManage(id)
         }
      }
      case 4:
         _LogsMenu(id)
      case 9:
      {
         client_print(id,print_chat,"[GUIAdmin] You have returned to the main menu.^n")
         CmdAdminMenu(id)
      }
   }
}

public _AdminManage_Add_Q_Online(id)
{
   new Menu[256]
   new key = (1<<0|1<<1|1<<9)
   add(Menu,255,"Is The New Admin Online?^n^n")
   add(Menu,255,"1. Yes^n")
   add(Menu,255,"2. No and Add Manualy^n^n")

   add(Menu,255,"0. Cancel And Return To Management Menu^n")
   show_menu(id,key,menu)
}

public action_AdminManage_Add_Q_Online(id,key)
{
   switch(key)
   {
      case 0:
         _OnlinePlayerList(id)
      case 1:
      {
         //_AdminManage_Add_Q_NameOrSteamID(id)
         _TotalPlayerList(id)
      }
      case 9:
      {
         client_print(id,print_chat,"[GUIAdmin] You have returned to the main menu.^n")
         _AdminManage(id)
      }
   }
}

/*
public _AdminManage_Add_Q_NameOrSteamID(id)
{
   new Menu[256]
   new key = (1<<0|1<<1|1<<9)
   add(Menu,255,"Add New Admin Via Name Or SteamID?^n^n")
   add(Menu,255,"1. Name^n")
   add(Menu,255,"2. SteamID^n^n")

   add(Menu,255,"0. Cancel And Return To Management Menu^n")
   show_menu(id,key,menu)
}

public action_AdminManage_Add_Q_NameOrSteamID(id,key)
{
   switch(key)
   {
      case 0:
         _TotalPlayerList(id)
      case 1:
         _GetText(id)
      case 9:
      {
         client_print(id,print_chat,"[GUIAdmin] You have returned to the main menu.^n")
         _AdminManage(id)
      }
   }
}
*/

//Thanks to hjvl, from voteban menu, v1.2, lines 97-150
public _OnlinePlayerList(id)
{
   new arrayloc = 0
   new keys = (1<<9)

   arrayloc = format(ga_MenuData,(MAX_menudata-1),"Add New Admin Menu^n")
   for(i=0; i<8; i++)
      if( gi_TotalPlayers>(gi_MenuPosition+i) )
      {
         arrayloc += format(ga_MenuData[arrayloc],(MAX_menudata-1-arrayloc),"%d. %s^n", i+1, ga_PlayerName[gi_MenuPosition+i])
         keys |= (1<<i)
      }
   if( gi_TotalPlayers>(gi_MenuPosition+8) )
   {
      arrayloc += format(ga_MenuData[arrayloc],(MAX_menudata-1-arrayloc),"^n9. More")
      keys |= (1<<8)
   }
   if(gi_MenuPosition>=8)
   {
      arrayloc += format(ga_MenuData[arrayloc],(MAX_menudata-1-arrayloc),"^n0. Back")
   }
   else
      arrayloc += format(ga_MenuData[arrayloc],(MAX_menudata-1-arrayloc),"^n0. Cancel And Return To Management Menu")

   show_menu(id, keys, ga_MenuData, 20, "ChoosePlayer")
   return PLUGIN_HANDLED 
}

public ChooseMenu(id,key)
{
   switch(key)
   {
      case 8:
      {
         gi_MenuPosition=gi_MenuPosition+8
         ShowPlayerMenu(id)
      }
      case 9:
      {
         if(gi_MenuPosition>=8)
         {
            gi_MenuPosition=gi_MenuPosition-8
            ShowPlayerMenu(id)
         }
         else
            _AdminManage(id)
      }
      default:
      {
         gi_Sellection=gi_MenuPosition+key
         new Now=get_systime(gi_SysTimeOffset)
         set_pcvar_num(gi_LastTime, Now)
         _AddAdminQuery(id)
      }
   }
   return PLUGIN_HANDLED
}

public _AdminWeapons(id)
{
   client_print(id,print_chat,"[GUIAdmin] Menu unavalable.^n")
   CmdAdminMenu(id)
}

public _AdminCvar(id)
{
   client_print(id,print_chat,"[GUIAdmin] Menu unavalable.^n")
   CmdAdminMenu(id)
}

public _AdminCustom(id)
{
   client_print(id,print_chat,"[GUIAdmin] Menu unavalable.^n")
   CmdAdminMenu(id)
}