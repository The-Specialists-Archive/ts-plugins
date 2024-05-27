#include <amxmodx>
#include <engine>

stock get_id_by_steamid(steamid[64])
{
	new authid[64]
	for(new i=0;i<33;i++)
	{
		get_user_authid(i,authid,31)
		if(equali(authid,steamid) && is_user_alive(i))
			return i
	}
	return 0
}

stock find_car_by_owner(id)
{
	new ent, Float:origin[3],Float:radius = 128.0, classname[64], locked[64], authid[64]
	get_user_authid(id,authid,63)
	entity_get_vector(id,EV_VEC_origin,origin)
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			entity_get_string(ent,EV_SZ_target,locked,63)
			if(equali(locked,authid))
				return ent
		}
	}
	return 0
}

stock find_car_by_origin_steamid(Float:origin[3],authid[64])
{
	new ent, classname[64], Float:radius = 100.0
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			get_user_authid(ent,authid,63)
			entity_get_string(ent,EV_SZ_target,authid,63)
			return ent
		}
	}
	return 0
}

stock sethijackercar(id,authid[64])
{
	new ent, Float:origin[3],Float:radius = 300.0, classname[64]
	entity_get_vector(id,EV_VEC_origin,origin)
	
	while((ent = find_ent_in_sphere(ent,origin,radius)) != 0)
	{
		entity_get_string(ent,EV_SZ_classname,classname,63)
		if(equali(classname,"item_car"))
		{
			entity_set_string(ent,EV_SZ_target,authid)
			entity_set_edict(ent, EV_ENT_owner, id)
		}
	}
	return 1
}


stock explode( output[][], input[], delimiter) 
{ 
	new nIdx = 0
	new iStringSize
	while ( input[iStringSize] ) 
		iStringSize++ 
	new nLen = (1 + copyc( output[nIdx], iStringSize-1, input, delimiter ))
	
	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], iStringSize-1, input[nLen], delimiter ))
	return nIdx + 1
}

stock player_exist(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return 0
	
	if(!is_user_alive(id) && !is_user_connected(id))
		return 0
	
	return 1
}

