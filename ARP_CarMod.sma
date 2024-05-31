#include <ApolloRP_SQL>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

new Handle:g_hSQLTuple, g_iGas[32]

new TravTrie:g_hCar, TravTrie:g_hParkedCar[32], g_iCar[32], g_szModel[32][24], g_szSoundFile[32][24], Float:g_fpCarSpeed[32], TravTrie:g_hStereo

new bool:g_bDriveToggle[32], bool:g_bDrivingPoliceCar[32], bool:g_bSirenToggle[32], bool:g_bStereoToggle[32], bool:g_bHeadlightToggle[32]
new bool:g_bAntiFloodRev[32],  bool:g_bAntiFloodHonk[32], bool:g_bAntiFloodNote[32], bool:g_bAntiFloodOwner[32], bool:g_bAntiFloodCrash[32]

new g_iEngineTaskID[32], g_iSirenTaskID[32], g_iSirenLightsTaskID[32], g_iStereoTaskID[32], g_iGasTaskID[32], g_iAntiFloodRevTaskID[32], g_iAntiFloodHonkTaskID[32]

new g_pDaylight, g_pDamage

new g_mStereoMenu[32]

public plugin_init()
{
	register_forward(FM_Touch, "fnDrive")

	RegisterHam(Ham_Spawn, "player", "fnSpawn", 1)
	RegisterHam(Ham_Killed, "player", "fnKilled", 0)
}

public client_PreThink(id)
{
	if (!is_user_alive(id))
		return

	if (g_bDriveToggle[id - 1])
	{
		new iButton = entity_get_int(id, EV_INT_button)

		iButton &= ~IN_ATTACK
		iButton &= ~IN_ATTACK2

		entity_set_int(id, EV_INT_button, iButton)
	}
}

