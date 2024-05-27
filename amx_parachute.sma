#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGINNAME	"TS Parachute"
#define VERSION		"x.61"
#define AUTHOR		"Shin"

new para_ent[33];

public plugin_init()
{
	register_plugin( PLUGINNAME, VERSION, AUTHOR )
	register_event( "ResetHUD", "event_resethud", "be" )
	register_event( "DeathMsg", "death_event", "a" )
}

public plugin_precache()
{
	precache_model("models/parachute.mdl")
}

public client_PreThink(id)
{

	if( !is_user_alive(id) )
	{
		return PLUGIN_CONTINUE
	}

	{
		if (get_user_button(id) & IN_USE )
			{
				new Float:velocity[3]
				entity_get_vector(id, EV_VEC_velocity, velocity)
				if(velocity[2] < 0)
					{
						para_ent[id] = create_entity("info_target")
						{
							entity_set_model(para_ent[id], "models/parachute.mdl")
							entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
							entity_set_edict(para_ent[id], EV_ENT_aiment, id)
						}
					{
						velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0
						entity_set_vector(id, EV_VEC_velocity, velocity)
						if (entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0)
						{
							if (entity_get_int(para_ent[id], EV_INT_sequence) != 1)
							{
								entity_set_int(para_ent[id], EV_INT_sequence, 1)
							}
							entity_set_float(para_ent[id], EV_FL_frame, 0.0)
						}
						else 
						{
							entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0)
						}
					}
				}
				else
				{
					if (para_ent[id] > 0)
					{
						remove_entity(para_ent[id])
						para_ent[id] = 0
					}
				}
			}
			else
			{
				if (para_ent[id] > 0)
				{
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			}
		}
		else if (get_user_oldbutton(id) & IN_USE)
		{
			if (para_ent[id] > 0)
			{
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
	}
	
	return PLUGIN_CONTINUE
}