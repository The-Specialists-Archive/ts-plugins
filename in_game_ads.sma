#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <xs>


#define MAIN_PRECACHE_FILE "precache_list.cfg"
#define MAIN_PRECACHE_FILE_TEXT "//If you would like to choose which model/sprite to place while placing an ad, add the item to the list below.^n//For example:^n//models/wall.mdl^n//models/player.mdl^n//etc..."
#define CONFIG_FOLDERNAME "In-Game Ads"


#define ERROR_FILE_NOT_FOUND "Error: Failed to precache/load (%s), model/sprite does not exist."
#define ERROR_USER_ALREADY_PLACING "Error: More than one user is placing an advertisement!"

#define SAVE_MENU_TEXT "Save this ad?^n^n1. Yes, save it.^n2. No, delete it.^n"
#define SELECT_MENU_TEXT_CHOOSE_MODEL "Choose a model: %i/%i^n^n"
#define SELECT_MENU_TEXT_OPTIONS_1 "^n5. Move 1 unit toward you^n6. Scale Up^n7. Scale Down^n^n8. Save this Ad!^n^n9. More Models...^n0. %s"
#define SELECT_MENU_TEXT_OPTIONS_2 "^n5. Move 1 unit toward you^n6. Scale Up^n7. Scale Down^n^n8. Save this Ad!^n^n0. %s"
#define SELECT_MENU_TEXT_PREVIOUS "Previous Page"
#define SELECT_MENU_TEXT_EXIT "Exit"



new ad_ent
new Float:aiming_origins[3][3]
new Float:ad_ent_angles[3]

new bool:is_user_placing_ad = false

//every X frames the ad's origin/angles will be updated
#define PRETHINK_REFRESH_TIME 5

new prethink_counter

//maximum number of models/sprites to choose from in the menu
#define MAX_AD_MODELS 16

//maximum length of the complete filename of a model/sprite, eg. "sprites/advert/bloodservers.spr"
#define MAX_MODEL_NAMELEN 48

//Do not change below.
#define SELECT_MENU_SIZE (128 + (MAX_AD_MODELS * MAX_MODEL_NAMELEN))
#define SELECT_MENU_OPTIONS_NUM 4
//Do not change above.

//list of model/sprite filenames
new ad_model_list[MAX_AD_MODELS][MAX_MODEL_NAMELEN]
new current_ad_model
new num_models_in_list
new select_menu_current_page

new file_name[256], map_name[32]

#define ADMIN_ACCESS_LEVEL ADMIN_BAN

public plugin_init()
{
	register_plugin("In-Game Ads", "1.44", "stupok69")
	
	register_clcmd("+place_ad", "cmd_place_ad", ADMIN_ACCESS_LEVEL)
	register_clcmd("-place_ad", "cmd_place_ad", ADMIN_ACCESS_LEVEL)
	
	register_menucmd(register_menuid("save_menu"), (1<<0)|(1<<1), "Pressedsave_menu")
	register_menucmd(register_menuid("select_menu"), 1023, "Pressedselect_menu")
	
	register_forward(FM_PlayerPreThink,"PreThink")
	
	load_saved_ads(file_name)
}

public plugin_precache()
{
	new configs_dir[64]
	
	get_configsdir(configs_dir, 63)
	get_mapname(map_name, 31)
	
	formatex(file_name, 255, "%s/%s", configs_dir, CONFIG_FOLDERNAME)
	
	if(!dir_exists(file_name))
	{
		mkdir(file_name)
	}
	
	format(file_name, 255, "%s/%s", file_name, MAIN_PRECACHE_FILE)
	
	if(!file_exists(file_name))
	{
		write_file(file_name, MAIN_PRECACHE_FILE_TEXT)
	}
	
	precache_from_file(file_name)
	
	formatex(file_name, 255, "%s/%s/%s.txt", configs_dir, CONFIG_FOLDERNAME, map_name)
	
	precache_from_file(file_name)
}

public cmd_place_ad(id)
{
	if(!(get_user_flags(id) & ADMIN_ACCESS_LEVEL))
		return PLUGIN_HANDLED
	
	new cmd[2]
	read_argv(0, cmd, 1)
	
	switch(cmd[0])
	{
		case '+':
		{
			if(is_user_placing_ad)
			{
				log_amx(ERROR_USER_ALREADY_PLACING)
				client_print(0, print_chat, ERROR_USER_ALREADY_PLACING)
				return PLUGIN_HANDLED
			}
			
			if(!pev_valid(ad_ent))
			{
				create_ad()
			}
			is_user_placing_ad = true
		}
		case '-':
		{
			if(pev_valid(ad_ent) && ad_ent != 0)
			{
				Showselect_menu(id, select_menu_current_page)
			}
			is_user_placing_ad = false
		}
	}
	return PLUGIN_HANDLED
}		

