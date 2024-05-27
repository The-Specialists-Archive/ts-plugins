//AMXMODX TsGore Mod by Pinkfairie

#include <amxmodx>
#include <engine>
#include <fun>
#include <fakemeta>

new TG_Blood_Drop;
new TG_Blood_Spray;
new TG_Gib_Flesh;
new TG_Gib_Head;
new TG_Gib_Legbone;
new TG_Gib_Lung;
new TG_Gib_Meat;
new TG_Gib_Spine;

new TG_Current_Health[33];

public plugin_precache() //Precache
{
	TG_Blood_Drop = precache_model("sprites/blood.spr");
	TG_Blood_Spray = precache_model("sprites/bloodspray.spr");
	TG_Gib_Flesh = precache_model("models/Fleshgibs.mdl");
	TG_Gib_Head = precache_model("models/GIB_Skull.mdl");
	TG_Gib_Legbone = precache_model("models/GIB_Legbone.mdl");
	TG_Gib_Lung = precache_model("models/GIB_Lung.mdl");
	TG_Gib_Meat = precache_model("models/GIB_B_Gib.mdl");
	TG_Gib_Spine = precache_model("models/GIB_B_Bone.mdl");
}

public TG_Blood(id) //Getting Shot
{
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Bleed(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
	TG_Spray(id,40);
}

public TG_Bleed(id,TG_Max_Z) //Bleed
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(101);
	write_coord(TG_Origin[0]+random_num(-20,20));
	write_coord(TG_Origin[1]+random_num(-20,20));
	write_coord(TG_Origin[2]+random_num(-30,TG_Max_Z));
	write_coord(random_num(-50,50));
	write_coord(random_num(-50,50));
	write_coord(-10);
	write_byte(70);
	write_byte(random_num(50,100));
	message_end();
}

public TG_Spray(id,TG_Max_Z) //Spray
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(115);
	write_coord(TG_Origin[0]+random_num(-20,20));
	write_coord(TG_Origin[1]+random_num(-20,20));
	write_coord(TG_Origin[2]+random_num(20,TG_Max_Z));
	write_short(TG_Blood_Spray);
	write_short(TG_Blood_Drop);
	write_byte(248);
	write_byte(10);
	message_end();
}

public TG_Head(id) //Head Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Head);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Spine(id) //Spine Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Spine);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Lung(id) //Lung Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Lung);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Flesh(id) //Flesh Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Flesh);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Legbone(id) //Legbone Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Legbone);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Meat(id) //Meat Gib
{
	new TG_Origin[3];
	get_user_origin(id,TG_Origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(106);
	write_coord(TG_Origin[0]);
	write_coord(TG_Origin[1]);
	write_coord(TG_Origin[2]+30);
	write_coord(TG_Origin[0]+random_num(-1500,1500));
	write_coord(TG_Origin[1]+random_num(-1500,1500));
	write_coord(TG_Origin[2]+random_num(0,1500));
	write_angle(random_num(0,360));
	write_short(TG_Gib_Meat);
	write_byte(0);
	write_byte(500);
	message_end();
}

public TG_Explode(id) //Explode!
{
	TG_Head(id);
	TG_Spine(id);
	TG_Spine(id);
	TG_Spine(id);
	TG_Spine(id);
	TG_Spine(id);
	TG_Lung(id);
	TG_Lung(id);
	TG_Lung(id);
	TG_Lung(id);
	TG_Lung(id);
	TG_Flesh(id);
	TG_Flesh(id);
	TG_Flesh(id);
	TG_Flesh(id);
	TG_Flesh(id);
	TG_Legbone(id);
	TG_Legbone(id);
	TG_Legbone(id);
	TG_Legbone(id);
	TG_Legbone(id);
	TG_Meat(id);
	TG_Meat(id);
	TG_Meat(id);
	TG_Meat(id);
	TG_Meat(id);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Bleed(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);
	TG_Spray(id,150);

}

public TG_Death() //Death
{
	new TG_Player = read_data(2);
	set_entity_visibility(TG_Player,0)
	set_task(3.0,"TG_Show",TG_Player);
	TG_Explode(TG_Player);
	TG_Current_Health[TG_Player] = 100;
}

public TG_Show(id)
{
	set_entity_visibility(id,1)
}

public TG_Loop(id) //Prethink
{
	if(is_user_connected(id)==0)return PLUGIN_HANDLED;
	if(is_user_alive(id)==0)
	{
		set_task(0.1,"TG_Loop",id);
		return PLUGIN_HANDLED;
	}
	if(get_user_health(id) < TG_Current_Health[id]) //If Lower HP, Bleed
	{
		TG_Blood(id);
		TG_Current_Health[id] = get_user_health(id);
		set_task(0.1,"TG_Loop",id);
		return PLUGIN_HANDLED;
	}
	TG_Current_Health[id] = get_user_health(id);
	set_task(0.1,"TG_Loop",id);
	return PLUGIN_HANDLED;
}

public client_putinserver(id) //Join
{
	TG_Current_Health[id] = 100;
	set_task(0.1,"TG_Loop",id);
}

public plugin_init() //Initation
{
	register_plugin("TsGore","1.0","Pinkfairie");
	register_event("DeathMsg","TG_Death","a","2!0")
}