public fnDrive(tid, id)
{
	new szClassName[12]
	entity_get_string(tid, EV_SZ_classname, szClassName, 11)

	new const iIndex = id - 1

	if (!equal(szClassName, "func_car"))
	{
		if (!get_speed(id))
			return

		if (is_user_alive(id) && g_bDriveToggle[iIndex] && !g_bAntiFloodCrash[iIndex] && is_user_alive(tid))
		{
			emit_sound(id, CHAN_AUTO, "spunky/carmod/crash.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			new Float:fpVelocity[3]
			entity_get_vector(id, EV_VEC_velocity, fpVelocity)

			new Float:fpTargetVelocity[3]

			for (new i; i < 3; i++)
				fpTargetVelocity[i] = fpVelocity[i] * 4.0

			entity_set_vector(tid, EV_VEC_velocity, fpTargetVelocity)

			new const Float:fpDamage = get_pcvar_float(g_pDamage)

			if (fpDamage < 1.0)
				fakedamage(tid, "car crash", 1.0, 0)

			else if (fpDamage > 100.0)
				fakedamage(tid, "car crash", 100.0, 0)

			else
				fakedamage(tid, "car crash", fpDamage, 0)

			g_bAntiFloodCrash[iIndex] = true

			new iData[1]
			iData[0] = id

			set_task(5.0, "fnResetFloodCrash", _, iData, 1)
		}

		return
	}

	if (g_bDriveToggle[iIndex])
	{
		if (!g_bAntiFloodNote[iIndex])
		{
			client_print(id, print_chat, "[CM] You might want to leave a note to the owner of that car...")

			g_bAntiFloodNote[iIndex] = true

			new iData[1]
			iData[0] = id

			set_task(10.0, "fnResetFloodNote", _, iData, 1)
		}

		return
	}

	new const iOwner = entity_get_edict(tid, EV_ENT_owner)

	if (id != iOwner)
	{
		if (!g_bAntiFloodOwner[iIndex])
		{
			if (access(id, ADMIN_KICK))
			{
				new szOwnerName[32]
				get_user_name(iOwner, szOwnerName, 31)

				client_print(id, print_chat, "[CM] ADMIN: This car belongs to %s.", szOwnerName)
			}
			else
				client_print(id, print_chat, "[CM] You are not the owner of this car.")

			g_bAntiFloodOwner[iIndex] = true

			new iData[1]
			iData[0] = id

			set_task(10.0, "fnResetFloodOwner", _, iData, 1)
		}

		return
	}

	new szOutput[96], szCarName[32], szCarModel[32], szCarSpeed[12], szPoliceCar[8], szEnt[6], iSpeed, Float:fpSpeed, travTrieIter:hParkedCarIter = GetTravTrieIterator(g_hParkedCar[iIndex])

	while (MoreTravTrie(hParkedCarIter))
	{
		ReadTravTrieKey(hParkedCarIter, szCarName, 31)
		ReadTravTrieString(hParkedCarIter, szOutput, 95)

		parse(szOutput, szCarModel, 31, szCarSpeed, 11, szPoliceCar, 7, szEnt, 5)

		if (tid == str_to_num(szEnt))
		{
			iSpeed = str_to_num(szCarSpeed)
			fpSpeed = float(iSpeed)

			g_fpCarSpeed[iIndex] = fpSpeed
			get_user_info(id, "model", g_szModel[iIndex], 23)
			set_user_maxspeed(id, fpSpeed)
			client_cmd(id, "cl_forwardspeed %d; cl_sidespeed %d; cl_backspeed %d", iSpeed, iSpeed, iSpeed)
			set_user_info(id, "model", szCarModel)
			set_user_footsteps(id, 1)
			emit_sound(id, CHAN_AUTO, "spunky/carmod/enginestart.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			new iData[1]
			iData[0] = id

			g_iEngineTaskID[iIndex] = random(1337)
			set_task(5.0, "fnEngine", g_iEngineTaskID[iIndex], iData, 1)

			remove_entity(tid)

			client_print(id, print_chat, "[CM] You get back into your %s, then start the engine.", szCarName)

			ARP_FindItemId(szCarName, szOutput, 95)
			g_iCar[iIndex] = szOutput[0]

			g_bDriveToggle[iIndex] = true

			TravTrieDeleteKey(g_hParkedCar[iIndex], szCarName)

			if (equali(szPoliceCar, "yes"))
				g_bDrivingPoliceCar[iIndex] = true

			new szID[24]
			get_user_authid(id, szID, 23)

			new szQuery[64]
			formatex(szQuery, 63, "SELECT * FROM arp_carmod WHERE SteamID = '%s'", szID)

			SQL_ThreadQuery(g_hSQLTuple, "fnLoadGas", szQuery, iData, 1)

			break
		}
	}

	DestroyTravTrieIterator(hParkedCarIter)
}

public fnResetFloodNote(iData[])
{
	new const iIndex = iData[0] - 1

	g_bAntiFloodNote[iIndex] = false
}

public fnResetFloodOwner(iData[])
{
	new const iIndex = iData[0] - 1

	g_bAntiFloodOwner[iIndex] = false
}

public fnResetFloodCrash(iData[])
{
	new const iIndex = iData[0] - 1

	g_bAntiFloodCrash[iIndex] = false
}

public fnSpawn(id)
{
	client_cmd(id, "cl_forwardspeed 320; cl_sidespeed 320; cl_backspeed 320")

	return HAM_HANDLED
}

public fnKilled(id, attacker_id)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		emit_sound(id, CHAN_AUTO, "spunky/carmod/enginestart.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(id, CHAN_AUTO, "spunky/carmod/rev.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(id, CHAN_AUTO, "spunky/carmod/horn.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

		if (task_exists(g_iEngineTaskID[iIndex], 0))
		{
			remove_task(g_iEngineTaskID[iIndex], 0)

			emit_sound(id, CHAN_AUTO, "spunky/carmod/engine.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		}

		if (task_exists(g_iSirenTaskID[iIndex], 0))
		{
			remove_task(g_iSirenTaskID[iIndex], 0)

			emit_sound(id, CHAN_AUTO, "spunky/carmod/fixedsiren.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

			g_bSirenToggle[iIndex] = false
		}

		if (task_exists(g_iSirenLightsTaskID[iIndex], 0))
			remove_task(g_iSirenLightsTaskID[iIndex], 0)

		if (task_exists(g_iStereoTaskID[iIndex], 0))
		{
			remove_task(g_iStereoTaskID[iIndex], 0)

			new szInput[48]
			formatex(szInput, 47, "spunky/carmod/stereo/%s.wav", g_szSoundFile[iIndex])
			emit_sound(id, CHAN_AUTO, szInput, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

			g_szSoundFile[iIndex] = ""
			g_bStereoToggle[iIndex] = false
		}

		if (task_exists(g_iGasTaskID[iIndex], 0))
			remove_task(g_iGasTaskID[iIndex], 0)

		if (task_exists(g_iAntiFloodRevTaskID[iIndex], 0))
		{
			remove_task(g_iAntiFloodRevTaskID[iIndex], 0)

			g_bAntiFloodRev[iIndex] = false
		}

		if (task_exists(g_iAntiFloodHonkTaskID[iIndex], 0))
		{
			remove_task(g_iAntiFloodHonkTaskID[iIndex], 0)

			g_bAntiFloodHonk[iIndex] = false
		}

		g_bAntiFloodCrash[iIndex] = false

		if (g_bHeadlightToggle[iIndex])
		{
			entity_set_int(id, EV_INT_effects, 0)

			g_bHeadlightToggle[iIndex] = false
		}

		g_fpCarSpeed[iIndex] = 0.0

		set_user_info(id, "model", g_szModel[iIndex])
		set_user_footsteps(id, 0)

		g_bDriveToggle[iIndex] = false
		g_bDrivingPoliceCar[iIndex] = false
	}

	if (is_user_alive(attacker_id))
		g_bAntiFloodCrash[attacker_id - 1] = false

	return HAM_HANDLED
}

public ARP_Init()
{
	ARP_RegisterPlugin("Car Mod", "1.3.4", "Spunky", "Allows players to drive cars")

	ARP_RegisterCmd("say /rev", "cmd_rev", "- revs the engine")
	ARP_RegisterCmd("say /honk", "cmd_honk", "- honks car horn")
	ARP_RegisterCmd("say /siren", "cmd_siren", "- turns siren on/off")
	ARP_RegisterCmd("say /headlight", "cmd_headlight", "- turns headlights on/off")

	ARP_RegisterEvent("HUD_Render", "fnHUDRender")

	g_pDaylight = register_cvar("arp_daylight", "1")
	g_pDamage = register_cvar("arp_crash_damage", "5")

	set_cvar_num("sv_maxspeed", 750)

	g_hSQLTuple = ARP_SqlHandle()

	if (g_hSQLTuple == Empty_Handle)
		set_fail_state("[CM] Failed to retrieve SQL handle.")

	new szDriver[8]
	SQL_GetAffinity(szDriver, 7)

	new szQuery[128]
	formatex(szQuery, 127, "CREATE TABLE IF NOT EXISTS arp_carmod (SteamID VARCHAR(20), Gasoline INT(6), %s (SteamID))", equali(szDriver, "mysql") ? "UNIQUE KEY" : "UNIQUE")

	SQL_ThreadQuery(g_hSQLTuple, "fnCreateTable", szQuery)

	for (new i; i < 32; i++)
		g_hParkedCar[i] = TravTrieCreate()
}

public fnHUDRender(szName[], iData[], iLen)
{
	new const id = iData[0], iIndex = id - 1

	if (!is_user_alive(id) || iData[1] != HUD_PRIM)
		return

	if (ARP_PlayerReady(id) && g_bDriveToggle[iIndex])
		ARP_AddHudItem(id, HUD_PRIM, 0, "Gasoline: %d%%", g_iGas[iIndex])
}

public fnCreateTable(FailState, Handle:hQuery, szError[], iErrorCode)
{
	if (FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[CM] Could not connect to SQL database!")

	else if (FailState == TQUERY_QUERY_FAILED)
		set_fail_state("[CM] Query failed to execute!")

	if (iErrorCode)
		set_fail_state(szError)

	return PLUGIN_CONTINUE
}

public ARP_RegisterItems()
{
	g_hCar = TravTrieCreate()
	g_hStereo = TravTrieCreate()

	new szConfigsDir[32]
	get_configsdir(szConfigsDir, 31)

	new szFilePath[48]
	formatex(szFilePath, 47, "%s/arp/carmod.cfg", szConfigsDir)

	new iFileSize = file_size(szFilePath, 1), szOutput[96], szInput[96]

	if (iFileSize)
	{
		new szCarName[32], szCarDescription[48], TravTrie:hOldCar = TravTrieCreate(), travTrieIter:hCarIter, szOldCarModel[32], szCarModel[32], szCarSpeed[12], szPoliceCar[8], iCarNum, iLen

		for (new i, bool:bRegisterItem = true; i < iFileSize; i++)
		{
			read_file(szFilePath, i, szOutput, 95, iLen)
			parse(szOutput, szCarName, 31, szCarModel, 31, szCarSpeed, 11, szPoliceCar, 7)

			hCarIter = GetTravTrieIterator(hOldCar)

			while (MoreTravTrie(hCarIter))
			{
				ReadTravTrieString(hCarIter, szOldCarModel, 31)

				if (equal(szCarModel, szOldCarModel))
				{
					bRegisterItem = false

					break
				}
			}

			if (!bRegisterItem)
			{
				bRegisterItem = true

				ARP_Log("Duplicate ^"%s^" found in ^"carmod.cfg^"! Skipped registration of item.", szCarName)

				continue
			}

			formatex(szInput, 95, "models/player/%s/%s.mdl", szCarModel, szCarModel)
			precache_model(szInput)

			formatex(szInput, 95, "%s Key", szCarName)
			formatex(szCarDescription, 47, "A key to a %s.", szCarName)
			ARP_RegisterItem(szInput, "fnCarItem", szCarDescription, 0)

			formatex(szInput, 95, "^"%s^" ^"%s^" ^"%s^"", szCarModel, szCarSpeed, szPoliceCar)
			TravTrieSetString(g_hCar, szCarName, szInput)

			TravTrieSetString(hOldCar, szCarName, szCarModel)

			iCarNum++
		}

		log_amx("[CM] Loaded %d cars...", iCarNum)

		DestroyTravTrieIterator(hCarIter)
		TravTrieDestroy(hOldCar)
	}
	else
		log_amx("[CM] Configuration file ^"carmod.cfg^" empty!")

	precache_sound("spunky/carmod/enginestart.wav")
	precache_sound("spunky/carmod/rev.wav")
	precache_sound("spunky/carmod/engine.wav")
	precache_sound("spunky/carmod/crash.wav")
	precache_sound("spunky/carmod/horn.wav")
	precache_sound("spunky/carmod/fixedsiren.wav")

	formatex(szFilePath, 47, "%s/arp/stereo.cfg", szConfigsDir)

	iFileSize = file_size(szFilePath, 1)

	if (iFileSize)
	{
		new szSongName[32], szArtistName[32], szSoundFile[24], szSongLength[8], szOldSongName[32], iSongNum, iLen, TravTrie:hOldSong = TravTrieCreate(), travTrieIter:hSongIter

		for (new i, bool:bPrecacheSong = true; i < iFileSize; i++)
		{
			read_file(szFilePath, i, szOutput, 95, iLen)

			if (!iLen)
				continue

			parse(szOutput, szSongName, 31, szArtistName, 31, szSoundFile, 23, szSongLength, 7)

			hSongIter = GetTravTrieIterator(hOldSong)

			while (MoreTravTrie(hSongIter))
			{
				ReadTravTrieString(hSongIter, szOldSongName, 31)

				if (equal(szSongName, szOldSongName))
				{
					bPrecacheSong = false

					break
				}
			}

			if (!bPrecacheSong)
			{
				bPrecacheSong = true

				ARP_Log("Duplicate sound found in ^"radio.cfg^"! Skipped precache of sound ^"%s.wav^".", szSoundFile)

				continue
			}

			formatex(szInput, 95, "spunky/carmod/stereo/%s.wav", szSoundFile)
			precache_sound(szInput)

			formatex(szInput, 95, "^"%s^" ^"%s^" ^"%s^"", szArtistName, szSoundFile, szSongLength)
			TravTrieSetString(g_hStereo, szSongName, szInput)

			TravTrieSetString(hOldSong, szSongName, szSongName)

			iSongNum++
		}

		log_amx("[CM] Loaded %d songs...", iSongNum)

		if (iSongNum)
			ARP_RegisterItem("Car Stereo System", "fnCarStereoSystemItem", "A car stereo system.", 0)

		if (iLen)
			DestroyTravTrieIterator(hSongIter)

		TravTrieDestroy(hOldSong)
	}
	else
		log_amx("[CM] Configuration file ^"radio.cfg^" empty!")

	ARP_RegisterItem("Gasoline", "fnGasolineItem", "A canister of gasoline.", 1)
}

public plugin_end()
{
	TravTrieDestroy(g_hCar)

	for (new i; i < 32; i++)
		TravTrieDestroy(g_hParkedCar[i])

	TravTrieDestroy(g_hStereo)
}

public client_disconnect(id)
{
	new const iIndex = id - 1

	g_iGas[iIndex] = 0
	g_iCar[iIndex] = 0
	g_bDriveToggle[iIndex] = false
	g_bDrivingPoliceCar[iIndex] = false
	g_bSirenToggle[iIndex] = false
	g_bStereoToggle[iIndex] = false
	g_bAntiFloodNote[iIndex] = false
	g_bAntiFloodOwner[iIndex] = false
	g_bAntiFloodCrash[iIndex] = false
	g_bHeadlightToggle[iIndex] = false
	g_szModel[iIndex] = ""
	g_szSoundFile[iIndex] = ""
	g_fpCarSpeed[iIndex] = 0.0

	if (task_exists(g_iEngineTaskID[iIndex], 0))
		remove_task(g_iEngineTaskID[iIndex], 0)

	if (task_exists(g_iSirenTaskID[iIndex], 0))
		remove_task(g_iSirenTaskID[iIndex], 0)

	if (task_exists(g_iSirenLightsTaskID[iIndex], 0))
		remove_task(g_iSirenLightsTaskID[iIndex], 0)

	if (task_exists(g_iStereoTaskID[iIndex], 0))
		remove_task(g_iStereoTaskID[iIndex], 0)

	if (task_exists(g_iGasTaskID[iIndex], 0))
		remove_task(g_iGasTaskID[iIndex], 0)

	if (task_exists(g_iAntiFloodRevTaskID[iIndex], 0))
	{
		remove_task(g_iAntiFloodRevTaskID[iIndex], 0)

		g_bAntiFloodRev[iIndex] = false
	}

	if (task_exists(g_iAntiFloodHonkTaskID[iIndex], 0))
	{
		remove_task(g_iAntiFloodHonkTaskID[iIndex], 0)

		g_bAntiFloodHonk[iIndex] = false
	}

	g_mStereoMenu[iIndex] = 0

	new szOutput[96], szCarModel[32], szCarSpeed[12], szPoliceCar[8], szEnt[6]

	new travTrieIter:hParkedCarIter = GetTravTrieIterator(g_hParkedCar[iIndex])

	while (MoreTravTrie(hParkedCarIter))
	{
		ReadTravTrieString(hParkedCarIter, szOutput, 95)
		parse(szOutput, szCarModel, 31, szCarSpeed, 11, szPoliceCar, 7, szEnt, 5)

		remove_entity(str_to_num(szEnt))
	}

	DestroyTravTrieIterator(hParkedCarIter)
	TravTrieClear(g_hParkedCar[iIndex])
}

public cmd_rev(id)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		if (g_bAntiFloodRev[iIndex])
			return PLUGIN_HANDLED

		emit_sound(id, CHAN_AUTO, "spunky/carmod/rev.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		g_bAntiFloodRev[iIndex] = true

		new iData[1]
		iData[0] = id

		g_iAntiFloodRevTaskID[iIndex] = random(1337)
		set_task(10.0, "fnAntiFloodRevUpdate", g_iAntiFloodRevTaskID[iIndex], iData, 1)
	}
	else
		client_print(id, print_chat, "[CM] You are not driving a car.")

	return PLUGIN_HANDLED
}

public fnAntiFloodRevUpdate(iData[])
{
	new const iIndex = iData[0] - 1

	g_bAntiFloodRev[iIndex] = false
}

public cmd_honk(id)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		if (g_bAntiFloodHonk[iIndex])
			return PLUGIN_HANDLED

		emit_sound(id, CHAN_AUTO, "spunky/carmod/horn.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		g_bAntiFloodHonk[iIndex] = true

		new iData[1]
		iData[0] = id

		g_iAntiFloodHonkTaskID[iIndex] = random(1337)
		set_task(5.0, "fnAntiFloodHonkUpdate", g_iAntiFloodHonkTaskID[iIndex], iData, 1)
	}
	else
		client_print(id, print_chat, "[CM] You are not driving a car.")

	return PLUGIN_HANDLED
}

public fnAntiFloodHonkUpdate(iData[])
{
	new const iIndex = iData[0] - 1

	g_bAntiFloodHonk[iIndex] = false
}

public cmd_siren(id)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		if (g_bDrivingPoliceCar[iIndex])
		{
			if (g_bStereoToggle[iIndex])
			{
				client_print(id, print_chat, "[CM] You must turn your stereo system off to use your siren.")

				return PLUGIN_HANDLED
			}

			if (g_bSirenToggle[iIndex])
			{
				client_print(id, print_chat, "[CM] You have turned your siren off.")

				if (task_exists(g_iSirenTaskID[iIndex], 0))
					remove_task(g_iSirenTaskID[iIndex], 0)

				if (task_exists(g_iSirenLightsTaskID[iIndex], 0))
					remove_task(g_iSirenLightsTaskID[iIndex], 0)

				emit_sound(id, CHAN_AUTO, "spunky/carmod/fixedsiren.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

				g_bSirenToggle[iIndex] = false
			}
			else
			{
				client_print(id, print_chat, "[CM] You have turned your siren on.")

				emit_sound(id, CHAN_AUTO, "spunky/carmod/fixedsiren.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				new iData[2]
				iData[0] = id
				iData[1] = 1

				g_iSirenTaskID[iIndex] = random(1337)
				set_task(11.7, "fnSiren", g_iSirenTaskID[iIndex], iData, 1)

				g_iSirenLightsTaskID[iIndex] = random(1337)
				set_task(0.1, "fnSirenLights", g_iSirenLightsTaskID[iIndex], iData, 2)

				g_bSirenToggle[iIndex] = true
			}
		}
		else
			client_print(id, print_chat, "[CM] You are not driving a police car.")
	}
	else
		client_print(id, print_chat, "[CM] You are not driving a car.")

	return PLUGIN_HANDLED
}

public fnSiren(iData[])
{
	new const id = iData[0], iIndex = id - 1

	emit_sound(id, CHAN_AUTO, "spunky/carmod/fixedsiren.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	set_task(11.7, "fnSiren", g_iSirenTaskID[iIndex], iData, 1)
}

public fnSirenLights(iData[])
{
	new const id = iData[0]

	new iOrigin[3]
	get_user_origin(id, iOrigin)

	message_begin(MSG_ALL, SVC_TEMPENTITY, {0, 0, 0}, id)
	write_byte(TE_DLIGHT)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])

	if (get_pcvar_num(g_pDaylight))
		write_byte(40)
	else
		write_byte(20)

	if (iData[1])
	{
		if (get_pcvar_num(g_pDaylight))
			write_byte(175)
		else
			write_byte(50)

		write_byte(0)
		write_byte(0)

		iData[1] = 0
	}
	else
	{
		write_byte(0)
		write_byte(0)

		if (get_pcvar_num(g_pDaylight))
			write_byte(175)
		else
			write_byte(50)

		iData[1] = 1
	}

	write_byte(75)
	write_byte(25)
	message_end()

	set_task(0.25, "fnSirenLights", g_iSirenTaskID[id - 1], iData, 2)
}

public cmd_headlight(id)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		if (g_bHeadlightToggle[iIndex])
		{
			client_print(id, print_chat, "[CM] You have turned your headlights off.")

			entity_set_int(id, EV_INT_effects, 0)

			g_bHeadlightToggle[iIndex] = false
		}
		else
		{
			client_print(id, print_chat, "[CM] You have turned your headlights on.")

			entity_set_int(id, EV_INT_effects, EF_DIMLIGHT)

			g_bHeadlightToggle[iIndex] = true
		}
	}
	else
		client_print(id, print_chat, "[CM] You are not driving a car.")

	return PLUGIN_HANDLED
}

public fnCarItem(id, iid)
{
	new const iIndex = id - 1

	new szName[64], szID[24]
	new szOutput[96], szTempOutput[48], szInput[96], szCarName[32], szParkedCarName[32], szCarModel[32], szCarSpeed[12], iSpeed, szPoliceCar[8], iCar, travTrieIter:hCarIter = GetTravTrieIterator(g_hCar), travTrieIter:hParkedCarIter = GetTravTrieIterator(g_hParkedCar[iIndex])
	new bool:bParked = false

	new Float:fpOrigin[3], Float:fpAngles[3]

	while (MoreTravTrie(hCarIter))
	{
		ReadTravTrieKey(hCarIter, szCarName, 31)

		ARP_FindItemId(szCarName, szOutput, 5)
		iCar = szOutput[0]

		ReadTravTrieString(hCarIter, szOutput, 95)

		if (iid == iCar)
		{
			if (g_bDriveToggle[iIndex])
			{
				if (g_iCar[iIndex] != iid)
				{
					client_print(id, print_chat, "[CM] You're already driving a different car.")

					break
				}

				emit_sound(id, CHAN_AUTO, "spunky/carmod/enginestart.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
				emit_sound(id, CHAN_AUTO, "spunky/carmod/rev.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
				emit_sound(id, CHAN_AUTO, "spunky/carmod/horn.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

				g_bAntiFloodRev[iIndex] = false
				g_bAntiFloodHonk[iIndex] = false

				if (task_exists(g_iEngineTaskID[iIndex], 0))
				{
					remove_task(g_iEngineTaskID[iIndex], 0)

					emit_sound(id, CHAN_AUTO, "spunky/carmod/engine.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
				}

				if (g_bSirenToggle[iIndex])
				{
					remove_task(g_iSirenTaskID[iIndex], 0)

					emit_sound(id, CHAN_AUTO, "spunky/carmod/fixedsiren.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

					g_bSirenToggle[iIndex] = false

					if (task_exists(g_iSirenLightsTaskID[iIndex], 0))
						remove_task(g_iSirenLightsTaskID[iIndex], 0)
				}

				if (g_bStereoToggle[iIndex])
				{
					remove_task(g_iStereoTaskID[iIndex], 0)

					formatex(szInput, 95, "spunky/carmod/stereo/%s.wav", g_szSoundFile[iIndex])
					emit_sound(id, CHAN_AUTO, szInput, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

					g_bStereoToggle[iIndex] = false
				}

				if (task_exists(g_iGasTaskID[iIndex], 0))
					remove_task(g_iGasTaskID[iIndex], 0)

				if (g_bHeadlightToggle[iIndex])
				{
					entity_set_int(id, EV_INT_effects, 0)

					g_bHeadlightToggle[iIndex] = false
				}

				g_fpCarSpeed[iIndex] = 0.0

				parse(szOutput, szCarModel, 31, szCarSpeed, 11, szPoliceCar, 7)

				entity_get_vector(id, EV_VEC_origin, fpOrigin)
				entity_get_vector(id, EV_VEC_angles, fpAngles)

				fpAngles[0] = 0.0

				new iEnt = create_entity("info_target")
				entity_set_string(iEnt, EV_SZ_classname, "func_car")
				entity_set_vector(iEnt, EV_VEC_origin, fpOrigin)
				entity_set_vector(iEnt, EV_VEC_angles, fpAngles)

				formatex(szInput, 95, "models/player/%s/%s.mdl", szCarModel, szCarModel)
				entity_set_model(iEnt, szInput)

				get_user_name(id, szName, 63)
				get_user_authid(id, szID, 23)

				ARP_Log("%s (%s) parked their car at coordinates (x: %d, y: %d, z: %d), at angle (pitch: %d, yaw: %d, roll: %d)...", szName, szID, floatround(fpOrigin[0]), floatround(fpOrigin[1]), floatround(fpOrigin[2]), floatround(fpAngles[0]), floatround(fpAngles[1]), floatround(fpAngles[2]))

				formatex(szInput, 95, "^"%s^" ^"%s^" ^"%s^" %d", szCarModel, szCarSpeed, szPoliceCar, iEnt)
				TravTrieSetString(g_hParkedCar[iIndex], szCarName, szInput)

				new iData[2]
				iData[0] = id
				iData[1] = iEnt

				set_task(2.5, "fnSolidifyCar", _, iData, 2)

				set_user_maxspeed(id, 320.0)
				client_cmd(id, "cl_forwardspeed 320; cl_sidespeed 320; cl_backspeed 320")
				set_user_info(id, "model", g_szModel[iIndex])
				set_user_footsteps(id, 0)

				client_print(id, print_chat, "[CM] You turn off the engine, then get out of the %s.", szCarName)

				g_iCar[iIndex] = 0
				g_bDriveToggle[iIndex] = false
				g_bDrivingPoliceCar[iIndex] = false
			}
			else
			{
				while (MoreTravTrie(hParkedCarIter))
				{
					ReadTravTrieKey(hParkedCarIter, szParkedCarName, 31)
					ReadTravTrieString(hParkedCarIter, szTempOutput, 47)

					if (equali(szCarName, szParkedCarName))
					{
						bParked = true

						break
					}
				}

				DestroyTravTrieIterator(hParkedCarIter)

				if (bParked)
				{
					client_print(id, print_chat, "[CM] Your %s is already parked elsewhere.", szCarName)
	
					break
				}

				parse(szOutput, szCarModel, 31, szCarSpeed, 11, szPoliceCar, 7)

				iSpeed = str_to_num(szCarSpeed)
				g_fpCarSpeed[iIndex] = float(iSpeed)

				get_user_info(id, "model", g_szModel[iIndex], 23)
				set_user_maxspeed(id, float(iSpeed))
				client_cmd(id, "cl_forwardspeed %d; cl_sidespeed %d; cl_backspeed %d", iSpeed, iSpeed, iSpeed)
				set_user_info(id, "model", szCarModel)

				set_user_footsteps(id, 1)

				emit_sound(id, CHAN_AUTO, "spunky/carmod/enginestart.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				new iData[1]
				iData[0] = id

				g_iEngineTaskID[iIndex] = random(1337)
				set_task(5.0, "fnEngine", g_iEngineTaskID[iIndex], iData, 1)

				client_print(id, print_chat, "[CM] You get into your %s, then start the engine.", szCarName)

				g_iCar[iIndex] = iid

				g_bDriveToggle[iIndex] = true

				if (equali(szPoliceCar, "yes"))
					g_bDrivingPoliceCar[iIndex] = true

				get_user_authid(id, szID, 23)

				new szQuery[64]
				formatex(szQuery, 63, "SELECT * FROM arp_carmod WHERE SteamID = '%s'", szID)

				SQL_ThreadQuery(g_hSQLTuple, "fnLoadGas", szQuery, iData, 1)
			}

			break
		}
	}

	DestroyTravTrieIterator(hCarIter)
}

public fnEngine(iData[])
{
	new const id = iData[0]

	emit_sound(id, CHAN_AUTO, "spunky/carmod/engine.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	set_task(1.15, "fnEngine", g_iEngineTaskID[id - 1], iData, 1)
}

public fnSolidifyCar(iData[])
{
	new const id = iData[0], iEnt = iData[1]

	if (is_user_connected(id))
	{
		entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER)
		entity_set_size(iEnt, Float:{-16.0, -16.0, -250.0}, Float:{16.0, 16.0, 40.0})
		drop_to_floor(iEnt)
		entity_set_edict(iEnt, EV_ENT_owner, id)

		client_print(id, print_chat, "[CM] You have successfully parked your car. Probably.")
	}
}

public fnCreateNewUser(FailState, Handle:hQuery, szError[], iErrorCode, iData[], iDataSize)
{
	if (FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[CM] Could not connect to SQL database!")

	else if (FailState == TQUERY_QUERY_FAILED)
		set_fail_state("[CM] Query failed to execute!")

	return PLUGIN_CONTINUE
}

public fnLoadGas(FailState, Handle:hQuery, szError[], iErrorCode, iData[], iDataSize)
{
	if (FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[CM] Could not connect to SQL database!")

	else if (FailState == TQUERY_QUERY_FAILED)
		set_fail_state("[CM] Query failed to execute!")

	new const id = iData[0], iIndex = id - 1

	if (SQL_NumResults(hQuery) > 0)
		g_iGas[iIndex] = SQL_ReadResult(hQuery, 1)
	else
	{
		g_iGas[iIndex] = 100

		new szID[24]
		get_user_authid(id, szID, 23)

		new szQuery[64]
		formatex(szQuery, 63, "INSERT INTO arp_carmod VALUES ('%s', 100)", szID)

		SQL_ThreadQuery(g_hSQLTuple, "fnCreateNewUser", szQuery)

		return PLUGIN_HANDLED
	}

	new iData[1]
	iData[0] = id

	g_iGasTaskID[iIndex] = random(1337)
	set_task(60.0, "fnGasUpdate", g_iGasTaskID[iIndex], iData, 1, "b")

	if (g_iGas[iIndex] <= 0)
	{
		client_print(id, print_chat, "[CM] Your car has no gas!")

		set_user_maxspeed(id, 0.0)
		client_cmd(id, "cl_forwardspeed 0; cl_sidespeed 0; cl_backspeed 0")
	}

	return PLUGIN_CONTINUE
}

public fnGasUpdate(iData[])
{
	new const id = iData[0], iIndex = id - 1

	g_iGas[iIndex]--

	if (g_iGas[iIndex] < 0)
		g_iGas[iIndex] = 0

	new szID[24]
	get_user_authid(id, szID, 23)

	new szQuery[96]
	formatex(szQuery, 95, "UPDATE arp_carmod SET Gasoline = %d WHERE SteamID = '%s'", g_iGas[iIndex], szID)

	SQL_ThreadQuery(g_hSQLTuple, "fnUpdateGasoline", szQuery)

	if (!g_iGas[iIndex])
	{
		client_print(id, print_chat, "[CM] Your vehicle has run out of gas!")

		remove_task(g_iGasTaskID[iIndex], 0)

		set_user_maxspeed(id, 0.0)
		client_cmd(id, "cl_forwardspeed 0; cl_sidespeed 0; cl_backspeed 0")
	}
}

public fnUpdateGasoline(FailState, Handle:hQuery, szError[], iErrorCode, iData[], iDataSize)
{
	if (FailState == TQUERY_CONNECT_FAILED)
		set_fail_state("[CM] Could not connect to SQL database!")

	else if (FailState == TQUERY_QUERY_FAILED)
		set_fail_state("[CM] Query failed to execute!")

	return PLUGIN_CONTINUE
}

public fnCarStereoSystemItem(id, iid)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		new szInput[64]

		client_print(id, print_chat, g_bStereoToggle[iIndex] ? "[CM] You turn your stereo system off." : "[CM] You turn your stereo system on.")

		if (g_bStereoToggle[iIndex])
		{
			if (task_exists(g_iStereoTaskID[iIndex], 0))
				remove_task(g_iStereoTaskID[iIndex], 0)

			formatex(szInput, 63, "spunky/carmod/stereo/%s.wav", g_szSoundFile[iIndex])
			emit_sound(id, CHAN_AUTO, szInput, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

			g_bStereoToggle[iIndex] = false
		}
		else
		{
			if (g_bDrivingPoliceCar[iIndex])
			{
				client_print(id, print_chat, "[CM] You can't listen to the stereo in a police issue vehicle.")

				return
			}

			new szOutput[96], szSongName[32], szArtistName[32], szSoundFile[24], szSongLength[8], travTrieIter:hStereoIter = GetTravTrieIterator(g_hStereo)

			g_mStereoMenu[iIndex] = menu_create("Stereo Menu:", "fnStereoMenu")

			while (MoreTravTrie(hStereoIter))
			{
				ReadTravTrieKey(hStereoIter, szSongName, 31)
				ReadTravTrieString(hStereoIter, szOutput, 95)
				parse(szOutput, szArtistName, 31, szSoundFile, 23, szSongLength, 7)

				formatex(szInput, 63, "^"%s^" by %s", szSongName, szArtistName)
				menu_additem(g_mStereoMenu[iIndex], szInput, szSoundFile)
			}

			DestroyTravTrieIterator(hStereoIter)

			menu_setprop(g_mStereoMenu[iIndex], MPROP_TITLE, "Stereo Menu:")
			menu_setprop(g_mStereoMenu[iIndex], MPROP_PERPAGE, 7)
			menu_setprop(g_mStereoMenu[iIndex], MPROP_EXIT, MEXIT_ALL)

			menu_display(id, g_mStereoMenu[iIndex], 0)
		}
	}
	else
		client_print(id, print_chat, "[CM] You are not driving a car.")
}

public fnStereoMenu(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)

		return PLUGIN_HANDLED
	}

	new const iIndex = id - 1

	new szData[24], access, callback
	menu_item_getinfo(menu, item, access, szData, 23, _, _, callback)

	new szOutput[64], szInput[64], szArtistName[32], szSoundFile[24], szSongLength[8]

	new travTrieIter:hStereoIter = GetTravTrieIterator(g_hStereo)

	while (MoreTravTrie(hStereoIter))
	{
		ReadTravTrieString(hStereoIter, szOutput, 63)
		parse(szOutput, szArtistName, 31, szSoundFile, 23, szSongLength, 7)

		if (equal(szData, szSoundFile))
		{
			formatex(szInput, 63, "spunky/carmod/stereo/%s.wav", szSoundFile)
			emit_sound(id, CHAN_AUTO, szInput, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

			g_szSoundFile[iIndex] = szSoundFile
			g_bStereoToggle[iIndex] = true

			g_iStereoTaskID[iIndex] = id
			set_task(str_to_float(szSongLength), "fnStereoLoop", id, _, _, "b")

			break
		}
	}

	DestroyTravTrieIterator(hStereoIter)

	return PLUGIN_CONTINUE
}

public fnStereoLoop(id)
{
	new const iIndex = id - 1

	new szInput[64]
	formatex(szInput, 63, "spunky/carmod/stereo/%s.wav", g_szSoundFile[iIndex])
	emit_sound(id, CHAN_AUTO, szInput, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public fnGasolineItem(id, iid)
{
	new const iIndex = id - 1

	if (g_bDriveToggle[iIndex])
	{
		if (g_iGas[iIndex] >= 100)
		{
			client_print(id, print_chat, "[CM] Your car is already running on a full tank!")

			ARP_SetUserItemNum(id, iid, ARP_GetUserItemNum(id, iid) + 1)
		}
		else
		{
			if (g_iGas[iIndex] + 50 >= 100)
				g_iGas[iIndex] = 100
			else
				g_iGas[iIndex] += 50

			new iSpeed = floatround(g_fpCarSpeed[iIndex])

			set_user_maxspeed(id, g_fpCarSpeed[iIndex])
			client_cmd(id, "cl_forwardspeed %d; cl_sidespeed %d; cl_backspeed %d", iSpeed, iSpeed, iSpeed)

			new szID[24]
			get_user_authid(id, szID, 23)

			new szQuery[96]
			formatex(szQuery, 95, "UPDATE arp_carmod SET Gasoline = %d WHERE SteamID = '%s'", g_iGas[iIndex], szID)

			SQL_ThreadQuery(g_hSQLTuple, "fnUpdateGasoline", szQuery)

			client_print(id, print_chat, "[CM] You used a tank of gasoline.")
		}
	}
	else
	{
		ARP_SetUserItemNum(id, iid, ARP_GetUserItemNum(id, iid) + 1)

		client_print(id, print_chat, "[CM] You are not driving a car.")
	}
}