public PreThink(id)
{
	if(!is_user_placing_ad)
		return PLUGIN_HANDLED
	
	if(prethink_counter++ > PRETHINK_REFRESH_TIME)
	{
		prethink_counter = 0
		
		fm_get_aim_origin(id, aiming_origins[2])
		
		if(equal_f(aiming_origins[1], aiming_origins[2]) < 3)
		{
			engfunc(EngFunc_SetOrigin, ad_ent, aiming_origins[2])
			
			//by using player's origin, I make sure sprites are facing the player
			static Float:normal[3], Float:player_origin[3], Float:test_origin[3]
			
			normal = cross_product(diff_f(aiming_origins[0], aiming_origins[1]), diff_f(aiming_origins[2], aiming_origins[1]))
			vector_to_angle(normal, ad_ent_angles)
			
			minimize_normal(normal)
			test_origin = sum_f(aiming_origins[2], normal)
			pev(id, pev_origin, player_origin)
			
			if(get_distance_f(player_origin, test_origin) > get_distance_f(player_origin, aiming_origins[2]))
			{
				//sprites had the wrong X rotation while models had the correct X rotation
				//maybe this problem only involves my wall.mdl
				if(contain(ad_model_list[current_ad_model], ".spr") != -1)
				{
					ad_ent_angles[0] *= -1.0
				}
				set_pev(ad_ent, pev_angles, ad_ent_angles)
			}	
		}
		if(equal_f(aiming_origins[1], aiming_origins[2]) < 2 && get_distance_f(aiming_origins[2], aiming_origins[1]) > 5.0)
		{
			aiming_origins[0] = aiming_origins[1]
			aiming_origins[1] = aiming_origins[2]
		}
	}
	return PLUGIN_HANDLED
}

public Showselect_menu(id, page)
{	
	if(page < 0) return
	
	static szMenuBody[SELECT_MENU_SIZE]
	new nCurrKey
	new nStart = page * SELECT_MENU_OPTIONS_NUM
	
	if(nStart >= num_models_in_list)
		nStart = page = select_menu_current_page = 0
	
	new nLen = formatex(szMenuBody, SELECT_MENU_SIZE-1, SELECT_MENU_TEXT_CHOOSE_MODEL, page+1, (num_models_in_list / SELECT_MENU_OPTIONS_NUM + ((num_models_in_list % SELECT_MENU_OPTIONS_NUM) ? 1 : 0 )) )
	new nEnd = nStart + SELECT_MENU_OPTIONS_NUM
	new nKeys = (1<<9)
	
	if( nEnd > num_models_in_list )
		nEnd = num_models_in_list
	
	for(new i = nStart; i < nEnd; i++ )
	{
		nKeys |= (1<<nCurrKey++)
		nLen += formatex( szMenuBody[nLen], (SELECT_MENU_SIZE-1-nLen), "%i. %s^n", nCurrKey, ad_model_list[i] )
	}
	
	if( nEnd != num_models_in_list )
	{
		formatex( szMenuBody[nLen], (SELECT_MENU_SIZE-1-nLen), SELECT_MENU_TEXT_OPTIONS_1, page ? SELECT_MENU_TEXT_PREVIOUS : SELECT_MENU_TEXT_EXIT )
		nKeys |= (1<<8)|(1<<7)|(1<<6)|(1<<5)|(1<<4)
	}
	else
	{
		formatex( szMenuBody[nLen], (SELECT_MENU_SIZE-1-nLen), SELECT_MENU_TEXT_OPTIONS_2, page ? SELECT_MENU_TEXT_PREVIOUS : SELECT_MENU_TEXT_EXIT )
		nKeys |= (1<<7)|(1<<6)|(1<<5)|(1<<4)
	}
	
	show_menu( id, nKeys, szMenuBody, -1, "select_menu" )
	
	return
}

