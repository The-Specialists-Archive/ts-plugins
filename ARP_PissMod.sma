/*
Advanced Bathroom Mod for Apollo RP
Made for: Shin
Made by: Knox
Idea from: Shin
Special Thanks:
Shin, for the support and the scripting support.. (You dont suck)

*/

#include <ApolloRP>
#include <ApolloRP_Chat>
#include <amxmodx>
#include <amxmisc>
#include <fun>


new piss_sprite

new bathroom[33] = 1

public plugin_init()
{
	register_plugin("Advanced Bathroom Mod","1.0","Knox")

}
public ARP_Init()
{
	ARP_RegisterEvent("HUD_Render","EventHudRender")
	ARP_AddChat(_,"CmdSay")
}

public plugin_precache()
{
	precache_sound("piss/pissing.wav")
	piss_sprite = precache_sound("sprites/plasma.spr")
}

// Called when player recieves his salary
public ARP_Salary(id)
{
	bathroom[id] += 2
	if(bathroom[id] >= 60)
	{
		client_print(id,print_chat,"[Bathroom Mod] You need to go take a piss!")
		set_user_maxspeed(id,200.0)
		set_task(20.0,"reset_speed")
	}
	if(bathroom[id] == 100)
	{
		client_print(id,print_chat,"[Bathroom Mod] You died because you didnt go to the bathroom!")
		user_kill(id)
		bathroom[id] = 0
	}
}

public CmdSay(id,Mode,Args[])
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(equali(Args,"/piss",5))
	{
		if(bathroom[id] >= 30)
		{
			new ids[1]
			ids[0]=id

			set_task(0.1,"make_pee",1481+id,ids,1,"a",106)
			emit_sound(id,CHAN_VOICE,"piss/pissing.wav",0.1,ATTN_NORM,0,PITCH_NORM)
			bathroom[id] -= 30

		}
		else
		{
			client_print(id,print_chat,"[Bathroom Mod] You dont feel like you need to piss!")
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public EventHudRender(Name[],Data[],Len)
{
	new id = Data[0]
	if(!is_user_alive(id) || Data[1] != HUD_PRIM)
		return
	
	ARP_AddHudItem(id,HUD_PRIM,0,"Bathroom: %i%",bathroom[id])
}	

public client_connect(id)
{
	bathroom[id] = 0
}

public client_disconnect(id) 
{
	bathroom[id] = 0
}

//Piss effects
public sqrt(num)
{
  new div = num
  new result = 1
  while (div > result) {
    div = (div + result) / 2
    result = num / div
  }
  return div
}
public make_pee(ids[])
{
  new id=ids[0]
  new vec[3]
  new aimvec[3]
  new velocityvec[3]
  new length
  get_user_origin(id,vec)
  get_user_origin(id,aimvec,3)
  new distance = get_distance(vec,aimvec)
  new speed = floatround(distance*1.9)

  velocityvec[0]=aimvec[0]-vec[0]
  velocityvec[1]=aimvec[1]-vec[1]
  velocityvec[2]=aimvec[2]-vec[2]

  length=sqrt(velocityvec[0]*velocityvec[0]+velocityvec[1]*velocityvec[1]+velocityvec[2]*velocityvec[2])

  velocityvec[0]=velocityvec[0]*speed/length
  velocityvec[1]=velocityvec[1]*speed/length
  velocityvec[2]=velocityvec[2]*speed/length

  switch(get_cvar_num("amx_piss_effect"))
  {
    case 0:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte(101)
      write_coord(vec[0])
      write_coord(vec[1])
      write_coord(vec[2])
      write_coord(velocityvec[0])
      write_coord(velocityvec[1])
      write_coord(velocityvec[2])
      write_byte(102) // color
      write_byte(160) // speed
      message_end()
    }
    case 1:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte (1)
      write_short (id)
      write_coord(aimvec[0])
      write_coord(aimvec[1])
      write_coord(aimvec[2])
      write_short(piss_sprite)
      write_byte( 1 ) // framestart
      write_byte( 6 ) // framerate
      write_byte( 1 ) // life
      write_byte( 8 ) // width
      write_byte( 0 ) // noise
      write_byte( 255 ) // r, g, b
      write_byte( 255 ) // r, g, b
      write_byte( 0 ) // r, g, b
      write_byte( 200 ) // brightness
      write_byte( 10 ) // speed
      message_end()
    }
    default:
    {
      message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      write_byte(101)
      write_coord(vec[0])
      write_coord(vec[1])
      write_coord(vec[2])
      write_coord(velocityvec[0])
      write_coord(velocityvec[1])
      write_coord(velocityvec[2])
      write_byte(102) // color
      write_byte(160) // speed
      message_end()
    }
  }   
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1031\\ f0\\ fs16 \n\\ par }
*/