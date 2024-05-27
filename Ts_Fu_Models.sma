//AMXMODX Kung-Fu Model Mod by Pinkfairie for TS
//Model by TS Development Team
//
//Enjoy

#include <amxmodx>
#include <engine>
#include <tsx>
#include <tsfun>
#include <fakemeta>

new Fu_Ent;
new Fu_Set[33];
new Fu_Death_Set[33];
new Fu_Last_Roll[33];
new Float:Fu_Overflow[33];
new Fu_Kick_Toggle[33];

public client_PreThink(id) //Prethink
{
	if(is_user_connected(id)==0)return PLUGIN_HANDLED;
	if(is_user_alive(id)==0)
	{	
		Fu_Death_Set[id] = 1;
		return PLUGIN_HANDLED;
	}
	new Fu_Weapon,Fu_Clip,Fu_Ammo,Fu_Mode,Fu_Addons;
	Fu_Weapon = ts_getuserwpn(id,Fu_Clip,Fu_Ammo,Fu_Mode,Fu_Addons);
	if((Fu_Weapon == 0 || Fu_Weapon == 36) && Fu_Death_Set[id] == 1) //If In Fu and Spawn Check
	{
		Fu_Death_Set[id] = 0;
		set_pev(id,pev_viewmodel,Fu_Ent);
		set_pev(id,pev_weaponanim,1);
			
	}
	if(Fu_Weapon!=0 && Fu_Weapon!=36) //If Not In Fu
	{
		Fu_Set[id] = 0;
	}
	if(Fu_Weapon == 0 || Fu_Weapon == 36) //If In Fu
	{
		new Fu_Trigger;
		Fu_Trigger = entity_get_int(id,EV_INT_button);
		if(Fu_Trigger & IN_ATTACK) //If Punching
		{
			if(get_gametime() < Fu_Overflow[id] + 0.25)return PLUGIN_HANDLED
			Fu_Overflow[id] = get_gametime();
			new Fu_Roll, Fu_Hold_Roll;
			Fu_Roll = random_num(1,3);
			if(Fu_Roll == Fu_Last_Roll[id])
			{
				if(Fu_Roll==1)
				{
					Fu_Hold_Roll = random_num(2,3);
				}
				if(Fu_Roll==2)
				{
					new Fu_Temp_Roll
					Fu_Temp_Roll = random_num(1,2);
					if(Fu_Temp_Roll==1)
					{
						Fu_Hold_Roll = 1;
					}
					if(Fu_Temp_Roll==2)
					{
						Fu_Hold_Roll = 3;
					}
				}
				if(Fu_Roll==3)
				{
					Fu_Hold_Roll = random_num(1,2);
				}
			}
			else
			{
				Fu_Hold_Roll = Fu_Roll;
			}
			Fu_Last_Roll[id] = Fu_Hold_Roll;
			if(Fu_Hold_Roll==1)set_pev(id,pev_weaponanim,2);
			if(Fu_Hold_Roll==2)set_pev(id,pev_weaponanim,3);
			if(Fu_Hold_Roll==3)set_pev(id,pev_weaponanim,4);
		}
		if(Fu_Trigger & IN_ATTACK2) //If Kicking
		{
			if(get_gametime() < Fu_Overflow[id] + 0.75)return PLUGIN_HANDLED
			if(Fu_Kick_Toggle[id]==1)
			{
				Fu_Kick_Toggle[id] = 0;
			}
			else
			{
				Fu_Kick_Toggle[id] = 1;
			}
			if(Fu_Kick_Toggle[id]==0)set_pev(id,pev_weaponanim,5);
			if(Fu_Kick_Toggle[id]==1)set_pev(id,pev_weaponanim,6);
		}
		if(Fu_Set[id] == 0)
		{
			set_pev(id,pev_viewmodel,Fu_Ent);
			set_pev(id,pev_weaponanim,1);
			Fu_Set[id] = 1;
			return PLUGIN_HANDLED;
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public plugin_precache() //Precache
{
	precache_model("models/v_melee.mdl");
}

public plugin_init() //Initation
{
	register_plugin("Kung-Fu","1.0","Pinkfairie");
	Fu_Ent = engfunc(EngFunc_AllocString,"models/v_melee.mdl");
}