public Pressedselect_menu(id, key)
{
	switch(key)
	{
		case 4:
		{
			move_toward_client(id)
			Showselect_menu(id, select_menu_current_page)
		}
		case 5:
		{
			new Float:f_scale
			pev(ad_ent, pev_scale, f_scale)
			set_pev(ad_ent, pev_scale, (f_scale + 0.05))
			Showselect_menu(id, select_menu_current_page)
		}
		case 6:
		{
			new Float:f_scale
			pev(ad_ent, pev_scale, f_scale)
			set_pev(ad_ent, pev_scale, (f_scale - 0.05))
			Showselect_menu(id, select_menu_current_page)
		}
		case 7:
		{
			Showsave_menu(id)
		}
		case 8:
		{
			Showselect_menu(id, ++select_menu_current_page)
		}
		case 9:
		{
			if(--select_menu_current_page < 0)
			{
				engfunc(EngFunc_RemoveEntity, ad_ent)
				select_menu_current_page = 0
			}
			else
			{
				Showselect_menu(id, select_menu_current_page)
			}
		}
		default:
		{
			current_ad_model = (select_menu_current_page * SELECT_MENU_OPTIONS_NUM + key)
		
			engfunc(EngFunc_SetModel, ad_ent, ad_model_list[current_ad_model])
		
			Showselect_menu(id, select_menu_current_page)
		}
	}
}

public Showsave_menu(id)
{
	show_menu(id, (1<<0)|(1<<1), SAVE_MENU_TEXT, -1, "save_menu")
}

public Pressedsave_menu(id, key)
{
	switch (key)
	{
		case 0: save_ad()
		case 1: engfunc(EngFunc_RemoveEntity, ad_ent)
	}
}
//moves one unit on an axis, not directly towards the client's origin
public move_toward_client(id)
{
	new Float:player_origin[3], Float:distance[3], greatest
	
	pev(id, pev_origin, player_origin)

	distance[0] = abs_f(player_origin[0] - aiming_origins[2][0])
	distance[1] = abs_f(player_origin[1] - aiming_origins[2][1])
	distance[2] = abs_f(player_origin[2] - aiming_origins[2][2])
	
	for(new i = 0; i < 3; i++)
	{
		if(distance[i] > distance[greatest])
		{
			greatest = i
		}
	}
	
	aiming_origins[2][greatest] += (player_origin[greatest] > aiming_origins[2][greatest] ? 1.0 : -1.0)
	
	engfunc(EngFunc_SetOrigin, ad_ent, aiming_origins[2])
	return 1
}

public precache_from_file(file_name[])
{	
	new file_handle = fopen(file_name, "r")
	
	if(!file_handle)
	{
		return PLUGIN_HANDLED
	}
	
	new file_text[MAX_MODEL_NAMELEN]
	
	while(!feof(file_handle))
	{
		fgets(file_handle, file_text, MAX_MODEL_NAMELEN - 1)
		remove_newline_char(file_text)
		
		if(equal(file_text, "//", 2) || !file_text[0])
		{
			continue
		}
		
		if(contain(file_text, ".spr") != -1 || contain(file_text, ".mdl") != -1)
		{	
			if(!file_exists(file_text))
			{
				log_amx(ERROR_FILE_NOT_FOUND, file_text)
				continue
			}
			else
			{
				precache_model(file_text)
				
				for(new i = 0; i < MAX_AD_MODELS; i++)
				{
					if(equal(file_text, ad_model_list[i]))
					{
						break
					}
					else if(!ad_model_list[i][0])
					{
						ad_model_list[num_models_in_list] = file_text
						num_models_in_list++
						break
					}
				}
			}
		}
	}
	
	fclose(file_handle)
	
	return PLUGIN_HANDLED
}

//from fakemeta_util.inc
stock fm_get_aim_origin(index, Float:origin[3])
{
	static Float:start[3], Float:view_ofs[3]
	pev(index, pev_origin, start)
	pev(index, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	static Float:dest[3]
	pev(index, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	xs_vec_mul_scalar(dest, 9999.0, dest)
	xs_vec_add(start, dest, dest)
	
	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0)
	get_tr2(0, TR_vecEndPos, origin)
	
	return 1
}

stock create_ad()
{		
	ad_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(ad_ent, pev_classname, "info_target")
	engfunc(EngFunc_SetModel, ad_ent, ad_model_list[current_ad_model])
	set_pev(ad_ent, pev_scale, 1.0)
}

stock save_ad()
{
	new Float:f_scale
	new text[256]
	
	get_configsdir(file_name, 255)
	format(file_name, 255, "%s/%s/%s.txt", file_name, CONFIG_FOLDERNAME, map_name)
	
	pev(ad_ent, pev_angles, ad_ent_angles)
	
	if(contain(ad_model_list[current_ad_model], ".spr") != -1)
	{
		pev(ad_ent, pev_scale, f_scale)
		formatex(text, 255, "^n%s^norigin %f %f %f^nangles %f %f %f^nscale %f", ad_model_list[current_ad_model], aiming_origins[2][0], aiming_origins[2][1], aiming_origins[2][2], ad_ent_angles[0], ad_ent_angles[1], ad_ent_angles[2], f_scale)
	}
	else
	{
		formatex(text, 255, "^n%s^norigin %f %f %f^nangles %f %f %f", ad_model_list[current_ad_model], aiming_origins[2][0], aiming_origins[2][1], aiming_origins[2][2], ad_ent_angles[0], ad_ent_angles[1], ad_ent_angles[2])
	}
	
	write_file(file_name, text)
	ad_ent = 0
}

stock minimize_normal(Float:normal[3])
{
	normal[0] /= 10.0
	normal[1] /= 10.0
	normal[2] /= 10.0
	return 1
}

stock Float:abs_f(Float:x)
{
	if(x < 0)
	{
		return (-1.0 * x)
	}
	return x
}

stock equal_f(Float:origin1[3], Float:origin2[3])
{
	new num_equal = (origin1[0] == origin2[0] ? 1 : 0)
	num_equal += (origin1[1] == origin2[1] ? 1 : 0)
	num_equal += (origin1[2] == origin2[2] ? 1 : 0)
	return num_equal
}

stock Float:sum_f(Float:origin1[3], Float:origin2[3])
{
	new Float:result[3]
	result[0] = origin1[0] + origin2[0]
	result[1] = origin1[1] + origin2[1]
	result[2] = origin1[2] + origin2[2]
	return result
}

stock Float:diff_f(Float:origin1[3], Float:origin2[3])
{
	new Float:result[3]
	result[0] = origin1[0] - origin2[0]
	result[1] = origin1[1] - origin2[1]
	result[2] = origin1[2] - origin2[2]
	return result
}

stock Float:cross_product(Float:origin1[3], Float:origin2[3])
{
	new Float:result[3]
	result[0] = origin1[1]*origin2[2] - origin1[2]*origin2[1]
	result[1] = origin1[2]*origin2[0] - origin1[0]*origin2[2]
	result[2] = origin1[0]*origin2[1] - origin1[1]*origin2[0]
	return result
}

stock remove_newline_char(text[])
{
	new len = strlen(text)
	if(text[len-1] == '^n')
	{
		text[len-1] = 0
		return 1
	}
	return 0
}

stock load_saved_ads(file_name[])
{	
	new file_handle = fopen(file_name, "r")
	
	if(!file_handle)
	{
		return PLUGIN_HANDLED
	}
	
	new file_text[64]
	new ent, str_value[3][16], Float:f_value[3]
	
	while(!feof(file_handle))
	{
		fgets(file_handle, file_text, 63)
		remove_newline_char(file_text)
		
		if(equal(file_text, "//", 2) || !file_text[0])
			continue
		
		if(contain(file_text, ".mdl") != -1 || contain(file_text, ".spr") != -1)
		{
			if(!file_exists(file_text))
			{
				log_amx(ERROR_FILE_NOT_FOUND, file_text)
				continue
			}
			ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
			set_pev(ent, pev_classname, "info_target")
			engfunc(EngFunc_SetModel, ent, file_text)
		}
		else if(equal(file_text, "origin", 6))
		{
			parse(file_text[6], str_value[0], 15, str_value[1], 15, str_value[2], 15)
			
			f_value[0] = str_to_float(str_value[0])
			f_value[1] = str_to_float(str_value[1])
			f_value[2] = str_to_float(str_value[2])
			
			engfunc(EngFunc_SetOrigin, ent, f_value)
		}
		else if(equal(file_text, "angles", 6))
		{
			parse(file_text[6], str_value[0], 15, str_value[1], 15, str_value[2], 15)
			
			f_value[0] = str_to_float(str_value[0])
			f_value[1] = str_to_float(str_value[1])
			f_value[2] = str_to_float(str_value[2])
			
			set_pev(ent, pev_angles, f_value)
		}
		else if(equal(file_text, "scale", 5))
		{
			parse(file_text[5], str_value[0], 15)
			
			f_value[0] = str_to_float(str_value[0])
			
			set_pev(ent, pev_scale, f_value[0])
		}
	}
	
	fclose(file_handle)
	
	return PLUGIN_HANDLED
}
